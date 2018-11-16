package ;

import uhx.uid.Nanoid;
import tink.unit.Assert.*;
import tink.unit.AssertionBuffer;

class NanoidSpec {

    public function new() {}

    public function testNanoid() {
        var b = new AssertionBuffer();
        var id = new Nanoid().toString();
        trace( id );
        b.assert( id.length == 22 );
        return b.done();
    }

}