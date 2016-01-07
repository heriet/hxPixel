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

package hxpixel.images.gif;

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

class GifDecoder
{
    public static function decode(bytes:Bytes): GifImage
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.LittleEndian);
        var gifInfo = new GifImage();
        
        readHeader(bytesInput, gifInfo);
        
        if(gifInfo.globalColorTableFlag) {
            readGlobalColorTable(bytesInput, gifInfo);
        }
        
        var gifFrameInfo = new GifFrame(gifInfo);
        
        while(true) {
            var signature = bytesInput.readByte();
            
            if (signature == 0x21) {
                var label = bytesInput.readByte();
                
                if (label == 0xF9) {
                    readGraphicControlExtension(bytesInput, gifFrameInfo);
                } else if (label == 0xFF) {
                    readApplicationExtension(bytesInput, gifFrameInfo);
                }
                else {
                    throw Error.UnsupportedFormat;
                }
            } else if (signature == 0x2C) {
                readImageDescriptor(bytesInput, gifFrameInfo);
                if (gifFrameInfo.localColorTableFlag) {
                    readLocalColorTable(bytesInput, gifFrameInfo);
                }
                readImageData(bytesInput, gifFrameInfo);
                
                gifInfo.frameList.push(gifFrameInfo);
                gifFrameInfo = new GifFrame(gifInfo);
                
            } else if (signature == 0x3b) {
                break;
            } else {
                throw Error.InvalidFormat;
            }
        }
        
        return gifInfo;
    }
    
    static function readHeader(input:Input, gifInfo:GifImage)
    {
        validateSignature(input.read(3));
        readVersion(input.read(3), gifInfo);
        
        gifInfo.logicalScreenWidth = input.readUInt16();
        gifInfo.logicalScreenHeight = input.readUInt16();
        
        var packedFields = input.readByte();
        gifInfo.globalColorTableFlag = (packedFields & 0x80) == 0x80; // 0b10000000
        gifInfo.colorResolution = (packedFields & 0x70) >> 4; // 0b01110000
        gifInfo.sortFlag = (packedFields & 0x08) == 0x08; // 0b00001000
        gifInfo.sizeOfGlobalTable = (packedFields & 0x07); // 0b00000111
        
        gifInfo.backgroundColorIndex = input.readByte();
        gifInfo.pixelAspectRaito = input.readByte();
        
    }
    
    static function validateSignature(bytes:Bytes)
    {
        if (bytes.toString() != "GIF") {
            throw Error.InvalidFormat;
        }
    }
    
    static function readVersion(bytes:Bytes, gifInfo:GifImage)
    {
        switch(bytes.toString()) {
            case "87a":
                gifInfo.version = Gif87a;
                throw Error.UnsupportedFormat;
            case "89a":
                gifInfo.version = Gif89a;
            default:
                throw Error.InvalidFormat;
        }
    }
    
    static function readGlobalColorTable(input:Input, gifInfo:GifImage)
    {
        var tableLength = 1 << (gifInfo.sizeOfGlobalTable + 1);
        
        for (i in 0 ... tableLength) {
            gifInfo.globalColorTable.push(ColorUtils.readRgb(input));
        }
    }
    
    static function readGraphicControlExtension(input:Input, gifFrameInfo:GifFrame)
    {
        var blockSize = input.readByte();
        if (blockSize != 0x04) {
            throw Error.InvalidFormat;
        }
        var packedFields = input.readByte();
        
        gifFrameInfo.disposalMothod = (packedFields & 0x1C) >> 2; // 0b00011100
        gifFrameInfo.userInputFlag = (packedFields & 0x02) == 0x02; // 0b00000010
        gifFrameInfo.transparentColorFlag = (packedFields & 0x01) == 0x01; // 0b00000001
        
        gifFrameInfo.delayTime = input.readUInt16();
        gifFrameInfo.transparentColorIndex = input.readByte();
        
        var terminator = input.readByte();
        if (terminator != 0) {
            throw Error.InvalidFormat;
        }
    }
    
    static function readApplicationExtension(input:Input, gifFrameInfo:GifFrame)
    {
        var blockSize = input.readByte();
        if (blockSize != 0x0b) {
            throw Error.InvalidFormat;
        }
        
        // Application Identifier
        input.readInt32();
        input.readInt32();
        
        // Application Authentication Code
        input.readByte();
        input.readByte();
        input.readByte();
        
        var applicationBlockSize = input.readByte();
        if (applicationBlockSize == 3) {
            input.readByte();
            
            gifFrameInfo.parent.animationLoopCount = input.readUInt16();
            
        } else {
            throw UnsupportedFormat;
        }
        
        var terminator = input.readByte();
        if (terminator != 0) {
            throw Error.InvalidFormat;
        }
    }
    
    static function readImageDescriptor(input:Input, gifFrameInfo:GifFrame) 
    {
        gifFrameInfo.imageLeftPosition = input.readUInt16();
        gifFrameInfo.imageTopPosition = input.readUInt16();
        gifFrameInfo.imageWidth = input.readUInt16();
        gifFrameInfo.imageHeight = input.readUInt16();
        
        var packedFields = input.readByte();
        
        gifFrameInfo.localColorTableFlag = (packedFields & 0x80) == 0x80; // 0b10000000
        gifFrameInfo.interlaceFlag = (packedFields & 0x40) == 0x40; // 0b01000000
        gifFrameInfo.sortFlag = (packedFields & 0x20) == 0x20; // 0b00100000
        gifFrameInfo.sizeOfLocalColorTable = (packedFields & 0x07); // 0b00000111
        
    }
    
    static function readLocalColorTable(input:Input, gifFrameInfo:GifFrame) 
    {
        var tableLength = 1 << (gifFrameInfo.sizeOfLocalColorTable + 1);
        
        for (i in 0 ... tableLength) {
            gifFrameInfo.localColorTable.push(ColorUtils.readRgb(input));
        }
    }
    
    static function readImageData(input:Input, gifFrameInfo:GifFrame) 
    {
        var lzwMinimumCodeSize = input.readByte();
        
        var joinOutput = new BytesOutput();
        while (true) {
            var blockSize = input.readByte();
            if (blockSize == 0) {
                break;
            }
            
            var bytes = input.read(blockSize);
            joinOutput.writeBytes(bytes, 0, bytes.length);
        }
        
        var joinBytes = joinOutput.getBytes();
        var bitReader = new BitReader(joinBytes);
        
        var codeLength = lzwMinimumCodeSize + 1;
        var clearCode = 1 << lzwMinimumCodeSize;
        var endCode = clearCode + 1;
        var registerNum = endCode + 1;
        
        var bitWriter = new BitWriter();
        var pixelNum = gifFrameInfo.imageWidth * gifFrameInfo.imageHeight;
        
        var dictionary = createInitialDictionary(lzwMinimumCodeSize);
        
        var firstCode = bitReader.readBits(codeLength);
        var prefix;
        
        if (firstCode.toInt() == clearCode) {
            prefix = bitReader.readBits(codeLength).subBits(0, lzwMinimumCodeSize);
        } else {
            prefix = firstCode.subBits(0, lzwMinimumCodeSize);
        }
        
        var suffix = prefix.copy();
        var readedPixel = 0;
        
        while (readedPixel < pixelNum) {
            var code = bitReader.bitsAvailable() >= codeLength 
                     ? bitReader.readIntBits(codeLength)
                     : bitReader.readIntBits(bitReader.bitsAvailable());
            
            if (code == clearCode) {
                dictionary = createInitialDictionary(lzwMinimumCodeSize);
                codeLength = lzwMinimumCodeSize + 1;
                registerNum = endCode + 1;
                
                bitWriter.writeBits(prefix);
                readedPixel = Std.int(bitWriter.length / lzwMinimumCodeSize);
                prefix = bitReader.readBits(codeLength).subBits(0, lzwMinimumCodeSize);
                
                continue;
            }
            
            if (!dictionary.exists(code)) {
                bitWriter.writeBits(prefix);
                
                suffix = prefix + prefix.subBits(0, lzwMinimumCodeSize);
                dictionary[registerNum] = suffix;
                registerNum++;
                
                if (registerNum >= (1 << codeLength) && codeLength < 12) {
                    codeLength++;
                }
                
                prefix = suffix.copy();
                
            } else {
                bitWriter.writeBits(prefix);
                suffix = dictionary[code];
                
                dictionary[registerNum] = prefix + suffix.subBits(0, lzwMinimumCodeSize);
                registerNum++;
                
                if (registerNum >= (1 << codeLength) && codeLength < 12) {
                    codeLength++;
                }
                
                prefix = suffix.copy();
            }
            
            readedPixel = Std.int(bitWriter.length / lzwMinimumCodeSize);
        }
        
        bitWriter.writeBits(prefix);
        
        var bytes = bitWriter.getBytes();
        var decodedBitReader = new BitReader(bytes);
        for (i in 0 ... pixelNum) {
            var color = decodedBitReader.bitsAvailable() >= lzwMinimumCodeSize 
                        ? decodedBitReader.readIntBits(lzwMinimumCodeSize)
                        : decodedBitReader.readIntBits(decodedBitReader.bitsAvailable());
                        
            gifFrameInfo.imageData[i] = color;
        }
    }
    
    static function createInitialDictionary(lzwMinimumCodeSize : Int) : Map<Int, Bits>
    {
        var dictionary = new Map<Int, Bits>();
        var len = 1 << lzwMinimumCodeSize;
        for (i in 0 ... len) {
            dictionary[i] = Bits.fromIntBits(i, lzwMinimumCodeSize);
        }
        
        return dictionary;
    }
}