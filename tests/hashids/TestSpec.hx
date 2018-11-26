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
		return assert(num_to_hash == b[0]);
	}
	
    @:variant(new uhx.uid.Hashids('this is my pepper'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my pepper'))
    @:variant(new uhx.uid.HashidsV('this is my pepper'))
	public function testWrongDecoding(a:HashidLike) {
		var b = a.decode('NkK9');
		return assert(0 == b.length);
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
		return asserts.done();
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
		return asserts.done();
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
		return asserts.done();
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
		return asserts.done();
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
		return asserts.done();
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
		return asserts.done();
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
		return asserts.done();
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
		return asserts.done();
	}

	// @see https://github.com/ivanakimov/hashids.js/blob/master/tests/custom-salt.js

	@:variant(new uhx.uid.Hashids(''))
    @:variant(new uhx.uid.Hashids.UhxHashids(''))
    @:variant(new uhx.uid.HashidsV(''))
	@:variant(new uhx.uid.Hashids('   '))
    @:variant(new uhx.uid.Hashids.UhxHashids('   '))
    @:variant(new uhx.uid.HashidsV('   '))
	@:variant(new uhx.uid.Hashids('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.Hashids.UhxHashids('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.HashidsV('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
	@:variant(new uhx.uid.Hashids('`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.Hashids.UhxHashids('`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.HashidsV('`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
	public function testCustomSalt_jsRepo(hash:HashidLike) {
		var numbers = [1, 2, 3];
		var id = hash.encode(numbers);
		var decodedNumbers = hash.decode(id);

		asserts.assert('$numbers' == '$decodedNumbers');
		return asserts.done();
	}

	// @see https://github.com/ivanakimov/hashids.js/blob/master/tests/custom-alphabet.js

	@:variant(new uhx.uid.Hashids('', 0, 'abdegjklCFHISTUc'))
    @:variant(new uhx.uid.Hashids.UhxHashids('', 0, 'abdegjklCFHISTUc'))
    @:variant(new uhx.uid.HashidsV('', 0, 'abdegjklCFHISTUc'))
	@:variant(new uhx.uid.Hashids('', 0, 'abdegjklmnopqrSF'))
    @:variant(new uhx.uid.Hashids.UhxHashids('', 0, 'abdegjklmnopqrSF'))
    @:variant(new uhx.uid.HashidsV('', 0, 'abdegjklmnopqrSF'))
	@:variant(new uhx.uid.Hashids('', 0, 'abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890'))
    @:variant(new uhx.uid.Hashids.UhxHashids('', 0, 'abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890'))
    @:variant(new uhx.uid.HashidsV('', 0, 'abdegjklmnopqrvwxyzABDEGJKLMNOPQRVWXYZ1234567890'))
	@:variant(new uhx.uid.Hashids('', 0, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.Hashids.UhxHashids('', 0, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.HashidsV('', 0, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
	@:variant(new uhx.uid.Hashids('', 0, '`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.Hashids.UhxHashids('', 0, '`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
    @:variant(new uhx.uid.HashidsV('', 0, '`~!@#$%^&*()-_=+\\|\'";:/?.>,<{[}]'))
	public function testCustomAlphabet_jsRepo(hash:HashidLike) {
		var numbers = [1, 2, 3];
		var id = hash.encode(numbers);
		var decodedNumbers = hash.decode(id);

		asserts.assert('$numbers' == '$decodedNumbers');
		return asserts.done();
	}

	// @see https://github.com/ivanakimov/hashids.js/blob/master/tests/min-length.js

	@:variant(new uhx.uid.Hashids('', 0), 0)
    @:variant(new uhx.uid.Hashids.UhxHashids('', 0), 0)
    @:variant(new uhx.uid.HashidsV('', 0), 0)
	@:variant(new uhx.uid.Hashids('', 1), 1)
    @:variant(new uhx.uid.Hashids.UhxHashids('', 1), 1)
    @:variant(new uhx.uid.HashidsV('', 1), 1)
	@:variant(new uhx.uid.Hashids('', 10), 10)
    @:variant(new uhx.uid.Hashids.UhxHashids('', 10), 10)
    @:variant(new uhx.uid.HashidsV('', 10), 10)
	@:variant(new uhx.uid.Hashids('', 999), 999)
    @:variant(new uhx.uid.Hashids.UhxHashids('', 999), 999)
    @:variant(new uhx.uid.HashidsV('', 999), 999)
	@:variant(new uhx.uid.Hashids('', 1000), 1000)
    @:variant(new uhx.uid.Hashids.UhxHashids('', 1000), 1000)
    @:variant(new uhx.uid.HashidsV('', 1000), 1000)
	public function testCustomMinLength_jsRepo(hash:HashidLike, minLength:Int) {
		var numbers = [1, 2, 3];
		var id = hash.encode(numbers);
		var decodedNumbers = hash.decode(id);

		asserts.assert('$numbers' == '$decodedNumbers');
		asserts.assert(id.length >= minLength);
		return asserts.done();
	}

	// @see https://github.com/ivanakimov/hashids.js/blob/master/tests/custom-params.js

	private static var _paramMap:Map<String, Array<Int>> = [
		'nej1m3d5a6yn875e7gr9kbwpqol02q' => [0],
		'dw1nqdp92yrajvl9v6k3gl5mb0o8ea' => [1],
		'onqr0bk58p642wldq14djmw21ygl39' => [928728],
		'18apy3wlqkjvd5h1id7mn5ore2d06b' => [1, 2, 3],
		'o60edky1ng3vl9hbfavwr5pa2q8mb9' => [1, 0, 0],
		'o60edky1ng3vlqfbfp4wr5pa2q8mb9' => [0, 0, 1],
		'qek2a08gpl575efrfd7yomj9dwbr63' => [0, 0, 0],
		'op7qrcdc3cgc2c0cbcrcoc5clce4d6' => [5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5],
		'mmmykr5nuaabgwnohmml6dakt00jmo3ainnpy2mk' => [1000000001, 1000000002, 1000000003, 1000000004, 1000000005],
		'w1hwinuwt1cbs6xwzafmhdinuotpcosrxaz0fahl' => [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]
	];

	/*private static var _larger:Map<String, Array<Float>> = [
		'm3d5a6yn875rae8y81a94gr9kbwpqo' => [1000000000000],
		'1q3y98ln48w96kpo0wgk314w5mak2d' => [9007199254740991],
		'5430bd2jo0lxyfkfjfyojej5adqdy4' => [10000000000, 0, 0, 0, 999999999999999],
		'aa5kow86ano1pt3e1aqm239awkt9pk380w9l3q6' => [9007199254740991, 9007199254740991, 9007199254740991],
	];*/

	@:variant(new uhx.uid.Hashids('this is my salt', 30, 'xzal86grmb4jhysfoqp3we7291kuct5iv0nd'))
    @:variant(new uhx.uid.Hashids.UhxHashids('this is my salt', 30, 'xzal86grmb4jhysfoqp3we7291kuct5iv0nd'))
    @:variant(new uhx.uid.HashidsV('this is my salt', 30, 'xzal86grmb4jhysfoqp3we7291kuct5iv0nd'))
	public function testCustomMap_jsRepo(hash:HashidLike) {
		for (key in _paramMap.keys()) {
			var numbers = _paramMap.get(key);
			var id = hash.encode(numbers);
			var decodedNumbers = hash.decode(id);

			asserts.assert( id == key );
			asserts.assert( '$numbers' == '$decodedNumbers' );
			asserts.assert( id.length >= 30 );

		}

		return asserts.done();
	}

	// @see https://github.com/ivanakimov/hashids.js/blob/master/tests/bad-input.js

	@:variant(() -> new uhx.uid.Hashids('', 0, '1234567890'), 'Alphabet must contain at least 16 unique characters.')
    @:variant(() -> new uhx.uid.Hashids.UhxHashids('', 0, '1234567890'), 'error: alphabet must contain at least 16 unique characters')
    @:variant(() -> new uhx.uid.HashidsV('', 0, '1234567890'), 'error: alphabet must contain at least 16 unique characters')
	@:variant(() -> new uhx.uid.Hashids('', 0, 'a cdefghijklmnopqrstuvwxyz'), 'Alphabet cannot contains spaces.')
    @:variant(() -> new uhx.uid.Hashids.UhxHashids('', 0, 'a cdefghijklmnopqrstuvwxyz'), 'error: alphabet cannot contain spaces')
    @:variant(() -> new uhx.uid.HashidsV('', 0, 'a cdefghijklmnopqrstuvwxyz'), 'error: alphabet cannot contain spaces')
	public function testBadInput_jsRepo0(make:Void->HashidLike, message:String, ?pos:haxe.PosInfos) {
		try {
			cast make();
			asserts.fail(tink.core.Error.withData(-1, 'Should not have reached this point.', pos));
		} catch (e:Any) {
			asserts.assert( e == message );
		}
		return asserts.done();
	}

	@:variant(new uhx.uid.Hashids(), [], '')
    @:variant(new uhx.uid.Hashids.UhxHashids(), [], '')
    @:variant(new uhx.uid.HashidsV(), [], '')
	@:variant(new uhx.uid.Hashids(), [-1], '')
	@:variant(new uhx.uid.Hashids.UhxHashids(), [-1], '')
	@:variant(new uhx.uid.HashidsV(), [-1], '')
	public function testBadInput_encode_jsRepo1(hash:HashidLike, values:Array<Int>, expected:String) {
		asserts.assert(hash.encode(values) == expected);
		return asserts.done();
	}

	@:variant(new uhx.uid.Hashids(), '[]', '')
    @:variant(new uhx.uid.Hashids.UhxHashids(), '[]', '')
    @:variant(new uhx.uid.HashidsV(), '[]', '')
	@:variant(new uhx.uid.Hashids(), '[]', 'f')
	@:variant(new uhx.uid.Hashids.UhxHashids(), '[]', 'f')
	@:variant(new uhx.uid.HashidsV(), '[]', 'f')
	public function testBadInput_decode_jsRepo1(hash:HashidLike, expected:String, value:String) {
		asserts.assert('${hash.decode(value)}' == expected);
		return asserts.done();
	}

}