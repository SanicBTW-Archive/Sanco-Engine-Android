package;

import sys.io.File;
import openfl.utils.Assets;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;

//this method will be deprecated once i find a good way to do it lol (expect to be on 0.3 or 0.4)
class StorageVariables
{
    
	public static var RequiredPath:String = Path.join([System.userDirectory, 'sanicbtw_psychfiles']);
	public static var DataPath:String = Path.join([RequiredPath, 'data']);
    public static var ImagesPath:String = Path.join([RequiredPath, 'images']);
    public static var CharactersPath:String = Path.join([RequiredPath, 'characters']);

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(DataPath)){FileSystem.createDirectory(DataPath);}
        if(!FileSystem.exists(ImagesPath)){FileSystem.createDirectory(ImagesPath);}
        if(!FileSystem.exists(CharactersPath)){FileSystem.createDirectory(CharactersPath);}
    }
}

enum Sources{
    ASSETS;
    INTERNAL;
}