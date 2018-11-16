package ;

import uhx.uid.Hashids;
import tink.unit.Benchmark;

class HashidsBench implements Benchmark {

    public static var lib_hashids = new Hashids();
    public static var uhx_hashids = new uhx.uid.Hashids.UhxHashids();

    public function new() {}

    @:benchmark(10000) public function benchHashIds_Lib_encode() {
        lib_hashids.encode([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
    }

    @:benchmark(10000) public function benchHashIds_Uhx_encode() {
        uhx_hashids.encode([5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5]);
    }

}