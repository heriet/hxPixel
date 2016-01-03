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

package hxpixel.images.psd;
import hxpixel.images.color.Rgb;
import hxpixel.images.color.Rgba;

@:enum
abstract ColorMode(Int) from Int to Int {
  var Bitmap = 0;
  var Grayscale = 1;
  var Indexed = 2;
  var Rgb = 3;
  var Cmyk = 4;
  var Multichannel = 7;
  var Duotone = 8;
  var Lab = 9;
}

class PsdImage
{
    public var width: Int;
    public var height: Int;
    public var numChannels: Int;
    public var colorMode: ColorMode;
    public var bitDepth: Int;
    
    public var palette: Array<Rgb>;
    public var layers: Array<PsdLayer>;
    
    public var imageData: Array<Rgba>; // layers merged image
    
    
    public function new() 
    {
        palette = [];
        layers = [];
        imageData = [];
    }
    
}