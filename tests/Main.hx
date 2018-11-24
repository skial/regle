package ;

import tink.unit.*;
import tink.testrunner.*;

class Main {

    public static function main() {
        Runner.run(TestBatch.make([
            //new HashidsSpec(),
            /*new OptimusSpec(),
            new NanoidSpec(),*/
            new hashids.TestSpec(),
        ]));
    }

}