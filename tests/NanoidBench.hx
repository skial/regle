package ;

import tink.unit.Benchmark;

class NanoidBench implements Benchmark {

    public function new() {}

    @:benchmark(10000) public function nanoid_default_bench() {
        new uhx.uid.Nanoid().toString();
    }

}