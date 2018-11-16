package uhx.uid;

import haxe.io.Bytes;
import haxe.io.BytesData;
import uhx.uid.Nanoid.NanoStringConsts.*;

using StringTools;
using haxe.io.Bytes;

class NanoStringConsts {
    public static var Alphabet = '_-0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
}

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

    @:pure public inline function toString():String {
        return id.toString();
    }

}