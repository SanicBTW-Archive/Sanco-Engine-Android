package test;

import flixel.util.FlxTimer;
import Song.SwagSong;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import haxe.io.Path;
import sys.FileSystem;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class ExtMusicState extends MusicBeatState
{
    var songs:Array<String> = [];
    var songsInstPaths:Array<String> = [];
    var songsVoicesPaths:Array<String> = [];
    var songsChartPaths:Array<String> = [];
    private var grpSongs:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var leText:String;
    var checkText:FlxText;
    var songCheck:Array<String> = [];
    var text:FlxText;
    var ltimer:FlxTimer;
    var loaded:Array<String> = [""];

    /*
    var inst:FlxSound;
    var vocals:FlxSound;*/

    override function create()
    {
        var initSongList = CoolUtil.coolTextFile(StorageVariables.CustomSF);
        for(i in 0...initSongList.length)
        {
            PushAndCheck(initSongList, i);
        }

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

        grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

        for(i in 0...songs.length)
        {
            var songsText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i], true ,false);
            songsText.isMenuItem = true;
            songsText.targetY = i;
            grpSongs.add(songsText);
        }

        checkText = new FlxText(FlxG.width * 0.7, 5, 0, "waitin", 32);
        checkText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

        var pathBG:FlxSprite = new FlxSprite(checkText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		pathBG.alpha = 0.6;
		add(pathBG);

        add(checkText);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        text = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        changeSelection();

        addVirtualPad(UP_DOWN, A_B);

        FlxG.sound.music.stop();

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK){
            FlxG.sound.music.resume();
            FlxG.switchState(new MainMenuState());
        }

        if(controls.UI_UP_P)
            changeSelection(-1);
        if(controls.UI_DOWN_P)
            changeSelection(1);

        if(controls.ACCEPT){
            trace("trying to play");
            FlxG.sound.destroy();
            
            play();

        }

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;

        if(curSelected < 0)
            curSelected = songs.length - 1;
        if(curSelected >= songs.length)
            curSelected = 0;

        var bullShit:Int = 0;

        play();

        for (item in grpSongs.members){
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if(item.targetY == 0)
                item.alpha = 1;
        }

        checkText.text = songCheck[curSelected];
        text.text = songsInstPaths[curSelected];
    }

    function play(){
        FlxG.sound.destroy();
        loaded = [""];

        /* method 1, doesnt works / doesnt play anything, does it need to be .mp3???
        if(songCheck[curSelected] == "Voice and Inst"){
            vocals = new FlxSound().loadStream(songsVoicesPaths[curSelected]);
        } 
        else
            vocals = new FlxSound();

        FlxG.sound.list.add(vocals);
        FlxG.sound.list.add(new FlxSound().loadStream(songsInstPaths[curSelected]));
        */

        /* method 2, doesnt works / doesnt play anything, does it need to be .mp3???
        vocals = new FlxSound().loadStream(songsVoicesPaths[curSelected]);
        vocals.play();
        inst = new FlxSound().loadStream(songsInstPaths[curSelected]);
        inst.play();
        */

        //method 3, works but plays the thing out of sync, depends on the order
        FlxG.sound.stream(songsVoicesPaths[curSelected], 1, false, null, false, null, () -> sync(vocals) );
        FlxG.sound.stream(songsInstPaths[curSelected], 1, false, null, false, null, () -> sync(instrumental));
    }

    function PushAndCheck(initSongList:Array<String>, i:Int)
    {
        songs.push(initSongList[i]);
        
        //possible paths and names
        var theInstName:String = "Inst." + Paths.SOUND_EXT;
        var theVoiceName:String = "Voices." + Paths.SOUND_EXT;
        var theChartName:String = initSongList[i] + ".json"; //lets just go with the normal one, lazy to add difs, this is a test state, not playstate :skull:
        var possibleInstPath:String = Path.join([StorageVariables.SongsPath, initSongList[i], theInstName]);
        var possibleVoicePath:String = Path.join([StorageVariables.SongsPath, initSongList[i], theVoiceName]);
        var possibleChartPath:String = Path.join([StorageVariables.DataPath, initSongList[i], theChartName]);
       
        //pushing for easy check for later
        trace("Pushing possible inst path");
        songsInstPaths.push(possibleInstPath);
        trace("Pushing possible voice path");
        songsVoicesPaths.push(possibleVoicePath);
        trace("Pushing possible chart path");
        songsChartPaths.push(possibleChartPath);

        //check, maybe try doing a failsafe? for ex: chart exists but not the audio and stuff
        if(FileSystem.exists(songsInstPaths[i]) && FileSystem.exists(songsVoicesPaths[i]) && FileSystem.exists(songsChartPaths[i])){
            trace("Everything needed exists (Chart, Inst, Voices)");
            songCheck.push("Everything alright");
        } else if(FileSystem.exists(songsInstPaths[i]) && FileSystem.exists(songsVoicesPaths[i])){
            trace("Existing voice and inst");
            songCheck.push("Voice and Inst");
        } else if (FileSystem.exists(songsInstPaths[i]) && !FileSystem.exists(songsVoicesPaths[i])) {
            trace("Existing inst");
            songCheck.push("Only Inst");
        } else {
            trace("fuck");
            songCheck.push("None");
        }

        //tracing data for debugging
        trace(songsInstPaths[i]);
        trace(songsVoicesPaths[i]);
        trace(songsChartPaths[i]);
    }

    function sync(type:SoundType){
        trace("trying to sync");

        var vocalsTickT;
        var instTickT;
        var formattedThing:String;

        switch(type)
        {
            case vocals:
                vocalsTickT = FlxG.game.ticks;
                formattedThing = type.getName() + " " + vocalsTickT;
                if(songs[curSelected] == "Voice and Inst"){
                    loaded.push(formattedThing);
                    trace(vocalsTickT);    
                    trace(loaded[1]);
                }
            case instrumental:
                instTickT = FlxG.game.ticks;
                formattedThing = type.getName() + " " + instTickT;
                if(songs[curSelected] == "Only Inst"){
                    loaded.push(formattedThing);
                    trace(instTickT);
                    trace(loaded[1]);
                }
                else {
                    loaded.push(formattedThing);
                    trace(instTickT);
                    trace(loaded[2]);
                }

        }

    }
}

enum SoundType
{
    vocals;
    instrumental;
}