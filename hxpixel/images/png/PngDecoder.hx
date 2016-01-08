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

package hxpixel.images.png;

import haxe.io.Bytes;
import haxe.io.BytesInput;
import haxe.io.BufferInput;
import haxe.io.BytesOutput;
import haxe.io.Input;
import haxe.zip.InflateImpl;
import hxpixel.bytes.Inflater;
import hxpixel.bytes.BytesInputWrapper;
import hxpixel.images.png.PngImage;

enum ChunkType {
    IHDR;
    sBIT;
    PLTE;
    IDAT;
    tRNS;
    bKGD;
    IEND;
}

enum Error {
    InvalidFormat;
    UnsupportedFormat;
}

class PngDecoder
{   
    public static function decode(bytes:Bytes): PngImage
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        validateSignature(bytesInput.read(8));
        
        var pngInfo = new PngImage();
        var idatBuffer = new BytesOutput();
        
        while (bytesInput.getAbailable() > 12) {
            var chunkLength = bytesInput.readInt32();
            var chunkTypeString = bytesInput.readString(4);
            var chunkData = chunkLength > 0 ? bytesInput.read(chunkLength) : null;
            var crc = bytesInput.readInt32();
            
            var chunkType;
            try {
                chunkType = Type.createEnum(ChunkType, chunkTypeString);
            } catch (e:String){
                continue;
            }
            
            switch(chunkType)
            {
                case ChunkType.IHDR:
                    decodeHeader(chunkData, pngInfo);
                case ChunkType.PLTE:
                    decodePalette(chunkData, pngInfo);
                case ChunkType.IDAT:
                    idatBuffer.writeBytes(chunkData, 0, chunkData.length);
                case ChunkType.tRNS:
                    decodeTransparent(chunkData, pngInfo);
                case ChunkType.bKGD:
                    decodeBackground(chunkData, pngInfo);
                default:
                    continue;
            }
             
        }
        
        decodeImage(idatBuffer.getBytes(), pngInfo);
        
