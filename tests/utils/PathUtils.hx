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

package tests.utils;


class PathUtils
{
    public static inline var PATH_DIR_ASSET_EDG = "./samples/assets/edg/";
    public static inline var PATH_DIR_ASSET_GAL = "./samples/assets/gal/";
    public static inline var PATH_DIR_ASSET_GIF = "./samples/assets/gif/";
    public static inline var PATH_DIR_ASSET_PNG = "./samples/assets/png/";
    public static inline var PATH_DIR_ASSET_PSD = "./samples/assets/psd/";

    public static function removeFileExtension(fileName : String) : String
    {
        var reg = ~/\.[0-9a-zA-Z]+$/;
        return reg.replace(fileName, "");
    }
    
}