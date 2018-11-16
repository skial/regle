package ;

import tink.unit.*;
import uhx.uid.Optimus;
import tink.unit.Assert.*;

using haxe.Int64;

@:keep class OptimusSpec {

    private var optimus = new Optimus(1580030173, 59260789, 1163945558);
    private var primes = [2, 17, 839, 3733, 999983, 15485863, 32452843, 49979687, 67867967, 1580030173, 2123809381];
    private var composites = [1, 4, 18, 25, 838, 3007];

    public function new() {
        
    }

    public function testGcd() {
        return assert( 11 == Optimus.gcd(121, 44).toInt() );
    }

    public function testEgcd() {
        var b = new AssertionBuffer();
        b.assert( '' + [3, 1, 0] == '' + Optimus.egcd(3, 0).map(i->i.toInt()) );
        b.assert( '' + [3, 0, 1] == '' + Optimus.egcd(0, 3).map(i->i.toInt()) );
        b.assert( '' + [21, -16, 27] == '' + Optimus.egcd(1239, 735).map(i->i.toInt()) );
        b.assert( '' + [2, -1, 0] == '' + Optimus.egcd(-2, -6).map(i->i.toInt()) );
        return b.done();
    }

    public function testModInverse() {
        var b = new AssertionBuffer();
        b.assert( 1 == Optimus.modInverse(1, 5).toInt() );
        b.assert( 59260789 == Optimus.modInverse(1580030173, Optimus.MAX_INT + 1).toInt() );
        b.assert( 4 == Optimus.modInverse(30, 17).toInt() );
        b.assert( 4 == Optimus.modInverse(3, 11).toInt() );
        b.assert( 1885413229 == Optimus.modInverse(2123809381, Optimus.MAX_INT + 1).toInt() );

        b.assert( 4 == Optimus.modInverse(3, 11).toInt() );
        b.assert( 4 == Optimus.modInverse(3, 11).toInt() );
        b.assert( 59260789 == Optimus.modInverse(1580030173, Optimus.MAX_INT + 1).toInt() );
        return b.done();
    }

    public function testPower() {
        var b = new AssertionBuffer();
        b.assert( 8 == Optimus.power(2, 3).toInt() );
        b.assert( 3125 == Optimus.power(5, 5).toInt() );
        return b.done();
    }

    public function testPowerMod() {
        var b = new AssertionBuffer();
        b.assert( 1 == Optimus.powerMod(1, -1, 5).toInt() );
        b.assert( 1 == Optimus.powerMod(2, 10, 3).toInt() );
        b.assert( 16 == Optimus.powerMod(2, Optimus.power(10, 9), 18).toInt() );
        b.assert( 6 != Optimus.powerMod(6, 0.5.fromFloat(), 10).toInt() ); // Loss of precision
        b.assert( 445 == Optimus.powerMod(4, 13, 497).toInt() );
        b.assert( 1 == Optimus.powerMod(67430, 499991, 999983).toInt() );
        return b.done();
    }

    public function testDivMod() {
        var b = new AssertionBuffer();
        b.assert( '' + {quotient:3.ofInt(), remainder:1.ofInt()} == '' + Optimus.divMod(10, 3) );
        b.assert( '' + {quotient:2.ofInt(), remainder:0.ofInt()} == '' + Optimus.divMod(12, 6) );
        return b.done();
    }

    public function testMillerRabin() {
        var b = new AssertionBuffer();
        for (i in primes) {
            var r = Optimus.isPrime(i, 4);
            b.assert( true == r/*, 'Primes, value == $i --- Should have been true but was $r.'*/ );
        }

        for (i in composites) {
            var r = Optimus.isPrime(i, 4);
            b.assert( false == r/*, 'Composites, value == $i --- Should have been false but was $r.'*/ );
        }
        return b.done();
    }
    
    public function testEncode() {
        return assert( 1103647397 == optimus.encode(15) );
    }

    public function testDecode() {
        return assert( 15 == optimus.decode(1103647397) );
    }

    public function testConfig() {
        var opt = Optimus.make();
        var encoded = opt.encode(20);
        
        return assert( 20 == opt.decode(encoded) );
    }

}