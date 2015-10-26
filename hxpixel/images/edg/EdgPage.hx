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

package hxpixel.images.edg;

import hxpixel.images.color.Rgb;
import hxpixel.images.color.Rgba;

class EdgPage
{
    public var parent: EdgImage;
    
    public var name: String;
    public var width: Int;
    public var height: Int;
    public var bitDepth: Int;
    public var isTransparent: Bool;
    public var isAbailable: Bool;
    public var transparentColorIndex: Int;
    
    public var wait: Int;
    public var nextBackgroundType: Int;
    
    public var isChild: Bool;
    public var x: Int;
    public var y: Int;
    public var isRelativeX: Bool;
    public var isRelativeY: Bool;
    public var paletteBankIndex: Int;
    
    public var palette(get, never): Array<Rgb>;
    
    public var layers: Array<EdgLayer>;
    public var numLayers(get, never): Int;
        
    public function new(parent : EdgImage) 
    {
        this.parent = parent;
        
        bitDepth = 8;
        isTransparent = false;
        isAbailable = true;
        isChild = false;
        x = 0;
        y = 0;
        isRelativeX = false;
        isRelativeY = false;
        
        layers = [];
    }
    
    public function get_palette() : Array<Rgb>
    {
        return parent.paletteBank[parent.isEachPalette ? paletteBankIndex : 0];
    }
    
    
    public function getRbgaPalette() : Array<Rgba>
    {
        var rgbaPalette = new Array<Rgba>();
        var currentPalette = palette;
        
        var currerntTransparentColorIndex = parent.isEachPalette ? transparentColorIndex : parent.transparentColorIndex;
        
        for (i in 0 ... currentPalette.length) {
            rgbaPalette[i] = currentPalette[i];
            
            if (isTransparent && (i == currerntTransparentColorIndex)) {
                rgbaPalette[i].alpha = 0;
            }
        }
        
        return rgbaPalette;
    }
    
    public function getRgbaImageData() : Array<Rgba>
    {
        var rgbaImage = new Array<Rgba>();
        
        for (i in 0 ... numLayers) {
            var layerIndex = numLayers - 1 - i; // reverse for merge [numLayers-1 ... 0]
            var layer = layers[layerIndex];
            
            if (layer.visible) {
                var layerImage = layer.getRgbaImageData();
                for (pos in 0 ... layerImage.length) {
                    rgbaImage[pos] = layerImage[pos];
                }
            }
        }
        
        return rgbaImage;
    }
    
    public function get_numLayers() : Int
    {
        return layers.length;
    }
    
}