package ;

import tink.unit.*;
import haxe.io.Bytes;
import tink.unit.Assert.*;
import uhx.uid.Hashids;
import uhx.uid.HashidsV;

@:keep class HashidsSpec {
    
    public function new() {
        
    }

	public function test123_Basic() {
		var hashid = new Hashids();
		var b = new AssertionBuffer();
		b.assert( 'o2fXhV' == hashid.encode([1, 2, 3]) );
		b.assert( '' + [1, 2, 3] == '' + hashid.decode( 'o2fXhV' ) );
		return b.done();
	}

	public function test123_Custom() {
		var hashid = new Hashids('this is my salt', 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890");
		var b = new AssertionBuffer();
		b.assert( 'GlaHquq0' == hashid.encode([1, 2, 3]) );
		b.assert( '' + [1, 2, 3] == '' + hashid.decode( 'GlaHquq0' ) );
		return b.done();
	}

	public function testConsistentShuffle() @:privateAccess {
		var h = new Hashids();
		var b = new AssertionBuffer();
		var u = new uhx.uid.Hashids.UhxHashids();
		var a = Bytes.ofString('cfhistuCFHISTU');
		var s = Bytes.ofString('this is my salt');

		b.assert( h.consistentShuffle('cfhistuCFHISTU', 'this is my salt') == u.consistentShuffle('cfhistuCFHISTU', 'this is my salt') );
		b.assert( h.consistentShuffle('cfhistuCFHISTU', 'this is my salt') == HashidsV.consistentShuffle(a, s, a.length, s.length).toString() );

		return b.done();
	}

	public function testHash() @:privateAccess {
		var h = new Hashids();
		var b = new AssertionBuffer();
		var u = new uhx.uid.Hashids.UhxHashids();
		var a = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

		b.assert( h.hash(97, a) == u.hash(97, a) );
		b.assert( HashidsV.toAlphabet(97, Bytes.ofString(a), a.length ) == h.hash(97, a) );

		return b.done();
	}

	public function testHashids_encodeBytes() @:privateAccess {
		var h = new Hashids();
		var b = new AssertionBuffer();
		var y = new uhx.uid.HashidsV();
		var u = new uhx.uid.Hashids.UhxHashids();

		b.assert( h.alphabet == u.alphabet );
		b.assert( h.salt == u.salt );
		b.assert( u.alphabet == y.alphabetBytes.toString() );
		b.assert( u.salt == y.saltBytes.toString() );

		b.assert( 'o2fXhV' == h.encode([1, 2, 3]) );
		b.assert( 'o2fXhV' == u.encode([1, 2, 3]) );
		b.assert( 'o2fXhV' == y.encode([1, 2, 3]) );

		return b.done();
	}

	public function testHashids_decodeBytes() @:privateAccess {
		var h = new Hashids();
		var b = new AssertionBuffer();
		var y = new uhx.uid.HashidsV();
		var u = new uhx.uid.Hashids.UhxHashids();

		b.assert( '' + h.decode('o2fXhV') == '' + [1, 2, 3] );
		b.assert( '' + u.decode('o2fXhV') == '' + [1, 2, 3] );
		b.assert( '' + y.decode('o2fXhV') == '' + [1, 2, 3] );

		return b.done();
	}

}