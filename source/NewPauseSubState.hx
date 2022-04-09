//the options and states are heavily based off the new options state code lol
package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class NewPauseSubState extends MusicBeatSubstate
{
    var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = [];
	//var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Chart editor', 'Character editor', 'Change Difficulty', 'Toggle Practice Mode', 'Botplay', 'Settings', 'Exit to menu'];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Settings', 'Exit to menu'];
	var difficultyChoices = [];
	var changeableSettings = [
		'Use Hit Sounds', 
		'Fullscreen', 
		'Camera Movement On Note', 
		'Change Difficulty', 
		'Practice Mode', 
		'Botplay',
		'Back'];
	var curSelected:Int = 0;
	var curStateSelc:Int = 0;
	var curOptionState:FlxText;
    var states:Array<Dynamic> = [];

	var pauseMusic:FlxSound;
	var practiceText:FlxText;
	var botplayText:FlxText;
	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var blueballedTxt:FlxText;
	//only shown if hide hud is true
	var scoreTxt:FlxText;
	var missesTxt:FlxText;
	var comboTxt:FlxText;
	var highestComboTxt:FlxText;
	var onSettings:Bool = false;
	var statsBG:FlxSprite;

    public function new(x:Float, y:Float)
    {
        super();
		menuItems = menuItemsOG;

        for (i in 0...CoolUtil.difficultyStuff.length) {
			var diff:String = '' + CoolUtil.difficultyStuff[i][0];
			difficultyChoices.push(diff);
		}
		difficultyChoices.push('Back 2 Settings');

		//music
        pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		//#region background stuff and menu options
		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, 0, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.forceX = 0;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		statsBG = new FlxSprite().makeGraphic(FlxG.width, 145, FlxColor.BLACK);
		statsBG.alpha = 0;
		statsBG.scrollFactor.set();
		add(statsBG);
		//#endregion

		var columnOne = statsBG.x + 10;
		var columnTwo = statsBG.x + 300;

		//#region stats and info stuff
		//column 1
		levelInfo = new FlxText(columnOne, statsBG.y - 50, 0, "", 32);
		levelInfo.text += PlayState.displaySongName; //change it to the dynamic values class
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		levelDifficulty = new FlxText(columnOne, statsBG.y - 50, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		blueballedTxt = new FlxText(columnOne, statsBG.y - 50, 0, "", 32);
		blueballedTxt.text = "Blueballed: " + PlayState.deathCounter;
		blueballedTxt.scrollFactor.set();
		blueballedTxt.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedTxt.updateHitbox();
		add(blueballedTxt);

		scoreTxt = new FlxText(columnOne, statsBG.y - 50, 0, "", 32);
		scoreTxt.text = "Score: " + PlayState.songScore;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font('vcr.ttf'), 32);
		scoreTxt.updateHitbox();
		scoreTxt.visible = ClientPrefs.hideHud;
		add(scoreTxt);

		//column 2
		comboTxt = new FlxText(columnTwo, statsBG.y - 50, 0, "", 32);
		comboTxt.text = "Combo: " + PlayState.combo;
		comboTxt.scrollFactor.set();
		comboTxt.setFormat(Paths.font('vcr.ttf'), 32);
		comboTxt.updateHitbox();
		comboTxt.visible = ClientPrefs.hideHud;
		add(comboTxt);

		highestComboTxt = new FlxText(columnTwo, statsBG.y - 50, 0, "", 32);
		highestComboTxt.text = "Highest Combo: " + PlayState.highestCombo;
		highestComboTxt.scrollFactor.set();
		highestComboTxt.setFormat(Paths.font('vcr.ttf'), 32);
		highestComboTxt.updateHitbox();
		highestComboTxt.visible = ClientPrefs.hideHud;
		add(highestComboTxt);

		missesTxt = new FlxText(columnTwo, statsBG.y - 50, 0, "", 32);
		missesTxt.text = "Misses: " + PlayState.songMisses;
		missesTxt.scrollFactor.set();
		missesTxt.setFormat(Paths.font('vcr.ttf'), 32);
		missesTxt.updateHitbox();
		missesTxt.visible = ClientPrefs.hideHud;
		add(missesTxt);

		//bg
		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(statsBG, {alpha: 0.8}, 0.4, {ease: FlxEase.quartInOut});
		//column one
		FlxTween.tween(levelInfo, {alpha: 1, y: rowCalc(1, levelInfo.y)}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelDifficulty, {alpha: 1, y:  rowCalc(2, levelDifficulty.y)}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(blueballedTxt, {alpha: 1, y: rowCalc(3, blueballedTxt.y)}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(scoreTxt, {alpha: 1, y: rowCalc(4, scoreTxt.y)}, 0.4, {ease: FlxEase.quartInOut});
		//column two
		FlxTween.tween(comboTxt, {alpha: 1, y:  rowCalc(1, comboTxt.y)}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(highestComboTxt, {alpha: 1, y:  rowCalc(2, highestComboTxt.y)}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(missesTxt, {alpha: 1, y: rowCalc(3, missesTxt.y)}, 0.4, {ease: FlxEase.quartInOut});
		//#endregion

		curOptionState = new FlxText(0, 5, 0, "dulce te quiero", 32);
        curOptionState.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER);
        curOptionState.scrollFactor.set();
		curOptionState.visible = false;

		add(curOptionState);

		practiceText = new FlxText(FlxG.width * 0.7, 5, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.updateHitbox();
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		botplayText = new FlxText(FlxG.width * 0.7, 30, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.updateHitbox();
		botplayText.visible = PlayState.cpuControlled;
		add(botplayText);

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		#if mobileC
		addVirtualPad(FULL, A_B);
		#end
    }

	override function update(elapsed:Float)
	{
		if(FlxG.keys.justPressed.H){

		}
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;
		var leftP = controls.UI_LEFT_P;
		var rightP = controls.UI_RIGHT_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if(leftP && onSettings)
		{
			settingsHandler(-1);
		}
		if(rightP && onSettings)
		{
			settingsHandler(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];
			//why, idk
			if(onSettings)
				optionsSelectHandler(daSelected);
			else
				selectHandler(daSelected);

		}
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		scroll(menuItems, VERTICAL);

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.5;

			if (item.targetY == 0)
			{
				item.alpha = 1;
				//curOptionState.x = item.length * 53;
			}
		}
	}

	function regenMenu():Void {
		for (i in 0...grpMenuShit.members.length) {
			this.grpMenuShit.remove(this.grpMenuShit.members[0], true);
		}
		for (i in 0...menuItems.length) {
			var item = new Alphabet(0,0, menuItems[i], true, false);
			item.isMenuItem = true;
			item.forceX = 0;
			item.targetY = i;
			grpMenuShit.add(item);
		}
		curSelected = 0;
		changeSelection();
	}

	function selectHandler(selected:String)
	{
		for (i in 0...difficultyChoices.length-1) {
			if(difficultyChoices[i] == selected) {
				var name:String = PlayState.SONG.song.toLowerCase();
				var poop = Highscore.formatSong(name, curSelected);
				PlayState.SONG = Song.loadFromJson(poop, name);
				PlayState.storyDifficulty = curSelected;
				MusicBeatState.resetState();
				FlxG.sound.music.volume = 0;
				PlayState.changedDifficulty = true;
				PlayState.cpuControlled = false;
				return;
			}
		}

		switch (selected)
		{
			case "Resume":
				close();
			case "Restart Song":
				MusicBeatState.resetState();
				FlxG.sound.music.volume = 0;
			case 'Settings':
				onSettings = true;
				curOptionState.visible = true;
				statsState(false);
				menuItems = changeableSettings;
				regenMenu();
			case "Exit to menu":
				PlayState.deathCounter = 0;
				PlayState.seenCutscene = false;
				if(PlayState.isStoryMode) {
					MusicBeatState.switchState(new StoryMenuState());
				} else {
					MusicBeatState.switchState(new FreeplayState());
				}
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				PlayState.usedPractice = false;
				PlayState.changedDifficulty = false;
				PlayState.cpuControlled = false;
			/* will move this to the new settings
			case "Chart editor":
				FlxG.switchState(new ChartingState());
			case "Character editor":
				FlxG.switchState(new CharacterEditorState());
			*/
			case 'Back 2 Settings':
				onSettings = true;
				curOptionState.visible = true;
				statsState(false);
				menuItems = changeableSettings;
				regenMenu();
		}
	}

	function rowCalc(rowNum:Int, addTo:Dynamic):Int
	{
		var row:Int = 0;
		switch(rowNum)
		{
			case 1:
				row = addTo + 55;
			case 2:
				row = addTo + 85;
			case 3:
				row = addTo + 115;
			case 4:
				row = addTo + 145;
		}
		return row;
	}

	function scroll(array:Array<Dynamic>, scrolltype:options.NewOptionsState.ScrollType)
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

        }
        curOptionState.text = returnOptionStr();
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

	function settingsHandler(change:Int = 0) 
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

        curStateSelc += change;
        var option:String = changeableSettings[curSelected];
        switch(option)
        {
            case 'Fullscreen':
                states = addOptState([true, false]);
            case 'Use Hit Sounds':
                states = addOptState([true, false]);
            case 'Camera Movement On Note':
                states = addOptState([true, false]);
			case 'Practice Mode':
				states = addOptState([true, false]);
			case 'Botplay':
				states = addOptState([true, false]);
        }
        scroll(states, HORIZONTAL);
        save(states[curStateSelc]);
	}

	function returnOptionStr():String
    {
        var current:String = "";
        var option:String = changeableSettings[curSelected];
        switch(option)
        {
			case 'Fullscreen':
				current = '${FlxG.fullscreen}';
            case "Use Hit Sounds":
                current = '${ClientPrefs.useHitSounds}';
			case 'Camera Movement On Note':
				current = '${ClientPrefs.cameraMovOnNotePress}';
			case 'Change Difficulty':
				#if android
				current = "Press A for more options";
				#else
				current = "Press ENTER for more options";
				#end
			case 'Practice Mode':
				current = '${PlayState.practiceMode}';
			case 'Botplay':
				current = '${PlayState.cpuControlled}';
			case "Back":
				current = "go back to the main menu";
        }
        return '< $current >';
    }

	function save(newState:Dynamic)
    {
        var option:String = changeableSettings[curSelected];

        switch(option)
        {
			case 'Fullscreen':
				FlxG.fullscreen = newState;
            case "Use Hit Sounds":
                ClientPrefs.useHitSounds = newState;
			case "Camera Movement On Note":
				ClientPrefs.cameraMovOnNotePress = newState;
			case 'Practice Mode':
				PlayState.practiceMode = newState;
				PlayState.usedPractice = true;
				practiceText.visible = newState;
			case 'Botplay':
				PlayState.cpuControlled = newState;
				PlayState.usedPractice = true;
				botplayText.visible = PlayState.cpuControlled;
        }
        curOptionState.text = returnOptionStr();
    }

	function optionsSelectHandler(selected:String)
	{
		switch(selected)
		{
			case 'Change Difficulty':
				onSettings = false;
				curOptionState.visible = false;
				menuItems = difficultyChoices;
				regenMenu();
			case 'Back':
				onSettings = false;
				curOptionState.visible = false;
				statsState(true);
				menuItems = menuItemsOG;
				regenMenu();
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();
	
		super.destroy();
	}

	//totally fucking dum
	function statsState(state:Bool) {
		statsBG.visible = state;
		levelInfo.visible = state;
		levelDifficulty.visible = state;
		blueballedTxt.visible = state;
		if(ClientPrefs.hideHud == true){
			scoreTxt.visible = state;
			comboTxt.visible = state;
			highestComboTxt.visible = state;
			missesTxt.visible = state;
		}
	}
}