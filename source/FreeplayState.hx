package;

import Section.SwagSection;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import DifficultyIcons;
import lime.system.System;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flixel.system.FlxSound;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;

class FreeplayState extends MusicBeatState
{
	public static var currentSongList:Array<SongMetadata> = [];
	public static var soundTest:Bool = false;
	var vocals:FlxSound;
	var songs:Array<SongMetadata> = [];

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
	var usingCategoryScreen:Bool = false;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	override function create()
	{
		trace('sus');
		songs = currentSongList;

		curDifficulty = DifficultyIcons.getDefaultDiffFP();
		trace('sus');
		/*
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS
		if (soundTest) {
			// disable auto pause. I NEED MUSIC
			FlxG.autoPause = false;
		}
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue', 'preload'));
		add(bg);
		trace('sus');
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			//var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			//icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			//iconArray.push(icon);
			//add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}
		trace('sus');
		scoreText = new FlxText(FlxG.width * 0.62, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.4), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);
		trace('sus');
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		if (!soundTest)
			add(diffText);

		add(scoreText);

		changeSelection();
		changeDiff();
		trace('sus');
		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		//selector = new FlxText();

		//selector.size = 40;
		//selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		trace('sus');
		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['bf'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
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
		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;
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
		if (!soundTest) {
			if (controls.LEFT_P)
				changeDiff(-1);
			if (controls.RIGHT_P)
				changeDiff(1);
		}
		

		if (controls.BACK)
		{
			// main menu or else we are cursed
			FlxG.autoPause = true;
			if (soundTest)
				FlxG.switchState(new SaveDataState());
			else {
				var epicCategoryJs:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getText(Paths.json('freeplaySongJson', 'preload')));
				if (epicCategoryJs.length > 1)
				{
					FlxG.switchState(new CategoryState());
				} else
					FlxG.switchState(new MainMenuState());
			}
				
		}

		if (accepted)
		{
			if (soundTest) {
				// play both the vocals and inst
				// bad music >:(
				FlxG.sound.music.stop();
				if (vocals != null && vocals.playing)
					vocals.stop();
				soundTestSong = Song.loadFromJson(songs[curSelected].songName.toLowerCase(), songs[curSelected].songName.toLowerCase());
				if (soundTestSong.needsVoices)
				{
					vocals = new FlxSound().loadEmbedded(Paths.voices(soundTestSong.song));
					FlxG.sound.list.add(vocals);
					vocals.play();
					vocals.pause();
					vocals.looped = true;
				}
				FlxG.sound.playMusic(Paths.inst(soundTestSong.song));
				Conductor.mapBPMChanges(soundTestSong);
				Conductor.changeBPM(soundTestSong.bpm);
				if (soundTestSong.needsVoices) {
					resyncVocals();
				}

				
			} else {
				var poop:String = songs[curSelected].songName.toLowerCase() + DifficultyIcons.getEndingFP(curDifficulty);
				trace(poop);
				if (!FNFAssets.exists(Paths.json(songs[curSelected].songName.toLowerCase() + '/' + poop.toLowerCase() + '.json', 'preload')))
				{
					// assume we pecked up the difficulty, return to default difficulty
					trace("UH OH SONG IN SPECIFIED DIFFICULTY DOESN'T EXIST\nUSING DEFAULT DIFFICULTY");
					poop = songs[curSelected].songName;
					curDifficulty = DifficultyIcons.getDefaultDiffFP();
				}
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
				PlayState.storyWeek = songs[curSelected].week;
				PlayState.isStoryMode = false;
				ModifierState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				if (!OptionsHandler.options.skipModifierMenu)
					FlxG.switchState(new ModifierState());
				else
				{
					if (FlxG.sound.music != null)
						FlxG.sound.music.stop();
					// loading state prepares the weeks
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
			

		}
	}

	function changeDiff(change:Int = 0)
	{
		trace("line 182 fp");
		var difficultyObject:Dynamic = DifficultyIcons.changeDifficultyFreeplay(curDifficulty,change);
		curDifficulty = difficultyObject.difficulty;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedAccuracy = Highscore.getAccuracy(songs[curSelected].songName, curDifficulty);
		#end

		diffText.text = difficultyObject.text;
	}
	override function stepHit()
	{
		super.stepHit();
		if (soundTest && soundTestSong != null && soundTestSong.needsVoices)
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

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu', 'preload'), 0.4);
		trace('sussy');
		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		#if !switch
		//intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		//intendedAccuracy = Highscore.getAccuracy(songs[curSelected].songName, curDifficulty);
		// lerpScore = 0;
		trace(Paths.inst(songs[curSelected].songName));
		trace('suspeck');
		
		#end
		if (!soundTest)
		#if sys
			FlxG.sound.playMusic(FNFAssets.getSound(Paths.inst(songs[curSelected].songName)), 0);
		#else
			throw('lol you\'re using web?');
		#end
		var bullShit:Int = 0;
		trace('ssuss');
		//for (i in 0...iconArray.length)
		//{
		//	iconArray[i].alpha = 0.6;
		//}

		//iconArray[curSelected].alpha = 1;

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
