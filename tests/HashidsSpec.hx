package ;

import utest.Assert;
import uhx.uid.Hashids;

@:keep class HashidsSpec {
    
    public function new() {
        
    }

	public function test123_Basic() {
		var hashid = new Hashids();
		Assert.equals( 'o2fXhV', hashid.encode([1, 2, 3]) );
		Assert.equals( '' + [1, 2, 3], '' + hashid.decode( 'o2fXhV' ) );
	}

	public function test123_Custom() {
		var hashid = new Hashids('this is my salt', 8, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890");
		Assert.equals( 'GlaHquq0', hashid.encode([1, 2, 3]) );
		Assert.equals( '' + [1, 2, 3], '' + hashid.decode( 'GlaHquq0' ) );
	}

}