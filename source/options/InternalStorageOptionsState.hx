package options;

import options.NewOptionsState;
import ui.Mobilecontrols;
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

class InternalStorageOptionsState extends MusicBeatState
{
    //heavily based off the new options state
    var avOptions:Array<String> = [];

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
        addOption("Use External Charts", avOptions, STORAGE_OPTIONS , categories);
        addOption("Use External Characters", avOptions, STORAGE_OPTIONS , categories);

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

        #if mobileC
        addVirtualPad(FULL, A_B);
        #end

        super.create();
    }

    override function update(elapsed:Float)
    {
        if(controls.BACK)
        {
            ClientPrefs.saveSettings();
            MusicBeatState.switchState(new NewOptionsState());
        }

        if(controls.UI_UP_P){
            changeSelection(-1);
        }
        if(controls.UI_DOWN_P){
            changeSelection(1);
        }

        if(controls.UI_LEFT_P)
            changeOptState(-1);
        if(controls.UI_RIGHT_P)
            changeOptState(1);

        super.update(elapsed);
    }

    //#region Options Handler
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

            item.alpha = 0.5;

            if(item.targetY == 0)
                item.alpha = 1;
        }

    }

    function addOption(optionName:String, optArray:Array<String>, category:NewOptionsState.Categories, catArray:Array<Categories>)
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
    //#endregion


    //#region Option States Handler
    function changeOptState(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curStateSelc += change;
        var option:String = avOptions[curSelected];
        switch(option)
        {
            case "Use External Charts":
                states = addOptState([true, false]);
            case "Use External Characters":
                states = addOptState([true, false]);
        }
        scroll(states, HORIZONTAL);
        save(states[curStateSelc]);
    }

    function addOptState(optStates:Array<Dynamic>):Array<Dynamic>
    {
        var optionStates:Array<Dynamic> = [];
        for(i in 0...optStates.length)
        {
            optionStates.push(optStates[i]);
        }
        return optionStates;
    }
    //#endregion

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
                hints();

        }
        curOptionState.text = returnOptionStr();
    }

    function save(newState:Dynamic)
    {
        var option:String = avOptions[curSelected];

        switch(option)
        {
            case "Use External Charts":
                ClientPrefs.useExternalCharts = newState;
            case "Use External Characters":
                ClientPrefs.useExternalCharacters = newState;
        }
        curOptionState.text = returnOptionStr();
    }

    function hints()
    {
        var option:String = avOptions[curSelected];
        var jaja:String = "";
        switch(option)
        {
            case "Use External Charts":
                jaja = "Enables compatibility of the data folder when trying to play charts";
            case "Use External Characters":
                jaja = "Enables the characters folder for your custom characters (Feature not implemented yet)";
        }
        hintText.text = jaja;
    }

    
    function returnOptionStr():String
    {
        var current:String = "";
        var option:String = avOptions[curSelected];
        switch(option)
        {
            case "Use External Charts":
                current = returnfunnyBool(ClientPrefs.useExternalCharts);
            case "Use External Characters":
                current = returnfunnyBool(ClientPrefs.useExternalCharacters);
        }
        return current;
    }

    //#region Helper
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
            case STORAGE_OPTIONS:
                current = "Storage Options";
        }
        return current;
    }


    function returnfunnyBool(condtion:Bool):String
    {
        var current:String = "";
        switch(condtion)
        {
            case true:
                current = "true";
            case false:
                current = "false";
        }
        return current;
    }
    //#endregion
}