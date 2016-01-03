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
abstract LayerType(Int) from Int to Int {
  var Layer = 0;
  var OpenFolder = 1;
  var ClosedFolder = 2;
  var BoundingSectionDivider = 3;
}

class PsdLayer
{
    public var parent: PsdImage;
    
    public var name: String;
    public var visible: Bool;
    public var isLocked: Bool;
    
    public var x: Int;
    public var y: Int;
    public var width: Int;
    public var height: Int;
    public var numChannels: Int;
    public var blendMode: String;
    public var opacity: Int;
    public var clipping: Int;
    public var flags:Int;
    
    public var type: LayerType;
    
    public var imageData: Array<Rgba>;
    
    public function new(parent : PsdImage) 
    {
        this.parent = parent;
        
        visible = true;
        imageData = [];
    }
    
    public function getRgbaImageData() : Array<Rgba>
    {
        return imageData.copy();
    }
}