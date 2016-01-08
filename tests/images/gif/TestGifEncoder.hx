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

package tests.images.gif;

import haxe.unit.TestCase;

import hxpixel.images.gif.GifEncoder;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.gif.GifFrame;
import hxpixel.images.gif.GifImage;

import tests.utils.PathUtils;

import sys.FileSystem;
import sys.io.File;

class TestGifEncoder extends TestCase
{   
    public function testEncode()
    {
        compareGifEncode(PathUtils.PATH_DIR_ASSET_GIF + "16x16_16colors_001.gif", "./testbin/enc_16x16_16colors_001.gif");
        compareGifEncode(PathUtils.PATH_DIR_ASSET_GIF + "48x48_32colors_001.gif", "./testbin/enc_48x48_32colors_001.gif");
        compareGifEncode(PathUtils.PATH_DIR_ASSET_GIF + "60x60_6frames_001.gif", "./testbin/enc_60x60_6frames_001.gif");
        compareGifEncode(PathUtils.PATH_DIR_ASSET_GIF + "161x237_64colors_001.gif", "./testbin/enc_161x237_64colors_001.gif");
    }
    
    function compareGifEncode(inputPath: String, outputPath: String)
    {
        var gifImage = decodeGifImage(inputPath);
        
        var gifBytes = GifEncoder.encode(gifImage);
        
        var file = File.write(outputPath);
        file.write(gifBytes);
        file.close();
        
        var reDecoded = GifDecoder.decode(gifBytes);
        assertEquals(gifImage.logicalScreenWidth, reDecoded.logicalScreenWidth);
        assertEquals(gifImage.logicalScreenHeight, reDecoded.logicalScreenHeight);
        
        compareGifRgba(gifImage, reDecoded);
    }
    
    function compareGifRgba(a: GifImage, b: GifImage)
    {
        assertEquals(a.numFrames, b.numFrames);
        
        for (frameIndex in 0 ... a.numFrames) {
            var aFrame = a.frameList[frameIndex];
            var bFrame = b.frameList[frameIndex];
            
            var aRgbaArray = aFrame.getRgbaImageData();
            var bRgbaArray = bFrame.getRgbaImageData();
        
            for (i in 0 ... aRgbaArray.length) {
                if (aRgbaArray[i] != bRgbaArray[i]) {
                    trace("[" + i % aFrame.imageWidth + ", " + Std.int(i / aFrame.imageWidth) + "]");
                    trace(aFrame.imageData[i] + " <> " + bFrame.imageData[i]);
                    trace(aRgbaArray[i].toString() + " <> " + bRgbaArray[i].toString());
                }
            
                assertEquals(aRgbaArray[i], bRgbaArray[i]);
            }
        }
    }
    
    function decodeGifImage(filePath: String) : GifImage
    {
        var gifBytes = File.getBytes(filePath);
        var gifImage = GifDecoder.decode(gifBytes);
        
        return gifImage;
    }
    
    
}