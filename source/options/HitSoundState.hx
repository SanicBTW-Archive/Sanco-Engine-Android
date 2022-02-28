package options;

import OptionsState.NotesSubstate;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import haxe.io.Path;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class HitSoundState extends MusicBeatState
{
    var soundExt = "ogg";
    var avHitS:Array<String> = [];
    var avHitSP:Array<String> = [];
    var checkArr:Array<String> = [];

    private var grpHitSounds:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var CheckText:FlxText;

    override function create()
    {
        CheckText = new FlxText(FlxG.width * 0.7, 5, 0, "i dont know", 32);
        CheckText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

        if(FileSystem.exists(StorageVariables.HSLFPath)){
            var initHitSoundsList = CoolUtil.coolTextFile(StorageVariables.HSLFPath);
            for(i in 0...initHitSoundsList.length){
                avHitS.push(initHitSoundsList[i]);
                var hitSName:String = avHitS[i] + "." + soundExt;
                var possibleFilePath:String = Path.join([StorageVariables.HitSoundsPath, hitSName]);
                trace("Pushing possible hit sound path");
                avHitSP.push(possibleFilePath.toLowerCase());
                if(FileSystem.exists(avHitSP[i])){
                    trace("File exists");
                    checkArr.push("Exists");
                } else {
                    trace("File doesn't exists, check the directory please");
                    checkArr.push("Check the directory");
                }
                trace(avHitSP[i]);
            }
        } else if (!FileSystem.exists(StorageVariables.HSLFPath)){
            //useless
            CheckText.text = "No hit sounds were found\nmaybe the necessary file isn't existing\nCheck your internal storage and check the help file";
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

        grpHitSounds = new FlxTypedGroup<Alphabet>();
		add(grpHitSounds);

        for(i in 0...avHitS.length)
        {
            var avSoundsText:Alphabet = new Alphabet(0, (70 * i) + 30, avHitS[i], true, false);
            avSoundsText.isMenuItem = true;
            avSoundsText.targetY = i;
            grpHitSounds.add(avSoundsText);
        }

        var checkTxtBG:FlxSprite = new FlxSprite(CheckText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		checkTxtBG.alpha = 0.6;
		add(checkTxtBG);

        add(CheckText);

        changeSelection();

        addVirtualPad(UP_DOWN, A_B);

        FlxG.sound.music.stop();
        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
            ClientPrefs.saveSettings();
            MusicBeatState.switchState(new OptionsState());
        }

        if(controls.UI_UP_P)
            changeSelection(-1);
        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(controls.ACCEPT)
        {
            ClientPrefs.currentHitSound = avHitS[curSelected];
            ClientPrefs.hitSoundPath = avHitSP[curSelected];
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
            ClientPrefs.saveSettings();
            MusicBeatState.switchState(new OptionsState());
        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;
        
        if(curSelected < 0)
            curSelected = avHitS.length - 1;
        if(curSelected >= avHitS.length)
            curSelected = 0;

        var bullShit:Int = 0;

        //FlxG.sound.stream(avHitSP[curSelected], 1000, true, null, false);

        for(item in grpHitSounds.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if(item.targetY == 0)
                item.alpha = 1;
        }

        CheckText.text = checkArr[curSelected];
    }
}