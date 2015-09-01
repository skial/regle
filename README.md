# regle

> Haitian Creole for Hash

## What is it?

Regle is a collection of utilities that generate ids.

Regle currently contains:
	
- A Hashids port that generates short, unique, non-sequential ids from numbers.

## Installation

You need to install the following libraries from HaxeLib and GitHub.

1. yaml - `haxelib install yaml`
2. regle - `haxelib git uri https://github.com/skial/uri master src`

Then in your `.hxml` file, add `-lib regle` and you're set.

## Usage

#### Hashids Usage

```Haxe
package ;

import uhx.uid.Hashids;

class Main {
	
	public static function main() {
		var hids = new Hashids( 'my salt' );
		var id = hids.encode( [683, 94108, 123, 5] ); // `id` is now `aBMswoO2UB3Sj`.
		var values = hids.decode( id ); // `values` is now `[683, 94108, 123, 5]`.
	}
	
}
```