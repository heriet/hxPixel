package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxpixel.images.gal.GalDecoder;
import hxpixel.images.gal.GalImage;

@:expose("GalDecoder")
class ExposeGalDecoder
{

    public static function decode(bytesData:BytesData): GalImage
    {
        return GalDecoder.decode(Bytes.ofData(bytesData));
    }
    
}