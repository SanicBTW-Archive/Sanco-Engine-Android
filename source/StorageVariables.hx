package;

import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

class StorageVariables
{
    static var freeplayListTemplate = "Tutorial:gf:0xFF9271FD";
    static var hitsoundsTempl = "osumania";
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sanicbtw_psychfiles']);
	public static var DataRPath:String = Path.join([RequiredPath, 'data']);
    public static var FPLPath:String = Path.join([DataRPath, 'freeplaySonglist.txt']);
    public static var HitSoundsPath:String = Path.join([RequiredPath, 'hitsounds']);
    public static var HSLFPath:String = Path.join([HitSoundsPath, 'hitsoundsList.txt']);  //for custom hit sounds and shit

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataRPath)){FileSystem.createDirectory(DataRPath);}
        if(!FileSystem.exists(FPLPath)){File.saveContent(FPLPath, freeplayListTemplate);}
        if(!FileSystem.exists(HitSoundsPath)){FileSystem.createDirectory(HitSoundsPath);}
        if(!FileSystem.exists(HSLFPath)){File.saveContent(HSLFPath, hitsoundsTempl);}
    }
}