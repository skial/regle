package ;

import utest.Assert;
import uhx.uid.Optimus;

using haxe.Int64;

@:keep class OptimusSpec {

    private var optimus = new Optimus(1580030173, 59260789, 1163945558);
    private var primes = [2, 17, 839, 3733, 999983, 15485863, 32452843, 49979687, 67867967, 1580030173, 2123809381];
    private var composites = [1, 4, 18, 25, 838, 3007];

    public function new() {
        
    }

    public function testGcd() {
        Assert.equals( 11, Optimus.gcd(121, 44).toInt() );
        trace( Optimus.gcd(1580030173, 2147483647) );
        trace( (4*3) % 11 );
        trace(1580030173, 1/1580030173, 1580030173 * (1/1580030173)); // inverse number
        trace(1580030173, 1/1580030173.ofInt(), 1580030173 * (1/1580030173.ofInt())); // loss of precision
    }

    public function testEgcd() {
        Assert.equals( '' + [3, 1, 0], '' + Optimus.egcd(3, 0).map(i->i.toInt()) );
        Assert.equals( '' + [3, 0, 1], '' + Optimus.egcd(0, 3).map(i->i.toInt()) );
        Assert.equals( '' + [21, -16, 27], '' + Optimus.egcd(1239, 735).map(i->i.toInt()) );
        Assert.equals( '' + [2, -1, 0], '' + Optimus.egcd(-2, -6).map(i->i.toInt()) );
    }

    public function testModInverse() {
        Assert.equals( 1, Optimus.modInverse(1, 5).toInt() );
        Assert.equals( 59260789, Optimus.modInverse(1580030173, Optimus.MAX_INT).toInt() );
        Assert.equals( 4, Optimus.modInverse(3, 11).toInt() );
        Assert.equals( 1885413229, Optimus.modInverse(2123809381, Optimus.MAX_INT).toInt() );
    }

    public function testPower() {
        Assert.equals( 8, Optimus.power(2, 3).toInt() );
        Assert.equals( 3125, Optimus.power(5, 5).toInt() );
    }

    public function testPowerMod() {
        Assert.equals( 1, Optimus.powerMod(1, -1, 5).toInt() );
        Assert.equals( 1, Optimus.powerMod(2, 10, 3).toInt() );
        Assert.equals( 16, Optimus.powerMod(2, Optimus.power(10, 9), 18).toInt() );
        Assert.notEquals( 6, Optimus.powerMod(6, 0.5.fromFloat(), 10).toInt() ); // Loss of precision
        Assert.equals( 445, Optimus.powerMod(4, 13, 497).toInt() );
        Assert.equals( 1, Optimus.powerMod(67430, 499991, 999983).toInt() );
    }

    public function testDivMod() {
        Assert.equals( '' + {quotient:3.ofInt(), remainder:1.ofInt()}, '' + Optimus.divMod(10, 3) );
        Assert.equals( '' + {quotient:2.ofInt(), remainder:0.ofInt()}, '' + Optimus.divMod(12, 6) );
    }

    public function testMillerRabin() {
        for (i in primes) {
            var r = Optimus.millerRabin(i);
            Assert.equals( true, r, 'Primes, value == $i --- Should have been true but was $r.' );
        }

        for (i in composites) {
            var r = Optimus.millerRabin(i);
            Assert.equals( false, r, 'Composites, value == $i --- Should have been false but was $r.' );
        }
    }
    
    public function testEncode() {
        Assert.equals( 1103647397, optimus.encode(15) );
    }

    public function testDecode() {
        Assert.equals( 15, optimus.decode(1103647397) );
    }

    /*public function testConfig() {
        var opt = Optimus.make();
        var encoded = opt.encode(20);
        
        Assert.equals( 20, opt.decode(encoded) );
    }*/

}