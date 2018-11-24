package hashids;

import tink.unit.*;
import tink.unit.Assert.*;

typedef HashidLike = {
    function encode(v:Array<Int>):String;
	function decode(h:String):Array<Int>;
};

// Originally from https://github.com/kevinresol/hashids/blob/master/tests/Test.hx
@:publicFields class TestSpec {
	
    public function new() {}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	function testBasic(a:HashidLike) {
		var num_to_hash = 900719925;
		var res = a.encode([num_to_hash]);
		var b = a.decode(res);
		return assert(num_to_hash == b[0]);
	}
	
    @:variant(new uhx.uid.Hashids('this is my pepper'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my pepper'))
    @:variant(new uhx.uid.HashidsV('this is my pepper'))
	function testWrongDecoding(a:HashidLike) {
		var b = a.decode('NkK9');
		return assert(0 == b.length);
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	function testOneNumber(a:HashidLike) {
		var expected = 'NkK9';
		var num_to_hash = 12345;
        var b = new AssertionBuffer();
		
		var res = a.encode([num_to_hash]);
		b.assert(expected == res);
		
		var res2 = a.decode(expected);
		b.assert(1 == res2.length);
		b.assert(num_to_hash == res2[0]);
        return b.done();
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	function testServeralNumbers(a:HashidLike) {
		var expected = 'aBMswoO2UB3Sj';
		var num_to_hash = [683, 94108, 123, 5];
        var b = new AssertionBuffer();
		
		var res = a.encode(num_to_hash);
		b.assert(expected == res);
		
		var res2 = a.decode(expected);
		b.assert(num_to_hash.length == res2.length);
		for(i in 0...res.length)
			b.assert(num_to_hash[i] == res2[i]);

        return b.done();
	}

    @:variant(new uhx.uid.Hashids('this is my salt', 0, '0123456789abcdef'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt', 0, '0123456789abcdef'))
    @:variant(new uhx.uid.HashidsV('this is my salt', 0, '0123456789abcdef'))
	function testSpecifyingCustomHashAlphabet(a:HashidLike) {
		var expected = 'b332db5';
		var num_to_hash = [1234567];
        var b = new AssertionBuffer();
		
		var res = a.encode(num_to_hash);
		b.assert(expected == res);
		
		var res2 = a.decode(expected);
		b.assert(num_to_hash[0] == res2[0]);

        return b.done();
	}

    @:variant(new uhx.uid.Hashids('this is my salt', 8))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt', 8))
    @:variant(new uhx.uid.HashidsV('this is my salt', 8))
	function testSpecifyingCustomHashLength(a:HashidLike) {
		var expected = 'gB0NV05e';
		var num_to_hash = [1];
        var b = new AssertionBuffer();
		
		var res = a.encode(num_to_hash);
		b.assert(expected == res);
		
		var res2 = a.decode(expected);
		b.assert(1 == res2.length);
		b.assert(num_to_hash[0] == res2[0]);

        return b.done();
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	function testRandomness(a:HashidLike) {
		var expected = '1Wc8cwcE', res;
		var num_to_hash = [5, 5, 5, 5];
        var b = new AssertionBuffer();
		
		var res = a.encode(num_to_hash);
		b.assert(expected == res);
		
		var res2 = a.decode(expected);
		b.assert(num_to_hash.length == res2.length);
		for(i in 0...res.length)
			b.assert(num_to_hash[i] == res2[i]);

        return b.done();
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	function testRandomnessForIncrementingNumbers(a:HashidLike) {
		var expected = 'kRHnurhptKcjIDTWC3sx';
		var num_to_hash = [1,2,3,4,5,6,7,8,9,10];
        var b = new AssertionBuffer();
		
		var res = a.encode(num_to_hash);
		b.assert(expected == res);
		
		var res2 = a.decode(expected);
		b.assert(res2.length == num_to_hash.length);
		for(i in 0...res.length)
			b.assert(num_to_hash[i] == res2[i]);

        return b.done();
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	function testRandomnessForIncrementing(a:HashidLike) {
        var b = new AssertionBuffer();

		b.assert('NV' == a.encode([1]));
		b.assert('6m' == a.encode([2]));
		b.assert('yD' == a.encode([3]));
		b.assert('2l' == a.encode([4]));
		b.assert('rD' == a.encode([5]));

        return b.done();
	}

    @:variant(new uhx.uid.Hashids('MyCamelCaseSalt', 10, 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'))
    @:variant(new uhx.uid.Hashids.UhxHashids('MyCamelCaseSalt', 10, 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'))
    @:variant(new uhx.uid.HashidsV('MyCamelCaseSalt', 10, 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'))
	function testAlphabetWithoutO0(a:HashidLike) {
		var expected = '9Q7MJ3LVGW';
		var num_to_hash = [1145];
        var b = new AssertionBuffer();
		
		var res = a.encode(num_to_hash);
		b.assert(expected == res);
		
		var res2:Array<Int> = a.decode(expected);
		b.assert(num_to_hash[0] == res2[0]);

        return b.done();
	}
}