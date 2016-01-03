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

import hxpixel.images.color.Rgba;
import hxpixel.images.psd.PsdImage;
import hxpixel.images.psd.PsdLayer;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Output;

class PsdEncoder
{   
    public static function encode(image:PsdImage): Bytes
    {
        var output = new BytesOutput();
        output.bigEndian = true;
        
        writeHeader(image, output);
        writeColorModeData(image, output);
        writeImageResources(image, output);
        writeLayerAndMaskInformation(image, output);
        writeImageData(image, output);
        
        return output.getBytes();
    }
    
    static function writeHeader(image:PsdImage, output: Output)
    {
        output.writeInt32(0x38425053); // 8BPS
        output.writeInt16(1);
        
        output.writeInt32(0);
        output.writeInt16(0);
        
        output.writeInt16(image.numChannels);
        
        output.writeInt32(image.height);
        output.writeInt32(image.width);
        
        output.writeInt16(image.bitDepth);
        output.writeInt16(image.colorMode);
    }
    
    static function writeColorModeData(image:PsdImage, output: Output)
    {
        output.writeInt32(0);
        
        // todo index colormode write palette
    }
    
    static function writeImageResources(image:PsdImage, output: Output)
    {
        output.writeInt32(0);
    }
    
    static function writeLayerAndMaskInformation(image:PsdImage, output: Output)
    {        
        var bytes = generateLayerAndMaskInformation(image);
        var bytesLength = bytes.length;
        
        output.writeInt32(bytesLength);
        
        if(bytesLength > 0) {
            output.write(bytes);
        }
    }
    
    static function generateLayerAndMaskInformation(image:PsdImage): Bytes
    {
        if (image.layers.length == 0) {
            return Bytes.alloc(0);
        }
        
        var chunk = new BytesOutput();
        chunk.bigEndian = true;
        
        writeLayerInfo(image, chunk);
        writeGlobalLayerMaskInfo(image, chunk);
        writeAdditionalLayerInfomation(image, chunk);
        
        return chunk.getBytes();
    }
    
    static function writeLayerInfo(image:PsdImage, output: Output)
    {
        var chunk = new BytesOutput();
        chunk.bigEndian = true;
        
        var numLayers = image.layers.length;
        chunk.writeInt16(numLayers);
        
        for (i in 0 ... numLayers) {
            var layer = image.layers[numLayers - i - 1]; // reverse
            writeLayerRecord(image, layer, chunk);
        }
        
        for (i in 0 ... numLayers) {
            var layer = image.layers[numLayers - i - 1]; // reverse
            writeLayerImageData(image, layer, chunk);
        }
        
        output.writeInt32(chunk.length);
        output.write(chunk.getBytes());
    }
    
    static function writeLayerRecord(image:PsdImage, layer:PsdLayer, output: Output)
    {
        var extraDataField = new BytesOutput();
        extraDataField.bigEndian = true;
        
        writeLayerRecordMask(image, layer, extraDataField);
        writeLayerRecordBlendingRanges(image, layer, extraDataField);
        writeLayerRecordName(image, layer, extraDataField);
        writeLayerRecordAdditionalLayerInformation(image, layer, extraDataField);
        
        output.writeInt32(layer.y);
        output.writeInt32(layer.x);
        output.writeInt32(layer.y + layer.height);
        output.writeInt32(layer.x + layer.width);
        output.writeInt16(layer.numChannels);
        
        var channelLength = layer.width * layer.height + 2; // compression + RAW data
        
        // red channel
        output.writeInt16(0);
        output.writeInt32(channelLength);
        
        // blue channel
        output.writeInt16(1);
        output.writeInt32(channelLength);
        
        // green channel
        output.writeInt16(2);
        output.writeInt32(channelLength);
        
        // alpha channel
        output.writeInt16(-1);
        output.writeInt32(channelLength);
        
        
        output.writeString("8BIM");
        output.writeString(layer.blendMode);
        
        output.writeByte(layer.opacity);
        output.writeByte(layer.clipping);
        output.writeByte(layer.flags);
        
        output.writeByte(0);
        
        output.writeInt32(extraDataField.length);
        output.write(extraDataField.getBytes());
    }
    
