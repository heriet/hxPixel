package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.gif.GifInfo;

@:expose("GifDecoder")
class ExposeGifDecoder
{

    public static function decode(bytesData:BytesData): GifInfo
    {
        return GifDecoder.decode(Bytes.ofData(bytesData));
    }
    
}