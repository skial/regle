package uhx.uid.util;

import Random;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using haxe.Int64;
using sys.io.File;
using tink.CoreApi;
using haxe.io.Path;
using sys.FileSystem;
using uhx.uid.Optimus;

typedef OptimusValues = {
    var prime:String;
    var inverse:String;
    var random:String;
}

class OptimusGenerator {

    private static function random():Surprise<OptimusValues, String> {
        var base = 'http://primes.utm.edu/lists/small/millions/primes_.zip';
        var primeDirectory = '${Sys.getCwd()}/primes/';
        var random = Std.random(50) + 1;
        var url = base.replace('_', '' + random);
        var f = Future.trigger();

        if (!'$primeDirectory/primes$random.zip'.exists()) {
            trace( 'Fetching $url' );
            var http = new haxe.Http(url);
            http.onData = function(d) {
                if (!primeDirectory.exists()) primeDirectory.createDirectory();
                sys.io.File.saveBytes('$primeDirectory/primes$random.zip', haxe.io.Bytes.ofString(d) );
                var r = extractPrimes('$primeDirectory/primes$random.zip');
                f.trigger( r == null ? Failure('please rerun generator.') : Success(r) );
            }
            http.onError = function(e) {
                f.trigger( Failure(e) );
            }
            http.onStatus = function(s) {
                trace(s);
            }
            http.request();

        } else {
            var r = extractPrimes('$primeDirectory/primes$random.zip');
            f.trigger( r == null ? Failure('please rerun generator.') : Success(r) );

        }

        return f.asFuture();
    }

    private static function extractPrimes(path:String):Null<OptimusValues> {
        var code = 0;
        var result = null;
        var unzip = 'unzip';
        var txtPath = path.withoutExtension() + '.txt';

        if (!txtPath.exists()) {
            if (Sys.systemName() == 'Windows') {
                var env = Sys.environment();
                if (env.exists('Path')) for (path in env.get('Path').split(';')) {
                    
                    switch path {
                        case _.endsWith('\\Gow\\bin') => true && ('$path\\unzip.exe'.exists()) => true:
                            unzip = (path + '\\' + unzip + '.exe').normalize();
                            break;

                        case _.endsWith('Git\\bin') => true:
                            if (('$path\\..\\usr\\bin\\unzip.exe'.normalize()).exists()) {
                                unzip = ('$path\\..\\usr\\bin\\unzip.exe').normalize();
                                break;

                            }

                        case _:

                    }
                }

            }

            code = Sys.command(unzip, ['-o', path, '-d', path.directory()]);

        }

        if (code == 0 && txtPath.exists()) {
            result = extractFromText(txtPath);
            
        }

        return result;
    }

    private static function extractFromText(path:String):OptimusValues {
        var str = sys.io.File.getContent(path);
           
        str = str.substring(str.indexOf(')')+1, str.length).trim();

        var a = Std.random(str.length);
        var b = Std.random(str.length);

        var min = a < b ? a : b;
        var max = a > b ? a : b;

        if (max < 1000) max = 1000;

        var section = str.substring(min, max);
        var sections = ~/[ \r\n]+/g.split(section).filter(s->s.length>2);
        var prime = sections[Std.random(sections.length)].parseString();

        while (!uhx.uid.Optimus.millerRabin(prime.toInt(), 100)) {
            prime = sections[Std.random(sections.length)].parseString();

        }

        var inverse = uhx.uid.Optimus.modInverse(prime.toInt(), uhx.uid.Optimus.MAX_INT);
        //if (inverse.isNeg()) inverse = inverse.neg();
        trace( (prime * inverse) & uhx.uid.Optimus.MAX_INT );
        
        return {
            prime:prime.toStr(), 
            inverse:inverse.toStr(), 
            random:(
                Std.parseInt(
                    haxe.io.Bytes.ofString(
                        Random.string(4)
                    ).toHex()
                ) 
                & uhx.uid.Optimus.MAX_INT
            ).toStr()
        };
    }

    // User methods

    public static function json() {
        random().handle( function(o) {
            switch o {
                case Success(s):
                    Sys.println(haxe.Json.stringify(s));

                case Failure(e):
                    Sys.println(haxe.Json.stringify({error:e}));

            }

        } );

    }

    public static function config() {
        var path = '${Sys.getCwd()}/.optimus'.normalize();

        if (!path.exists()) random().handle( function(o) {
            switch o {
                case Success(s):
                    path.saveContent(
                        haxe.Json.stringify(s)
                    );

                case Failure(e):
                    Sys.println(haxe.Json.stringify({error:e}));

            }

        } );

    }

}