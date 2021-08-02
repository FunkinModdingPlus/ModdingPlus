package;

import flixel.util.typeLimit.OneOfTwo;
import FreeplayState.JsonMetadata;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import lime.system.System;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;
#end
import haxe.Json;
import tjson.TJSON;
using StringTools;

class CategoryState extends MusicBeatState
{
	var categories:Array<String> = [];
	public static var choosingFor:String = "freeplay";
	var categorySongs:Array<Array<OneOfTwo<JsonMetadata, String>>> =[];
	var categorybgs:Array<Array<String>> =[];
	var selector:FlxText;
	var curSelected:Int = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		// it's a js file to make syntax highlighting acceptable
		#if windows
		// Updating Discord Rich Presence
		Discord.DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
		var epicCategoryJs:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getText('assets/data/freeplaySongJson.jsonc'));
		if (epicCategoryJs.length > 1 || choosingFor != "freeplay") {
			for (category in epicCategoryJs) {
				categories.push(category.name);
				categorySongs.push(category.songs);
				categorybgs.push(category.bgs);
			}
		} else {
			// just set freeplay states songs to the only category
			trace(epicCategoryJs[0].songs);
			trace(epicCategoryJs[0].Bg);
			FreeplayState.currentSongList = epicCategoryJs[0].songs;
			LoadingState.loadAndSwitchState(new FreeplayState());
		}

		/*
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);
			}
		 */


		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuBGBlue.png');
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...categories.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, categories[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);
			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}





		changeSelection();
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

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}


		var upP = controls.UP_MENU;
		var downP = controls.DOWN_MENU;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}


		if (controls.BACK)
		{
			LoadingState.loadAndSwitchState(new MainMenuState());
		}
		// make sure it isn't a header
		
		if (accepted && categorySongs[curSelected].length > 0 && choosingFor == "freeplay")
		{
			var songsButData:Array<JsonMetadata> = [];
			for (song in categorySongs[curSelected])
			{
				if ((song is String))
				{
					// we have to generate our own metadata
					songsButData.push({name: song, week: -1, character: "face"});
				}
				else
				{
					songsButData.push(cast(song : JsonMetadata));
				}
			}
			FreeplayState.currentSongList = songsButData;
			LoadingState.loadAndSwitchState(new FreeplayState());

		} else if (accepted && categorySongs[curSelected].length > 0) {
			var songsButData:Array<JsonMetadata> = [];
			for (song in categorySongs[curSelected]) {
				if ((song is String)) {
					// we have to generate our own metadata
					songsButData.push({name: song, week: -1, character: "face"});
				} else {
					songsButData.push(cast (song : JsonMetadata));
				}
			}
			SortState.stuffToSort = songsButData;
			SortState.category = categories[curSelected];
			LoadingState.loadAndSwitchState(new SortState());
		} 
	}


	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = categories.length - 1;
		if (curSelected >= categories.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;
		var bullShit:Int = 0;

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
