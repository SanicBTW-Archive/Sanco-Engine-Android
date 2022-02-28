package;

import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

class StorageVariables
{
    //templates for missing files
    static var freeplayListTemplate = "Tutorial:gf:0xFF9271FD";
    static var freeplayColorTemplate = "0xFF9271FD
    0xFF9271FD
    0xFF223344
    0xFF941653
    0xFFFC96D7
    0xFFA0D1FF
    0xFFFF78BF";
    static var hitsoundsTempl = "osumania";

    //directories
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sanicbtw_psychfiles']);
	public static var DataRPath:String = Path.join([RequiredPath, 'data']);
    public static var HitSoundsPath:String = Path.join([RequiredPath, 'hitsounds']);

    //files
    public static var FPLPath:String = Path.join([DataRPath, 'freeplaySonglist.txt']);
    public static var HSLFPath:String = Path.join([HitSoundsPath, 'hitsoundsList.txt']);  //for custom hit sounds and shit
    public static var FPCPath:String = Path.join([DataRPath, 'freeplayColors.txt']);

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataRPath)){FileSystem.createDirectory(DataRPath);}
        if(!FileSystem.exists(HitSoundsPath)){FileSystem.createDirectory(HitSoundsPath);}

        if(!FileSystem.exists(FPLPath)){File.saveContent(FPLPath, freeplayListTemplate);}
        if(!FileSystem.exists(HSLFPath)){File.saveContent(HSLFPath, hitsoundsTempl);}
        if(!FileSystem.exists(FPCPath)){File.saveContent(FPCPath, freeplayColorTemplate);}
    }
}