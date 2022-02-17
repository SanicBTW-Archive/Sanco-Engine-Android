package;

import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

//this method will be deprecated once i find a good way to do it lol (expect to be on 0.3 or 0.4)
class StorageVariables
{
    static var freeplayListTemplate = "Tutorial:gf:0xFF9271FD";
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sanicbtw_psychfiles']);
	public static var DataRPath:String = Path.join([RequiredPath, 'data']);
    public static var FPLPath:String = Path.join([DataRPath, 'freeplaySonglist.txt']);

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataRPath)){FileSystem.createDirectory(DataRPath);}
        if(!Assets.exists(FPLPath, TEXT)){File.saveContent(FPLPath, freeplayListTemplate);}
    }
}