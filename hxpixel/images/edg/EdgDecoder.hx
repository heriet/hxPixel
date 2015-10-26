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
import haxe.io.BytesOutput;
import haxe.io.Input;
import hxpixel.bytes.BitReader;
import hxpixel.bytes.Bits;
import hxpixel.bytes.BitWriter;
import hxpixel.bytes.BytesInputWrapper;
import hxpixel.images.color.Rgb;
import hxpixel.images.color.ColorUtils;
 
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
        var version = input.readInt8();
        
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
        
        edgImage.width = input.readInt32();
        edgImage.height = input.readInt32();
        
        page.width = edgImage.width;
        page.height = edgImage.height;
        
        var layerNum = input.readUInt16();
        page.transparentColorIndex = input.readInt8();
        
        readEdge1Palette(input, edgImage);
        page.paletteBankIndex = 0;
        
        var resolution = edgImage.width * edgImage.height;
        
        for (layerIndex in 0 ... layerNum) {
            var layer = new EdgLayer(page);
            
            layer.name = input.readString(LAYER_NAME_MAX);
            layer.visible = (input.readInt8() == 1);
            
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
            values.push(input.readInt8());
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
				layer.imageData[dest] = input.readInt8();
				dest++;
			}
            
            i++;
        }
    }
    
    static function readEdge2(input:Input, edgImage:EdgImage)
    {
        // todo
    }
}