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

package hxpixel.images.utils;

import hxpixel.images.file.PixelArtFileType;

import haxe.io.Bytes;

class FileUtils
{

    public static function distinctPixelArtFileType(bytes: Bytes): PixelArtFileType
    {
        var signature = bytes.getInt32(0);
        
        switch(signature) {
            case 0x45474445: // EDGE
                return PixelArtFileType.Edge;
            
            case 0x656c6147: // Gale
                return PixelArtFileType.Gale;
            
            case 0x38464947: // GIG8
                return PixelArtFileType.Gif;
                
            case 0x474e5089: // \x89PNG
                return PixelArtFileType.Png;
            
            case 0x53504238: // 8BPS
                return PixelArtFileType.Psd;
            
            default:
                return PixelArtFileType.Unknown;
        }
    }
    
}