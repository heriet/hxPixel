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

import hxpixel.images.edg.EdgDecoder;
import hxpixel.images.edg.EdgImage;

import hxpixel.images.gal.GalDecoder;
import hxpixel.images.gal.GalImage;

import hxpixel.images.gif.GifConverter;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.gif.GifEncoder;
import hxpixel.images.gif.GifImage;
import hxpixel.images.gif.GifFrame;

import sys.FileSystem;
import sys.io.File;

class TestGifConverter extends TestCase
{
    static inline var PATH_DIR_ASSET_EDG = "./samples/assets/edg/";
    static inline var PATH_DIR_ASSET_GAL = "./samples/assets/gal/";

    public function testConvertEdg()
    {
        compareEdgToGif(PATH_DIR_ASSET_EDG + "edg2_16x16_16colors_001.edg", "./testbin/enc_edg2_16x16_16colors_001.gif");
        compareEdgToGif(PATH_DIR_ASSET_EDG + "edg2_16x16_16colors_3layer_001.edg", "./testbin/enc_edg2_16x16_16colors_3layer_001.gif");
        compareEdgToGif(PATH_DIR_ASSET_EDG + "edg2_60x60_6frames_001.edg", "./testbin/enc_edg2_60x60_6frames_001.gif");
    }
    
    public function compareEdgToGif(inputPath: String, outputPath: String)
    {
        var edgImage = decodeEdgImage(inputPath);
        var gifImage = GifConverter.convertFromEdg(edgImage);
        var gifBytes = GifEncoder.encode(gifImage);
        
        var file = File.write(outputPath);
        file.write(gifBytes);
        file.close();
        
        var size = edgImage.getSize();
                
        var reDecoded = GifDecoder.decode(gifBytes);
        assertEquals(size[0], reDecoded.logicalScreenWidth);
        assertEquals(size[1], reDecoded.logicalScreenHeight);
    }
    
    function decodeEdgImage(filePath: String) : EdgImage
    {
        var edgBytes = File.getBytes(filePath);
        var edgImage = EdgDecoder.decode(edgBytes);
        
        return edgImage;
    }
    
    
    public function testConvertGal()
    {
        compareGalToGif(PATH_DIR_ASSET_GAL + "galx200_16x16_16colors_001.gal", "./testbin/enc_galx200_16x16_16colors_001.gif");
        compareGalToGif(PATH_DIR_ASSET_GAL + "galx200_16x16_16colors_3layer_001.gal", "./testbin/enc_galx200_16x16_16colors_3layer_001.gif");
        compareGalToGif(PATH_DIR_ASSET_GAL + "galx200_60x60_6frames_001.gal", "./testbin/enc_galx200_60x60_6frames_001.gif");
    }
    
    public function compareGalToGif(inputPath: String, outputPath: String)
    {
        var galImage = decodeGalImage(inputPath);
        var gifImage = GifConverter.convertFromGal(galImage);
        var gifBytes = GifEncoder.encode(gifImage);
        
        var file = File.write(outputPath);
        file.write(gifBytes);
        file.close();
                
        var reDecoded = GifDecoder.decode(gifBytes);
        assertEquals(galImage.width, reDecoded.logicalScreenWidth);
        assertEquals(galImage.height, reDecoded.logicalScreenHeight);
    }
    
    function decodeGalImage(filePath: String) : GalImage
    {
        var galBytes = File.getBytes(filePath);
        var galImage = GalDecoder.decode(galBytes);
        
        return galImage;
    }
}