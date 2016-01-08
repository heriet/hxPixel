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

package ;

import haxe.io.Bytes;
import neko.Lib;
import sys.io.File;

import hxpixel.images.color.Rgb;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.png.PngDecoder;
import hxpixel.images.pnm.PpmEncoder;

class Main 
{
    
    static function main() 
    {   
        var pngBytes = haxe.Resource.getBytes("16x16_16colors_001_png");
        var pngPpm = convertPngToPpm(pngBytes);
        Lib.print(pngPpm);
        File.saveContent("16x16_16colors_001_png.ppm", pngPpm);
        
        Lib.print("\n-------------\n");
        
        var gifBytes = haxe.Resource.getBytes("16x16_16colors_001_gif");
        var gifPpm = convertGifToPpm(gifBytes);
        Lib.print(gifPpm);
        File.saveContent("16x16_16colors_001_gif.ppm", gifPpm);
    }
    
    static function convertPngToPpm(bytes : Bytes)
    {
        var pnginfo = PngDecoder.decode(bytes);        
        var rgbaImageData = pnginfo.getRgbaImageData();
        
        return PpmEncoder.encodeP3(pnginfo.width, pnginfo.height, 255, rgbaImageData);
    }
    
    static function convertGifToPpm(bytes : Bytes)
    {
        var gifinfo = GifDecoder.decode(bytes);
        var gifFrameInfo = gifinfo.frameList[0];
        var rgbaImageData = gifFrameInfo.getRgbaImageData();
        
        return PpmEncoder.encodeP3(gifFrameInfo.imageWidth, gifFrameInfo.imageHeight, 255, rgbaImageData);
    }
}