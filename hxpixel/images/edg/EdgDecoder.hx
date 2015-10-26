/*
 * Copyright (c) 2013 Heriet [http://heriet.info/].
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package hxpixel.images.edg;

import haxe.io.Bytes;
import haxe.io.Input;
import hxpixel.bytes.BytesInputWrapper;
import hxpixel.bytes.Inflater;
import hxpixel.images.color.ColorUtils;
import hxpixel.images.color.Rgb;
 
enum Error {
    InvalidFormat;
    UnsupportedFormat;
}

class EdgDecoder
{
    private static inline var LAYER_NAME_MAX = 80; // 80 bytes
    
    public static function decode(bytes:Bytes): EdgImage
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.LittleEndian);
        var edgImage = new EdgImage();
        
        readHeader(bytesInput, edgImage);
                
        switch(edgImage.version) {
            case Edge1:
                readEdge1(bytesInput, edgImage);
            case Edge2:
                readEdge2(bytesInput, edgImage);
            default:
                throw Error.InvalidFormat;
        }
        
        return edgImage;
    }
    
    static function readHeader(input:Input, edgImage:EdgImage)
    {
        validateSignature(input.read(4));
        readVersion(input, edgImage);
    }
    
    static function validateSignature(bytes:Bytes)
    {
        if (bytes.toString() != "EDGE") {
            throw Error.InvalidFormat;
        }
    }
    
    static function readVersion(input:Input, edgImage:EdgImage)
    {
        var version = input.readByte();
        
        switch(version) {
            case 0:
                edgImage.version = Edge1;
            case 50:
                edgImage.version = Edge2;
            default:
                throw Error.InvalidFormat;
        }
    }
    
    static function readEdge1(input:Input, edgImage:EdgImage)
    {
        // edge1 is single page
        var page = new EdgPage(edgImage);
        
        input.read(5);
        
        page.width = input.readInt32();
        page.height = input.readInt32();
        
        var layerNum = input.readUInt16();
        edgImage.transparentColorIndex = input.readByte();
        page.transparentColorIndex = edgImage.transparentColorIndex;
        
        readEdge1Palette(input, edgImage);
        page.paletteBankIndex = 0;
        
        var resolution = page.width * page.height;
        
        for (layerIndex in 0 ... layerNum) {
            var layer = new EdgLayer(page);
            
            layer.name = input.readString(LAYER_NAME_MAX);
            layer.visible = (input.readByte() == 1);
            
            readEdge1LayerImage(input, layer, resolution);
            
            page.layers.push(layer);
        }
        
        edgImage.pages.push(page);
    }
    
    static function readEdge1Palette(input:Input, edgImage:EdgImage)
    {
        var palette = new Array<Rgb>();
        for (i in 0 ... 256) {
			palette[i] = ColorUtils.readRgb(input);
		}
        edgImage.paletteBank.push(palette);
    }
    
    static function readEdge1LayerImage(input:Input, layer:EdgLayer, resolution:Int)
    {
        var compressMax = input.readInt32();
        var positions = new Array<Int>();
        var lengths = new Array<Int>();
        var values = new Array<Int>();
        
        for (i in 0 ... compressMax) {
            positions.push(input.readInt32());
            lengths.push(input.readInt32());
            values.push(input.readByte());
        }
        
        var srcMax = input.readInt32();
        var comp = 0;
        var dest = 0;
           
        var i = 0;
        while (i <= srcMax) {
            if (comp < compressMax && i == positions[comp]) {
				for (j in 0 ... lengths[comp] ) {
					if (dest + j < resolution) {
						layer.imageData[dest + j] = values[comp];
					}
				}
				dest += lengths[comp];
				comp++;
				continue;
			}
            
			if (i < srcMax) {
				layer.imageData[dest] = input.readByte();
				dest++;
			}
            
            i++;
        }
    }
    
    static function readEdge2(input:Input, edgImage:EdgImage)
    {
        input.read(7);
        
        var bytes = input.readAll();
        var uncompressed = Inflater.uncompress(bytes);
        
        var source = new BytesInputWrapper(uncompressed, Endian.LittleEndian);
        
        var paletteBankLength = 0;
        var paletteLength = 0;
        
        var sourceLength = source.length;
        while (source.position < sourceLength) {
            var id = source.readInt16();
            var length = source.readInt32();
            
            switch(id) {
                case 1000:
                    if (length != 1) throw Error.InvalidFormat;
                    edgImage.bitDepth = source.readByte();
                case 1006:
                    readEdge2Header1006(source, length, edgImage);
                case 2003:
                    var page = readEdge2Page(source, length, edgImage);
                    edgImage.pages.push(page);
                case 3001:
                    if (length != 2) throw Error.InvalidFormat;
                    paletteBankLength = source.readInt16();
                case 3002:
                    if (length != 4) throw Error.InvalidFormat;
                    paletteLength = source.readInt32();
                case 3003:
                    var palette = readEdge2Palette(source, length, edgImage);
                    edgImage.paletteBank.push(palette);
                case 3008:
                    readEdge2Header3008(source, length, edgImage);
                default:
                    source.read(length);
            }
        }
        
    }
    
    static function readEdge2Header1006(source:Input, headerLength:Int, edgImage:EdgImage)
    {
        var pos = 0;
        
        while (pos < headerLength) {
            var id = source.readInt16();
            var length = source.readInt32();
            
            switch(id) {
                case 1000:
                    if (length != 2) throw Error.InvalidFormat;
                    edgImage.basePosition = source.readInt16();
                default:
                    source.read(length);
            }
            
            pos += 6 + length; // id(2 byte) + length(4 byte) + length byte
        }
    }
    
    
    static function readEdge2Header3008(source:Input, headerLength:Int, edgImage:EdgImage)
    {
        var pos = 0;
        
        while (pos < headerLength) {
            var id = source.readInt16();
            var length = source.readInt32();
            
            switch(id) {
                case 1000:
                    if (length != 1) throw Error.InvalidFormat;
                    edgImage.transparentColorIndex = source.readByte();
                default:
                    source.read(length);
            }
            
            pos += 6 + length; // id(2 byte) + length(4 byte) + length byte
        }
    }
    
    static function readEdge2Palette(source:Input, dataLength:Int, edgImage:EdgImage)
    {
        var paletteTable = new Array<Rgb>();
        var pos = 0;
        
        while (pos < dataLength) {
            var id = source.readInt16();
            var length = source.readInt32();
            
            switch(id) {
                case 1005:
                    var colorNum = Std.int(length / 3); // length / RGB(3 byte)
                    
                    for (i in 0 ... colorNum) {
                        var color = ColorUtils.readBgr(source);
                        paletteTable.push(color);
                    }
                    
                    return paletteTable;
                    
                default:
                    source.read(length);
            }
            
            pos += 6 + length; // id(2 byte) + length(4 byte) + length byte
        }
        
        return paletteTable;
    }
    
    static function readEdge2Page(source:Input, dataLength:Int, edgImage:EdgImage): EdgPage
    {
        var page = new EdgPage(edgImage);
        var pos = 0;
        
        var layerLength = 0;
        
        while (pos < dataLength) {
            var id = source.readInt16();
            var length = source.readInt32();
            
            switch(id) {
                case 1000:
                    page.name = source.readString(length);
                case 1005:
                    if (length != 2) throw Error.InvalidFormat;
                    page.width = source.readInt16();
                case 1006:
                    if (length != 2) throw Error.InvalidFormat;
                    page.height = source.readInt16();
                case 1007:
                    if (length != 4) throw Error.InvalidFormat;
                    page.paletteBankIndex = source.readInt32();
                case 1008:
                    if (length != 4) throw Error.InvalidFormat;
                    page.paletteBankIndex = source.readInt32();
                case 2001:
                    if (length != 4) throw Error.InvalidFormat;
                    layerLength = source.readInt32();
                case 2003:
                    var layer = readEdge2Layer(source, length, edgImage, page);
                    page.layers.push(layer);
                case 3000:
                    if (length != 4) throw Error.InvalidFormat;
                    page.wait = source.readInt32();
                case 3001:
                    if (length != 1) throw Error.InvalidFormat;
                    page.isTransparent = (source.readByte() != 0);
                case 3002:
                    page.name = source.readString(length);
                case 3003:
                    if (length != 5) throw Error.InvalidFormat;
                    page.x = source.readInt32();
                    page.isRelativeX = (source.readByte() != 0);
                case 3004:
                    if (length != 5) throw Error.InvalidFormat;
                    page.y = source.readInt32();
                    page.isRelativeY = (source.readByte() != 0);
                case 3005:
                    if (length != 1) throw Error.InvalidFormat;
                    page.isAbailable = (source.readByte() != 0);
                 
                default:
                    source.read(length);
            }
            
            pos += 6 + length; // id(2 byte) + length(4 byte) + length byte
        }
        
        if (layerLength != page.numLayers) {
            throw Error.InvalidFormat;
        }
        
        return page;
    }
    
    
    static function readEdge2Layer(source:Input, dataLength:Int, edgImage:EdgImage, page:EdgPage): EdgLayer
    {
        var layer = new EdgLayer(page);
        var pos = 0;
        
        while (pos < dataLength) {
            var id = source.readInt16();
            var length = source.readInt32();
            
            switch(id) {
                case 1000:
                    layer.name = source.readString(length);
                case 1002:
                    if (length != 1) throw Error.InvalidFormat;
                    layer.isChild = (source.readByte() != 0);
                case 1005:
                    if (length != 1) throw Error.InvalidFormat;
                    layer.visible = (source.readByte() != 0);
                case 1006:
                    readEdge2LayerImage(source, length, layer);
                case 1007:
                    if (length != 1) throw Error.InvalidFormat;
                    layer.isLocked = (source.readByte() != 0);
                
                default:
                    source.read(length);
            }
            
            pos += 6 + length; // id(2 byte) + length(4 byte) + length byte
        }
        
        return layer;
    }
    
    static function readEdge2LayerImage(source: Input, dataLength: Int, layer: EdgLayer)
    {
        var pos = 0;
        while (pos < dataLength) {
            layer.imageData.push(source.readByte());
            pos++;
        }
    }
}