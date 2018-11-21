package ;

import tink.unit.*;
import tink.testrunner.*;

class Bench {

    public static function main() {
        Runner.run(TestBatch.make([
            new HashidsBench(),
            //new OptimusBench(),
            //new NanoidBench(),
        ]));
    }

}