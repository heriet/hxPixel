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
                // todo readGaleX200(bytesInput, galImage);
                throw Error.UnsupportedFormat;
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
        
        var imageLength = input.readInt32();
        var imageBytes = input.read(imageLength);
        var uncompressed = Inflater.uncompress(imageBytes);
        var imageInput = new BytesInputWrapper(uncompressed, Endian.LittleEndian);
        
        if (frame.bitDepth == 8) {
            readGale106LayerImage8Bit(imageInput, uncompressed.length, frame, layer);
        } else {
            readGale106LayerImage(imageInput, uncompressed.length, frame, layer);
        }
        
        input.read(12);
        
        return layer;
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
    
    static function readGale106LayerImage(input:Input, length:Int, frame:GalFrame, layer:GalLayer)
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
    
    
}