package uhx.uid;

import haxe.Int64;

using haxe.io.Path;
using uhx.uid.Optimus;
using haxe.Int64;

class Optimus {

    public static var MAX_INT:Int64 = 2147483647.ofInt();

    public static macro function make() {
        var path = '${Sys.getCwd()}/.optimus'.normalize();
        if (!sys.FileSystem.exists(path)) {
            uhx.uid.util.OptimusGenerator.config();
        }

        var json:uhx.uid.util.OptimusGenerator.OptimusValues 
        = haxe.Json.parse(sys.io.File.getContent(path));

        return macro new uhx.uid.Optimus(
            $v{Std.parseInt(json.prime)},
            $v{Std.parseInt(json.inverse)},
            $v{Std.parseInt(json.random)}
        );
    }

    public var prime:Int64;
    public var inverse:Int64;
    public var random:Int64;

    public function new(prime:Int64, inverse:Int64, random:Int64):Void {
        if (prime < MAX_INT && prime.millerRabin()) {
            this.prime = prime;
            if ((prime * inverse) & MAX_INT != 1) {
                throw 'Inverse value $inverse is not the inverse of the Prime value $prime.';
            }
            this.inverse = inverse;
            this.random = random;

        } else {
            throw 'Prime value $prime is not a valid prime number.';
        }

    }

