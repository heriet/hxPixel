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

package tests.images.psd;

import haxe.unit.TestCase;
import hxpixel.images.psd.PsdDecoder;
import hxpixel.images.psd.PsdImage;
import hxpixel.images.png.PngDecoder;
import hxpixel.images.png.PngImage;
import sys.FileSystem;
import sys.io.File;

class TestPsdDecoder extends TestCase
{
    static inline var PATH_DIR_ASSET_PSD = "./samples/assets/psd/";
    static inline var PATH_DIR_ASSET_PNG = "./samples/assets/png/";
    
    public function test16x16Psd()
    {
        var psdImage = decodePsdImage(PATH_DIR_ASSET_PSD + "16x16_16colors_001.psd");
        
    }
    
    function decodePsdImage(filePath: String) : PsdImage
    {
        var psdBytes = File.getBytes(filePath);
        var psdImage = PsdDecoder.decode(psdBytes);
        
        assertEquals(16, psdImage.width);
        assertEquals(16, psdImage.height);
        assertEquals(ColorMode.Rgb, psdImage.colorMode);
        
        return psdImage;
    }
    
    function removeExtension(fileName : String) : String
    {
        var reg = ~/\.[0-9a-zA-Z]+$/;
        return reg.replace(fileName, "");
    }
    
    
}