# regle

> Haitian Creole for Hash

## What is it?

Regle is a collection of utilities that generate ids.

Regle currently contains:
	
- An [Hashids] port that generates short, unique, non-sequential ids from numbers.
	+ To access the original `uhx.uid` Hashids implementation add `-D uhx_hashids`. The lib `hashids` by @kevinresol has better expanded tests.
- An [Optimus] port that obfuscates ids based on Knuth's multiplicative hashing method.
- An [Nano ID] port that is a tiny, _platform dependant_ secure, URL friendly, unique string ID generator.
	+ The [HashLink](https://github.com/HaxeFoundation/hashlink/blob/master/src/std/random.c) & Neko targets uses `Math.random`. They pass the flat distribution test, but wont be classed as secure.

## Installation

You need to install the following libraries from HaxeLib and GitHub.

1. yaml - `haxelib install yaml`
2. hashids - `haxelib git hashids https://github.com/kevinresol/hashids master src`
3. regle - `haxelib git regle https://github.com/skial/regle master src`

Then in your `.hxml` file, add `-lib regle` and you're set.

## Hashids Usage

```Haxe
package ;

import uhx.uid.Hashids;

class Main {
	
	public static function main() {
		var hids = new Hashids();
		var id = hids.encode( [1, 2, 3] ); // `id` is now `o2fXhV`.
		var values = hids.decode( id ); // `values` is now `[1, 2, 3]`.
	}
	
}
```

## Optimus Usage 

```Haxe
package ;

import uhx.uid.Optimus;

class Main {

	public static function main() {
		var optimus = new Optimus(1580030173, 59260789, 1163945558);
		var id = optimus.encode(15); // 1103647397
		var value = optimus.decode(id); // 15
	}

}
```

To generate project specific values, call `Optimus.make()` which will generate an `.optimus` file containing a Json string. The only
dependency at the moment to use `Opimus.make()` is to have the `unzip` command available. See [`OptimusSpec`](https://github.com/skial/regle/blob/master/tests/OptimusSpec.hx#L80) for an example.

## Nano ID Usage
```Haxe
package ;

import uhx.uid.Nanoid;

class Main {

	public static function main() {
		var nanoid = new Nanoid();
		var id = nanoid.toString(); // `nanoid.toString() == nanoid.toString()` == true.
		// Using a custom alphabet and length
		var id = Nanoid.generate(Nanoid.Url, 50);
	}

}
```

[Hashids]: http://hashids.org/ "Generate short, unique, non-sequential ids"
[Optimus]: https://github.com/jenssegers/optimus "Id obfuscation based on Knuth's multiplicative hashing method"
[Nano ID]: https://github.com/ai/nanoid "Tiny, secure, URL friendly, unique string ID generator"