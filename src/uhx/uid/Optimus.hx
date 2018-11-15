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
        if (prime < MAX_INT && prime.isPrime(4)) {
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
    }

    /*
    * Calculate the modular inverse of a number.
    * ---
    * @see http://www.geeksforgeeks.org/multiplicative-inverse-under-modulo-m/
    */
    public static #if !debug inline #end function modInverse(a:Int64, m:Int64):Int64 {
        var m0:Int64 = m, t:Int64, q:Int64;
        var x0:Int64 = 0;
        var x1:Int64 = 1;
    
        if (m == 1) return 0;
    
        while (a > 1) {
            // q is quotient
            q = a / m;
    
            t = m;
    
            // m is remainder now, process same as
            // Euclid's algo
            m = a % m;
            a = t;
    
            t = x0;
    
            x0 = x1 - q * x0;
    
            x1 = t;
        }
    
        // Make x1 positive
        if (x1 < 0) x1 += m0;
    
        return x1;
    }

    /*
    * Determine if a number is prime in Polynomial time, using a randomized algorithm.
    * ---
    * @see http://www.geeksforgeeks.org/primality-test-set-3-miller-rabin/
    */
    public static function millerRabin(d:Int64, n:Int64):Bool {
        // Pick a random number in [2..n-2]
        // Corner cases make sure that n > 4
        //var a = 2 + Math.random() % (n - 4);
        var a = Random.int(2, n.toInt()-4);
    
        // Compute a^d % n
        var x = powerMod(a, d, n);
    
        if (x == 1  || x == n-1) return true;
    
        // Keep squaring x while one of the following doesn't
        // happen
        // (i)   d does not reach n-1
        // (ii)  (x^2) % n is not 1
        // (iii) (x^2) % n is not n-1
        while (d != n-1) {
            x = (x * x) % n;
            d *= 2;
    
            if (x == 1) return false;
            if (x == n-1) return true;
        }
    
        // Return composite
        return false;
    }

    // @see http://www.geeksforgeeks.org/primality-test-set-3-miller-rabin/
    public static function isPrime(n:Int64, k:Int64):Bool {
        // Corner cases
        if (n <= 1 || n == 4)  return false;
        if (n <= 3) return true;
    
        // Find r such that n = 2^d * r + 1 for some r >= 1
        var d = n - 1;
        while (d % 2 == 0) d /= 2;
    
        // Iterate given nber of 'k' times
        var i = 0;
        while (i < k) {
            if (millerRabin(d, n) == false) return false;
            i++;
        }
    
        return true;
    }

    /*
    * ---
    * @see https://stackoverflow.com/a/8498251
    */
    public static #if !debug inline #end function powerMod(a:Int64, b:Int64, m:Int64):Int64 {
        a %= m;
        var result:Int64 = 1;
        while (b > 0) {
            if (b & 1 == 1) result = (result * a) % m;
            a = (a * a) % m;
            b >>= 1;
        }
        return result;
    }
    
    /**
    * @see https://stackoverflow.com/a/101613
    **/
    public static #if !debug inline #end function power(x:Int64, y:Int64):Int64 {
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