    static function writeLayerRecordMask(image:PsdImage, layer:PsdLayer, output: Output)
    {
        output.writeInt32(0);
    }
    
    static function writeLayerRecordBlendingRanges(image:PsdImage, layer:PsdLayer, output: Output)
    {
        output.writeInt32(8 + layer.numChannels*8);
        
        output.writeInt32(0x0000FFFF);
        output.writeInt32(0x0000FFFF);
        
        for (i in 0 ... layer.numChannels) {
            output.writeInt32(0x0000FFFF);
            output.writeInt32(0x0000FFFF);
        }
        
    }
    
    static function writeLayerRecordName(image:PsdImage, layer:PsdLayer, output: Output)
    {
        var chunk = new BytesOutput();
        chunk.bigEndian = true;
        
        var nameBytes = Bytes.ofString(layer.name);
        chunk.write(nameBytes);
        
        // padded to a multiple of 4 bytes
        while ((chunk.length + 1) % 4 != 0) {
            chunk.writeByte(0);
        }
        
        output.writeByte(chunk.length);
        output.write(chunk.getBytes());
    }
    
    static function writeLayerRecordAdditionalLayerInformation(image:PsdImage, layer:PsdLayer, output: Output)
    {
        if (layer.type != LayerType.Layer) {
            writeAdditionalLayerInformationLsct(image, layer, output);
        }
    }
    
    static function writeAdditionalLayerInformationLsct(image:PsdImage, layer:PsdLayer, output: Output)
    {
        var chunk = new BytesOutput();
        chunk.bigEndian = true;
        chunk.writeInt32(layer.type);
        
        if (layer.type == LayerType.OpenFolder) {
            chunk.writeString("8BIM");
            chunk.writeString("pass");
        }
        
        output.writeString("8BIM");
        output.writeString("lsct");
        output.writeInt32(chunk.length);
        output.write(chunk.getBytes());
    }
    
    static function writeLayerImageData(image:PsdImage, layer:PsdLayer, output: Output)
    {
        var imageData = layer.imageData;
        writeRawRgbaChannels(imageData, output);
    }
    
    static function writeGlobalLayerMaskInfo(image:PsdImage, output: Output)
    {
        output.writeInt32(0);
    }
    
    static function writeAdditionalLayerInfomation(image:PsdImage, output: Output)
    {
        // pass
    }
    
    static function writeImageData(image:PsdImage, output: Output)
    {
        var imageData = image.imageData;
        writeRawRgba(imageData, output);
    }
    
    static function writeRawRgba(imageData:Array<Rgba>, output: Output)
    {
        var length = imageData.length;
        
        output.writeInt16(0); // RAW
        
        // Red
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.red);
        }
        
        // Green
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.green);
        }
        
        // Blue
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.blue);
        }
        
        // Alpha
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.alpha);
        }
        
        // pad byte
        var writeLength = 2 + length * 4;
        if (writeLength % 2 == 1) {
            output.writeByte(0);
        }
        
    }
    
    static function writeRawRgbaChannels(imageData:Array<Rgba>, output: Output)
    {
        var length = imageData.length;
        
        output.writeInt16(0); // RAW
        
        // Red
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.red);
        }
        
        output.writeInt16(0); // RAW
        
        // Green
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.green);
        }
        
        output.writeInt16(0); // RAW
        
        // Blue
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.blue);
        }
        
        output.writeInt16(0); // RAW
        
        // Alpha
        for (i in 0 ... length) {
            var color = imageData[i];
            output.writeByte(color.alpha);
        }
        
        // pad byte
        var writeLength = 2 + length * 4;
        if (writeLength % 2 == 1) {
            output.writeByte(0);
        }
        
    }
    
}