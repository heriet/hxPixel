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
import js.Browser;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.ImageData;
import hxpixel.images.png.PngDecoder;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.color.Rgba;

class Main 
{
	
	static function main() 
	{
		var document = Browser.document;
        var canvas:CanvasElement = cast document.createElement("canvas");
        canvas.width = 100;
        canvas.height = 100;
        document.body.appendChild(canvas);
        
        var context = canvas.getContext2d();
        context.fillStyle = "#FFF";
        context.fillRect(0, 0, 40, 40);
        
        var gifBytes = haxe.Resource.getBytes("16x16_16colors_001_gif");
        var gifImage = createGifImage(gifBytes, context);
        context.putImageData(gifImage, 1, 1);
        
        var pngBytes = haxe.Resource.getBytes("16x16_16colors_001_png");
        var pngImage = createPngImage(pngBytes, context);
        context.putImageData(pngImage, 1+16+1, 0);
        
	}
	
    static function createPngImage(bytes : Bytes, context : CanvasRenderingContext2D)
    {
        var pnginfo = PngDecoder.decode(bytes);
        trace("width: " + pnginfo.width);
        trace("height: " + pnginfo.height);
        trace("colorType: " + pnginfo.colotType);
        trace("filterMethod: " + pnginfo.filterMethod);
        trace("bitDepth: " + pnginfo.bitDepth);
        
        var pngImage = context.createImageData(pnginfo.width, pnginfo.height);
        
        var rgbaImageData = pnginfo.getRgbaImageData();
        var pos = 0;
        var imageDataPos = 0;
        for (y in 0 ... pnginfo.height) {
            for (x in 0 ... pnginfo.width) {
                var rgba:Rgba = rgbaImageData[pos];
                pngImage.data[imageDataPos++] = rgba.red;
                pngImage.data[imageDataPos++] = rgba.green;
                pngImage.data[imageDataPos++] = rgba.blue;
                pngImage.data[imageDataPos++] = rgba.alpha;
                ++pos;
            }
        }
        
        return pngImage;
    }
    
    static function createGifImage(bytes : Bytes, context : CanvasRenderingContext2D)
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
        
        var gifImage = context.createImageData(gifFrameInfo.imageWidth, gifFrameInfo.imageHeight);
        var rgbaImageData = gifFrameInfo.getRgbaImageData();
        var pos = 0;
        var imageDataPos = 0;
        for (y in 0 ... gifFrameInfo.imageHeight) {
            for (x in 0 ... gifFrameInfo.imageWidth) {
                var rgba:Rgba = rgbaImageData[pos];
                gifImage.data[imageDataPos++] = rgba.red;
                gifImage.data[imageDataPos++] = rgba.green;
                gifImage.data[imageDataPos++] = rgba.blue;
                gifImage.data[imageDataPos++] = rgba.alpha;
                ++pos;
            }
        }
        
        return gifImage;
    }
}