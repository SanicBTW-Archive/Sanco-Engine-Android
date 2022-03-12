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

class MoveMusicState extends MusicBeatState
{
    var songs:Array<String> = [];
    var songsInstPaths:Array<String> = [];
    var songsVoicesPaths:Array<String> = [];
    var songsChartPaths:Array<String> = [];
    private var grpSongs:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var checkText:FlxText;
    var songCheck:Array<String> = [];

    override function create()
    {
        var initSongList = CoolUtil.coolTextFile(StorageVariables.CustomSF);
        for(i in 0...initSongList.length)
        {
            PushAndCheck(initSongList, i);
        }

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

        changeSelection();
        
        #if android
        addVirtualPad(UP_DOWN, A_B);
        #end

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
            var folder:String = songs[curSelected];
            var instDir:String = Path.join(['assets', 'songs', '${folder.toLowerCase()}']);
            var voicesDir:String = Path.join(['assets', 'songs', '${folder.toLowerCase()}']);
            var chartDir:String = Path.join(['assets', 'data', '${folder.toLowerCase()}']);

            var instPath:String = Path.join([instDir, 'Inst.${Paths.SOUND_EXT}']);
            var voicesPath:String = Path.join([voicesDir, 'Voices.${Paths.SOUND_EXT}']);
            var chartPath:String = Path.join([chartDir, '${songs[curSelected]}.json']);
            trace(folder);
            trace(instPath);
            trace(voicesPath);
            if(songCheck[curSelected] == "Everything alright")
            {
                //move chart, inst and vocals
                StorageVariables.copySongIntoAssets(instDir, songsInstPaths[curSelected], instPath);
                StorageVariables.copySongIntoAssets(voicesDir, songsVoicesPaths[curSelected], voicesPath);
                StorageVariables.copySongIntoAssets(chartDir, songsChartPaths[curSelected], chartPath);

            }
            else if(songCheck[curSelected] == "Voice and Inst")
            {
                //move voice and inst
                StorageVariables.copySongIntoAssets(instDir, songsInstPaths[curSelected], instPath);
                StorageVariables.copySongIntoAssets(voicesDir, songsVoicesPaths[curSelected], voicesPath);
            }
            else
            {
                StorageVariables.copySongIntoAssets(instDir, songsInstPaths[curSelected], instPath);
            }

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

        for (item in grpSongs.members){
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;

            if(item.targetY == 0)
                item.alpha = 1;
        }

        checkText.text = songCheck[curSelected];
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
}