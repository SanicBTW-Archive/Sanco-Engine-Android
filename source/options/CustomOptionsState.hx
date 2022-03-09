package options;

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
    private var grpOptions:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;
    var curStateSelc:Int = 0;
    var hintText:String = "hello world";
    var curOptionState:FlxText;
    var stateText:String = "";
    var displayState:String = "";
    var states:Array<Dynamic> = [];
    var initialized:Bool = false;
    var whatChanged:Array<String> = [];

    override function create()
    {
        addOption("Internal Storage Type", avOptions);
        addOption("Use Hit Sounds", avOptions);

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

        curOptionState = new FlxText(FlxG.width * 0.7, 5, 0, stateText, 32);
        curOptionState.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
        curOptionState.scrollFactor.set();

        var optionStateBG:FlxSprite = new FlxSprite(curOptionState.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
        optionStateBG.alpha = 0.6;
        add(optionStateBG);

        add(curOptionState);

        var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

        var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, hintText, 18);
		text.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);

        changeSelection();
        changeOptState(avOptions[curSelected]);

        #if mobileC
        addVirtualPad(FULL, A_B);
        #end

        initialized = true;
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

        if(controls.UI_UP_P)
            changeSelection(-1);
        if(controls.UI_DOWN_P)
            changeSelection(1);

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
            case 'Use Hit Sounds':
                states = addOptState(avOptions[1], [true, false]);
                scroll(states, HORIZONTAL);
                trace(states[curStateSelc]);
        }
    }

    //optName: Option Name, the name of your option obviously lol
    //optStates: Option States, the options that you want to make available for that option, for ex ->
    //optName: Use Hit Sounds, optStates: true, false
    //maybe i will work on this again once i find a better way to store stuff
    function addOptState(optName:String, optStates:Array<Dynamic>):Array<Dynamic>
    {
        var optionStates:Array<Dynamic> = [];
        switch(optName)
        {
            case "Internal Storage Type":
                for(i in 0...optStates.length)
                {
                    optionStates.push(optStates[i]);
                }
            case 'Use Hit Sounds':
                for(i in 0...optStates.length)
                {
                    optionStates.push(optStates[i]);
                }
        }
        return optionStates;
    }

    //optionName: Option Name, the name says it all
    //optArray: Option Array, push the option to an existing array, if its null it creates one
    //maybe the create array doesnt work properly
    function addOption(optionName:String, ?optArray:Array<String>):Array<String>
    {
        var optionArray:Array<String> = [];

        if(optArray != null){
            optArray.push(optionName);
        } else {
            optionArray.push(optionName);
            return optionArray;
        }
        return optionArray;
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
                doTheFunny(STATES, false);

            case VERTICAL:
                if (curSelected < 0)
                    curSelected = array.length - 1;
                if(curSelected >= array.length)
                    curSelected = 0;
                doTheFunny(OPTIONS, false);
        }

    }

    function currentState(optionName:String):String
    {
        var current:String = "";
        switch(optionName)
        {
            case "Internal Storage Type":
                switch(ClientPrefs.internalStorageUseType)
                {
                    case BASIC:
                        current = "basic";
                    case FULL:
                        current = "full";
                    case NONE:
                        current = "none";
                }
            case 'Use Hit Sounds':
                switch(ClientPrefs.useHitSounds)
                {
                    case true:
                        current = "true";
                    case false:
                        current = "false";
                }
        }
        return current;
    }

    function doTheFunny(type:FunnyType, ?refresh:Bool = true)
    {
        if(initialized == true) 
        {
            switch(type)
            {
                case STATES:
                    for(i in 0...states.length)
                    {
                        curOptionState.text = states[i];
                    }
    
                case OPTIONS:
                    for(i in 0...avOptions.length)
                    {
                        displayState = currentState(avOptions[i]);
                        curOptionState.text = displayState;
                    }
            }
        }
    }

}

enum ScrollType
{
    HORIZONTAL;
    VERTICAL;
}

enum FunnyType
{
    STATES;
    OPTIONS;
}