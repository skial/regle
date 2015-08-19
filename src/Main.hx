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
		
		id = hids.encode( [683, 94108, 123, 5] );
		trace( id, hids.decode( id ) );
		
		hids = new Hashids('this is my salt', 8);
		id = hids.encode([1]);
		trace( id, hids.decode( id ) );
		
		hids = new Hashids('this is my salt', 0, '0123456789abcdef');
		id = hids.encode( [1234567] );
		
		trace( id, hids.decode( id ) );
	}
	
}