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

package hxpixel.images.gif;

import hxpixel.images.gif.GifDecoder;
import hxpixel.images.gif.GifFrame;
import hxpixel.images.gif.GifImage;
import hxpixel.bytes.Bits;
import hxpixel.bytes.BitWriter;

import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Output;

class GifEncoder
{   
    public static function encode(image:GifImage): Bytes
    {
        var output = new BytesOutput();
        output.bigEndian = false;
        
        writeHeader(image, output);
        
        if(image.globalColorTableFlag) {
            writeGlobalColorTable(image, output);
        }
        
        if (image.numFrames > 1) {
            writeApplicationExtension(image, output);
        }
        
        for (frame in image.frameList) {
            
            writeGraphicControlExtension(frame, output);
            writeImageDescriptor(frame, output);
            
            if (frame.localColorTableFlag) {
                writeLocalColorTable(frame, output);
            }
            
            writeImageData(frame, output);
        }
            
        output.writeByte(0x3b); // Trailer
        
        return output.getBytes();
    }
        
    static function writeHeader(image:GifImage, output: Output)
    {
        output.writeString("GIF");
        output.writeString("89a");
        output.writeUInt16(image.logicalScreenWidth);
        output.writeUInt16(image.logicalScreenHeight);
        
        var packedField = 0;
        packedField += image.globalColorTableFlag ? 0x80 : 0;
        packedField += image.colorResolution << 4;
        packedField += image.sortFlag ? 0x08 : 0;
        packedField += image.sizeOfGlobalTable;
        output.writeByte(packedField);
        
        output.writeByte(image.backgroundColorIndex);
        output.writeByte(image.pixelAspectRaito);
        
    }
    
    static function writeGlobalColorTable(image:GifImage, output: Output)
    {
         var tableLength = 1 << (image.sizeOfGlobalTable + 1);
        
        for (i in 0 ... tableLength) {
            var color = image.globalColorTable[i];
            output.writeByte(color.red);
            output.writeByte(color.green);
            output.writeByte(color.blue);
        }
    }
    
    static function writeLocalColorTable(frame:GifFrame, output: Output)
    {
         var tableLength = 1 << (frame.sizeOfLocalColorTable + 1);
        
        for (i in 0 ... tableLength) {
            var color = frame.localColorTable[i];
            output.writeByte(color.red);
            output.writeByte(color.green);
            output.writeByte(color.blue);
        }
    }
    
    static function writeGraphicControlExtension(frame: GifFrame, output: Output)
    {
        var block = new BytesOutput();
        block.bigEndian = false;
        
        var packedFields = 0;
        packedFields += frame.disposalMothod != null ? frame.disposalMothod << 2 : 0;
        packedFields += frame.userInputFlag ? 0x02 : 0;
        packedFields += frame.transparentColorFlag ? 0x01 : 0;
        block.writeByte(packedFields);
        
        block.writeUInt16(frame.delayTime != null ? frame.delayTime : 0);
        block.writeByte(frame.transparentColorIndex != null ? frame.transparentColorIndex : 0);
        
        writeExtension(0xf9, block.getBytes(), output);
    }
    
    static function writeImageDescriptor(frame:GifFrame, output: Output)
    {
        output.writeByte(0x2c); // Image Separator
        output.writeUInt16(frame.imageLeftPosition);
        output.writeUInt16(frame.imageTopPosition);
        output.writeUInt16(frame.imageWidth);
        output.writeUInt16(frame.imageHeight);
        
        var packedFields = 0;
        packedFields += frame.localColorTableFlag ? 0x80 : 0;
        packedFields += frame.interlaceFlag ? 0x40 : 0;
        packedFields += frame.sortFlag ? 0x20 : 0;
        packedFields += frame.sizeOfLocalColorTable;
        output.writeByte(packedFields);
    }
    
    static function writeImageData(frame:GifFrame, output: Output)
    {
        var lzwMinimumCodeSize = frame.parent.colorResolution > 1 ? frame.parent.colorResolution + 1 : 2;
        output.writeByte(lzwMinimumCodeSize);
        
        var compressdBytes = compressLzw(frame, lzwMinimumCodeSize);
        
        var rest = compressdBytes.length;
        var pos = 0;
        while(rest >= 255) {
            output.writeByte(0xff);
            output.writeBytes(compressdBytes, pos, 0xff);
            pos += 0xff;
            rest -= 0xff;
        }
        
        if (rest > 0) {
            output.writeByte(rest);
            output.writeBytes(compressdBytes, pos, rest);
        }
        
        output.writeByte(0); // Block Terminator
    }
    
    static function compressLzw(frame: GifFrame, lzwMinimumCodeSize: Int): Bytes
    {   
        var dictionary = createInitialDictionary(lzwMinimumCodeSize);
        
        var colorLength = lzwMinimumCodeSize;
        var codeLength = lzwMinimumCodeSize + 1;
        var clearCode = 1 << lzwMinimumCodeSize;
        var endCode = clearCode + 1;
        var registerNum = endCode + 1;
        
        var bitWriter = new BitWriter();
        bitWriter.writeIntBits(clearCode, codeLength);
        
        var imageData = frame.imageData;
        
        var prefix = Bits.fromIntBits(imageData[0], colorLength);
        var code = imageData[0];
        
        for (i in 1 ... imageData.length) {
            var suffix = Bits.fromIntBits(imageData[i], colorLength);
            var word = suffix + prefix;
            var wordStr = word.toString();
            
            if (!dictionary.exists(wordStr)) {
                dictionary[wordStr] = registerNum;
                bitWriter.writeIntBits(code, codeLength);
                
                registerNum++;
                
                if (registerNum > (1 << codeLength)) {
                    if(codeLength < 12) {
                        codeLength++;
                    } else {
                        // reset dictonary
                        bitWriter.writeIntBits(clearCode, codeLength);
                        
                        dictionary = createInitialDictionary(lzwMinimumCodeSize);
                        codeLength = lzwMinimumCodeSize + 1;
                        registerNum = endCode + 1;
                    }
                }
                
                code = imageData[i];
                prefix = suffix.copy();
                
            } else {
                code = dictionary[wordStr];
                prefix = word.copy();
            }
        }
        
        bitWriter.writeIntBits(code, codeLength);
        bitWriter.writeIntBits(endCode, codeLength);
        
        return bitWriter.getBytes();
    }
    
    static function writeApplicationExtension(image:GifImage, output: Output)
    {
        output.writeByte(0x21); // Extension Introducer
        output.writeByte(0xff); // Extension Label
        
        output.writeByte(0x0b);
        output.writeString("NETSCAPE"); // Application Identifier
        output.writeString("2.0"); // Application Authentication Code
        
        output.writeByte(3); // Application Block Size
        output.writeByte(0x01);
        output.writeUInt16(image.animationLoopCount);
        
        output.writeByte(0x00); // Block Terminator
    }
    
    static function writeExtension(label:Int, blockBytes:Bytes, output:Output)
    {
        output.writeByte(0x21); // Extension Introducer
        output.writeByte(label);
        output.writeByte(blockBytes.length);
        output.write(blockBytes);
        output.writeByte(0x00); // Block Terminator
    }
    
    static function createInitialDictionary(lzwMinimumCodeSize : Int) : Map<String, Int>
    {
        var dictionary = new Map<String, Int>();
        var len = 1 << lzwMinimumCodeSize;
        for (i in 0 ... len) {
            var str = Bits.fromIntBits(i, lzwMinimumCodeSize);
            dictionary[str] = i;
        }
        
        return dictionary;
    }
}