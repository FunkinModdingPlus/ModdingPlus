package;

import haxe.ds.Option;
import OptionsHandler.TOptions;
import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Controls.KeyboardScheme;
import OptionsHandler.AccuracyMode;
// visual studio code gets pissy when you don't use conditionals
#if sys
import sys.io.File;
#end
import haxe.Json;
import tjson.TJSON;

using StringTools;
typedef TOption = {
	var name:String;
	var intName:String;
	var value:Bool;
	var desc:String;
	var ?ignore:Bool;
	var ?amount:Float;
	var ?defAmount:Float;
	var ?precision:Float;
	var ?max:Float;
	var ?min:Float;
}
class SaveDataState extends MusicBeatState
{

	var saves:FlxTypedSpriteGroup<SaveFile>;
	var options:FlxTypedSpriteGroup<Alphabet>;
	var optionMenu:FlxTypedSpriteGroup<FlxSprite>;
	// this will need to be initialized in title state!!!
	public static var optionList:Array<TOption>;
	var curSelected:Int = 0;
	var mappedOptions:Dynamic = {};
	var inOptionsMenu:Bool = false;
	var optionsSelected:Int = 0;
	var checkmarks:FlxTypedSpriteGroup<FlxSprite>;
	var numberDisplays:Array<NumberDisplay> = [];
	var preferredSave:Int = 0;
	var description:FlxText;
	override function create()
	{
		FlxG.sound.music.stop();
		var goodSound = FNFAssets.getSound('assets/music/custom_menu_music/'
			+ CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Options
			+ '/options'
			+ TitleState.soundExt);
		FlxG.sound.playMusic(goodSound);
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
			optionList = [
							{name: "Always Show Cutscenes", intName: "alwaysDoCutscenes", value: false, desc: "Force show cutscenes, even in freeplay"}, 
							{name: "Skip Modifier Menu", value: false, intName: "skipModifierMenu", desc: "Skip the modifier menu"}, 
							{name: "Skip Victory Screen", value: false, intName : "skipVictoryScreen", desc: "Skip the victory screen at the end of songs."},
							{name: "Skip Debug Screen", value: false, intName : "skipDebugScreen", desc: "Skip the warning screen that happens when you enter charting mode."},
							{name: "Downscroll", value: false, intName: "downscroll", desc: "Put da arrows on the bottom and have em scroll down"},
							{name: "Don't mute on miss", intName: "dontMuteMiss", value: false, desc: "When missing notes, don't mute vocals"},
							{name: "Judge", value: false, intName: "judge", desc: "The Judge to use.", amount: cast Judge.Jury.Classic, defAmount: cast Judge.Jury.Classic, max: 10},
							{name: "Ghost Tapping", value: false, intName: "useCustomInput", desc: "Whether to allow spamming"},
							// sorry, always ignore bad timing :penisve:
							/*{name: "Ignore Bad Timing", value: false, intName:"ignoreShittyTiming", desc: "Even with new input on, if you hit a note really poorly, it counts as a miss. This disables that."},*/
							{name: "Show Song Position", value: false, intName: "showSongPos", desc: "Whether to show the song bar."},
							{name: "Style", value: false, intName: "style", desc: "Whether to use fancy style or default to base game."},
							{
								name: "Ignore Unlocks",
								value: false,
								intName: "ignoreUnlocks",
								desc: "Show/Unlock all songs/weeks, even if you haven't met conditions."
							},
							{
								name: "New Judgement Layout",
								value: false,
								intName: "newJudgementPos",
								desc: "Put judgements in a more convenient place."
							},						
							{name: "Overwrite Judgement", value: false, intName: "preferJudgement", desc: "What judgement to display other than default, if any.", defAmount: 0, amount: 0, max: CoolUtil.coolTextFile('assets/data/judgements.txt').length - 1},
							{name: "Emulate Osu Lifts", value: false, intName: "emuOsuLifts", desc: "Whether to add lift notes at the end of sustains to force releasing buttons."},
							{name: "Show Combo Breaks", value: false, intName:"showComboBreaks", desc: "Whether to display any combo breaks by flashing the screen."},
							{name: "Funny Songs", value: false, intName: "stressTankmen", desc: "funny songs"},
							{name: "Use Kade Health", value: false, intName: "useKadeHealth", desc: "Use kade engines health numbers when healing and dealing damage"},
							{name: "Use Miss Stun", value: false, intName: "useMissStun", desc: "Prevent hitting notes for a short time after missing."},
							{name: "Don't Use Vile Rating", value: false, intName: "ignoreVile", desc: "Don't use the \"Vile\" rating"},
							{name: "Offset", value: false, intName: "offset", desc: "How much to offset notes when playing. Can fix some latency issues! Hold Control to scroll faster.", amount: 0, defAmount: 0, max: 1000, min: -1000, precision: 0.1,},
							{name: "Accuracy Mode", value: false, intName: "accuracyMode", desc: "How accuracy is calculated. Complex = uses ms timing, Simple = uses rating only", amount: 0, defAmount: 0, min: -1, max: 2,},
							{name: "Credits", value: false, intName:'credits', desc: "Show the credits!", ignore: true},
							{name: "Sound Test...", value: false, intName: 'soundtest', desc: "Listen to the soundtrack", ignore: true,},
							{name: "Controls...", value: false, intName:'controls', desc:"Edit bindings!", ignore: true,},
							{name: "Hit Sounds", value: false, intName:"hitSounds", desc: "Play a sound when hitting a note"},
							{name: "Fps Cap", value: false, intName: "fpsCap", desc: "What should the max fps be.", amount: 60, defAmount: 60, max: 240, min: 20, precision: 10,},
							{name: "Allow Story Mode", value: false, intName:"allowStoryMode", desc: "Show story mode from the main menu."},
							{name: "Allow Freeplay", value: false, intName:"allowFreeplay", desc: "Show freeplay from the main menu."},
							{name: "Allow Donate Button", value: false, intName:"allowDonate", desc: "Show the donate button from the main menu."},
							#if sys
							{name:"New Character...", value: false, intName:'newchar', desc: "Make a new character!", ignore: true,},
							{name:"New Stage...", value:false, intName:'newstage', desc: "Make a new stage!", ignore: true, },
							{name: "New Song...", value: false, intName:'newsong', desc: "Make a new song!", ignore: true, },
							{name: "New Week...", value: false, intName: 'newweek', desc: "Make a new week!", ignore: true,},
							{name: "Sort...", value: false, intName: 'sort', desc: "Sort some of your current songs/weeks!", ignore : true,}
							#end
						];
		// amount of things that aren't options
		var curOptions:TOptions = OptionsHandler.options;
		for (i in 0...optionList.length) {
			if (optionList[i].ignore)
				continue;
			Reflect.setField(mappedOptions, optionList[i].intName, optionList[i]);
			optionList[i].value = Reflect.field(curOptions, optionList[i].intName);
			if ((Reflect.field(curOptions, optionList[i].intName) is Int) || (Reflect.field(curOptions, optionList[i].intName) is Float)) {
				optionList[i].amount = Reflect.field(curOptions, optionList[i].intName);
				optionList[i].value = optionList[i].amount != optionList[i].defAmount;
			}
		}
		// we use a var because if we don't it will read the file each time
		// although it isn't as laggy thanks to assets
		
		preferredSave = curOptions.preferredSave;
		/*
		optionList[0].value = curOptions.alwaysDoCutscenes;
		optionList[1].value = curOptions.skipModifierMenu;
		optionList[2].value = curOptions.skipVictoryScreen;
		optionList[3].value = curOptions.downscroll;
		optionList[4].value = curOptions.useCustomInput;
		optionList[5].value = curOptions.DJFKKeys;
		optionList[6].value = curOptions.showSongPos;
		*/
		saves = new FlxTypedSpriteGroup<SaveFile>();
		menuBG.color = 0xFF7194fc;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		trace("before");
		for (i in 0...10) {
			var saveFile = new SaveFile(420, 0, i);

			saves.add(saveFile);
		}
		trace("x3");
		checkmarks = new FlxTypedSpriteGroup<FlxSprite>();
		options = new FlxTypedSpriteGroup<Alphabet>();
		optionMenu = new FlxTypedSpriteGroup<FlxSprite>();
		optionMenu.add(options);
		trace("hmmm");
		var curNum = 0;
		for (j in 0...optionList.length) {
			trace("l53");
			var swagOption = new Alphabet(0,0,optionList[j].name,true,false, false);
			swagOption.isMenuItem = true;
			swagOption.targetY = curNum;
			trace("l57");
			var coolCheckmark = new FlxSprite().loadGraphic('assets/images/checkmark.png');
			var numDisplay = new NumberDisplay(0, 0, optionList[j].defAmount, optionList[j].precision != null ? optionList[j].precision : 1, optionList[j].min != null ? optionList[j].min : 0, optionList[j].max);
			numDisplay.visible = optionList[j].amount != null;
			numberDisplays.push(numDisplay);
			numDisplay.value = optionList[j].amount;
			coolCheckmark.visible = optionList[j].value;
			if (optionList[j].intName == "judge") {
				switch (cast(Std.int(optionList[j].amount) : Judge.Jury))
				{
					case Judge.Jury.Classic:
						numberDisplays[j].text = "Classic";
					case Judge.Jury.Hard:
						numberDisplays[j].text = "Hard";
					default:
						numberDisplays[j].text = optionList[j].amount + 1 + "";
				}
			}
			numDisplay.size = 40;
			numDisplay.x += numDisplay.width + swagOption.width;
			checkmarks.add(coolCheckmark);
			swagOption.add(coolCheckmark);
			swagOption.add(numDisplay);
			options.add(swagOption);
			curNum++;
		}
		add(menuBG);
		add(saves);
		add(optionMenu);
		trace("hewwo");
		options.x = 10;
		optionMenu.x = FlxG.width;
		options.y = 10;
		description = new FlxText(750, 150, 350, "", 90);
		description.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		description.text = "Amongus???";
		description.scrollFactor.set();
		optionMenu.add(description);
		changeSelection();
		if (curOptions.allowEditOptions)
			swapMenus();
		super.create();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) {
			if (!saves.members[curSelected].beingSelected) {
				// our current save saves this
				// we are gonna have to do some shenanagins to save our preffered save

				saveOptions();
				saveOptions();
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new MainMenuState());
			} else {
				if (saves.members[curSelected].askingToConfirm)
					saves.members[curSelected].askToConfirm(false);
				else
					saves.members[curSelected].beSelected(false);
			}
		}
		if (inOptionsMenu || !saves.members[curSelected].askingToConfirm) {
			if (controls.UP_MENU)
			{
				if (inOptionsMenu||!saves.members[curSelected].beingSelected)
					changeSelection(-1);
			}
			if (controls.DOWN_MENU)
			{
				if (inOptionsMenu||!saves.members[curSelected].beingSelected)
					changeSelection(1);
			}
			if ((controls.RIGHT_MENU || controls.LEFT_MENU)) {
				if (saves.members[curSelected].beingSelected)
					saves.members[curSelected].changeSelection();
				else if (optionList[optionsSelected].amount != null) {

					changeAmount(controls.RIGHT_MENU);

				}	else {
					if ((OptionsHandler.options.allowEditOptions && !inOptionsMenu) || (OptionsHandler.options.useSaveDataMenu && inOptionsMenu))
						swapMenus();

				}
			}
		}
		// holding control makes changing things go WEEEEEEEEEEE
		if (FlxG.keys.pressed.CONTROL && (controls.RIGHT_MENU_H || controls.LEFT_MENU_H)) {
			if (inOptionsMenu && optionList[optionsSelected].amount != null)
			{
				changeAmount(controls.RIGHT_MENU_H);
			}
		}
		if (controls.ACCEPT) {
			if (saves.members[curSelected].beingSelected) {
				if (!saves.members[curSelected].askingToConfirm) {
					if (saves.members[curSelected].selectingLoad) {
						var saveName = "save" + curSelected;
						FlxG.save.close();
						preferredSave = curSelected;
						FlxG.save.bind(saveName, "bulbyVR");
						FlxG.sound.play('assets/sounds/custom_menu_sounds/'
							+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuConfirm+'/confirmMenu.ogg');
						// don't edit the djkf
						if (FlxG.save.data.songScores == null) {
							FlxG.save.data.songScores = ["tutorial" => 0];
						}
						Highscore.load();
					} else {
						saves.members[curSelected].askToConfirm(true);
					}

				} else {
					// this means the user confirmed!
					var oldSave = FlxG.save.name;
					var saveName = "save" + curSelected;
					FlxG.save.bind(saveName, "bulbyVR");
					FlxG.save.erase();
					saves.members[curSelected].askToConfirm(false);
					// sounds like someone farted into the mic. perfect for a delete sfx
					FlxG.sound.play('assets/sounds/freshIntro.ogg');
					FlxG.save.data.songScores = ["tutorial" => 0];
					FlxG.save.bind(oldSave, "bulbyVR");
					Highscore.load();
				}
			} else if (!inOptionsMenu) {
				FlxG.sound.play('assets/sounds/custom_menu_sounds/'
					+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt);
				saves.members[curSelected].beSelected(true);
			} else {
				switch (optionList[optionsSelected].name) {
					case "New Character...":
						// our current save saves this
						// we are gonna have to do some shenanagins to save our preffered save

						saveOptions();
						LoadingState.loadAndSwitchState(new NewCharacterState());
					case "New Stage...":
						// our current save saves this
						// we are gonna have to do some shenanagins to save our preffered save

						saveOptions();

						LoadingState.loadAndSwitchState(new NewStageState());
					case "New Song...":
						saveOptions();

						LoadingState.loadAndSwitchState(new NewSongState());
					case "New Week...":
						saveOptions();
						NewWeekState.sorted = false;
						LoadingState.loadAndSwitchState(new NewWeekState());
					case "Sort...":
						saveOptions();

						LoadingState.loadAndSwitchState(new SelectSortState());
					case "Sound Test...":
						saveOptions();
						FreeplayState.soundTest = true;
						CategoryState.choosingFor = "freeplay";
						LoadingState.loadAndSwitchState(new CategoryState());
					case "Controls...": 
						saveOptions();
						LoadingState.loadAndSwitchState(new ControlsState());
					case "Credits": 
						saveOptions();
						LoadingState.loadAndSwitchState(new CreditsState());
					default:
						if (OptionsHandler.options.allowEditOptions){
							checkmarks.members[optionsSelected].visible = !checkmarks.members[optionsSelected].visible;
							optionList[optionsSelected].value = checkmarks.members[optionsSelected].visible;
						}
						
				}

				FlxG.sound.play('assets/sounds/custom_menu_sounds/'
					+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt);
			}
		}

	}
	function changeAmount(increase:Bool=false) {
		if (!numberDisplays[optionsSelected].visible)
			return;
		numberDisplays[optionsSelected].changeAmount(increase);
		optionList[optionsSelected].amount = Std.int(numberDisplays[optionsSelected].value);
		if (numberDisplays[optionsSelected].value == numberDisplays[optionsSelected].useDefaultValue && optionList[optionsSelected].value) {
			toggleSelection();
		}
		else if (numberDisplays[optionsSelected].value != numberDisplays[optionsSelected].useDefaultValue && !optionList[optionsSelected].value) {
			toggleSelection();
		}
		if (optionList[optionsSelected].intName == "judge") {
			switch (cast (Std.int(optionList[optionsSelected].amount) : Judge.Jury)) {
				case Judge.Jury.Classic:
					numberDisplays[optionsSelected].text = "Classic";
				case Judge.Jury.Hard:
					numberDisplays[optionsSelected].text = "Hard";
				default:
					numberDisplays[optionsSelected].text = optionList[optionsSelected].amount + 1 + "";
			}
		}
		if (optionList[optionsSelected].intName == "preferJudgement") {
			var judgementList = CoolUtil.coolTextFile('assets/data/judgements.txt');
			numberDisplays[optionsSelected].text = judgementList[Std.int(optionList[optionsSelected].amount)];
		}
		if (optionList[optionsSelected].intName == "accuracyMode") {
			switch (cast (Std.int(optionList[optionsSelected].amount) : OptionsHandler.AccuracyMode)) {
				case Simple: 
					numberDisplays[optionsSelected].text = "Simple";
				case Binary:
					numberDisplays[optionsSelected].text = "Binary";
				case Complex:
					numberDisplays[optionsSelected].text = "Complex";
				case None:
					numberDisplays[optionsSelected].text = "Disable";
			}
		}
	}
	function changeSelection(change:Int = 0)
	{
		if (!inOptionsMenu) {
			FlxG.sound.play('assets/sounds/custom_menu_sounds/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt, 0.4);

			curSelected += change;

			if (curSelected < 0)
				curSelected = saves.members.length - 1;
			if (curSelected >= saves.members.length)
				curSelected = 0;


			var bullShit:Int = 0;

			for (item in saves.members)
			{
				item.targetY = bullShit - curSelected;
				bullShit++;

				item.color = 0xFF828282;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.color = 0xFFFFFFFF;
					// item.setGraphicSize(Std.int(item.width));
				}
			}
		} else {
			FlxG.sound.play('assets/sounds/custom_menu_sounds/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt, 0.4);

			optionsSelected += change;

			if (optionsSelected < 0)
				optionsSelected = options.members.length - 1;
			if (optionsSelected >= options.members.length)
				optionsSelected = 0;


			var bullShit:Int = 0;

			for (item in options.members)
			{
				item.targetY = bullShit - optionsSelected;
				bullShit++;

				item.alpha = 0.6;
				// item.setGraphicSize(Std.int(item.width * 0.8));

				if (item.targetY == 0)
				{
					item.alpha = 1;
					// item.setGraphicSize(Std.int(item.width));
				}
			}
			description.text = optionList[optionsSelected].desc;
		}

	}
	function swapMenus() {
		if (inOptionsMenu) {
			FlxTween.tween(optionMenu, {x: FlxG.width}, 0.2, {type: FlxTweenType.ONESHOT, ease: FlxEase.backInOut});
			FlxTween.tween(saves, {x: 0}, 0.2, {type: FlxTweenType.ONESHOT, ease: FlxEase.backInOut});
			inOptionsMenu = false;
		} else {
			FlxTween.tween(optionMenu, {x: 0}, 0.2, {type: FlxTweenType.ONESHOT, ease: FlxEase.backInOut});
			FlxTween.tween(saves, {x: -FlxG.width }, 0.2, {type: FlxTweenType.ONESHOT, ease: FlxEase.backInOut});
			inOptionsMenu = true;
		}
	}
	function saveOptions() {
		var noneditableoptions:Dynamic = {
			"allowEditOptions": OptionsHandler.options.allowEditOptions,
			"preferredSave": preferredSave,
			"useSaveDataMenu": true
		};
		for (field in Reflect.fields(mappedOptions)) {
			Reflect.setField(noneditableoptions, field, Reflect.field(mappedOptions, field).value);
			if (Reflect.field(mappedOptions, field).amount != null) {
				Reflect.setField(noneditableoptions, field, Reflect.field(mappedOptions, field).amount);
			}
		}
		OptionsHandler.options = noneditableoptions;
	}
	function toggleSelection() { 
		switch (optionList[optionsSelected].name)
		{
			case "New Character...":
				// our current save saves this
				// we are gonna have to do some shenanagins to save our preffered save

				saveOptions();
				LoadingState.loadAndSwitchState(new NewCharacterState());
			case "New Stage...":
				// our current save saves this
				// we are gonna have to do some shenanagins to save our preffered save

				saveOptions();

				LoadingState.loadAndSwitchState(new NewStageState());
			case "New Song...":
				saveOptions();

				LoadingState.loadAndSwitchState(new NewSongState());
			case "New Week...":
				saveOptions();
				NewWeekState.sorted = false;
				LoadingState.loadAndSwitchState(new NewWeekState());
			case "Sort...":
				saveOptions();

				LoadingState.loadAndSwitchState(new SelectSortState());
			case "Sound Test...":
				saveOptions();
				FreeplayState.soundTest = true;
				CategoryState.choosingFor = "freeplay";
				LoadingState.loadAndSwitchState(new CategoryState());
			case "Credits":
				saveOptions();
				LoadingState.loadAndSwitchState(new CreditsState());
			default:
				if (OptionsHandler.options.allowEditOptions)
				{
					checkmarks.members[optionsSelected].visible = !checkmarks.members[optionsSelected].visible;
					optionList[optionsSelected].value = checkmarks.members[optionsSelected].visible;
				}
		}
	}
}
