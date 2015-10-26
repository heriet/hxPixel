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

package tests.images.edg;

import haxe.unit.TestCase;

import hxpixel.images.edg.EdgDecoder;
import hxpixel.images.edg.EdgImage;
import hxpixel.images.edg.EdgPage;
import hxpixel.images.edg.EdgLayer;

import hxpixel.images.png.PngDecoder;
import hxpixel.images.png.PngImage;
import sys.FileSystem;
import sys.io.File;

class TestEdgDecoder extends TestCase
{
    static inline var PATH_DIR_ASSET_EDG = "./samples/assets/edg/";
    static inline var PATH_DIR_ASSET_PNG = "./samples/assets/png/";
    
    
    public function testDecode()
    {
        var pngAssetArray = FileSystem.readDirectory(PATH_DIR_ASSET_PNG);
        
        for (fileName in pngAssetArray) {
            
            var fileNameWithoutExt = removeExtension(fileName);
            
            var edg1FileName = "edg1_" + fileNameWithoutExt + ".edg";
            if(FileSystem.exists(PATH_DIR_ASSET_EDG + edg1FileName)) {
                compareWithPngDecoder(fileName, edg1FileName);
            }
        }
    }
    
    public function testEdge1()
    {
        var edgImage = decodeEdgImage(PATH_DIR_ASSET_EDG + "edg1_16x16_16colors_001.edg");
        
        assertEquals(Version.Edge1, edgImage.version);
        assertEquals(16, edgImage.width);
        assertEquals(16, edgImage.height);
        assertEquals(1, edgImage.numPages);
        
        var page = edgImage.pages[0];
        assertEquals(1, page.numLayers);
        
        var layer = page.layers[0];
        assertEquals(16*16, layer.imageData.length);
        
    }   
    
    function compareWithPngDecoder(pngFileName: String, edgFileName: String)
    {
        var pngBytes = File.getBytes(PATH_DIR_ASSET_PNG + pngFileName);
        var pngImage = PngDecoder.decode(pngBytes);
        var pngRgbaArray = pngImage.getRgbaImageData();
        
        var edgImage = decodeEdgImage(PATH_DIR_ASSET_EDG + edgFileName);
        var edgPage = edgImage.pages[0];
        if (pngImage.isTransparent) {
            edgPage.isTransparent = true;
        }
        var edgRgbaArray = edgPage.getRgbaImageData();
        
        
        for (i in 0 ... edgRgbaArray.length) {
            if (edgRgbaArray[i] != pngRgbaArray[i]) {
                trace("file: " + edgFileName);
                trace("[" + i % edgPage.width + ", " + Std.int(i / edgPage.width) + "]");
                trace(pngRgbaArray[i].toString() + " <> " + edgRgbaArray[i].toString());
            }
            
            assertEquals(pngRgbaArray[i], edgRgbaArray[i]);
            
        }
    }
    
    function decodeEdgImage(filePath: String) : EdgImage
    {
        var edgBytes = File.getBytes(filePath);
        var edgImage = EdgDecoder.decode(edgBytes);
        
        return edgImage;
    }
    
    function removeExtension(fileName : String) : String
    {
        var reg = ~/\.[0-9a-zA-Z]+$/;
        return reg.replace(fileName, "");
    }
    
    
}