package ;

import tink.unit.*;
import haxe.io.Bytes;
import tink.unit.Assert.*;
import uhx.uid.Hashids;
import uhx.uid.HashidsV;

@:asserts class HashidsSpec {
    
    public function new() {
        
    }

	@:variant(new uhx.uid.Hashids())
    @:variant(new uhx.uid.Hashids.UhxHashids())
    @:variant(new uhx.uid.HashidsV())
	public function test123_Basic(hashid:HashidLike) {
		asserts.assert( 'o2fXhV' == hashid.encode([1, 2, 3]) );
		asserts.assert( '' + [1, 2, 3] == '' + hashid.decode( 'o2fXhV' ) );
	}

	@:variant(new uhx.uid.Hashids('this is my salt', 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt', 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"))
    @:variant(new uhx.uid.HashidsV('this is my salt', 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"))
	public function test123_Custom(hashid:HashidLike) {
		asserts.assert( 'GlaHquq0' == hashid.encode([1, 2, 3]) );
		asserts.assert( '' + [1, 2, 3] == '' + hashid.decode( 'GlaHquq0' ) );
	}

	public function testConsistentShuffle() @:privateAccess {
		var h = new Hashids();
		var u = new uhx.uid.Hashids.UhxHashids();
		var a = Bytes.ofString('cfhistuCFHISTU');
		var s = Bytes.ofString('this is my salt');

		asserts.assert( h.consistentShuffle('cfhistuCFHISTU', 'this is my salt') == u.consistentShuffle('cfhistuCFHISTU', 'this is my salt') );
		asserts.assert( h.consistentShuffle('cfhistuCFHISTU', 'this is my salt') == HashidsV.consistentShuffle(a, s, a.length, s.length).toString() );
	}

	public function testHash() @:privateAccess {
		var h = new Hashids();
		var u = new uhx.uid.Hashids.UhxHashids();
		var a = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

		asserts.assert( h.hash(97, a) == u.hash(97, a) );
		asserts.assert( HashidsV.toAlphabet(97, Bytes.ofString(a), a.length ) == h.hash(97, a) );
	}

	public function testHashids_encodeBytes() @:privateAccess {
		var h = new Hashids();
		var y = new uhx.uid.HashidsV();
		var u = new uhx.uid.Hashids.UhxHashids();

		asserts.assert( h.alphabet == u.alphabet );
		asserts.assert( h.salt == u.salt );
		asserts.assert( u.alphabet == y.alphabetBytes.toString() );
		asserts.assert( u.salt == y.saltBytes.toString() );

		asserts.assert( 'o2fXhV' == h.encode([1, 2, 3]) );
		asserts.assert( 'o2fXhV' == u.encode([1, 2, 3]) );
		asserts.assert( 'o2fXhV' == y.encode([1, 2, 3]) );
	}

	public function testHashids_decodeBytes() @:privateAccess {
		var h = new Hashids();
		var y = new uhx.uid.HashidsV();
		var u = new uhx.uid.Hashids.UhxHashids();

		asserts.assert( '' + h.decode('o2fXhV') == '' + [1, 2, 3] );
		asserts.assert( '' + u.decode('o2fXhV') == '' + [1, 2, 3] );
		asserts.assert( '' + y.decode('o2fXhV') == '' + [1, 2, 3] );
	}

}