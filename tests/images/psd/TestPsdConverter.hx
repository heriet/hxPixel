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

package tests.images.psd;

import haxe.unit.TestCase;
import hxpixel.images.edg.EdgDecoder;
import hxpixel.images.edg.EdgImage;
import hxpixel.images.psd.PsdConverter;
import hxpixel.images.psd.PsdDecoder;
import hxpixel.images.psd.PsdEncoder;
import hxpixel.images.psd.PsdImage;
import sys.FileSystem;
import sys.io.File;

class TestPsdConverter extends TestCase
{
    static inline var PATH_DIR_ASSET_EDG = "./samples/assets/edg/";
    
    
    public function testConvertEdgSingle()
    {
        var edgImage = decodeEdgImage(PATH_DIR_ASSET_EDG + "edg2_16x16_16colors_001.edg");
        var psdImage = PsdConverter.convertFromEdg(edgImage);
        var psdBytes = PsdEncoder.encode(psdImage);
        
        var file = File.write("./testbin/enc_16x16_16colors_001.psd");
        file.writeBytes(psdBytes, 0, psdBytes.length);
        file.close();
                
        var reDecoded = PsdDecoder.decode(psdBytes);
        assertEquals(16, reDecoded.width);
        assertEquals(16, reDecoded.height);
    }
    
    public function testConvertEdgLayers()
    {
        var edgImage = decodeEdgImage(PATH_DIR_ASSET_EDG + "edg2_16x16_16colors_3layer_001.edg");
        var psdImage = PsdConverter.convertFromEdg(edgImage);
        var psdBytes = PsdEncoder.encode(psdImage);
        
        var file = File.write("./testbin/enc_16x16_16colors_3layer_001.psd");
        file.writeBytes(psdBytes, 0, psdBytes.length);
        file.close();
                
        var reDecoded = PsdDecoder.decode(psdBytes);
        assertEquals(16, reDecoded.width);
        assertEquals(16, reDecoded.height);
    }
    
    public function testConvertEdgPages()
    {
        var edgImage = decodeEdgImage(PATH_DIR_ASSET_EDG + "edg2_60x60_6frames_001.edg");
        var psdImage = PsdConverter.convertFromEdg(edgImage);
        var psdBytes = PsdEncoder.encode(psdImage);
        
        var file = File.write("./testbin/enc_60x60_6frames_001.psd");
        file.writeBytes(psdBytes, 0, psdBytes.length);
        file.close();
                
        var reDecoded = PsdDecoder.decode(psdBytes);
        assertEquals(60, reDecoded.width);
        assertEquals(60, reDecoded.height);
    }
    
    function decodeEdgImage(filePath: String) : EdgImage
    {
        var edgBytes = File.getBytes(filePath);
        var edgImage = EdgDecoder.decode(edgBytes);
        
        return edgImage;
    }
    
    
}