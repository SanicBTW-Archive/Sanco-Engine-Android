package;

import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

class StorageVariables
{
    //for the next version the R in the paths will be deleted cuz they look ugly lol

    //templates for missing files
    static var freeplayListTemplate = "Tutorial:gf:0xFF9271FD";
    static var freeplayColorTemplate = "0xFF9271FD\n0xFF9271FD\n0xFF223344\n0xFF941653\n0xFFFC96D7\n0xFFA0D1FF\n0xFFFF78BF";
    static var helpFileText = "This file is for the file system support help in case you don't know how anything that i did works\n
Hit Sounds Support\n
Go to the hit sounds folder and create a text file called 'hitsoundsList.txt'
in order to put your custom hit sounds, add the name of the hit sound to the text file
and add the sound file in the same folder, with the .ogg extension"; //YO this is going to be sent to the engine wiki just in case

    //directories
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sancoengine_files']);
	public static var DataRPath:String = Path.join([RequiredPath, 'data']);
    public static var HitSoundsPath:String = Path.join([RequiredPath, 'hitsounds']);
    public static var SongsRPath:String = Path.join([RequiredPath, 'songs']);
    public static var LuaRPath:String = Path.join([RequiredPath, 'scripts']); //only folder is created, no support is given yet

    //files
    public static var FPLPath:String = Path.join([DataRPath, 'freeplaySonglist.txt']);
    public static var HSLFPath:String = Path.join([HitSoundsPath, 'hitsoundsList.txt']);  //for custom hit sounds and shit
    public static var FPCPath:String = Path.join([DataRPath, 'freeplayColors.txt']);
    public static var CustomSF:String = Path.join([DataRPath, 'customsongs.txt']); // only a placeholder for the external music state thingy

    public static var HelpFile:String = Path.join([RequiredPath, 'readme.txt']);

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataRPath)){FileSystem.createDirectory(DataRPath);}
        if(!FileSystem.exists(HitSoundsPath)){FileSystem.createDirectory(HitSoundsPath);}
        if(!FileSystem.exists(SongsRPath)){FileSystem.createDirectory(SongsRPath);}
        if(!FileSystem.exists(LuaRPath)){FileSystem.createDirectory(LuaRPath);}

        if(!FileSystem.exists(FPLPath)){File.saveContent(FPLPath, freeplayListTemplate);}
        if(!FileSystem.exists(FPCPath)){File.saveContent(FPCPath, freeplayColorTemplate);}
        File.saveContent(HelpFile, helpFileText); //will be deprecated in the next release or once i migrate it to the wiki
        if(!FileSystem.exists(CustomSF)){File.saveContent(CustomSF, "tutorial");}
    }
}