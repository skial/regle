package uhx.uid;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesData;

using StringTools;
using haxe.io.Bytes;

@:forward @:forwardStatics @:notNull enum abstract NanoIntConsts(Int) from Int to Int {
    var Size = 22;
    var Mask = 5;
    var Len = 63;
}

@:structInt class Nanoid {

    private var bytes:BytesData;
    private var id:Bytes;

    public inline function new(size:Int = Size) {
        bytes = uhx.uid.util.SecureRandom.random(size).getData();
        id = Bytes.alloc(size);
        for (i in 0...size) {
            id.set( i, Alphabet.fastCodeAt(bytes.fastGet(i)&Len) );

        }
    }

    public inline function toString():String {
        return id.toString();
    }

    //

    public static final Url = 'ModuleSymbhasOwnPr-0123456789ABCDEFGHIJKLNQRTUVWXYZ_cfgijkpqtvxz';
    public static final Alphabet = '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

    public static function generate(alphabet:String, size:Int):String {
        var masks = initMasks(size);
        var mask = getMask(alphabet, masks);
        var ceilArg = 1.6 * (mask*size) / (alphabet.length);
        var step = Math.ceil(ceilArg);

        var id = Bytes.alloc(size);
        var bytes = uhx.uid.util.SecureRandom.random(step).getData();

        var idx = 0;
        while (true) {
            for (i in 0...step) {
                var currentByte = bytes.fastGet(i) & mask;
                if (currentByte < alphabet.length) {
                    id.set(idx, alphabet.fastCodeAt(currentByte));
                    idx++;
                    if (idx == size) return id.toString();

                }

            }

        }        

        return '';
    }

    public static function initMasks(size:Int = Mask):Vector<Int> {
        var masks = new Vector(size);
        for (i in 0...size) {
            masks.set(i, (2 << (i+3)) - 1) ;
        }
        return masks;
    }

    public static function getMask(alphabet:String, masks:Vector<Int>):Int {
        for (i in 0...masks.length) {
            var current = masks[i];
            if (current >= alphabet.length - 1) return current;
        }
        return 0;
    }

}