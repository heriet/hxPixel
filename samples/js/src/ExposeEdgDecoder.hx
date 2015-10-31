package;

import haxe.io.Bytes;
import haxe.io.BytesData;
import hxpixel.images.edg.EdgDecoder;
import hxpixel.images.edg.EdgImage;

@:expose("EdgDecoder")
class ExposeEdgDecoder
{

    public static function decode(bytesData:BytesData): EdgImage
    {
        return EdgDecoder.decode(Bytes.ofData(bytesData));
    }
    
}