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

package tests.images.png;

import haxe.unit.TestCase;
import hxpixel.images.png.PngDecoder;
import hxpixel.images.png.PngEncoder;
import hxpixel.images.png.PngImage;

import tests.utils.PathUtils;

import sys.FileSystem;
import sys.io.File;

class TestPngEncoder extends TestCase
{
    public function testEncode()
    {
        var pngImage = decodePngImage(PathUtils.PATH_DIR_ASSET_PNG + "48x48_32colors_001.png");
        
        var pngBytes = PngEncoder.encode(pngImage);
        
        var file = File.write("./testbin/enc_48x48_32colors_001.png");
        file.writeBytes(pngBytes, 0, pngBytes.length);
        file.close();
        
        var reDecoded = PngDecoder.decode(pngBytes);
        assertEquals(48, reDecoded.width);
        assertEquals(48, reDecoded.height);
        
        var pngRgbaArray = pngImage.getRgbaImageData();
        var reDecodedRgbaArray = reDecoded.getRgbaImageData();
        
        for (i in 0 ... reDecodedRgbaArray.length) {
            assertEquals(pngRgbaArray[i], reDecodedRgbaArray[i]);
        }
    }
    
    function decodePngImage(filePath: String) : PngImage
    {
        var pngBytes = File.getBytes(filePath);
        var pngImage = PngDecoder.decode(pngBytes);
        
        return pngImage;
    }
    
    
}