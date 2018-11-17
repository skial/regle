package ;

import uhx.uid.Nanoid;
import tink.unit.Assert.*;
import tink.unit.AssertionBuffer;

using Lambda;

class NanoidSpec {

    public function new() {}

    public function testNanoid() {
        var b = new AssertionBuffer();
        var id = new Nanoid().toString();
        trace( id );
        b.assert( id.length == 22 );
        return b.done();
    }

    public function testNanoid_urlFriendly() {
        var b = new AssertionBuffer();

        for (i in 0...100) {
            var id = new Nanoid().toString();
            if (id.length != 22) b.fail( 'Nanoid length not equal to 22. Generated ID was $id, with length of ${id.length}' );
            for (j in 0...id.length) {
                if (Nanoid.Url.indexOf(id.charAt(j)) == -1) b.fail( 'Nanoid doesnt contain url safe character.' );
            }
            
        }

        return b.done();
    }

    public function testNanoid_customAlphabet() {
        return assert( Nanoid.generate('a', 5) == 'aaaaa' );
    }

    // @:see https://github.com/ai/nanoid/blob/master/test/generate.test.js
    public function testNanoid_hashFlatDistribution() {
        var length = 5;
        var count = 100 * 1000;
        var chars = new Map<String,Int>();
        var buffer = new AssertionBuffer();
        var alphabet = 'abcdefghijklmnopqrstuvwxyz';

        for (i in 0...count) {
            var id = Nanoid.generate(alphabet, length);

            for (j in 0...id.length) {
                var char = id.charAt(j);
                if (!chars.exists(char)) chars.set(char, 0);
                chars.set(char, chars.get(char) + 1);

            }

        }

        buffer.assert([for (k in chars.keys()) k].length == alphabet.length );

        var max:Float = 0;
        var min:Float = 9007199254740991; // This is gonna break! Meant to be max int.

        for (key in chars.keys()) {
            var distribution = (chars.get(key) * alphabet.length) / (count * length);
            if (distribution > max) max = distribution;
            if (distribution < min) min = distribution;
        }

        buffer.assert((max - min) <= 0.05);

        return buffer.done();
    }

}