package uhx.uid.util;

import haxe.crypto.Sha256;
import haxe.io.Bytes;

// Originally taken from haxe-crypto
// @see https://github.com/soywiz/haxe-crypto/blob/master/src/com/hurlant/crypto/prng/SecureRandom.hx
class SecureRandom {
    public static inline function random(length:Int):Bytes {
        #if flash
            return Bytes.ofData(untyped __global__["flash.crypto.generateRandomBytes"](length));
        #elseif js
            #if hxnodejs
            return js.node.Crypto.randomBytes(length).hxToBytes();
            #else
            return Bytes.ofData( js.Browser.window.crypto.getRandomValues( new js.html.Uint8Array(Bytes.alloc(length).getData()) ).buffer );
            #end
        #elseif php
            // http://php.net/manual/en/function.random-bytes.php
            return Bytes.ofData( (php.Syntax.code('random_bytes({0})', length):String) );
        #elseif python
            return Bytes.ofData( OS.urandom(length) );
        #elseif java
            return Bytes.ofData(java.security.SecureRandom.getSeed(length));
        #elseif cs
            var out = Bytes.alloc(length);
            var rng = new cs.system.security.cryptography.RNGCryptoServiceProvider();
            rng.GetBytes(out.getData());
            return out;
        #elseif sys
            // https://en.wikipedia.org/wiki//dev/random
            var out = Bytes.alloc(length);
            var input = sys.io.File.read( (Sys.systemName() == 'Windows') ? "\\Device\\KsecDD" : "/dev/urandom");
            input.readBytes(out, 0, length);
            input.close();
            return out;
        #else
            //#error "Target not supported.";
            throw "Target is not supported.";
        #end
    }
}

#if hl
@:hlNative("ssl")
class SSL {

}
/*
mbedtls_ctr_drbg_random
mbedtls_hmac_drbg_random
*/
#end

#if python
@:pythonImport("os")
extern class OS {
    static public function urandom(count:Int):python.Bytes;
}
#end