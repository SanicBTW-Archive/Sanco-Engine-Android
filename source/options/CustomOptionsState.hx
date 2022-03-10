package options;

import flixel.util.FlxTimer;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import haxe.io.Path;
#if sys
import sys.FileSystem;
#end
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxG;

class CustomOptionsState extends MusicBeatState
{
    var avOptions:Array<String> = [];
    var stringOptions:Array<String> = [];

    private var grpOptions:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    var curStateSelc:Int = 0;
    var curOptionState:FlxText;
    var states:Array<Dynamic> = [];

    var hintText:FlxText;

    var categoryText:FlxText;
    var categories:Array<Categories> = [];

    override function create()
    {
        //lets bloat the thing with addOption statements
        addOption("Internal Storage Type", avOptions, ENGINE_OPTIONS, categories);
        addOption("Use Hit Sounds", avOptions, ENGINE_OPTIONS, categories);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

        grpOptions = new FlxTypedGroup<Alphabet>();
        add(grpOptions);

        for(i in 0...avOptions.length)
        {
            var avOptText:Alphabet = new Alphabet(0,(70 * i) + 30, avOptions[i], true, false);
            avOptText.isMenuItem = true;
            avOptText.targetY = i;
            grpOptions.add(avOptText);
        }

        curOptionState = new FlxText(FlxG.width * 0.7, 5, 0, "dulce te quiero", 32);
        curOptionState.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
        curOptionState.scrollFactor.set();

        var optionStateBG:FlxSprite = new FlxSprite(curOptionState.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
        optionStateBG.alpha = 0.6;
        add(optionStateBG);

        add(curOptionState);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        hintText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, "holis", 18);
		hintText.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		hintText.scrollFactor.set();
		add(hintText);

        categoryText = new FlxText(100, 50, 0, "dulce te quiero", 32);
        categoryText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
        categoryText.scrollFactor.set();
        add(categoryText);

        changeSelection();
        changeOptState(avOptions[curSelected]);

        #if mobileC
        addVirtualPad(FULL, A_B);
        #end

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK)
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
            ClientPrefs.saveSettings();
            MusicBeatState.switchState(new MainMenuState());
        }

        if(controls.UI_UP_P){
            changeSelection(-1);
        }
        if(controls.UI_DOWN_P){
            changeSelection(1);
        }

        if(controls.UI_LEFT_P)
            changeOptState(avOptions[curSelected], -1);
        if(controls.UI_RIGHT_P)
            changeOptState(avOptions[curSelected], 1);

        super.update(elapsed);
    }

    function changeSelection(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curSelected += change;
        
        scroll(avOptions, VERTICAL);

        var bullShit:Int = 0;

        for(item in grpOptions.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.4;

            if(item.targetY == 0)
                item.alpha = 1;
        }

    }

    function changeOptState(option:String, change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curStateSelc += change;

        switch(option)
        {
            case "Internal Storage Type":
                states = addOptState(avOptions[0], [StorageVariables.IntStorageUseType.BASIC, StorageVariables.IntStorageUseType.FULL, StorageVariables.IntStorageUseType.NONE]);
                scroll(states, HORIZONTAL);
                trace(states[curStateSelc]);
                saveandcheck(ClientPrefs.internalStorageUseType, states[curStateSelc], option);
            case 'Use Hit Sounds':
                states = addOptState(avOptions[1], [true, false]);
                scroll(states, HORIZONTAL);
                trace(states[curStateSelc]);
                saveandcheck(ClientPrefs.useHitSounds, states[curStateSelc], option);
        }
    }

    //optName: Option Name, the name of your option obviously lol
    //optStates: Option States, the options that you want to make available for that option, for ex ->
    //optName: Use Hit Sounds, optStates: true, false
    //maybe i will work on this again once i find a better way to store stuff
    function addOptState(optName:String, optStates:Array<Dynamic>):Array<Dynamic>
    {
        var optionStates:Array<Dynamic> = [];
        for(i in 0...optStates.length)
        {
            optionStates.push(optStates[i]);
        }
        return optionStates;
    }

    //optionName: Option Name, the name says it all
    //optArray: Option Array, push the option to an existing array, if its null it creates one
    //maybe the create array doesnt work properly
    function addOption(optionName:String, optArray:Array<String>, category:Categories, catArray:Array<Categories>)
    {
        if(category != null)
        {
            if(optArray != null){
                optArray.push(optionName);
                if(catArray != null){
                    catArray.push(category);
                }
            }
        }
    }

    function scroll(array:Array<Dynamic>, scrolltype:ScrollType)
    {
        switch(scrolltype)
        {
            case HORIZONTAL:
                if (curStateSelc < 0)
                    curStateSelc = array.length - 1;
                if(curStateSelc >= array.length)
                    curStateSelc = 0;

            case VERTICAL:
                if (curSelected < 0)
                    curSelected = array.length - 1;
                if(curSelected >= array.length)
                    curSelected = 0;
                categoryText.text = returnFunkyCategory();
                hints(avOptions[curSelected]);

        }
        refreshOptStTxt(avOptions[curSelected]);
    }

    function saveandcheck(oldState:Dynamic, newState:Dynamic, option:String)
    {
        switch(option)
        {
            case "Internal Storage Type":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.internalStorageUseType = newState;
                }
            case "Use Hit Sounds":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.useHitSounds = newState;
                }
        }
        refreshOptStTxt(option);
    }

    //kind of stupid ngl
    function funnycheck(oldState:Dynamic, newState:Dynamic):Bool{
        if(oldState != newState){
            return true; //it changed
        } else {
            return false; //didnt change
        }
        return false;
    }

    function hints(option:String)
    {
        switch(option)
        {
            case "Internal Storage Type":
                hintText.text = "Basic: Hitsounds and nothing essential for gameplay | Full: ?? | None: Don't use internal storage";
            case "Use Hit Sounds":
                hintText.text = "If there is a hit sound chosen it will play every time you hit a note";
        }
    }

    function refreshOptStTxt(option:String) 
    {
        switch(option)
        {
            case "Internal Storage Type":
                curOptionState.text = returnOptionStr(option);
            case "Use Hit Sounds":
                curOptionState.text = returnOptionStr(option);
        }
    }

    function returnOptionStr(option:String):String
    {
        var current:String = "";
        switch(option)
        {
            case "Internal Storage Type":
                switch(ClientPrefs.internalStorageUseType)
                {
                    case BASIC:
                        current = "Basic";
                    case FULL:
                        current = "Full";
                    case NONE:
                        current = "None";
                }
            
            case "Use Hit Sounds":
                switch(ClientPrefs.useHitSounds)
                {
                    case true:
                        current = "True";
                    case false:
                        current = "False";
                }
        }
        return current;
    }

    function returnFunkyCategory():String 
    {
        var current:String = "";
        switch(categories[curSelected])
        {
            case GRAPHICS:
                current = "Graphics";
            case GAMEPLAY:
                current = "Gameplay";
            case ENGINE_OPTIONS:
                current = "Engine Options";
        }
        return current;
    }
}

enum ScrollType
{
    HORIZONTAL;
    VERTICAL;
}

enum Categories
{
    GRAPHICS;
    GAMEPLAY;
    ENGINE_OPTIONS;
}