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

import hxpixel.images.gal.GalDecoder;
import hxpixel.images.gal.GalImage;

import hxpixel.images.psd.PsdConverter;
import hxpixel.images.psd.PsdDecoder;
import hxpixel.images.psd.PsdEncoder;
import hxpixel.images.psd.PsdImage;

import tests.utils.PathUtils;

import sys.FileSystem;
import sys.io.File;

class TestPsdConverter extends TestCase
{
    
    public function testConvertEdg()
    {
        compareEdgToPsd(PathUtils.PATH_DIR_ASSET_EDG + "edg2_16x16_16colors_001.edg", "./testbin/enc_edg2_16x16_16colors_001.psd");
        compareEdgToPsd(PathUtils.PATH_DIR_ASSET_EDG + "edg2_16x16_16colors_3layer_001.edg", "./testbin/enc_edg2_16x16_16colors_3layer_001.psd");
        compareEdgToPsd(PathUtils.PATH_DIR_ASSET_EDG + "edg2_60x60_6frames_001.edg", "./testbin/enc_edg2_60x60_6frames_001.psd");
    }
    
    public function compareEdgToPsd(inputPath: String, outputPath: String)
    {
        var edgImage = decodeEdgImage(inputPath);
        var psdImage = PsdConverter.convertFromEdg(edgImage);
        var psdBytes = PsdEncoder.encode(psdImage);
        
        var file = File.write(outputPath);
        file.write(psdBytes);
        file.close();
        
        var size = edgImage.getSize();
                
        var reDecoded = PsdDecoder.decode(psdBytes);
        assertEquals(size[0], reDecoded.width);
        assertEquals(size[1], reDecoded.height);
    }
    
    function decodeEdgImage(filePath: String) : EdgImage
    {
        var edgBytes = File.getBytes(filePath);
        var edgImage = EdgDecoder.decode(edgBytes);
        
        return edgImage;
    }
    
    
    public function testConvertGal()
    {
        compareGalToPsd(PathUtils.PATH_DIR_ASSET_GAL + "galx200_16x16_16colors_001.gal", "./testbin/enc_galx200_16x16_16colors_001.psd");
        compareGalToPsd(PathUtils.PATH_DIR_ASSET_GAL + "galx200_16x16_16colors_3layer_001.gal", "./testbin/enc_galx200_16x16_16colors_3layer_001.psd");
        compareGalToPsd(PathUtils.PATH_DIR_ASSET_GAL + "galx200_60x60_6frames_001.gal", "./testbin/enc_galx200_60x60_6frames_001.psd");
    }
    
    function compareGalToPsd(inputPath: String, outputPath: String)
    {
        var galImage = decodeGalImage(inputPath);
        var psdImage = PsdConverter.convertFromGal(galImage);
        var psdBytes = PsdEncoder.encode(psdImage);
        
        var file = File.write(outputPath);
        file.write(psdBytes);
        file.close();
                
        var reDecoded = PsdDecoder.decode(psdBytes);
        assertEquals(galImage.width, reDecoded.width);
        assertEquals(galImage.height, reDecoded.height);
    }
    
    function decodeGalImage(filePath: String) : GalImage
    {
        var galBytes = File.getBytes(filePath);
        var galImage = GalDecoder.decode(galBytes);
        
        return galImage;
    }
}