        return pngInfo;
    }
    
    private static function validateSignature(signatureBytes:Bytes)
    {
        var bytesInput = new BytesInputWrapper(signatureBytes, Endian.BigEndian);

        if (bytesInput.readInt32() != 0x89504E47 || bytesInput.readInt32() != 0x0D0A1A0A) {
            throw Error.InvalidFormat;
        }
    }
    
    private static function decodeHeader(bytes:Bytes, pngInfo:PngImage)
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        pngInfo.width = bytesInput.readInt32();
        pngInfo.height = bytesInput.readInt32();
        pngInfo.bitDepth = bytesInput.readByte();
        
        pngInfo.colotType = switch(bytesInput.readByte()) {
            case 0: throw Error.UnsupportedFormat; //ColorType.GreyScale;
            case 2: ColorType.TrueColor;
            case 3: ColorType.IndexedColor;
            case 4: throw Error.UnsupportedFormat; //ColorType.GreyScaleWithAlpha;
            case 5: throw Error.UnsupportedFormat; //ColorType.TrueColorWithAlpha;
            default: throw Error.InvalidFormat;
        }
        
        pngInfo.compressionMethod = switch(bytesInput.readByte()) {
            case 0: CompressionMethod.Deflate;
            default: throw Error.InvalidFormat;
        }
        
        pngInfo.filterMethod = readFilterMethod(bytesInput);
        
        pngInfo.interlaceMethod = switch(bytesInput.readByte()) {
            case 0: InterlaceMethod.None;
            case 1: throw Error.UnsupportedFormat; // InterlaceMethod.Adam7;
            default: throw Error.InvalidFormat;
        }
        
    }
    
    private static function readFilterMethod(input : Input)
    {
        return switch(input.readByte()) {
            case 0: FilterMethod.None;
            case 1: FilterMethod.Sub;
            case 2: FilterMethod.Up;
            case 3: FilterMethod.Average;
            case 4: FilterMethod.Peath;
            default: throw Error.InvalidFormat;
        }
    }
    
    private static function decodePalette(bytes:Bytes, pngInfo:PngImage)
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        pngInfo.palette = [];
        
        var index = 0;
        while (bytesInput.getAbailable() >= 3) {
            pngInfo.palette[index] = readRgb(bytesInput);
            ++index;
        }
        
    }
    
    private static function decodeImage(bytes:Bytes, pngInfo:PngImage)
    {
        var uncompressed = Inflater.uncompress(bytes);
        
        switch(pngInfo.colotType) {
            case ColorType.TrueColor:
                decodeRgbImage(uncompressed, pngInfo);
            case ColorType.IndexedColor:
                decodeIndexedImage(uncompressed, pngInfo);
            default:
                throw Error.UnsupportedFormat;
        }
    }
    
    private static function decodeRgbImage(bytes:Bytes, pngInfo:PngImage)
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        var position = 0;
        pngInfo.imageData = [];
        
        for (y in 0 ... pngInfo.height) {
            var filterMethod = readFilterMethod(bytesInput);
            var reverseFilter = selectReverseFilter(filterMethod);
            
            for (x in 0 ... pngInfo.width) {
                var color = readRgb(bytesInput);
                var reconColor = reverseFilter.bind(x, y, color, pngInfo)();
                pngInfo.imageData[position] = (0xFF << 24) + reconColor;
                
                ++position;
            }
        }
    }
    
    private static function selectReverseFilter(filterMethod: FilterMethod)
    {
        return switch(filterMethod) {
            case FilterMethod.None:
                applyReverseFilterNone;
            case FilterMethod.Sub:
                applyReverseFilterSub;
            case FilterMethod.Up:
                applyReverseFilterUp;
            case FilterMethod.Average:
                applyReverseFilterAverage;
            case FilterMethod.Peath:
                applyReverseFilterPaeth;
        }
    }
    
    private static function applyReverseFilterNone(x:Int, y:Int, color:Int, pngInfo:PngImage)
    {
        return color;
    }
    
    private static function applyReverseFilterSub(x:Int, y:Int, color:Int, pngInfo:PngImage)
    {
        var leftColor = seekScanLine(x - 1, y, pngInfo);
        return margeColor(color, leftColor);
    }
    
    private static function applyReverseFilterUp(x:Int, y:Int, color:Int, pngInfo:PngImage)
    {
        var aboveColor = seekScanLine(x, y - 1, pngInfo);
        return margeColor(color, aboveColor);
    }
    
    private static function applyReverseFilterAverage(x:Int, y:Int, color:Int, pngInfo:PngImage)
    {
        var leftColor = seekScanLine(x - 1, y, pngInfo);
        var aboveColor = seekScanLine(x, y - 1, pngInfo);
        return margeColor(color, Std.int(margeColor(leftColor, aboveColor)/2));
    }
    
    private static function applyReverseFilterPaeth(x:Int, y:Int, color:Int, pngInfo:PngImage)
    {
        var leftColor = seekScanLine(x - 1, y, pngInfo);
        var aboveColor = seekScanLine(x, y - 1, pngInfo);
        var upperLeftColor = seekScanLine(x - 1, y - 1, pngInfo);
        
        var byteNum = 3;
        var paethColor = 0;
        for (i in 0 ... byteNum) {
            var shiftNum = i * 8;
            var mask = 0xFF << shiftNum;
            var maskedLeft = (leftColor & mask) >> shiftNum;
            var maskedAbove = (aboveColor & mask) >> shiftNum;
            var maskedUpperLeft = (upperLeftColor & mask) >> shiftNum;
            paethColor += applyPaethPredictor(maskedLeft, maskedAbove, maskedUpperLeft) << shiftNum;
        }
        
        return margeColor(color, paethColor);
    }
    
    private static function seekScanLine(x:Int, y:Int, pngInfo:PngImage)
    {
        if (x < 0 || y < 0) {
            return 0;
        }
        
        return (pngInfo.imageData[y * pngInfo.width + x]) & 0xFFFFFF;
    }
    
    private static function margeColor(a:Int, b:Int)
    {
        var red = ((a & 0xFF0000) + (b & 0xFF0000)) & 0xFF0000;
        var green = ((a & 0xFF00) + (b & 0xFF00)) & 0xFF00;
        var blue = ((a & 0xFF) + (b & 0xFF) ) & 0xFF;
        
        return red + green + blue;
    }
    
    private static function applyPaethPredictor(left:Int, above:Int, upperLeft:Int)
    {
        var distance = function (a, b) {
            return a < b ? b - a : a - b;
        }
        
        var p = left + above - upperLeft;
        var pLeft = distance.bind(p, left)();
        var pAbove = distance.bind(p, above)();
        var pUpperLeft = distance.bind(p, upperLeft)();
        
        if (pLeft <= pAbove && pLeft <= pUpperLeft) {
            return left;
        }
        else if (pAbove <= pUpperLeft) {
            return above;
        }
        else {
            return upperLeft;
        }
    }
    
    private static function decodeIndexedImage(bytes:Bytes, pngInfo:PngImage)
    {
        pngInfo.imageData = [];
        
        if(pngInfo.bitDepth == 8) {
            decodeByteIndexedImage(bytes, pngInfo);
        } else {
            decodeBitIndexedImage(bytes, pngInfo);
        }
    }
    
    private static function decodeByteIndexedImage(bytes:Bytes, pngInfo:PngImage)
    {
        var pixelIndex = 0;
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        for (y in 0 ... pngInfo.height) {
            bytesInput.readByte();
            for (x in 0 ... pngInfo.width) {
                var paletteIndex = bytesInput.readByte();
                pngInfo.imageData[pixelIndex] = paletteIndex;
                ++pixelIndex;
            }
        }
    }
    
    private static function decodeBitIndexedImage(bytes:Bytes, pngInfo:PngImage)
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        var n = bytes.length;
        var bitDepth = pngInfo.bitDepth;
        var mask = (1 << bitDepth) - 1;
        
        bytesInput.readByte();
        
        var x = 0;
        var y = 0;
        var width = pngInfo.width;
        var height = pngInfo.height;
        var value = 0;
        var bitPosition = 0;
        var pixelIndex = 0;
        
        while (bytesInput.getAbailable() > 0 && y < height) {
            value <<= bitPosition;
            value += bytesInput.readByte();
            bitPosition += 8;
            
            while (bitPosition >= bitDepth) {
                var shiftMask = mask << (bitPosition - bitDepth);
                var paletteIndex = (value & shiftMask) >> (bitPosition - bitDepth);
                
                value &= ~shiftMask;
                bitPosition -= bitDepth;
                
                pngInfo.imageData[pixelIndex] = paletteIndex;
                ++pixelIndex;
                ++x;
                
                if (x >= width) {
                    x = 0;
                    ++y;
                    
                    if (bytesInput.getAbailable() > 0 && y < height) {
                        bytesInput.readByte();
                    }
                }
            }
        }
        
    }
    
    private static function decodeTransparent(bytes:Bytes, pngInfo:PngImage)
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        switch(pngInfo.colotType) {
            case ColorType.GreyScale:
                pngInfo.transparent = bytesInput.readUInt16();
            case ColorType.TrueColor:
                pngInfo.transparent = readRgb(bytesInput);
            case ColorType.IndexedColor:
                pngInfo.paletteTransparent = readBytesArray(bytesInput);
            default:
                throw Error.InvalidFormat;
        }
    }
    
    private static function decodeBackground(bytes:Bytes, pngInfo:PngImage)
    {
        var bytesInput = new BytesInputWrapper(bytes, Endian.BigEndian);
        
        switch(pngInfo.colotType) {
            case ColorType.IndexedColor:
                pngInfo.background = bytesInput.readByte();
            case ColorType.GreyScale, ColorType.GreyScaleWithAlpha:
                pngInfo.background = bytesInput.readUInt16();
            case ColorType.TrueColor, ColorType.TrueColorWithAlpha:
                pngInfo.background = readRgb(bytesInput);
        }
        
        pngInfo.existBackground = true;
    }
    
    private static function readRgb(input: Input)
    {
        var red = input.readByte();
        var green = input.readByte();
        var blue = input.readByte();
        
        return (red << 16) + (green << 8) + blue;
    }
    
    private static function readBytesArray(bytesInput: BytesInputWrapper)
    {
        var bytesArray = new Array<Int>();
        while (bytesInput.getAbailable() > 0) {
            bytesArray.push(bytesInput.readByte());
        }
        return bytesArray;
    }
}