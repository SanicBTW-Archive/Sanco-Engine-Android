package;

#if sys
import sys.io.File;
import sys.FileSystem;
#end
import openfl.utils.Assets;
import lime.system.System;
import haxe.io.Path;

class StorageVariables
{
    #if sys
    //templates for missing files
    static var freeplayListTemplate = "Tutorial:gf:0xFF9271FD";
    static var freeplayColorTemplate = "0xFF9271FD\n0xFF9271FD\n0xFF223344\n0xFF941653\n0xFFFC96D7\n0xFFA0D1FF\n0xFFFF78BF";

    //directories
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sancoengine_files']);
	public static var DataPath:String = Path.join([RequiredPath, 'data']);
    public static var HitSoundsPath:String = Path.join([RequiredPath, 'hitsounds']);
    public static var CharactersPath:String = Path.join([RequiredPath, 'characters']);
    public static var CharDataPath:String = Path.join([CharactersPath, 'data']);
    public static var CharImgPath:String = Path.join([CharactersPath, 'images']);

    //files
    public static var FPLPath:String = Path.join([DataPath, 'freeplaySonglist.txt']);
    public static var HSLFPath:String = Path.join([HitSoundsPath, 'hitsoundsList.txt']);  //for custom hit sounds and shit
    public static var FPCPath:String = Path.join([DataPath, 'freeplayColors.txt']);

    public static function CheckStuff() {
        //stable
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataPath)){FileSystem.createDirectory(DataPath);}
        if(!FileSystem.exists(HitSoundsPath)){FileSystem.createDirectory(HitSoundsPath);}
        //not tested
        if(!FileSystem.exists(CharactersPath)){FileSystem.createDirectory(CharactersPath);}
        if(!FileSystem.exists(CharDataPath)){FileSystem.createDirectory(CharDataPath);}
        if(!FileSystem.exists(CharImgPath)){FileSystem.createDirectory(CharImgPath);}

        if(!FileSystem.exists(FPLPath)){File.saveContent(FPLPath, freeplayListTemplate);}
        if(!FileSystem.exists(FPCPath)){File.saveContent(FPCPath, freeplayColorTemplate);}
    }
    #end
}