package ;

typedef HashidLike = {
    function encode(v:Array<Int>):String;
	function decode(h:String):Array<Int>;
}