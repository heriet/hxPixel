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

import hxpixel.images.edg.EdgImage;
import hxpixel.images.edg.EdgPage;
import hxpixel.images.psd.PsdImage;
import hxpixel.images.psd.PsdLayer;

class PsdConverter
{   
    public static function convertFromEdg(edgImage:EdgImage): PsdImage
    {
        var psdImage = new PsdImage();
        
        if (edgImage.numPages == 1) {
            
            if (edgImage.pages[0].numLayers == 1) {
                convertFromEdgSingle(edgImage, psdImage);
            } else {
                convertFromEdgLayers(edgImage, psdImage);
            }
        } else {
            convertFromEdgPages(edgImage, psdImage);
        }
        
        return psdImage;
    }
    
    static function convertFromEdgSingle(edgImage:EdgImage, psdImage: PsdImage)
    {
        var size = edgImage.getSize();
        
        psdImage.width = size[0];
        psdImage.height = size[1];
        psdImage.numChannels = 4;
        psdImage.colorMode = ColorMode.Rgb;
        psdImage.bitDepth = edgImage.bitDepth;
        
        psdImage.imageData = edgImage.pages[0].getRgbaImageData();
    }
    
    static function convertFromEdgLayers(edgImage:EdgImage, psdImage: PsdImage)
    {
        convertFromEdgSingle(edgImage, psdImage);
        
        addEdgPageLayers(edgImage.pages[0], psdImage);
    }
    
    static function convertFromEdgPages(edgImage:EdgImage, psdImage: PsdImage)
    {
        convertFromEdgSingle(edgImage, psdImage);
        
        for (page in edgImage.pages) {
            
            var pageStart = createGroupStartLayer(psdImage, page.name);
            psdImage.layers.push(pageStart);
            
            addEdgPageLayers(page, psdImage);
            
            var pageEnd = createGroupEndLayer(psdImage);
            psdImage.layers.push(pageEnd);
        }
    }
    
    static function addEdgPageLayers(page: EdgPage, psdImage: PsdImage)
    {
        for (layer in page.layers) {
            var psdLayer = new PsdLayer(psdImage);
            
            psdLayer.type = LayerType.Layer;
            psdLayer.name = layer.name;
            psdLayer.visible = layer.visible;
            psdLayer.isLocked = layer.isLocked;
            
            psdLayer.x = page.x;
            psdLayer.y = page.y;
            psdLayer.width = page.width;
            psdLayer.height = page.height;
            
            psdLayer.numChannels = 4;
            psdLayer.blendMode = "norm";
            psdLayer.opacity = 255;
            psdLayer.clipping = 0;
            psdLayer.flags = 8;
            
            psdLayer.imageData = layer.getRgbaImageData();
            
            psdImage.layers.push(psdLayer);
        }
    }
    
    static function createGroupStartLayer(parent: PsdImage, groupName: String): PsdLayer
    {
        var psdLayer = new PsdLayer(parent);
        psdLayer.type = LayerType.OpenFolder;
        psdLayer.name = groupName;
        
        psdLayer.x = 0;
        psdLayer.y = 0;
        psdLayer.width = 0;
        psdLayer.height = 0;
        
        psdLayer.numChannels = 4;
        psdLayer.blendMode = "norm";
        psdLayer.opacity = 255;
        psdLayer.clipping = 0;
        psdLayer.flags = 24;
        
        return psdLayer;        
    }
    
    static function createGroupEndLayer(parent: PsdImage): PsdLayer
    {
        var psdLayer = new PsdLayer(parent);
        psdLayer.type = LayerType.BoundingSectionDivider;
        psdLayer.name = "</Layer group>";
        
        psdLayer.x = 0;
        psdLayer.y = 0;
        psdLayer.width = 0;
        psdLayer.height = 0;
        
        psdLayer.numChannels = 4;
        psdLayer.blendMode = "norm";
        psdLayer.opacity = 255;
        psdLayer.clipping = 0;
        psdLayer.flags = 24;
        
        return psdLayer;        
    }
    
}