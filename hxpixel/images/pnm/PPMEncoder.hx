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

package hxpixel.images.pnm;

import hxpixel.images.color.Rgb;

class PpmEncoder
{

    public static function encodeP3(width:Int, height:Int, maxval:Int, imageData:Array<Int>) : String
    {
        var ppm = "P3\n";
        ppm += width + " " + height + "\n";
        ppm += maxval + "\n";
        
        // No line should be longer than 70 characters.
        var pixelLen = Std.string(maxval).length * 3 + 3;
        var linePixelNum = Std.int(70 / pixelLen);
        
        for (i in 0 ... imageData.length) {
            var rgb:Rgb = imageData[i];
            ppm += rgb.red + " " + rgb.green + " " + rgb.blue;
            
            if ((i+1) % linePixelNum != 0) {
                ppm += " ";
            } else {
                ppm += "\n";
            }
        }
        
        return ppm;
    }
    
}