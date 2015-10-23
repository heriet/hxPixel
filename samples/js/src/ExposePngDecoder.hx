package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxpixel.images.png.PngDecoder;
import hxpixel.images.png.PngInfo;

@:expose("PngDecoder")
class ExposePngDecoder
{

    public static function decode(bytesData:BytesData): PngInfo
    {
        return PngDecoder.decode(Bytes.ofData(bytesData));
    }
    
}