package;
#if cpp
import Sys.sleep;
import discord_rpc.DiscordRpc;
#end
import openfl.Lib;
import flixel.util.typeLimit.OneOfTwo;
import Character.EpicLevel;
import FNFAssets.HScriptAssets;
import flixel.ui.FlxButton.FlxTypedButton;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.FlxGame;
import flixel.FlxObject;
#if desktop
import Sys;
import sys.FileSystem;
#end
#if cpp
import Discord.DiscordClient;
#end
import DifficultyIcons;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSubState;
import flash.display.BitmapData;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import lime.system.System;
import openfl.media.Sound;
import flixel.group.FlxGroup;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;

#end
import tjson.TJSON;
import Judgement.TUI;
using StringTools;
using CoolUtil.FlxTools;
using StringTools;

class DiscordClient
{
	public function new()
	{
		var curID:Array<String> = [];
		var curName:Array<String> = [];
        #if cpp
		trace("Discord Client starting...");
		DiscordRpc.start({
			clientID: CoolUtil.parseJson(FNFAssets.getJson("assets/data/discordShit")).curID,
			onReady: onReady,
			onError: onError,
			onDisconnected: onDisconnected
		});
		trace("Discord Client started.");

		while (true)
		{
			DiscordRpc.process();
			sleep(2);
			// trace("Discord Client Update");
		}

		DiscordRpc.shutdown();
        #end
	}

	public static function shutdown()
	{
        #if cpp
		DiscordRpc.shutdown();
        #end
	}

	static function onReady()
	{
        #if cpp
		DiscordRpc.presence({
			details: "In the Menus",
			state: null,
			largeImageKey: 'icon',
			largeImageText: CoolUtil.parseJson(FNFAssets.getJson("assets/data/discordShit")).curName;
		});
        #end
	}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
        #if cpp
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
        #end
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float,
			?smallImageString:String)
	{
        #if cpp
		var startTimestamp:Float = if (hasStartTimestamp) Date.now().getTime() else 0;

		if (endTimestamp > 0)
		{
			endTimestamp = startTimestamp + endTimestamp;
		}
		if (smallImageKey == null) {
			smallImageKey = "icon";
		}
		if (smallImageString == null) {
			smallImageString = 	CoolUtil.parseJson(FNFAssets.getJson("assets/data/discordShit")).curName;
		}
		DiscordRpc.presence({
			details: details,
			state: state,
			largeImageKey: smallImageKey,
			largeImageText: smallImageString,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp: Std.int(startTimestamp / 1000),
			endTimestamp: Std.int(endTimestamp / 1000)
		});
        #end
		// trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}
