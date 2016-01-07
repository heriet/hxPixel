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

package tests.images.gal;

import haxe.unit.TestCase;

import hxpixel.images.gal.GalDecoder;
import hxpixel.images.gal.GalImage;
import hxpixel.images.gal.GalFrame;
import hxpixel.images.gal.GalLayer;

import hxpixel.images.png.PngDecoder;
import hxpixel.images.png.PngImage;

import tests.utils.TestFileUtils;

import sys.FileSystem;
import sys.io.File;

class TestGalDecoder extends TestCase
{
    static inline var PATH_DIR_ASSET_GAL = "./samples/assets/gal/";
    static inline var PATH_DIR_ASSET_PNG = "./samples/assets/png/";
    
    public function testDecode()
    {
        var pngAssetArray = FileSystem.readDirectory(PATH_DIR_ASSET_PNG);
        
        for (fileName in pngAssetArray) {
            
            var fileNameWithoutExt = TestFileUtils.removeFileExtension(fileName);
            
            var gal106FileName = "gal106_" + fileNameWithoutExt + ".gal";
            if(FileSystem.exists(PATH_DIR_ASSET_GAL + gal106FileName)) {
                compareWithPngDecoder(fileName, gal106FileName);
            }
            
            var galx200FileName = "galx200_" + fileNameWithoutExt + ".gal";
            if(FileSystem.exists(PATH_DIR_ASSET_GAL + galx200FileName)) {
                compareWithPngDecoder(fileName, galx200FileName);
            }
        }
    }
    
    public function testGale106()
    {
        var galImage = decodeGalImage(PATH_DIR_ASSET_GAL + "gal106_16x16_16colors_001.gal");
        
        assertEquals(Version.Gale106, galImage.version);
        assertEquals(1, galImage.numFrames);
        
        var frame = galImage.frames[0];
        assertEquals(16, frame.width);
        assertEquals(16, frame.height);
        assertEquals(1, frame.numLayers);
        
        var layer = frame.layers[0];
        assertEquals(16*16, layer.imageData.length);
        
    }
    
    public function testGaleX200()
    {
        var galImage = decodeGalImage(PATH_DIR_ASSET_GAL + "galx200_16x16_16colors_001.gal");
        
        assertEquals(Version.GaleX200, galImage.version);
        assertEquals(1, galImage.numFrames);
        
        var frame = galImage.frames[0];
        assertEquals(16, frame.width);
        assertEquals(16, frame.height);
        assertEquals(1, frame.numLayers);
        
        var layer = frame.layers[0];
        assertEquals(16*16, layer.imageData.length);
        
    }
    
    function compareWithPngDecoder(pngFileName: String, galFileName: String)
    {
        var pngBytes = File.getBytes(PATH_DIR_ASSET_PNG + pngFileName);
        var pngImage = PngDecoder.decode(pngBytes);
        var pngRgbaArray = pngImage.getRgbaImageData();
        
        var galImage = decodeGalImage(PATH_DIR_ASSET_GAL + galFileName);
        var galFrame = galImage.frames[0];
        if (pngImage.isTransparent) {
            galFrame.layers[0].isTransparent = true;
            galFrame.layers[0].transparentColorIndex = 0;
        }
        var galRgbaArray = galFrame.layers[0].getRgbaImageData();
        
        for (i in 0 ... galRgbaArray.length) {
            if (galRgbaArray[i] != pngRgbaArray[i]) {
                trace("file: " + galFileName);
                trace("[" + i % galFrame.width + ", " + Std.int(i / galFrame.width) + "]");
                trace(pngRgbaArray[i].toString() + " <> " + galRgbaArray[i].toString());
            }
            
            assertEquals(pngRgbaArray[i], galRgbaArray[i]);
        }
    }
    
    function decodeGalImage(filePath: String) : GalImage
    {
        var galBytes = File.getBytes(filePath);
        var galImage = GalDecoder.decode(galBytes);
        
        return galImage;
    }
    
    
}