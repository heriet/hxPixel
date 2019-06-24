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

class EdgLayer
{
    public var parent: EdgPage;
    
    public var name: String;
    public var visible: Bool;
    public var isChild: Bool;
    public var isLocked: Bool;
    
    /* Image Data */
    public var imageData: Array<Int>;
    
    public function new(parent : EdgPage) 
    {
        this.parent = parent;
        
        imageData = [];
    }
    
    public function getRgbaImageData() : Array<Rgba>
    {
        var rgbaImageData = new Array<Rgba>();

        if (parent.parent.isFullColor) {
            var transparentColor = parent.parent.transparentColor;
            var colorNum = Std.int(imageData.length / 3);
            for (i in 0 ... colorNum) {
                var blue = imageData[i*3];
                var green = imageData[i*3+1];
                var red = imageData[i*3+2];
                var color = Rgba.fromComponents(red, green, blue);
                
                if (
                    transparentColor.blue == blue
                    && transparentColor.green == green
                    && transparentColor.red == red) {
                    color.alpha = 0;
                }

                rgbaImageData.push(color);
            }

        } else {
            var rgbaPalette = parent.getRbgaPalette();
            for (i in 0 ... imageData.length) {
                rgbaImageData[i] = rgbaPalette[imageData[i]];
            }
        }
        
        return rgbaImageData;
    }
}