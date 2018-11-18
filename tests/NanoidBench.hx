package ;

import tink.unit.Benchmark;

class NanoidBench implements Benchmark {

    public function new() {}

    @:benchmark(10000) public function nanoid_default() {
        new uhx.uid.Nanoid().toString();
    }

    @:benchmark(10000) public function nanoid_customAlphabet() {
        uhx.uid.Nanoid.generate('abcdefghijklmnopqrstuvwxyz', 5);
    }

}