    public #if !debug inline #end function encode(v:Int):Int {
        var _v:Int64 = v;
        return (((_v * prime) & MAX_INT) ^ random).toInt();
    }

    public #if !debug inline #end function decode(v:Int):Int {
        var _v:Int64 = v;
        return (((_v ^ random) * inverse) & MAX_INT).toInt();
    }

    public static function gcd(a:Int64, b:Int64) {
        if (b == 0) return a;
        return gcd(b, a%b);
    }

    /*
    * Calculate the extended Euclid Algorithm or extended GCD.
    * ---
    * @see https://github.com/numbers/numbers.js/blob/master/lib/numbers/basic.js#L398
    */
    public static #if !debug inline #end function egcd(a:Int64, b:Int64):Array<Int64> {
        if (a != a || b != b) {
            return [];
        }

        if (a.toInt() == Math.POSITIVE_INFINITY || a.toInt() == Math.NEGATIVE_INFINITY || b.toInt() == Math.POSITIVE_INFINITY || b.toInt() == Math.NEGATIVE_INFINITY) {
            return [];
        }

        var signX:Int64 = (a < 0) ? -1 : 1;
        var signY:Int64 = (b < 0) ? -1 : 1;
        var x:Int64 = 0;
        var y:Int64 = 1;
        var oldX:Int64 = 1;
        var oldY:Int64 = 0;
        var q:Int64 = 0, r:Int64 = 0, m:Int64 = 0, n:Int64 = 0;
        
        a = a < 0 ? -a : a;
        b = b < 0 ? -b : b;

        while (a != 0) {
            q = b / a;
            r = b % a;
            m = x - oldX * q;
            n = y - oldY * q;
            b = a;
            a = r;
            x = oldX;
            y = oldY;
            oldX = m;
            oldY = n;
        }
        return [b, signX * x, signY * y];
        /*if (a == 0) {
            return [b, 0, 1];
        } else {
            var r = egcd(b % a, a);
            var g = r[0], x = r[1], y = r[2]; 
            return [g, x - (b / a) * y, y];
        }*/
        //if (a.isNeg()) a = a.neg();
        //if (b.isNeg()) b = b.neg();
        /*if (b == 0) {
            return [a, 1, 0];
        } else {
            var r = egcd(b, a%b);
            var t = r[1];
            var t2 = r[2];
            r[1] = r[2];
            r[2] = t - (a/b) * t2;
            return r;
        }*/
    }

    /*
    * Calculate the modular inverse of a number.
    * ---
    * @see https://github.com/numbers/numbers.js/blob/master/lib/numbers/basic.js#L444
    */
    public static #if !debug inline #end function modInverse(a:Int64, m:Int64):Int64 {

        var r = egcd(a, m);
        if (r.length == 0 || r[0] != 1) {
            throw 'modular inverse does not exist';

        } else {
            return (r[1] % m + m) % m;
            //return powerMod(a, m-2, m);

        }
        /*var t:Int64 = 0;
        var newT:Int64 = 1;
        var r:Int64 = m;
        var newR:Int64 = a.isNeg() ? a.neg() : a;
        var q:Int64 = 0;
        var lastT:Int64 = 0;
        var lastR:Int64 = 0;

        while (newR != 0) {
            q = r / newR;
            lastT = t;
            lastR = r;
            t = newT;
            r = newR;
            newT = lastT - (q * newT);
            newR = lastR - (q * newR);
        }

        if (r != 1) throw '$a and $m are not co-prime';
        if (t < 0) t += m;
        if (a.isNeg()) t = t.neg();
        return t;*/
    }

    /*
    * Determine if a number is prime in Polynomial time, using a randomized algorithm.
    * http://en.wikipedia.org/wiki/Miller-Rabin_primality_test
    * ---
    * @see https://github.com/numbers/numbers.js/blob/df0a1cb39d4d0a5e4c8218a31fac1d6eb24b7444/lib/numbers/prime.js#L92
    */
    public static function millerRabin(n:Int64, ?itr:Int = 20):Bool {
        if (n == 2) return true;
        if (n <= 1 || n % 2 == 0) return false;
        
        var s = 0;
        var d:Int64 = n - 1;

        while (true) {
            var dm = d.divMod(2);
            var quotient = dm.quotient;
            var remainder = dm.modulus;

            if (remainder == 1) break;

            s += 1;
            d = quotient;
        }
        
        var tryComposite = function (a) {
            if (powerMod(a, d, n) == 1) return false;

            var i = 0;
            while (i < s) {
                if (powerMod(a, power(2, i) * d, n) == n - 1) return false;
                
                i++;
            }

            return true;
        };

        var i = 0;
        while (i < itr) {
            var a = 2 + Math.floor(Math.random() * (n.toInt() - 2 - 2));
            if (tryComposite(a)) return false;
            
            i++;
        }

        return true;
    }

    /*
    * Calculate:
    * if b >= 1: a^b mod m.
    * if b = -1: modInverse(a, m).
    * if b < 1: finds a modular rth root of a such that b = 1/r.
    * ---
    * @see https://github.com/numbers/numbers.js/blob/master/lib/numbers/basic.js#L367
    */
    public static #if !debug inline #end function powerMod(a:Int64, b:Int64, m:Int64):Int64 {
        // If b < -1 should be a small number, this method should work for now.
        if (b < -1) return power(a, b) % m;
        if (b == 0) return 1 % m;
        if (b >= 1) {
            var result:Int64 = 1;

            while (b > 0) {
                if ((b % 2) == 1) {
                    result = (result * a) % m;
                }

                a = (a * a) % m;
                b = b >> 1;
            }

            return result;
        }

        if (b == -1) return modInverse(a, m);
        if (b < 1) {
            return powerMod(a, power(b, -1), m);
        }
        return b;
    }
    
    /**
    * @see https://stackoverflow.com/a/38666376
    **/
    public static #if !debug inline #end function power(x:Int64, y:Int64):Int64 {
        /*if (y==0) {
            return 1;

        } else if (y%2 == 0) {
            return power(x, y/2) * power(x, y/2);

        } else {
            return x * power(x, y/2) * power(x, y/2);

        }*/
        // @see https://stackoverflow.com/a/101613
        var result:Int64 = 1;
        while (y != 0) {
            if (y & 1 == 1) result *= x;
            y >>= 1;
            x *= x;
        }

        return result;
    }

    public static #if !debug inline #end function divMod(a:Int64, b:Int64):{quotient:Int64, remainder:Int64} {
        if (b <= 0) throw "b $b cannot be zero. Undefined.";
        return {quotient:a / b, remainder:a % b};
    }


}