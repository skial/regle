package uhx.uid;
import yaml.util.Ints;

/**
 * ...
 * @author Skial Bainn
 */
class Hashids {
	
	private var salt:String = '';
	private var alphabet:String = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
	private var separators:String = 'cfhistuCFHISTU';
	
	private var minAlphabetLength:Int = 16;
	private var sepDiv:Float = 3.5;
	private var guardDiv:Int = 12;
	
	private var guards:String = '';
	private var minHashLength:Int = 0;

	public inline function new(?salt:String, ?minHashLength:Int, ?alphabet:String) {
		if (salt != null) this.salt = salt;
		if (alphabet != null) this.alphabet = alphabet;
		
		var guardCount = 0;
		var diff = 0;
		var sepLength = 0;
		var uniqueAlphabet = '';
		for (i in 0...this.alphabet.length) {
			if (uniqueAlphabet.indexOf( this.alphabet.charAt( i ) ) == -1) {
				uniqueAlphabet += this.alphabet.charAt( i );
				
			}
		}
		
		this.alphabet = uniqueAlphabet;
		this.minHashLength = Ints.parseInt('' + minHashLength, 10) > 0 ? minHashLength : 0;
		
		if (this.alphabet.length < this.minAlphabetLength) {
			throw 'error: alphabet must contain at least $minAlphabetLength unique characters';
		}
		
		if (this.alphabet.indexOf(' ') > -1) {
			throw 'error: alphabet cannot contain spaces';
		}
		
		for (i in 0...this.separators.length) {
			var j = this.alphabet.indexOf( this.separators.charAt( i ) );
			if (j == -1) {
				this.separators = this.separators.substring(0, i) + ' ' + this.separators.substring(i + 1);
			} else {
				this.alphabet = this.alphabet.substring(0, j) + ' ' + this.alphabet.substring(j + 1);
			}
			
		}
		
		this.alphabet = ~/ /g.replace(this.alphabet, '');
		this.separators = ~/ /g.replace(this.separators, '');
		
		this.separators = consistentShuffle(this.separators, this.salt);
		
		if (separators.length > 0 || (this.alphabet.length / this.separators.length) > this.sepDiv) {
			sepLength = Math.ceil(this.alphabet.length / this.sepDiv);
			
			if (sepLength == 1) sepLength++;
			if (sepLength > this.separators.length) {
				diff = sepLength - this.separators.length;
				this.separators += this.alphabet.substr(0, diff);
				this.alphabet = this.alphabet.substr(diff);
			} else {
				this.separators = this.separators.substr(0, sepLength);
			}
			
		}
		
		this.alphabet = consistentShuffle(this.alphabet, this.salt);
		
		guardCount = Math.ceil(this.alphabet.length / this.guardDiv);
		
		if (this.alphabet.length < 3) {
			this.guards = this.separators.substr(0, guardCount);
			this.separators = this.separators.substr(guardCount);
		} else {
			this.guards = this.alphabet.substr(0, guardCount);
			this.alphabet = this.alphabet.substr(guardCount);
		}
	}
	
	public function consistentShuffle(alphabet:String, ?salt:String):String {
		if (salt == null) return alphabet;
		
		var integer:Int = 0;
		var temp:String = '';
		var i:Int = alphabet.length - 1;
		var v:Int = 0;
		var p:Int = 0;
		var j:Int = 0;
		
		while (i > 0) {
			v %= salt.length;
			p += integer = salt.charAt(v).charCodeAt(0);
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
		var result = '';
		var i = 0;
		var length = 0;
		var numbers = args.length;
		
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
		var alphabet = this.alphabet;
		var numbersHashInt = 0;
		var numbersSize = numbers.length;
		
		for (i in 0...numbers.length) numbersHashInt += (numbers[i] % (i + 100));
		
		var result = '';
		var lottery = result = alphabet.charAt( numbersHashInt % alphabet.length );
		
		for (i in 0...numbers.length) {
			var number = numbers[i];
			var buffer = lottery + this.salt + alphabet;
			alphabet = consistentShuffle(alphabet, buffer.substr(0, alphabet.length) );
			var last = this.hash(number, alphabet);
			
			result += last;
			
			if (i + 1 < numbersSize) {
				number %= (last.charCodeAt(0) + i);
				var sepsIndex = number % this.separators.length;
				result += this.separators.charAt(sepsIndex);
			}
		}
		
		if (result.length < this.minHashLength) {
			var guardIndex = (numbersHashInt + result.charCodeAt(0)) % this.guards.length;
			var guard = this.guards.charAt(guardIndex);
			
			result = guard + result;
			
			if (result.length < this.minHashLength) {
				guardIndex = (numbersHashInt + result.charCodeAt(2)) % this.guards.length;
				guard = this.guards.charAt(guardIndex);
				
				result += guard;
			}
		}
		
		var halfLength = Ints.parseInt('' + (alphabet.length / 2), 10);
		while (result.length < this.minHashLength) {
			alphabet = this.consistentShuffle(alphabet, alphabet);
			result = alphabet.substr(halfLength) + result + alphabet.substr(0, halfLength);
			
			var excess = result.length - this.minHashLength;
			if (excess > 0) {
				result = result.substr(Std.int(excess / 2), this.minHashLength);
			}
		}
		
		return result;
	}
	
	private function _decode(hash:String, alphabet:String):Array<Int> {
		var results = [];
		
		var i = 0;
		var r = new EReg('[$guards]', 'g');
		var hashBreakdown = r.replace(hash, ' ');
		var hashArray = hashBreakdown.split(' ');
		
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
			
			if (_encode(results) != hash) {
				results = [];
			}
		}
		
		return results;
	}
	
	private function hash(input:Int, alphabet:String):String {
		var hash = '';
		var alphabetLength = alphabet.length;
		
		do {
			hash = alphabet.charAt(input % alphabetLength) + hash;
			input = Ints.parseInt('' + input / alphabetLength, 10);
		} while (input != null && input > 0);
		
		return hash;
	}
	
	private function unhash(input:String, alphabet:String):Int {
		var number = 0.0;
		var pos = 0;
		
		for (i in 0...input.length) {
			pos = alphabet.indexOf(input.charAt(i));
			number += pos * Math.pow(alphabet.length, input.length - i - 1);
		}
		
		return Std.int( number );
	}
	
}