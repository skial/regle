package uhx.uid;

import yaml.util.Ints;

#if !uhx_hashids
typedef Hashids = hashids.Hashids;
#else
/**
 * @author Skial Bainn
 * Port of the JavaScript version of Hashids
 * @see http://hashids.org/
 */
class Hashids {
	
	private var salt:String = '';
	private var alphabet:String = '';
	private var separators:String = 'cfhistuCFHISTU';
	
	private var minAlphabetLength:Int = 16;
	private var separatorDiv:Float = 3.5;
	private var guardDiv:Int = 12;
	
	private var guards:String = '';
	private var minHashLength:Int = 0;

	public function new(?salt:String = '', ?minHashLength:Int = 0, ?alphabet:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890') {
		this.salt = salt;
		this.alphabet = alphabet;
		
		var diff = 0, sepLength = 0, guardCount = 0, uniqueAlphabet = '';
		
		for (i in 0...this.alphabet.length) if (uniqueAlphabet.indexOf( this.alphabet.charAt( i ) ) == -1) {
			uniqueAlphabet += this.alphabet.charAt( i );
			
		}
		
		this.alphabet = uniqueAlphabet;
		this.minHashLength = Ints.parseInt('' + minHashLength, 10) > 0 ? minHashLength : 0;
		
		if (this.alphabet.length < this.minAlphabetLength) {
			throw 'error: alphabet must contain at least $minAlphabetLength unique characters';
		}
		
		if (this.alphabet.indexOf(' ') > -1) throw 'error: alphabet cannot contain spaces';
		
		for (i in 0...this.separators.length) {
			var j = this.alphabet.indexOf( separators.charAt( i ) );
			
			if (j == -1) {
				separators = separators.substring(0, i) + ' ' + separators.substring(i + 1);
				
			} else {
				this.alphabet = this.alphabet.substring(0, j) + ' ' + this.alphabet.substring(j + 1);
				
			}
			
		}
		
		this.alphabet = ~/ /g.replace(this.alphabet, '');
		separators = ~/ /g.replace( separators, '' );
		separators = consistentShuffle( separators, this.salt );
		
		if (separators.length > 0 || (this.alphabet.length / separators.length) > separatorDiv) {
			sepLength = Math.ceil(this.alphabet.length / separatorDiv);
			
			if (sepLength == 1) sepLength++;
			if (sepLength > separators.length) {
				diff = sepLength - separators.length;
				separators += this.alphabet.substr(0, diff);
				this.alphabet = this.alphabet.substr(diff);
				
			} else {
				separators = separators.substr(0, sepLength);
				
			}
			
		}
		
		this.alphabet = consistentShuffle( this.alphabet, this.salt );
		
		guardCount = Math.ceil( this.alphabet.length / guardDiv );
		
		if (this.alphabet.length < 3) {
			this.guards = separators.substr(0, guardCount);
			separators = separators.substr(guardCount);
			
		} else {
			this.guards = this.alphabet.substr(0, guardCount);
			this.alphabet = this.alphabet.substr(guardCount);
			
		}
	}
	
	public function consistentShuffle(alphabet:String, salt:String):String {
		if (salt.length == 0) return alphabet;
		
		var i = alphabet.length - 1;
		var v = 0, p = 0, j = 0;
		var integer = 0, temp = '';
		
		while (i > 0) {
			v = v % salt.length;
			p += (integer = salt.charAt(v).charCodeAt(0));
			j = (integer + v + p) % i;
			
			temp = alphabet.charAt(j);
			alphabet = alphabet.substr(0, j) + alphabet.charAt(i) + alphabet.substr(j + 1);
			alphabet = alphabet.substr(0, i) + temp + alphabet.substr(i + 1);
			
			i--;
			v++;
		}
		
		return alphabet;
	}
	
	public function encode(args:Array<Int>):String {
		var numbers = args.length;
		var result = '', i = 0, length = 0;
		
		if (args.length == 0) return result;
		
		for (i in 0...args.length) {
			if (args[i] % 1 != 0 || args[i] < 0) {
				return result;
			}
		}
		
		return _encode(args);
	}
	
	public function decode(hash:String):Array<Int> {
		if (hash.length == 0) return [];
		
		return _decode(hash, alphabet);
	}
	
	private function _encode(numbers:Array<Int>):String {
		var numbersHashInt = 0, numbersSize = numbers.length;
		
		for (i in 0...numbers.length) numbersHashInt += (numbers[i] % (i + 100));
		
		var result = '', alphabet = this.alphabet;
		var lottery = result = alphabet.charAt( numbersHashInt % alphabet.length );
		
		for (i in 0...numbers.length) {
			var number = numbers[i];
			var buffer = '$lottery$salt$alphabet';
			alphabet = consistentShuffle( alphabet, buffer.substr(0, alphabet.length ) );
			var last = this.hash(number, alphabet);
			
			result += last;
			
			if (i + 1 < numbersSize) {
				number %= (last.charCodeAt(0) + i);
				var sepsIndex = number % separators.length;
				result += separators.charAt(sepsIndex);
			}
		}
		
		if (result.length < minHashLength) {
			var guardIndex = (numbersHashInt + result.charCodeAt(0)) % this.guards.length;
			var guard = this.guards.charAt(guardIndex);
			
			result = guard + result;
			
			if (result.length < minHashLength) {
				guardIndex = (numbersHashInt + result.charCodeAt(2)) % this.guards.length;
				guard = this.guards.charAt(guardIndex);
				
				result += guard;
			}
		}
		
		var halfLength = Ints.parseInt('' + (alphabet.length / 2), 10);
		
		while (result.length < minHashLength) {
			alphabet = consistentShuffle( alphabet, alphabet );
			result = alphabet.substr(halfLength) + result + alphabet.substr(0, halfLength);
			
			var excess = result.length - minHashLength;
			
			if (excess > 0) {
				result = result.substr(Std.int(excess / 2), minHashLength);
			}
			
		}
		
		return result;
	}
	
	private function _decode(hash:String, alphabet:String):Array<Int> {
		var results = [], i = 0, r = new EReg('[$guards]', 'g');
		var hashBreakdown = r.replace(hash, ' '), hashArray = hashBreakdown.split(' ');
		
		if (hashArray.length == 3 || hashArray.length == 2) i = 1;
		
		hashBreakdown = hashArray[i];
		
		if (hashBreakdown.charAt(0) != null) {
			var lottery = hashBreakdown.charAt(0);
			hashBreakdown = hashBreakdown.substr(1);
			
			r = new EReg('[$separators]', 'g');
			hashBreakdown = r.replace(hashBreakdown, ' ');
			hashArray = hashBreakdown.split(' ' );
			
			for (i in 0...hashArray.length) {
				var subhash = hashArray[i];
				var buffer = lottery + salt + alphabet;
				
				alphabet = consistentShuffle( alphabet, buffer.substr(0, alphabet.length));
				results.push( unhash( subhash, alphabet ) );
			}
			
			if (_encode(results) != hash) results = [];
			
		}
		
		return results;
	}
	
	private function hash(input:Int, alphabet:String):String {
		var hash = '';
		
		while (input > 0) {
			hash = alphabet.charAt(input % alphabet.length) + hash;
			input = Ints.parseInt('' + input / alphabet.length, 10);
		}
		
		return hash;
	}
	
	private function unhash(input:String, alphabet:String):Int {
		var number = 0.0, pos = 0;
		
		for (i in 0...input.length) {
			pos = alphabet.indexOf(input.charAt(i));
			number += pos * Math.pow(alphabet.length, input.length - i - 1);
		}
		
		return Std.int( number );
	}
	
}
#end