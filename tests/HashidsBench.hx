package ;

import uhx.uid.Hashids;
import tink.unit.Benchmark;

class HashidsBench implements Benchmark {

    public static var lib_hashids = new Hashids();
    public static var uhx_hashids = new uhx.uid.Hashids.UhxHashids();

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

}