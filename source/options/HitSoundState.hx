package options;

import OptionsState.NotesSubstate;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import haxe.io.Path;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;
#if sys
import sys.FileSystem;
#end

class HitSoundState extends MusicBeatState
{
    var avHitS:Array<String> = [];
    var avHitSP:Array<String> = [];
    var checkArr:Array<String> = [];

    private var grpHitSounds:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var CheckText:FlxText;
    var leText:String = "Current hit sound: " + ClientPrefs.currentHitSound;
    override function create()
    {
        CheckText = new FlxText(FlxG.width * 0.7, 5, 0, "i dont know", 32);
        CheckText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

        if(FileSystem.exists(StorageVariables.HSLFPath)){
            var initHitSoundsList = CoolUtil.coolTextFile(StorageVariables.HSLFPath);
            for(i in 0...initHitSoundsList.length){
                avHitS.push(initHitSoundsList[i]);
                var hitSName:String = avHitS[i] + '.${Paths.SOUND_EXT}';
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

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        changeSelection();

        #if mobileC
        addVirtualPad(UP_DOWN, A_B);
        #end

        FlxG.sound.music.stop();
        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
            ClientPrefs.saveSettings();
            MusicBeatState.switchState(new NewOptionsState());
        }

        if(controls.UI_UP_P)
            changeSelection(-1);
        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(controls.ACCEPT)
        {
            if(checkArr[curSelected] == "Check the directory"){
                openSubState(new PromptSubState(["You will be sent to the download page of the hitsound", "once downloaded go to the internal storage and move it to hitsounds","sanco engine files folder"], "https://github.com/SanicBTW/Sanco-Engine-Android/releases/download/v0.1/osumania.ogg"));
            } else {
                ClientPrefs.currentHitSound = avHitS[curSelected];
                ClientPrefs.hitSoundPath = avHitSP[curSelected];
                FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
                ClientPrefs.saveSettings();
                MusicBeatState.switchState(new NewOptionsState());
            }
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

        play();

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

    function play()
    {
        FlxG.sound.stream(avHitSP[curSelected], 1000, true, null, false);
    }
}


//has alpha problems, will look into it soon
class PromptSubState extends MusicBeatSubstate
{
    var onOk:Bool = false;
    var okText:Alphabet;
	var cancelText:Alphabet;
    var alphabetArray:Array<Alphabet> = [];
    var bg:FlxSprite;
    var todoAfterOk:String = "";
    public function new(promptText:Array<String>, gotoAfterOk:String)
    {
        super();

        var text:Alphabet = new Alphabet(0, 0, "hola", true);
        for(i in 0...promptText.length)
        {
            text = new Alphabet(0, 180, promptText[i], true);
            text.screenCenter(X);
            alphabetArray.push(text);
            text.alpha = 0;
            add(text);
        }

        okText = new Alphabet(0, text.y + 150, 'Ok', true);
		okText.screenCenter(X);
		okText.x -= 200;
		add(okText);
		cancelText = new Alphabet(0, text.y + 150, 'Cancel', true);
		cancelText.screenCenter(X);
		cancelText.x += 200;
		add(cancelText);

        bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);
        updateOptions();

        #if mobileC
		addVirtualPad(FULL, A_B);
		#end

        gotoAfterOk = todoAfterOk;
    }

    override function update(elapsed:Float)
    {
        bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onOk = !onOk;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		} else if(controls.ACCEPT) {
			if(onOk) {
                CoolUtil.browserLoad(todoAfterOk);
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		super.update(elapsed);
    }

    function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onOk ? 1 : 0;

		okText.alpha = alphas[confirmInt];
		okText.scale.set(scales[confirmInt], scales[confirmInt]);
		cancelText.alpha = alphas[1 - confirmInt];
		cancelText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
	}

}