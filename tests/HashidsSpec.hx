package ;

import tink.unit.*;
import uhx.uid.Hashids;

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

}