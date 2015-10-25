package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxpixel.images.gif.GifDecoder;
import hxpixel.images.gif.GifImage;

@:expose("GifDecoder")
class ExposeGifDecoder
{

    public static function decode(bytesData:BytesData): GifImage
    {
        return GifDecoder.decode(Bytes.ofData(bytesData));
    }
    
}