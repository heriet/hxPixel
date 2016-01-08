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

package hxpixel.images.gal;

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

class GalDecoder
{
    
    public static function decode(bytes:Bytes): GalImage
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.LittleEndian);
        var galImage = new GalImage();
        
        readHeader(bytesInput, galImage);
                
        switch(galImage.version) {
            case Gale102:
                throw Error.UnsupportedFormat;
            case Gale106:
                readGale106(bytesInput, galImage);
            case GaleX200:
                readGaleX200(bytesInput, galImage);
            default:
                throw Error.UnsupportedFormat;
        }
        
        return galImage;
    }
    
    static function readHeader(input:Input, galImage:GalImage)
    {
        validateSignature(input.read(4));
        readVersion(input, galImage);
    }
    
    static function validateSignature(bytes:Bytes)
    {
        if (bytes.toString() != "Gale") {
            throw Error.InvalidFormat;
        }
    }
    
    static function readVersion(input:Input, galImage:GalImage)
    {
        var version = input.read(1).toString();
        
        switch(version) {
            case "1":
                readVersionGale1(input, galImage);
            case "X":
                readVersionGale2(input, galImage);
            default:
                throw Error.InvalidFormat;
        }
    }
    
    static function readVersionGale1(input:Input, galImage:GalImage)
    {
        var version = input.read(2).toString();
        
        switch(version) {
            case "02":
                galImage.version = Gale102;
            case "06":
                galImage.version = Gale106;
            default:
                throw Error.InvalidFormat;
        }
    }
    
    static function readVersionGale2(input:Input, galImage:GalImage)
    {
        var version = input.read(3).toString();
        
        switch(version) {
            case "200":
                galImage.version = GaleX200;
            default:
                throw Error.InvalidFormat;
        }    
    }
    
    static function readGale106(input:Input, galImage:GalImage)
    {
        input.read(8);
        
        galImage.width = input.readInt32();
        galImage.height = input.readInt32();
        galImage.bitDepth = input.readInt32();
        
        if (galImage.bitDepth > 8) {
            throw Error.UnsupportedFormat;
        }
        
        var frameNum = input.readInt32();
        
        input.read(20);
        
        for (frameIndex in 0 ... frameNum) {
            var frame = readGale106Frame(input, galImage);
            galImage.frames.push(frame);
        }
    }
    
    static function readGale106Frame(input:Input, galImage:GalImage): GalFrame
    {
        var frame = new GalFrame(galImage);
        
        var nameLength = input.readInt32();
        frame.name = input.read(nameLength).toString();
        frame.transparentColorIndex = input.readByte();
        
        var transparentAble:Int = input.readInt24();
        frame.isTransparent = (transparentAble == 0);
        
        frame.wait = input.readInt32();
        frame.nextBackgroundType = input.readByte();
        
        input.read(4);
        
        var leyerNum = input.readInt32();
        frame.width = input.readInt32();
        frame.height = input.readInt32();
        frame.bitDepth = input.readInt32();
        
        var paletteLength = 1 << frame.bitDepth;
        for (paletteIndex in 0 ... paletteLength) {
            var color = ColorUtils.readBgr(input);
            frame.paletteTable.push(color);
            
            input.read(1);
        }
        
        input.read(8);
        
        for (layerIndex in 0 ... leyerNum) {
            var layer = readGale106Layer(input, galImage, frame);
            frame.layers.push(layer);
        }
        
        return frame;
    }
    
    static function readGale106Layer(input:Input, galImage:GalImage, frame:GalFrame): GalLayer
    {
        var layer = new GalLayer(frame);
        
        layer.visible = (input.readByte() != 0);
        layer.transparentColorIndex = input.readByte();
        
        var transparentAble:Int = input.readInt24();
        layer.isTransparent = (transparentAble == 0);
        layer.density = input.readByte();
        
        input.read(4);
        
        var nameLength = input.readInt32();
        layer.name = input.read(nameLength).toString();
        
        readGale106LayerImage(input, galImage, frame, layer);
        
        input.read(12);
        
        return layer;
    }
    
    static function readGale106LayerImage(input:Input, galImage:GalImage, frame:GalFrame, layer:GalLayer)
    {
        var imageLength = input.readInt32();
        
        if (imageLength == 0) {
            return;
        }
        
        var imageBytes = input.read(imageLength);
        var uncompressed = Inflater.uncompress(imageBytes);
        var imageInput = new BytesInputWrapper(uncompressed, Endian.LittleEndian);
        
        if (frame.bitDepth == 8) {
            readGale106LayerImage8Bit(imageInput, uncompressed.length, frame, layer);
        } else {
            readGale106LayerImageLowBit(imageInput, uncompressed.length, frame, layer);
        }
    }
    
    static function readGale106LayerImage8Bit(input:Input, length:Int, frame:GalFrame, layer:GalLayer)
    {
        // (byte of line = 4 * x) >= 4 * frame.width. if x > frame.width then lineEndSupply = x - frame.width
        var lineEndSupply = frame.width % 4 == 0 ? 0 : (4 - frame.width % 4);
         
        for (y in 0 ... frame.height) {
            
            for (x in 0 ... frame.width) {
                var colorIndex = input.readByte();
                layer.imageData.push(colorIndex);
            }
            
            if (lineEndSupply > 0) {
                input.read(lineEndSupply);
            }
        }
    }
    
    static function readGale106LayerImageLowBit(input:Input, length:Int, frame:GalFrame, layer:GalLayer)
    {
        // (byte of line = 4 * x) >= 4 * frame.width. if x > frame.width then lineEndSupply = x - frame.width
        var lineEndSupply = frame.width % 4 == 0 ? 0 : (4 - frame.width % 4);
        
        var pos = 0;
        
        var value = 0;
        var seekBit = 0;
        var mask = (1 << frame.bitDepth) - 1;
        
        var x = 0;
        var y = 0;
        
        while (pos < length && y < frame.height) {
            value <<= seekBit;
            
            value += input.readByte();
            seekBit += 8; // readByte() = read 8bit
                    
            while (seekBit >= frame.bitDepth) {
                var shiftMask = mask << (seekBit - frame.bitDepth);
                
                var colorIndex = (value & shiftMask) >> (seekBit - frame.bitDepth);
                layer.imageData.push(colorIndex);
                
                value &= ~shiftMask;
                seekBit -= frame.bitDepth;
                
                x++;
                
                // new line
                if (x >= frame.width) {
                    x = 0;
                    y++;
                    
                    if (pos < length && y < frame.height && lineEndSupply > 0) {
                        input.read(lineEndSupply);
                    }
                }
            }
        }
    }
    
    static function readGaleX200(input:Input, galImage:GalImage)
    {
        var headerByteLength = input.readInt32();
        var headerXml = readGale200XHeader(input, headerByteLength, galImage);
        
        for (frameXml in headerXml.elementsNamed("Frame")) {
            var frame = readGale200XFrame(frameXml, input, galImage);
            galImage.frames.push(frame);
        }
    }
    
    static function readGale200XHeader(input:Input, length:Int, galImage:GalImage):Xml
    {
        var headerBytes = input.read(length);
        var uncompressed = Inflater.uncompress(headerBytes);
        
        var headerXml = Xml.parse(uncompressed.toString()).firstElement();
        
        var version = headerXml.get("Version");
        if (version != "200") {
            throw Error.UnsupportedFormat;
        }
        
        galImage.width = Std.parseInt(headerXml.get("Width"));
        galImage.height = Std.parseInt(headerXml.get("Height"));
        galImage.bitDepth = Std.parseInt(headerXml.get("Bpp"));
        
        // var count = Std.parseInt(headerXml.get("Count"));
        // galImage.syncPal = Std.parseInt(headerXml.get("SyncPal"));
        // galImage.randomized = Std.parseInt(headerXml.get("Randomized"));
        // galImage.compType = Std.parseInt(headerXml.get("CompType"));
        // galImage.compLevel = Std.parseInt(headerXml.get("CompLevel"));
        // var bgColor = Rgb(Std.parseInt(headerXml.get("BGColor"))));
        // galImage.blockWidth = Std.parseInt(headerXml.get("BlockWidth"));
        // galImage.blockHeight = Std.parseInt(headerXml.get("BlockHeight"));
        // galImage.notFillBg = Std.parseInt(headerXml.get("NotFillBG"));
        
        return headerXml;
    }
    
    static function readGale200XFrame(frameXml:Xml, input:Input, galImage:GalImage): GalFrame
    {
        var frame = new GalFrame(galImage);
        
        frame.name = frameXml.get("Name");
        
        frame.transparentColorIndex = Std.parseInt(frameXml.get("TransColor"));
        frame.isTransparent = (frame.transparentColorIndex >= 0);
        frame.wait = Std.parseInt(frameXml.get("Delay"));
        frame.nextBackgroundType = Std.parseInt(frameXml.get("Disposal"));
        
        var layersXml;
        for (node in frameXml.elementsNamed("Layers")) {
            layersXml = node;
        }
        
        // var layerCount = Std.parseInt(layersXml.get("Count"));
        frame.width = Std.parseInt(layersXml.get("Width"));
        frame.height = Std.parseInt(layersXml.get("Height"));
        frame.bitDepth = Std.parseInt(layersXml.get("Bpp"));
        
        for (rgbXml in layersXml.elementsNamed("RGB")) {
            readGale200XFramePalette(rgbXml, frame);
        }
        
        for (layerXml in layersXml.elementsNamed("Layer")) {
            var layer = readGale200XLayer(layerXml, input, galImage, frame);
            frame.layers.push(layer);
        }
        
        frame.layers.reverse();
        
        return frame;
    }
    
    static function readGale200XFramePalette(rgbXml:Xml, frame:GalFrame)
    {
        var paletteString = rgbXml.firstChild().nodeValue;
        
        var pos = 0;
        var length = paletteString.length;
        while ((length - pos) >= 6) {
            var blue = Std.parseInt("0x" + paletteString.substr(pos, 2));
            var green = Std.parseInt("0x" + paletteString.substr(pos+2, 2));
            var red = Std.parseInt("0x" + paletteString.substr(pos + 4, 2));
            frame.paletteTable.push(Rgb.fromComponents(red, green, blue));
            pos += 6;
        }
    }
    
    static function readGale200XLayer(layerXml:Xml, input:Input, galImage:GalImage, frame:GalFrame): GalLayer
    {
        var layer = new GalLayer(frame);
        
        layer.name = layerXml.get("Name");
        
        layer.transparentColorIndex = Std.parseInt(layerXml.get("TransColor"));
        layer.isTransparent = (layer.transparentColorIndex >= 0);
        layer.visible = (layerXml.get("Visible") != "0");
        layer.density = Std.parseInt(layerXml.get("Alpha"));
        // layer.isAlphaOn = (layerXml.get("AlphaOn") != "0");
        layer.isLock = (layerXml.get("Lock") != "0");
        
        readGale200XLayerImage(input, galImage, frame, layer);
        
        return layer;
    }
    
    static function readGale200XLayerImage(input:Input, galImage:GalImage, frame:GalFrame, layer:GalLayer)
    {
        readGale106LayerImage(input, galImage, frame, layer);
        
        var imageEnd = input.readInt32();
        if (imageEnd != 0) {
            throw Error.InvalidFormat;
        }
    }
    
}