package;

import flixel.input.keyboard.FlxKey;
import flixel.tweens.FlxTween;
import flixel.util.FlxGradient;
import Section.SwagSection;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flixel.system.FlxSound;
import sys.FileSystem;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var currentSongList:Array<JsonMetadata> = [];
	public static var soundTest:Bool = false;
	var vocals:FlxSound;
	var songs:Array<SongMetadata> = [];
	var bgs:Array<String> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	var soundTestSong:Song.SwagSong;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var intendedAccuracy:Float = 0;
	var lerpAccuracy:Int = 0;
	var bg:FlxSprite;
	var bgInfo:Array<String> = [];
	var bgDir:Array<String> = [];
	var bgNames:Array<String> = [];
	var categoryBG:Array<String> = [];
	var categoriesNames:Array<String> = [];
	private var iconArray:Array<HealthIcon> = [];
	var isPixelIcon:Array<Bool> = [];
	var usingCategoryScreen:Bool = false;
	var nightcoreMode:Bool = false;
	var daycoreMode:Bool = false;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	var charJson:Dynamic;
	var iconJson:Dynamic;
	var record:Record;
	var recordPixel:Record;
	var curOverlay:FlxSprite;
	var infoPanel:SongInfoPanel;
	override function create()
	{
		for (songSnippet in currentSongList) {
			var songData = new SongMetadata(songSnippet.name, songSnippet.week, songSnippet.character);
			if (songSnippet.flags == null || songSnippet.flags.length == 0)
				songs.push(songData);
			else {
				var canUse = true;
				for (flag in songSnippet.flags) {
					switch (flag) {
						case 'debug':
							#if debug
								continue;
							#else
								canUse = false;
								break;
							#end
						default:
							var reg = ~/week(\d+)/g;
							if (reg.match(flag)) {
								var week:Int = Std.parseInt(reg.matched(1));
								var diffJson = CoolUtil.parseJson(Assets.getText("assets/images/custom_difficulties/difficulties.json"));
								var difficultiesFP:Array<Dynamic> = diffJson.difficulties;
								var existsWeek = false;
								for (diff in 0...difficultiesFP.length) {
									if (Highscore.getWeekScore(week, diff) != 0) {
										existsWeek = true;
										break;
									}
										
								}
								if (existsWeek) {
									continue;
								} else {
									canUse = false;
									break;
								}
							}
							var songReg = ~/song-(.+)/g;
							if (songReg.match(flag)) {
								var songie = songReg.matched(1);
								var diffJson = CoolUtil.parseJson(Assets.getText("assets/images/custom_difficulties/difficulties.json"));
								var existsSong = false;
								for (diff in 0...diffJson.difficulties.length) {
									if (Highscore.getScore(songie, diff) != 0) {
										existsSong = true;
										break;
									}
								}
								if (!existsSong) {
									canUse = false;
									break;
								}
									
							}
					}
				}
				if (canUse) 
					songs.push(songData);
			}
		}

		curDifficulty = DifficultyIcons.getDefaultDiffFP();
		/*
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
			}
		 */
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(FNFAssets.getSound('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Menu
				+ '/freakyMenu'
				+ TitleState.soundExt));
		}
		#if windows
		// Updating Discord Rich Presence
		Discord.DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		var isDebug:Bool = false;
		charJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_chars/custom_chars.jsonc'));
		iconJson = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_chars/icon_only_chars.json"));
		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS
		if (soundTest) {
			// disable auto pause. I NEED MUSIC
			FlxG.autoPause = false;
			curDifficulty = 0;
		}
		// imagine making a sprite and not assigning a var
		bg =  new FlxSprite();
		if (FNFAssets.exists('assets/images/Custom_Menu_BGs/Default/menuDesat.png')) {
			bg.loadGraphic('assets/images/Custom_Menu_BGs/Default/menuDesat.png');
 		} else {
			 bg.loadGraphic('assets/images/menuDesat.png');
		 }
		add(bg);
		// no fancy :)
		//curOverlay = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, [FlxColor.WHITE]);

		//add(curOverlay); 
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, false, null, null, null, true);
			if (!OptionsHandler.options.style) {
				songText.itemType = "Classic";
			}
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			// icons won't be visible 
			icon.visible = !OptionsHandler.options.style;
			iconArray.push(icon);
			add(icon);
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		
		scoreText = new FlxText(FlxG.width * 0.62, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		if (!soundTest && OptionsHandler.options.style) {
			diffText.x = scoreText.x;
			diffText.y = scoreText.y;
			diffText.size = scoreText.size;
		}
		diffText.font = scoreText.font;
		add(diffText);
		if (soundTest || !OptionsHandler.options.style)
			add(scoreText);
		var curCharacter = songs[0].songCharacter;
		
		if (OptionsHandler.options.style) {
			record = new Record(FlxG.width, FlxG.height, Reflect.field(charJson, curCharacter).colors, songs[0].week, Highscore.getComplete(songs[0].songName, curDifficulty));
			// DON'T update hitbox, it breaks everything
			record.scale.set(0.7, 0.7);
			record.x -= record.width / 1.5;
			record.y -= record.height / 1.5;
			add(record);
		}
		infoPanel = new SongInfoPanel(FlxG.width - 500, 100, songs[0].songName, curDifficulty);
		if (!soundTest && OptionsHandler.options.style)
			add(infoPanel);
		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic('assets/music/title' + TitleState.soundExt, 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/*
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */
		
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		// :grief: what
		if (FlxG.sound.music.volume < 0.7 && (!soundTest || curDifficulty != 2))
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}
		// why the fuck does this exist
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		lerpAccuracy = Std.int(Math.round(intendedAccuracy * 100));
		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (!soundTest)
			scoreText.text = "PERSONAL BEST:" + lerpScore + ", " + lerpAccuracy + "%";
		else
			scoreText.text = "Sound Test";
		var upP = controls.UP_MENU;
		var downP = controls.DOWN_MENU;
		var accepted = controls.ACCEPT;
		#if debug
		if (FlxG.keys.justPressed.F5) {
			Highscore.saveScore('Tutorial', 0, 1, 0, Sick);
		}
		#end
		if (soundTest && soundTestSong != null) {
			Conductor.songPosition += FlxG.elapsed * 1000;
		}
		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}
		if (controls.LEFT_MENU)
			changeDiff(-1);
		if (controls.RIGHT_MENU)
			changeDiff(1);
		
		if (controls.TERTIARY)
			infoPanel.changeDisplay(-1);
		else if (controls.SECONDARY)
			infoPanel.changeDisplay(1);
		if (controls.BACK)
		{
			// main menu or else we are cursed
			FlxG.autoPause = true;
			if (soundTest)
				LoadingState.loadAndSwitchState(new SaveDataState());
			else {
				var epicCategoryJs:Array<Dynamic> = CoolUtil.parseJson(Assets.getText('assets/data/freeplaySongJson.jsonc'));
				if (epicCategoryJs.length > 1)
				{
					LoadingState.loadAndSwitchState(new CategoryState());
				} else
					LoadingState.loadAndSwitchState(new MainMenuState());
			}
				
		}

		if (accepted)
		{
			// im shortening this for my mind to be at rest
			if (soundTest)
			{
				// play both the vocals and inst
				// bad music >:(
				var suffix = "";
				if (nightcoreMode)
					suffix = "-Nightcore";
				if (daycoreMode)
					suffix = "-Daycore";
				var shit = "";
				
				FlxG.sound.music.stop();
				if (vocals != null && vocals.playing)
					vocals.stop();
				soundTestSong = Song.loadFromJson(songs[curSelected].songName.toLowerCase(), songs[curSelected].songName.toLowerCase());
				if (soundTestSong.needsVoices)
				{
					if (OptionsHandler.options.stressTankmen
						&& FNFAssets.exists("assets/music/" + soundTestSong.song + "Shit" + suffix + "_Voices" + TitleState.soundExt))
						shit = "Shit";
					var vocalSound = FNFAssets.getSound("assets/music/" + soundTestSong.song + shit + suffix + "_Voices" + TitleState.soundExt);
					vocals = new FlxSound().loadEmbedded(vocalSound);
					vocals.volume = curDifficulty != 1 ? 1 : 0;
					FlxG.sound.list.add(vocals);
					vocals.play();
					vocals.pause();
					vocals.looped = true;
				}
				if (OptionsHandler.options.stressTankmen
					&& FNFAssets.exists("assets/music/" + soundTestSong.song + "Shit" + suffix + "_Inst" + TitleState.soundExt))
					shit = "Shit";
				else
					shit = "";
				FlxG.sound.playMusic(FNFAssets.getSound("assets/music/" + soundTestSong.song + suffix + "_Inst" + TitleState.soundExt), curDifficulty == 2 ? 0 : 1);
				Conductor.mapBPMChanges(soundTestSong);
				Conductor.changeBPM(soundTestSong.bpm);
				if (soundTestSong.needsVoices)
				{
					resyncVocals();
				}
			}
			else
			{
				var poop:String = songs[curSelected].songName.toLowerCase() + DifficultyIcons.getEndingFP(curDifficulty);
				trace(poop);
				if (!FNFAssets.exists('assets/data/' + songs[curSelected].songName.toLowerCase() + '/' + poop.toLowerCase() + '.json'))
				{
					// assume we pecked up the difficulty, return to default difficulty
					trace("UH OH SONG IN SPECIFIED DIFFICULTY DOESN'T EXIST\nUSING DEFAULT DIFFICULTY");
					poop = songs[curSelected].songName;
					curDifficulty = DifficultyIcons.getDefaultDiffFP();
				}
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.isStoryMode = false;
				ModifierState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				if (!OptionsHandler.options.skipModifierMenu)
					LoadingState.loadAndSwitchState(new ModifierState());
				else
				{
					if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					LoadingState.loadAndSwitchState(new PlayState(), true);
				}
			}
			

		}
	}

	function changeDiff(change:Int = 0)
	{
		if (!soundTest) {
			// get valid one : )
			// also forces
			var difficultyObject:Dynamic = DifficultyManager.changeDifficultySans(curDifficulty, change, songs[curSelected].songName);
			curDifficulty = difficultyObject.difficulty;

			#if !switch
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedAccuracy = Highscore.getAccuracy(songs[curSelected].songName, curDifficulty);
			#end

			diffText.text = difficultyObject.text;
		} else {
			curDifficulty += change;
			if (curDifficulty > 2) {
				curDifficulty = 0;
			}
			if (curDifficulty < 0) {
				curDifficulty = 2;
			}
			switch (curDifficulty) {
				case 0:
					diffText.text = "Both tracks";
				case 1:
					diffText.text = "Inst Only";
				case 2:
					diffText.text = "Vocals Only";
			}
			
		}
		// do it here for the sweet sweet gold record
		infoPanel.changeSong(songs[curSelected].songName, curDifficulty);
		if (OptionsHandler.options.style)
		{
			var coolors = ["black"];
			if (Reflect.hasField(charJson, songs[curSelected].songCharacter))
			{
				coolors = Reflect.field(charJson, songs[curSelected].songCharacter).colors;
			}
			else
			{
				coolors = Reflect.field(iconJson, songs[curSelected].songCharacter).colors;
			}
			record.changeColor(coolors, songs[curSelected].songCharacter, songs[curSelected].week,
				songs[curSelected].songName, curDifficulty);
		}
	}
	override function stepHit()
	{
		super.stepHit();
		if (soundTest && soundTestSong != null && soundTestSong.needsVoices && curDifficulty == 0)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}
	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play('assets/sounds/custom_menu_sounds/'+CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll+'/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedAccuracy = Highscore.getAccuracy(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		#end
		// comment out because lag?
		// if (!soundTest)
		//	FlxG.sound.playMusic(FNFAssets.getSound("assets/music/"+songs[curSelected].songName+"_Inst"+TitleState.soundExt), 0);
		var bullShit:Int = 0;
		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;
		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		/*
		var dealphaedColors:Array<FlxColor> = [];
		for (color in (Reflect.field(charJson,songs[curSelected].songCharacter).colors : Array<String>)) {
			var newColor = FlxColor.fromString(color);
			newColor.alphaFloat = 0.5;
			dealphaedColors.push(newColor);
		}*/
		//remove(curOverlay);
		//curOverlay = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, dealphaedColors);
		//insert(1, curOverlay);
		
		changeDiff();
		// trace(Highscore.getComplete(songs[0].songName, curDifficulty));
		
		var coolors = ["black"];
		if (Reflect.hasField(charJson, songs[curSelected].songCharacter)) {
			coolors = Reflect.field(charJson, songs[curSelected].songCharacter).colors;
		} else {
			coolors = Reflect.field(iconJson, songs[curSelected].songCharacter).colors;
		}
		FlxTween.color(bg,0.5, bg.color, FlxColor.fromString(coolors[0]));
		/*
		if (OptionsHandler.options.style) {
			record.changeColor(coolors, songs[curSelected].songCharacter, songs[curSelected].week,
				songs[curSelected].songName, curDifficulty);
			
		}*/
		
		infoPanel.changeSong(songs[curSelected].songName, curDifficulty);
	}
}
class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";

	public function new(song:String, week:Int, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}
typedef JsonMetadata = {
	var name:String;
	var week:Int;
	var character:String;
	var ?flags:Array<String>;
}