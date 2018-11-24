package hashids;

import tink.unit.*;
import tink.unit.Assert.*;

// Originally from https://github.com/kevinresol/hashids/blob/master/tests/Test.hx
@:asserts class TestSpec {
	
    public function new() {}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	public function testBasic(a:HashidLike) {
		var num_to_hash = 900719925;
		var res = a.encode([num_to_hash]);
		var b = a.decode(res);
		assert(num_to_hash == b[0]);
	}
	
    @:variant(new uhx.uid.Hashids('this is my pepper'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my pepper'))
    @:variant(new uhx.uid.HashidsV('this is my pepper'))
	public function testWrongDecoding(a:HashidLike) {
		var b = a.decode('NkK9');
		assert(0 == b.length);
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	public function testOneNumber(a:HashidLike) {
		var expected = 'NkK9';
		var num_to_hash = 12345;
		
		var res = a.encode([num_to_hash]);
		asserts.assert(expected == res);
		
		var res2 = a.decode(expected);
		asserts.assert(1 == res2.length);
		asserts.assert(num_to_hash == res2[0]);
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	public function testServeralNumbers(a:HashidLike) {
		var expected = 'aBMswoO2UB3Sj';
		var num_to_hash = [683, 94108, 123, 5];
		
		var res = a.encode(num_to_hash);
		asserts.assert(expected == res);
		
		var res2 = a.decode(expected);
		asserts.assert(num_to_hash.length == res2.length);
		for(i in 0...res.length)
			asserts.assert(num_to_hash[i] == res2[i]);
	}

    @:variant(new uhx.uid.Hashids('this is my salt', 0, '0123456789abcdef'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt', 0, '0123456789abcdef'))
    @:variant(new uhx.uid.HashidsV('this is my salt', 0, '0123456789abcdef'))
	public function testSpecifyingCustomHashAlphabet(a:HashidLike) {
		var expected = 'b332db5';
		var num_to_hash = [1234567];
		
		var res = a.encode(num_to_hash);
		asserts.assert(expected == res);
		
		var res2 = a.decode(expected);
		asserts.assert(num_to_hash[0] == res2[0]);
	}

    @:variant(new uhx.uid.Hashids('this is my salt', 8))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt', 8))
    @:variant(new uhx.uid.HashidsV('this is my salt', 8))
	public function testSpecifyingCustomHashLength(a:HashidLike) {
		var expected = 'gB0NV05e';
		var num_to_hash = [1];
		
		var res = a.encode(num_to_hash);
		asserts.assert(expected == res);
		
		var res2 = a.decode(expected);
		asserts.assert(1 == res2.length);
		asserts.assert(num_to_hash[0] == res2[0]);
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	public function testRandomness(a:HashidLike) {
		var expected = '1Wc8cwcE', res;
		var num_to_hash = [5, 5, 5, 5];
		
		var res = a.encode(num_to_hash);
		asserts.assert(expected == res);
		
		var res2 = a.decode(expected);
		asserts.assert(num_to_hash.length == res2.length);
		for(i in 0...res.length)
			asserts.assert(num_to_hash[i] == res2[i]);
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	public function testRandomnessForIncrementingNumbers(a:HashidLike) {
		var expected = 'kRHnurhptKcjIDTWC3sx';
		var num_to_hash = [1,2,3,4,5,6,7,8,9,10];
		
		var res = a.encode(num_to_hash);
		asserts.assert(expected == res);
		
		var res2 = a.decode(expected);
		asserts.assert(res2.length == num_to_hash.length);
		for(i in 0...res.length)
			asserts.assert(num_to_hash[i] == res2[i]);
	}

    @:variant(new uhx.uid.Hashids('this is my salt'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt'))
    @:variant(new uhx.uid.HashidsV('this is my salt'))
	public function testRandomnessForIncrementing(a:HashidLike) {
		asserts.assert('NV' == a.encode([1]));
		asserts.assert('6m' == a.encode([2]));
		asserts.assert('yD' == a.encode([3]));
		asserts.assert('2l' == a.encode([4]));
		asserts.assert('rD' == a.encode([5]));
	}

    @:variant(new uhx.uid.Hashids('MyCamelCaseSalt', 10, 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'))
    @:variant(new uhx.uid.Hashids.UhxHashids('MyCamelCaseSalt', 10, 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'))
    @:variant(new uhx.uid.HashidsV('MyCamelCaseSalt', 10, 'ABCDEFGHIJKLMNPQRSTUVWXYZ123456789'))
	public function testAlphabetWithoutO0(a:HashidLike) {
		var expected = '9Q7MJ3LVGW';
		var num_to_hash = [1145];
		
		var res = a.encode(num_to_hash);
		asserts.assert(expected == res);
		
		var res2:Array<Int> = a.decode(expected);
		asserts.assert(num_to_hash[0] == res2[0]);
	}
}