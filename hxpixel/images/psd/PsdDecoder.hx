/*
 * Copyright (c) heriet [http://heriet.info/].
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

package hxpixel.images.psd;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BufferInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import haxe.zip.InflateImpl;
import hxpixel.bytes.Inflater;
import hxpixel.bytes.BytesInputWrapper;
import hxpixel.images.psd.PsdImage;
import hxpixel.images.color.ColorUtils;

enum Error {
    InvalidFormat;
    UnsupportedFormat;
}

class PsdDecoder
{
    
    public static function decode(bytes:Bytes): PsdImage
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        var psdImage = new PsdImage();
        
        readHeader(bytesInput, psdImage);
        readColorModeDataSection(bytesInput, psdImage);
        readImageResorcesSection(bytesInput, psdImage);
        readLayerAndMaskInformationSection(bytesInput, psdImage);
        readImageDataSection(bytesInput, psdImage);
        
        return psdImage;
    }
    
    static function readHeader(input:Input, psdImage:PsdImage)
    {
        validateSignature(input.read(4));
        
        var version = input.readUInt16();
        if (version != 1) {
            throw Error.InvalidFormat;
        }
        
        input.read(6); // Reserved: must be zero
        
        var numChannels = input.readUInt16();
        psdImage.numChannels = numChannels;
        
        var width = input.readInt32();
        var height = input.readInt32();
        psdImage.width = width;
        psdImage.height = height;
        
        var bitDepth = input.readUInt16();
        if (bitDepth != 8) {
            throw Error.UnsupportedFormat;
        }
        psdImage.bitDepth = bitDepth;
        
        var colorMode = input.readUInt16();
        if (colorMode != ColorMode.Rgb) {
            throw Error.UnsupportedFormat;
        }
        psdImage.colorMode = colorMode;
    }
    
    static function validateSignature(bytes:Bytes)
    {
        if (bytes.toString() != "8BPS") {
            throw Error.InvalidFormat;
        }
    }
    
    static function readColorModeDataSection(input:Input, psdImage:PsdImage)
    {
        var sectionLength = input.readInt32();
        var numColors = Std.int(8 / psdImage.bitDepth * sectionLength / 3);
        
        for (i in 0 ... numColors) {
            var color = ColorUtils.readRgb(input);
            psdImage.palette.push(color);
        }
    }
    
    static function readImageResorcesSection(input:Input, psdImage:PsdImage)
    {
        var sectionLength = input.readInt32();
        input.read(sectionLength); // ignore
    }
    
    static function readLayerAndMaskInformationSection(input:Input, psdImage:PsdImage)
    {
        var sectionLength = input.readInt32();
        
        if (sectionLength == 0) {
            return;
        }
        
        var layerInfoLength = readLayerInfo(input, psdImage);
        var globalLayerMaskInfoLength = readGlabalLayerMaskInfo(input, psdImage);
        
        var rest = sectionLength - (layerInfoLength + globalLayerMaskInfoLength);
        
        while(rest > 0) {
            var readLength = readAdditionalLayerInformation(input, psdImage);
            rest -= readLength;
        }
    }
    
    static function readLayerInfo(input:Input, psdImage:PsdImage): Int
    {
        var sectionLength = input.readInt32();
        
        if (sectionLength == 0) {
            return 4;
        }
        
        var layerCount = input.readUInt16();
        input.read(sectionLength - 2);
        
        return 4 + sectionLength;
    }
    
    static function readGlabalLayerMaskInfo(input:Input, psdImage:PsdImage): Int
    {
        var sectionLength = input.readInt32();
        
        if (sectionLength == 0) {
            return 4;
        }
        
        input.read(sectionLength);
        
        return 4 + sectionLength;
    }
    
    static function readAdditionalLayerInformation(input:Input, psdImage:PsdImage): Int
    {
        var signatureBytes = input.read(4);
        var codeBytes = input.read(4);
        var blockLength = input.readInt32();
        
        if(blockLength > 0) {
            input.read(blockLength); // ignore
        }
        
        return 12 + blockLength;
    }
    
    static function readImageDataSection(input:Input, psdImage:PsdImage)
    {
        var compressionMethod = input.readUInt16();
        
        // Raw image data
        if (compressionMethod != 0) {
            throw Error.UnsupportedFormat;
        }
        
        var psdLayer = new PsdLayer(psdImage);
        var numPixel = psdImage.width * psdImage.height;
        
        for (i in 0 ... numPixel) {
            var color = ColorUtils.readRgb(input);
            psdLayer.imageData.push(color); // todo divide channels
        }
        
        psdImage.layers.push(psdLayer);
    }
}