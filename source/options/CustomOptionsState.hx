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
    //todo: order the code or put them inside a region
    var avOptions:Array<String> = [];
    var graphicsOptions:Array<String> = [
        "Low Quality", 
        "Anti-Aliasing", 
        'Persistent Cached Data', 
        #if !html5 
        'Framerate' 
        #end
    ];
    var gameplayOptions:Array<String> = [
        'Downscroll',
        'Middlescroll',
        'Ghost Tapping',
        'Note Delay',
        'Note Splashes',
        'Hide HUD',
        'Hide Song Length',
        'Flashing Lights',
        'Camera Zooms',
        #if !mobile
        'FPS Counter'
        #end
    ];
    var engineOptions:Array<String> = [
        "Internal Storage Type", 
        "Use Hit Sounds"
    ];

    private var grpOptions:FlxTypedGroup<Alphabet>;
    var curSelected:Int = 0;

    var curStateSelc:Int = 0;
    var curOptionState:FlxText;
    var states:Array<Dynamic> = [];

    var hintText:FlxText;

    var categoryText:FlxText;
    var categories:Array<Categories> = [];

    var holdTime:Float = 0;

    override function create()
    {
        setOptions();

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
            MusicBeatState.switchState(new MainMenuState());
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

    function changeOptState(change:Int = 0)
    {
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curStateSelc += change;
        var option:String = avOptions[curSelected];
        var add:Int = controls.UI_LEFT ? -1 : 1;
        switch(option)
        {
            case 'Low Quality':
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.lowQuality, states[curStateSelc]);
            case "Anti-Aliasing":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.globalAntialiasing, states[curStateSelc]);
            case "Persistent Cached Data":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.imagesPersist, states[curStateSelc]);
            case "Framerate":
                //i doubt it will work
                if(holdTime > 0.5 || controls.UI_LEFT_P || controls.UI_RIGHT_P)
                {
                    ClientPrefs.framerate += add;
                    if(ClientPrefs.framerate < 60) ClientPrefs.framerate = 60;
                    else if(ClientPrefs.framerate > 240) ClientPrefs.framerate = 240;

                    if(ClientPrefs.framerate > FlxG.drawFramerate) {
                        FlxG.updateFramerate = ClientPrefs.framerate;
                        FlxG.drawFramerate = ClientPrefs.framerate;
                    } else {
                        FlxG.drawFramerate = ClientPrefs.framerate;
                        FlxG.updateFramerate = ClientPrefs.framerate;
                    }
                }
            case "Downscroll":
                 states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.downScroll, states[curStateSelc]);
            case "Middlescroll":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.middleScroll, states[curStateSelc]);
            case "Ghost Tapping":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.ghostTapping, states[curStateSelc]);
            case "Note Delay":
                var mult:Int = 1;
				if(holdTime > 1.5) { //Double speed after 1.5 seconds holding
					mult = 2;
				}
				ClientPrefs.noteOffset += add * mult;
				if(ClientPrefs.noteOffset < 0) ClientPrefs.noteOffset = 0;
				else if(ClientPrefs.noteOffset > 500) ClientPrefs.noteOffset = 500;
            case "Note Splashes":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.noteSplashes, states[curStateSelc]);
            case "Hide HUD":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.hideHud, states[curStateSelc]);
            case "Hide Song Length":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.hideTime, states[curStateSelc]);
            case "Flashing Lights":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.flashing, states[curStateSelc]);
            case "Camera Zooms":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.camZooms, states[curStateSelc]);
            case "FPS Counter":
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.showFPS, states[curStateSelc]);
            case "Internal Storage Type":
                states = addOptState([StorageVariables.IntStorageUseType.BASIC, StorageVariables.IntStorageUseType.FULL, StorageVariables.IntStorageUseType.NONE]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.internalStorageUseType, states[curStateSelc]);
            case 'Use Hit Sounds':
                states = addOptState([true, false]);
                scroll(states, HORIZONTAL);
                save(ClientPrefs.useHitSounds, states[curStateSelc]);
        }
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
                hints();

        }
        curOptionState.text = returnOptionStr();
    }

    function save(oldState:Dynamic, newState:Dynamic) //will improve it soon
    {
        var option:String = avOptions[curSelected];
        switch(option)
        {
            case "Low Quality":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.lowQuality = newState;
                }
            case "Anti-Aliasing":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.globalAntialiasing = newState;
                }
            case "Persistent Cached Data":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.imagesPersist = newState;
                }
            case "Framerate":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.framerate = newState;
                }
            case "Downscroll":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.downScroll = newState;
                }
            case "Middlescroll":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.middleScroll = newState;
                }
            case "Ghost Tapping":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.ghostTapping = newState;
                }
            case "Note Delay":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.noteOffset = newState;
                }
            case "Note Splashes":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.noteSplashes = newState;
                }
            case "Hide HUD":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.hideHud = newState;
                }
            case "Hide Song Length":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.hideTime = newState;
                }
            case "Flashing Lights":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.flashing = newState;
                }
            case "Camera Zooms":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.camZooms = newState;
                }
            case "FPS Counter":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.showFPS = newState;
                }
            case "Internal Storage Type":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.internalStorageUseType = newState;
                }
            case "Use Hit Sounds":
                if(funnycheck(oldState, newState) == true){
                    ClientPrefs.useHitSounds = newState;
                }
        }
        curOptionState.text = returnOptionStr();
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

    function hints()
    {
        var option:String = avOptions[curSelected];
        var jaja:String = "";
        switch(option)
        {
            case "Low Quality":
                jaja = "If true, disables some background details, decreases loading times and improves performance.";
            case "Anti-Aliasing":
                jaja = "If false, disables anti-aliasing, increases performance at the cost of the graphics not looking as smooth.";
            case "Persistent Cached Data":
                jaja =  "If true, images loaded will stay in memory until the game is closed, this increases memory usage, but basically makes reloading times instant.";
            case "Framerate":
                jaja = "Pretty self explanatory, isn't it? Default value is 60.";
            case "Downscroll":
                jaja = "If true, notes go Down instead of Up, simple enough.";
            case "Middlescroll":
                jaja = "If true, hides Opponent's notes and your notes get centered.";
            case "Ghost Tapping":
                jaja = "If true, you won't get misses from pressing keys while there are no notes able to be hit.";
            case "Note Delay":
                jaja = "Changes how late a note is spawned. Useful for preventing audio lag from wireless earphones.";
            case "Note Splashes":
                jaja = "If false, hitting \"Sick!\" notes won't show particles.";
            case "Hide HUD":
                jaja = "If true, hides most HUD elements.";
            case "Hide Song Length":
                jaja = "If checked, the bar showing how much time is left will be hidden.";
            case "Flashing Lights":
                jaja = "Uncheck this if you're sensitive to flashing lights!";
            case "Camera Zooms":
                jaja = "If unchecked, the camera won't zoom in on a beat hit.";
            case "FPS Counter":
                jaja = "If unchecked, hides FPS Counter.";
            case "Internal Storage Type":
                jaja = "Basic: Hitsounds and nothing essential for gameplay | Full: ?? | None: Don't use internal storage";
            case "Use Hit Sounds":
                jaja = "If there is a hit sound chosen it will play every time you hit a note";
        }
        hintText.text = jaja;
    }

    
    function returnOptionStr():String
    {
        var current:String = "";
        var option:String = avOptions[curSelected];
        switch(option)
        {
            case "Low Quality":
                current = returnfunnyBool(ClientPrefs.lowQuality);
            case "Anti-Aliasing":
                current = returnfunnyBool(ClientPrefs.globalAntialiasing);
            case "Persistent Cached Data":
                current = returnfunnyBool(ClientPrefs.imagesPersist);
            case "Framerate":
                current = '${ClientPrefs.framerate}';
            case "Downscroll":
                current = returnfunnyBool(ClientPrefs.downScroll);
            case "Middlescroll":
                current = returnfunnyBool(ClientPrefs.middleScroll);
            case "Ghost Tapping":
                current = returnfunnyBool(ClientPrefs.ghostTapping);
            case "Note Delay":
                current = '${ClientPrefs.noteOffset}';
            case "Note Splashes":
                current = returnfunnyBool(ClientPrefs.noteSplashes);
            case "Hide HUD":
                current = returnfunnyBool(ClientPrefs.hideHud);
            case "Hide Song Length":
                current = returnfunnyBool(ClientPrefs.hideTime);
            case "Flashing Lights":
                current = returnfunnyBool(ClientPrefs.flashing);
            case "Camera Zooms":
                current = returnfunnyBool(ClientPrefs.camZooms);
            case "FPS Counter":
                current = returnfunnyBool(ClientPrefs.showFPS);
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
                current = returnfunnyBool(ClientPrefs.useHitSounds);
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

    function setOptions()
    {
        for(i in 0...graphicsOptions.length)
        {
            addOption(graphicsOptions[i], avOptions, GRAPHICS, categories);
        }

        for(i in 0...gameplayOptions.length)
        {
            addOption(gameplayOptions[i], avOptions, GAMEPLAY, categories);
        }

        for(i in 0...engineOptions.length)
        {
            addOption(engineOptions[i], avOptions, ENGINE_OPTIONS, categories);
        }
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