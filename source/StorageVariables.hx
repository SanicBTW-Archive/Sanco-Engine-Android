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
    public static var ExportsPath:String = Path.join([RequiredPath, 'exports']);

    public static function CheckStuff() {
        if(!FileSystem.exists(RequiredPath)){FileSystem.createDirectory(RequiredPath);}
        if(!FileSystem.exists(ExportsPath)){FileSystem.createDirectory(ExportsPath);}

    }
}