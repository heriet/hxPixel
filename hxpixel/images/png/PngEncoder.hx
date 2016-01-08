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

import haxe.crypto.Crc32;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import haxe.io.Output;
import hxpixel.bytes.Deflater;
import hxpixel.images.png.PngImage;

class PngEncoder
{   
    public static function encode(image:PngImage): Bytes
    {
        var output = new BytesOutput();
        output.bigEndian = true;
        
        writeSignature(output);
        
        writeIhdr(image, output);
        
        writePlte(image, output);
        
        if (image.isTransparent) {
            writeTrns(image, output);
        }
        
        writeIdat(image, output);
        
        writeIend(output);
        
        return output.getBytes();
    }
    
    static function writeSignature(output: Output)
    {
        output.writeInt32(0x89504E47);
        output.writeInt32(0x0D0A1A0A);
    }
    
    static function writeIhdr(image:PngImage, output: Output)
    {
        var chunkData = new BytesOutput();
        chunkData.bigEndian = true;
        
        chunkData.writeInt32(image.width);
        chunkData.writeInt32(image.height);
        
        chunkData.writeByte(image.bitDepth);
        
        chunkData.writeByte(image.colotType);
        chunkData.writeByte(0); // Compression method: deflate/inflate
        chunkData.writeByte(0); // Fileter method: None
        chunkData.writeByte(0); // Interlace method: None
        
        writeChunk("IHDR", chunkData.getBytes(), output);
    }
    
    static function writePlte(image:PngImage, output: Output)
    {
        var chunkData = new BytesOutput();
        chunkData.bigEndian = true;
        
        for (pigment in image.palette) {
            chunkData.writeByte(pigment.red);
            chunkData.writeByte(pigment.green);
            chunkData.writeByte(pigment.blue);
        }
        
        writeChunk("PLTE", chunkData.getBytes(), output);
    }
    
    static function writeTrns(image:PngImage, output: Output)
    {
        switch(image.colotType) {
            case ColorType.IndexedColor:
                writeTrnsIndexColor(image, output);
            default:
                return;
        }
    }
    
    static function writeTrnsIndexColor(image:PngImage, output: Output)
    {
        var chunkData = new BytesOutput();
        chunkData.bigEndian = true;
        
        for (alpha in image.paletteTransparent) {
            chunkData.writeByte(alpha);
        }
        
        writeChunk("tRNS", chunkData.getBytes(), output);
    }
    
    static function writeIdat(image:PngImage, output: Output)
    {
        image.bitDepth == 8
            ? writeIdat8Bit(image, output)
            : writeIdatBits(image, output);
    }
    
    static function writeIdat8Bit(image:PngImage, output: Output)
    {
        // todo check size
        
        var chunkData = new BytesOutput();
        chunkData.bigEndian = true;
        var position = 0;
        
        for (y in 0 ... image.height) {
            
            chunkData.writeByte(0); // Filter method: none
            
            for (x in 0 ... image.width) {
                var color = image.imageData[position];
                chunkData.writeByte(color);
                ++position;
            }
        }
        
        var compressed = Deflater.compress(chunkData.getBytes());
        
        writeChunk("IDAT", compressed, output);
    }
    
    static function writeIdatBits(image:PngImage, output: Output)
    {
        // todo
    }
    
    static function writeIend(output: Output)
    {
        writeChunk("IEND", Bytes.alloc(0), output);
    }
    
    static function writeChunk(chunkType:String, chunkData:Bytes, output: Output)
    {
        var chunkLength = chunkData.length;
        
        var chunkTypeAndData = new BytesOutput();
        chunkTypeAndData.bigEndian = true;
        
        chunkTypeAndData.writeString(chunkType);
        if (chunkLength > 0) {
            chunkTypeAndData.writeBytes(chunkData, 0, chunkLength);
        }
        
        var chunkTypeAndDataBytes = chunkTypeAndData.getBytes();
        var crc = Crc32.make(chunkTypeAndDataBytes);
        
        output.writeInt32(chunkLength);
        output.writeBytes(chunkTypeAndDataBytes, 0, chunkTypeAndDataBytes.length);
        output.writeInt32(crc);
    }
}