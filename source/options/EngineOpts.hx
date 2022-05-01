package options;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class EngineOpts extends BaseOptionsMenu
{
    public function new()
    {
        title = "Engine Options";
        rpcTitle = "Engine Options Menu";

        var option:Option = new Option("Camera Movement On Note Press",
            'If checked the camera will snap on the notes direction',
            "cameraMovOnNotePress",
            "bool",
            true);
        addOption(option);

        var option:Option = new Option("Use Hit Sounds",
            "Will play hit sounds when hitting notes",
            "useHitSounds",
            "bool",
            false);
        addOption(option);

        var option:Option = new Option("Classic Middlescroll",
            "If checked, it will show up the classic middlescroll",
            "classicMiddlescroll",
            "bool",
            true);
        addOption(option);

        var option:Option = new Option("KE Sustains",
            "This one is from the base engine, literally ke sustains",
            "keSustains",
            "bool",
            true);
        addOption(option);
        super();
    }
}