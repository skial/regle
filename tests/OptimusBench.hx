package ;

import uhx.uid.Optimus;
import tink.unit.Benchmark;

class OptimusBench implements Benchmark {

    public static var optimus = new Optimus(1580030173, 59260789, 1163945558);

    public function new() {}

    @:benchmark(10000) public function optimus_encode() {
        optimus.encode(15);
    }

}