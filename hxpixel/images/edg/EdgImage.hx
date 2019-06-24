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

package hxpixel.images.edg;

import hxpixel.images.color.Rgb;
import hxpixel.images.color.Rgba;

enum Version {
    Edge1;
    Edge2;
}

class EdgImage
{
    /* Edg Header */
    public var version: Version;
    public var bitDepth: Int;
    public var isEachPalette: Bool; // ページ毎にパレット指定
    public var basePosition: Int;   // ページ座標基準
    
    /* Edg Palette Bank */
    public var paletteBank: Array<Array<Rgb>>;
    public var transparentColorIndex: Int;
    public var transparentColor: Rgb;
    
    /* Edg Page */
    public var pages: Array<EdgPage>;
    public var numPages(get, never): Int;
    public var isFullColor(get, never): Bool;
    
    public function new() 
    {
        paletteBank = [];
        pages = [];
        isEachPalette = false;
        basePosition = 0;
    }
    
    public function get_numPages() : Int
    {
        return pages.length;
    }

    public function get_isFullColor() : Bool
    {
        return bitDepth > 8;
    }
    
    public function getSize() : Array<Int>
    {
        var imageWidth = 0;
        var imageHeight = 0;
        
        for (page in pages) {
            var pageRight = page.x + page.width;
            
            if (imageWidth < pageRight) {
                imageWidth = pageRight;
            }
            
            var pageBottom = page.y + page.height;
            
            if (imageHeight < pageBottom) {
                imageHeight = pageBottom;
            }
        }
        
        return [imageWidth, imageHeight];
    }
}