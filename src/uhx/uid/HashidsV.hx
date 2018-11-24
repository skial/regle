package uhx.uid;

import haxe.io.Bytes;

using StringTools;
using haxe.io.Bytes;
using uhx.uid.HashidsV.ByteHelper;

class HashidsV {

    public static final Alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    public static final Separators = 'cfhistuCFHISTU';

    public var seps:Bytes = Bytes.ofString(Separators);
    public var guards:Bytes;
    public var saltBytes:Bytes;
    public var alphabetBytes:Bytes;
    public var minHashLength:Int = 0;

    public function new(salt:String = '', minHashLength:Int = 0, ?alphabet:String) {
        if (minHashLength > 0) this.minHashLength = minHashLength;
        if (alphabet == null) alphabet = Alphabet;

        var diff = 0;
        var sepLength = 0;
        var code = ' '.code;
        var uniqueAlphabet = Bytes.alloc(alphabet.length);

        saltBytes = Bytes.ofString(salt);

        // Set any duplicates and spaces as -1.
        var index = 0;
        for (i in 0...alphabet.length) {
            code = alphabet.fastCodeAt(i);
            if (code == ' '.code && uniqueAlphabet.indexOf( code ) != -1) continue;
            uniqueAlphabet.set(index++, code);
        }

        // `seps` should contain only characters present in `alphabet`.
        // `alphabet` should not contain `seps` characters.
        var data = seps.getData();

        for (i in 0...seps.length) {
            var index = uniqueAlphabet.indexOf(data.fastGet(i));

            if (index == -1) {
                seps.set(i, ' '.code);
            } else {
                uniqueAlphabet.set(index, ' '.code);
            }

        }

        var r = uniqueAlphabet.filterNulls();
        uniqueAlphabet = r.b;
        var length = r.l;

        r = seps.filterNulls();
        seps = r.b;
        var slength = r.l;

        if (saltBytes.length > 0) seps = consistentShuffle(seps, saltBytes, slength, saltBytes.length);
        if (slength == 0 || (length / slength) > SepDiv) {
            sepLength = Math.ceil(length / SepDiv);

            if (sepLength > slength) {
                diff = sepLength - slength;
                seps = Bytes.ofString(seps.toString() + uniqueAlphabet.sub(0, diff).toString());
                uniqueAlphabet = uniqueAlphabet.sub(diff, length-diff);
                length = length-diff;

            }

        }

        if (saltBytes.length > 0) {
            uniqueAlphabet = consistentShuffle(uniqueAlphabet, saltBytes, length, saltBytes.length);
        }

        var guardCount = Math.ceil(length / GuardDiv );
        if (length < 3) {
            guards = seps.sub(0, guardCount);
            seps = seps.sub(guardCount, slength-guardCount);

        } else {
            guards = uniqueAlphabet.sub(0, guardCount);
            uniqueAlphabet = uniqueAlphabet.sub(guardCount, length - guardCount);

        }
        
        alphabetBytes = uniqueAlphabet;

    }

    public function encode(numbers:Array<Int>) {
        var result = '';

        if (numbers.length == 0) return result;

        for (i in 0...numbers.length) {
            if (numbers[i] < 0) return result;

        }

        return _encode(numbers);
    }

    public function _encode(numbers:Array<Int>):String {
        var result = '';
        var idInt = 0;
        var index = 0;

        while(index != numbers.length) {
            idInt += (numbers[index] % (index + 100));
            index++;
        }

        var alphabetBytes = alphabetBytes.copy();
        var length = alphabetBytes.trueLength();
        var code = alphabetBytes.getData().fastGet(idInt % length);

        result = String.fromCharCode( code );

        var lottery = result;

        for (index in 0...numbers.length) {
            var number = numbers[index];
            var buffer = lottery + saltBytes.toString() + alphabetBytes.toString();

            alphabetBytes = consistentShuffle(alphabetBytes, Bytes.ofString(buffer.substr(0, length)), length, buffer.length);

            var last = toAlphabet(number, alphabetBytes, length);

            result += last;
            
            if (index + 1 < numbers.length) {
                number %= (last.fastCodeAt(0) + index);
                var sepsIndex = number % seps.length;
                result += String.fromCharCode( seps.getData().fastGet(sepsIndex) );

            }

        }

        if (result.length < minHashLength) {
            var guardIndex = (idInt + result.fastCodeAt(0)) % guards.length;
            var guard = guards.getData().fastGet(guardIndex);

            result = String.fromCharCode(guard) + result;

            if (result.length < minHashLength) {
                guardIndex = (idInt + result.fastCodeAt(2)) % guards.length;
                guard = guards.getData().fastGet(guardIndex);

                result += String.fromCharCode(guard);

            }

        }

        var halfLength = length >> 1;
        while (result.length < minHashLength) {
            alphabetBytes = consistentShuffle(alphabetBytes, alphabetBytes.copy(), length, length);
            result = alphabetBytes.sub(halfLength, length - halfLength).toString() + result + alphabetBytes.sub(0, halfLength).toString();

            var excess = result.length - minHashLength;
            if (excess > 0) {
                result = result.substr(excess >> 1, minHashLength);

            }

        }

        return result;
    }

