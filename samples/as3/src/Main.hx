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

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.Lib;
import haxe.io.Bytes;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.png.PngDecoder;

class Main 
{
    
    static function main() 
    {
        var stage = Lib.current.stage;
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.align = StageAlign.TOP_LEFT;
        
        var movieClip:MovieClip = flash.Lib.current;
        
        var gifBytes = haxe.Resource.getBytes("16x16_16colors_001_gif");
        var gifImage = createGifImage(gifBytes);
        movieClip.addChild(gifImage);
        gifImage.x = 16;
        gifImage.y = 16;
        gifImage.scaleX = 10.0;
        gifImage.scaleY = 10.0;
        
        var pngBytes = haxe.Resource.getBytes("16x16_16colors_001_png");
        var pngImage = createPngImage(pngBytes);
        movieClip.addChild(pngImage);
        pngImage.x = 16 + gifImage.width + 16;
        pngImage.y = 16;
        pngImage.scaleX = 10.0;
        pngImage.scaleY = 10.0;
    }
    
    static function createPngImage(bytes : Bytes)
    {
        var pnginfo = PngDecoder.decode(bytes);
        trace("width: " + pnginfo.width);
        trace("height: " + pnginfo.height);
        trace("colorType: " + pnginfo.colotType);
        trace("filterMethod: " + pnginfo.filterMethod);
        trace("bitDepth: " + pnginfo.bitDepth);
        
        var bitmapData = new BitmapData(pnginfo.width, pnginfo.height, true, 0xFF000000);
        var bitmap = new Bitmap(bitmapData);
        
        var rgbaImageData = pnginfo.getRgbaImageData();
        var pos = 0;
        for (y in 0 ... pnginfo.height) {
            for (x in 0 ... pnginfo.width) {
                bitmapData.setPixel32(x, y, rgbaImageData[pos]);
                ++pos;
            }
        }
        
        return bitmap;
    }
    
    static function createGifImage(bytes : Bytes)
    {
        var gifinfo = GifDecoder.decode(bytes);
        trace("width: " + gifinfo.logicalScreenWidth);
        trace("height: " + gifinfo.logicalScreenHeight);
        trace("colorResolution: " + gifinfo.colorResolution);
        trace("globalColotTableFlag:" + gifinfo.globalColorTableFlag);
        trace("globalColotTable:" + gifinfo.globalColorTable);
        
        trace("numFrames: " + gifinfo.numFrames);
        
        for (i in 0 ... gifinfo.numFrames) {
            var gifFrameInfo = gifinfo.frameList[i];
            trace("imageWidth: " + gifFrameInfo.imageWidth);
            trace("imageHeight: " + gifFrameInfo.imageHeight);
            trace("localColorTable:" + gifFrameInfo.localColorTable);
        }
        
        var gifFrameInfo = gifinfo.frameList[0];
        var bitmapData = new BitmapData(gifFrameInfo.imageWidth, gifFrameInfo.imageHeight, true, 0xFF000000);
        var bitmap = new Bitmap(bitmapData);
        
        var rgbaImageData = gifFrameInfo.getRgbaImageData();
        var pos = 0;
        for (y in 0 ... gifFrameInfo.imageHeight) {
            for (x in 0 ... gifFrameInfo.imageWidth) {
                bitmapData.setPixel32(x, y, rgbaImageData[pos]);
                ++pos;
            }
        }
        
        return bitmap;
    }
}