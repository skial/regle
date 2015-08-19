package;

import uhx.uid.Hashids;

/**
 * ...
 * @author Skial Bainn
 */
class Main {
	
	static function main() {
		var hids = new Hashids('this is my salt');
		var id = hids.encode( [12345] );
		trace( id, hids.decode( id ) );
	}
	
}