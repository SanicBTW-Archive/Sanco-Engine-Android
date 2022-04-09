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
    //the freeplay data got deprecated due to not being able to add dynamic songs support
    #if sys

    //directories
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sancoengine_files']);
	public static var DataPath:String = Path.join([RequiredPath, 'data']);
    public static var HitSoundsPath:String = Path.join([RequiredPath, 'hitsounds']);
    public static var CharactersPath:String = Path.join([RequiredPath, 'characters']);
    public static var CharDataPath:String = Path.join([CharactersPath, 'data']);
    public static var CharImgPath:String = Path.join([CharactersPath, 'images']);

    //files
    public static var HSLFPath:String = Path.join([HitSoundsPath, 'hitsoundsList.txt']);  //for custom hit sounds and shit

    public static function CheckStuff() 
    {
        //stable
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataPath)){FileSystem.createDirectory(DataPath);}
        if(!FileSystem.exists(HitSoundsPath)){FileSystem.createDirectory(HitSoundsPath);}
        //not tested
        if(!FileSystem.exists(CharactersPath)){FileSystem.createDirectory(CharactersPath);}
        if(!FileSystem.exists(CharDataPath)){FileSystem.createDirectory(CharDataPath);}
        if(!FileSystem.exists(CharImgPath)){FileSystem.createDirectory(CharImgPath);}

        //now gives an exception if the file is not found
        if(!FileSystem.exists(HSLFPath)){File.saveContent(HSLFPath, "osumania");}
    }
    #end
}