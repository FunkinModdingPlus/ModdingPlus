package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import lime.app.Application;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.FlxObject;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import sys.FileSystem;
import Song.SwagSong;
#end
import tjson.TJSON;
using StringTools;
typedef VersionJson = {
	var version: String;
	var name_1: String;
	var name_2: String;
	var name_3: String;

}
	
class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var customMenuConfirm: Array<Array<String>>;
	var customMenuScroll: Array<Array<String>>;
	var parsedcustomMenuConfirmJson:Array<Array<String>>;
	var menuItems:FlxTypedGroup<FlxSprite>;
	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end
	var menuSoundJson:Dynamic;
	var scrollSound:String;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var version:String = "";
	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		Discord.DiscordClient.changePresence("In Menus", null);
		#end
		menuSoundJson = CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json"));
		scrollSound = menuSoundJson.customMenuScroll;
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;
		if (!OptionsHandler.options.allowStoryMode) 
			optionShit.remove("story mode");
		if (!OptionsHandler.options.allowFreeplay) 
			optionShit.remove("freeplay");
		if (!OptionsHandler.options.allowDonate) 
			optionShit.remove("donate");
		if (!OptionsHandler.options.useSaveDataMenu && !OptionsHandler.options.allowEditOptions) 
			optionShit.remove("options");
		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(FNFAssets.getSound('assets/music/custom_menu_music/'
				+ CoolUtil.parseJson(FNFAssets.getText("assets/music/custom_menu_music/custom_menu_music.json")).Menu+'/freakyMenu' + TitleState.soundExt));
		}
		
		persistentUpdate = persistentDraw = true;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic('assets/images/menuDesat.png');
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.18;
		magenta.setGraphicSize(Std.int(magenta.width * 1.2));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = FlxAtlasFrames.fromSparrow('assets/images/FNF_main_menu_assets.png', 'assets/images/FNF_main_menu_assets.xml');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, 100 + (i * 160));
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.x = 450;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			FlxTween.tween(menuItem, { x: menuItem.x , y: 60 + (i * 160) }, 2, { ease: FlxEase.quadOut });
		}

		FlxG.camera.follow(camFollow, null, 0.06);
		var infoJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson("assets/data/gameInfo"));
		if (infoJson.version != "") {
			infoJson.version = " - " + infoJson.version; 
		}
		// ok, if you can't fucking code then don't edit the fucking code
		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "v"+ Application.current.meta.get("version") + infoJson.version, 12);
		#if !final
		versionShit.text += "-" + FNFAssets.getText('VERSION');
		#end
		version = versionShit.text;
		var usingSave:FlxText = new FlxText(5, FlxG.height - 36, 0, FlxG.save.name, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		usingSave.scrollFactor.set();
		usingSave.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		if (OptionsHandler.options.useSaveDataMenu)
			add(usingSave);
		// NG.core.calls.event.logEvent('swag').send();
		switch (FlxG.save.name) {
			case "save0":
				usingSave.text = "bf";
			case "save1":
				usingSave.text = "classic";
			case "save2":
				usingSave.text = "bf-pixel";
			case "save3":
				usingSave.text = "spooky";
			case "save4":
				usingSave.text = "dad";
			case "save5":
				usingSave.text = "pico";
			case "save6":
				usingSave.text = "mom";
			case "save7":
				usingSave.text = "gf";
			case "save8":
				usingSave.text = "lemon";
			case "save9":
				usingSave.text = "senpai";
		}

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!selectedSomethin)
		{
			if (controls.UP_MENU)
			{
				FlxG.sound.play('assets/sounds/custom_menu_sounds/'
				+ menuSoundJson.customMenuScroll +'/scrollMenu' + TitleState.soundExt);
				changeItem(-1);
			}

			if (controls.DOWN_MENU)
			{
				FlxG.sound.play('assets/sounds/custom_menu_sounds/'
				+ menuSoundJson.customMenuScroll +'/scrollMenu' + TitleState.soundExt);
				changeItem(1);
			}

			if (controls.BACK)
			{
				LoadingState.loadAndSwitchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					#if linux
					Sys.command('/usr/bin/xdg-open', [FNFAssets.getText("assets/data/donate_button_link.txt"), "&"]);
					#else
					FlxG.openURL(FNFAssets.getText("assets/data/donate_button_link.txt"));
					#end
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play('assets/sounds/custom_menu_sounds/'
					+ menuSoundJson.customMenuConfirm+'/confirmMenu' + TitleState.soundExt);

					FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										LoadingState.loadAndSwitchState(new StoryMenuState());
										trace("Story Menu Selected");
									case 'freeplay':
										CategoryState.choosingFor = "freeplay";
										var epicCategoryJs:Array<Dynamic> = CoolUtil.parseJson(FNFAssets.getJson('assets/data/freeplaySongJson'));
										FreeplayState.soundTest = false;
										if (epicCategoryJs.length > 1)
										{
											LoadingState.loadAndSwitchState(new CategoryState());
										}  else {
											FreeplayState.currentSongList = epicCategoryJs[0].songs;
											LoadingState.loadAndSwitchState(new FreeplayState());
										}
										
									case 'options':
										LoadingState.loadAndSwitchState(new SaveDataState());
								}
							});
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
	}
}
