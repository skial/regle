package uhx.uid.util;

import Random;
import haxe.macro.Expr;
import haxe.macro.Context;

using StringTools;
using haxe.Int64;
using haxe.io.Path;
using sys.FileSystem;
using uhx.uid.Optimus;

class OptimusGenerator {

    public static function init() {
        var base = 'http://primes.utm.edu/lists/small/millions/primes_.zip';
        var primeDirectory = '${Sys.getCwd()}/primes/';
        var random = Std.random(50) + 1;
        var url = base.replace('_', '' + random);
        if (!'$primeDirectory/primes$random.zip'.exists()) {
            trace( 'Fetching $url' );
            var http = new haxe.Http(url);
            http.onData = function(d) {
                if (!primeDirectory.exists()) primeDirectory.createDirectory();
                sys.io.File.saveBytes('$primeDirectory/primes$random.zip', haxe.io.Bytes.ofString(d) );
                extractPrimes('$primeDirectory/primes$random.zip');
            }
            http.onError = function(e) {
                trace(e);
            }
            http.onStatus = function(s) {
                trace(s);
            }
            http.request();

        } else {
            extractPrimes('$primeDirectory/primes$random.zip');

        }

    }

    private static function extractPrimes(path:String):Void {
        var code = 0;
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
            var result = extractFromText(txtPath);
            Sys.println(result);
        }

    }

    private static function extractFromText(path:String):String {
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

        while (!prime.millerRabin(100)) {
            prime = sections[Std.random(sections.length)].parseString();

        }

        var inverse = prime.modInverse(uhx.uid.Optimus.MAX_INT-1);
        if (inverse.isNeg()) inverse = inverse.neg();

        return haxe.Json.stringify( {
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
        } );
    }

}