    public inline function decode(hash:String):Array<Int> {
        return hash.length == 0 ? [] : _decode(hash, alphabetBytes.copy());
    }

    public function _decode(hash:String, alphabet:Bytes):Array<Int> {
        var result = [];
        var index = 0;
        var lastNormal = 0;
        var code = ' '.code;
        var parts:Array<Bytes> = [];

        for (i in 0...hash.length) {
            code = hash.fastCodeAt(i);

            if (guards.indexOf(code) != -1 || code == ' '.code) {
                parts.push( Bytes.ofString(hash.substring(lastNormal, i)) );
                lastNormal = i+1;

            }

        }

        if (lastNormal < hash.length) {
            parts.push( Bytes.ofString(hash.substring(lastNormal, hash.length)) );
        }
        
        if (parts.length == 3 || parts.length == 2) index = 1;

        var idBreakdown = parts[index];
        var lottery = String.fromCharCode(idBreakdown.getData().fastGet(0));

        parts = [];
        lastNormal = 1;

        for (i in 1...idBreakdown.length) {
            code = idBreakdown.getData().fastGet(i);
            index = seps.indexOf(code);

            if (index != -1) {
                parts.push( idBreakdown.sub(lastNormal, i - lastNormal) );
                lastNormal = i+1;
                   
            }
            
        }

        if (lastNormal < idBreakdown.length) {
            parts.push( idBreakdown.sub(lastNormal, idBreakdown.length - lastNormal) );
        }

        var aLength = alphabet.trueLength();

        for (i in 0...parts.length) {
            var subId = parts[i];
            var buffer = lottery + saltBytes.toString() + alphabet.toString();
            alphabet = consistentShuffle(alphabet, Bytes.ofString(buffer.substr(0, aLength)), aLength, aLength);
            var v = fromAlphabet(subId, alphabet, aLength);
            result.push( v );

        }

        var check = _encode(result);
        if (check != hash) {
            result = [];
        }

        return result;
    }

    //

    public static final SepDiv = 3.5;
    public static final GuardDiv = 12;

    public static function consistentShuffle(alphabet:Bytes, salt:Bytes, alphabetLength:Int, saltLength:Int):Bytes {
        var int = 0;
        var tmp = 0;
        var v = 0;
        var p = 0;
        var j = 0;
        var i = alphabetLength - 1;
        var data = alphabet.getData();
        
        while (i > 0) {
            v %= saltLength;
            int = salt.getData().fastGet(v);
            p += int;
            j = (int + v + p) % i;
            tmp = data.fastGet(j);
            alphabet.set(j, alphabet.getData().fastGet(i) );
            alphabet.set(i, tmp);

            i--;
            v++;

        }

        return alphabet;
    }

    public static function toAlphabet(input:Int, alphabet:Bytes, length:Int):String {
        var id = '';
        
        do {
            id = String.fromCharCode( alphabet.getData().fastGet(input % length) ) + id;
            input = Std.int(input / length);

        } while (input > 0);

        return id;
    }

    public static function fromAlphabet(input:Bytes, alphabet:Bytes, length:Int):Int {
        var result = 0;

        for (i in 0...input.length) {
            var index = alphabet.indexOf(input.getData().fastGet(i));
            result += Std.int(index * Math.pow(length, input.length - i - 1));
        }

        return result;
    }

}

class ByteHelper {

    public static function indexOf(b:Bytes, v:Int):Int {
        var result = -1;

        var d = b.getData();
        for (i in 0...b.length) if (d.fastGet(i) == v) {
            result = i;
            break;
        }

        return result;
    }

    public static function lastIndexOf(b:Bytes, v:Int):Int {
        var result = -1;

        var d = b.getData();
        var i = b.length - 1;
        while(i > 0) if (d.fastGet(i) == v) {
            result = i;
            break;

        } else {
            i--;

        }

        return result;
    }

    public static function filterNulls(b:Bytes):{b:Bytes, l:Int} {
        var result = Bytes.alloc(b.length);

        var index = 0;
        var value = -1;
        for (i in 0...b.length) {
            value = b.getData().fastGet(i);

            if (value != ' '.code) {
                result.set(index, value);
                index++;

            }

        }

        return {b:result, l:index};
    }

    public static function trueLength(b:Bytes):Int {
        if (b.length <= 0) return 0;

        var length = b.length-1;

        while (length > 0) {
            if (b.getData().fastGet(length) != 0) {
                length++;
                break;
            }
            length--;
        }

        return length;
    }

    public static inline function copy(b:Bytes):Bytes {
        var result = Bytes.alloc(b.length);
        var data = b.getData();
        for (i in 0...b.length) result.set(i, data.fastGet(i));

        return result;
    }

}