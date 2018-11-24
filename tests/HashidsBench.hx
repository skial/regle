package ;

import haxe.io.Bytes;
import uhx.uid.Hashids;
import tink.unit.Benchmark;

class HashidsBench implements Benchmark {

    public static var lib_hashids = new Hashids();
    public static var uhx_hashids = new uhx.uid.Hashids.UhxHashids();
    public static var byte_hashids = new uhx.uid.HashidsV();

    public static var seps = 'cfhistuCFHISTU';
    public static var salt = 'this is my salt';

    public function new() {}

    @:benchmark(10000) public function hashIds_Lib_encode() {
        lib_hashids.encode([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
    }

    @:benchmark(10000) public function hashIds_Lib_decode() {
        lib_hashids.decode('BrtltWt2tyt1tvt7tJt2t1tD');
    }

    @:benchmark(10000) public function HashIds_Uhx_encode() {
        uhx_hashids.encode([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
    }

    @:benchmark(10000) public function hashIds_Uhx_decode() {
        uhx_hashids.decode('BrtltWt2tyt1tvt7tJt2t1tD');
    }

    @:benchmark(10000) public function hashIds_Byte_encode() {
        byte_hashids.encode([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
    }

    @:benchmark(10000) public function hashIds_Byte_decode() {
        byte_hashids.decode('BrtltWt2tyt1tvt7tJt2t1tD');
    }

    @:benchmark(10000) public function hashIds_Lib_shuffle() @:privateAccess {
        lib_hashids.consistentShuffle(seps, salt);
    }

    @:benchmark(10000) public function hashIds_Uhx_shuffle() @:privateAccess {
        uhx_hashids.consistentShuffle(seps, salt);
    }

    @:benchmark(10000) public function hashIds_Bytes_shuffle() @:privateAccess {
        uhx.uid.HashidsV.consistentShuffle(Bytes.ofString(seps), Bytes.ofString(salt), seps.length, salt.length);
    }

    @:benchmark(10000) public function hashIds_Lib_toAlphabet() @:privateAccess {
        lib_hashids.hash(97, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890');
    }

    @:benchmark(10000) public function hashIds_Uhx_toAlphabet() @:privateAccess {
        uhx_hashids.hash(97, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890');
    }

    @:benchmark(10000) public function hashIds_Bytes_toAlphabet() @:privateAccess {
        uhx.uid.HashidsV.toAlphabet(97, Bytes.ofString('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'), 62);
    }


}