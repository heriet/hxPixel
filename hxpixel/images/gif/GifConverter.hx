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

package hxpixel.images.gif;

import hxpixel.images.edg.EdgImage;
import hxpixel.images.edg.EdgPage;
import hxpixel.images.edg.EdgLayer;

import hxpixel.images.gal.GalImage;
import hxpixel.images.gal.GalFrame;
import hxpixel.images.gal.GalLayer;

import hxpixel.images.gif.GifImage;
import hxpixel.images.gif.GifFrame;


class GifConverter
{   
    public static function convertFromEdg(edgImage: EdgImage): GifImage
    {
        var gifImage = new GifImage();
        
        var size = edgImage.getSize();
        gifImage.logicalScreenWidth = size[0];
        gifImage.logicalScreenHeight = size[1];
        
        gifImage.version = Version.Gif89a;
        gifImage.colorResolution = calcEdgColorResolution(edgImage) - 1;
        gifImage.sortFlag = false;
        
        if (edgImage.isEachPalette) {
            gifImage.sizeOfGlobalTable = 0;
            gifImage.globalColorTableFlag = false;
            
        } else {
            var palette = edgImage.paletteBank[0];
            
            gifImage.sizeOfGlobalTable = calcExponent(palette.length) - 1;
            var tableLength = 1 << (gifImage.sizeOfGlobalTable + 1);
            for (i in 0 ... tableLength) {
                gifImage.globalColorTable[i] = i < palette.length ? palette[i] : 0;
            }
            gifImage.globalColorTableFlag = true;
        }
        
        gifImage.backgroundColorIndex = edgImage.transparentColorIndex;
        
        gifImage.pixelAspectRaito = 0;
        gifImage.animationLoopCount = 0;
        
        for (edgPage in edgImage.pages) {
            var gifFrame = createFrameFromEdgPage(edgPage, gifImage);
            gifImage.frameList.push(gifFrame);
        }
        
        return gifImage;
    }
    
    static function calcEdgColorResolution(edgImage: EdgImage): Int
    {
        var paletteMax = 0;
        
        for (palette in edgImage.paletteBank) {
            if (paletteMax < palette.length) {
                paletteMax = palette.length;
            }
        }
        
        return calcExponent(paletteMax);
    }
    
    static function calcExponent(num: Int): Int
    {
        var i = 0;
        while ((1 << i) < num) {
            i++;
        }
        return i;
    }
    
    static function createFrameFromEdgPage(edgPage: EdgPage, gifImage:GifImage) : GifFrame
    {
        var gifFrame = new GifFrame(gifImage);
        
        gifFrame.disposalMothod = edgPage.nextBackgroundType;
        gifFrame.userInputFlag = false;
        gifFrame.transparentColorFlag = edgPage.isTransparent;
        gifFrame.delayTime = Std.int(edgPage.wait / 60);
        gifFrame.transparentColorIndex = edgPage.transparentColorIndex;
        
        gifFrame.imageLeftPosition = edgPage.x;
        gifFrame.imageTopPosition = edgPage.y;
        gifFrame.imageWidth = edgPage.width;
        gifFrame.imageHeight = edgPage.height;
        
        if (edgPage.paletteBankIndex <= 0) {
            gifFrame.localColorTableFlag = false;
            gifFrame.localColorTable = [];
            gifFrame.sizeOfLocalColorTable = 0;
        } else {
            
            var palette = edgPage.palette;
            gifFrame.sizeOfLocalColorTable = calcExponent(palette.length) - 1;
            var tableLength = 1 << (gifFrame.sizeOfLocalColorTable + 1);
            for (i in 0 ... tableLength) {
                gifFrame.localColorTable[i] = i < palette.length ? palette[i] : 0;
            }
            gifFrame.localColorTableFlag = true;
        }
        
        gifFrame.interlaceFlag = false;
        gifFrame.sortFlag = false;
        
        gifFrame.imageData = edgPage.imageData;
        
        return gifFrame;
    }
    
}