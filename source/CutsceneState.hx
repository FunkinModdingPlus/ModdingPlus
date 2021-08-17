package;

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
typedef LuaAnim = {
	var prefix : String;
	@:optional var indices: Array<Int>;
	var name : String;
	@:optional var fps : Int;
	@:optional var loop : Bool;
}
enum abstract DisplayLayer(Int) from Int to Int {
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}
class VideoState extends State
{
	#if true
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			trace("Function doesn't exist, silently skipping...");
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
		}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function getHaxeActor(name:String):Dynamic {
		switch (name) {
			case "boyfriend" | "bf":
				return boyfriend;
			case "girlfriend" | "gf":
				return gf;
			case "dad":
				return dad;
			default:
				return strumLineNotes.members[Std.parseInt(name)];
		}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getHscript(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("BEHIND_GF", BEHIND_GF);
		interp.variables.set("BEHIND_BF", BEHIND_BF);
		interp.variables.set("BEHIND_DAD", BEHIND_DAD);
		interp.variables.set("BEHIND_ALL", BEHIND_ALL);
		interp.variables.set("BEHIND_NONE", 0);
		interp.variables.set("switchCharacter", switchCharacter);
		interp.variables.set("difficulty", storyDifficulty);
		interp.variables.set("bpm", Conductor.bpm);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("showOnlyStrums", false);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("mustHit", false);
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("gf", gf);
		interp.variables.set("dad", dad);
		interp.variables.set("vocals", vocals);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);
		interp.variables.set("health", health);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("window", Lib.application.window);
		// give them access to save data, everything will be fine ;)
		interp.variables.set("isInCutscene", function () return inCutscene);
		trace("set vars");
		interp.variables.set("camZooming", false);
		// callbacks
		interp.variables.set("start", function (song) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function()
		{
		});
		interp.variables.set("playerOneMiss", function()
		{
		});
		interp.variables.set("playerOneSing", function()
		{
		});
		interp.variables.set("noteHit", function(player1:Bool, note:Note, wasGoodHit:Bool) {});
		interp.variables.set("addSprite", function (sprite, position) {
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_GF != 0)
				remove(gf);
			if (position & BEHIND_DAD != 0)
				remove(dad);
			if (position & BEHIND_BF != 0)
				remove(boyfriend);
			add(sprite);
			if (position & BEHIND_GF != 0)
				add(gf);
			if (position & BEHIND_DAD != 0)
				add(dad);
			if (position & BEHIND_BF != 0)
				add(boyfriend); 
		});
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("setDefaultZoom", function(zoom) {defaultCamZoom = zoom;});
		interp.variables.set("removeSprite", function(sprite) {
			remove(sprite);
		});
		
		interp.variables.set("getHaxeActor", getHaxeActor);
		interp.variables.set("instancePluginClass", instanceExClass);
		interp.variables.set("scaleChar", function (char:String, amount:Float) {
			switch(char) {
				case 'boyfriend':
					remove(boyfriend);
					boyfriend.setGraphicSize(Std.int(boyfriend.width * amount));
					boyfriend.y *= amount;
					add(boyfriend);
				case 'dad':
					remove(dad);
					dad.setGraphicSize(Std.int(dad.width * amount));
					dad.y *= amount;
					add(dad);
				case 'gf':
					remove(gf);
					gf.setGraphicSize(Std.int(gf.width * amount));
					gf.y *= amount;
					add(gf);
			}
		});
		interp.variables.set("swapChar", function (charState:String, charTo:String) {
			switch(charState) {
				case 'boyfriend':
					remove(boyfriend);
					remove(iconP1);
					remove(camHUD);
					boyfriend = new Character(770, 450, charTo, true);
					var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
					camPos.x += boyfriend.camOffsetX;
					camPos.y += boyfriend.camOffsetY;
					boyfriend.x += boyfriend.playerOffsetX;
					boyfriend.y += boyfriend.playerOffsetY;
					if (boyfriend.likeGf) {
						boyfriend.setPosition(gf.x, gf.y);
						gf.visible = false;
						if (isStoryMode)
						{
							camPos.x += 600;
							tweenCamIn();
						}
					} else if (!dad.likeGf) {
						gf.visible = true;
					}
					boyfriend.x += bfoffset[0];
					boyfriend.y += bfoffset[1];
					iconP1 = new HealthIcon(charTo, true);
					iconP1.y = healthBar.y - (iconP1.height / 2);
					iconP1.cameras = [camHUD];
	
					// Layering nonsense
					add(boyfriend);
					add(camHUD);
					add(iconP1);
				case 'dad':
					remove(dad);
					remove(iconP2);
					remove(camHUD);
					dad = new Character(100, 100, charTo);
					var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
					dad.x += dad.enemyOffsetX;
					dad.y += dad.enemyOffsetY;
					camPos.x += dad.camOffsetX;
					camPos.y += dad.camOffsetY;
					if (dad.likeGf) {
						dad.setPosition(gf.x, gf.y);
						gf.visible = false;
						if (isStoryMode)
						{
							camPos.x += 600;
							tweenCamIn();
						}
					} else if (!boyfriend.likeGf) {
						gf.visible = true;
					}
					dad.x += dadoffset[0];
							dad.y += dadoffset[1];
					iconP2 = new HealthIcon(charTo, false);
					iconP2.y = healthBar.y - (iconP2.height / 2);
					iconP2.cameras = [camHUD];
	
					// Layering nonsense
					add(dad);
					add(camHUD);
					add(iconP2);
				case 'gf':
					remove(gf);
					remove(camHUD);
					gf = new Character(400, 130, charTo);
					gf.scrollFactor.set(0.95, 0.95);
					gf.x += gfoffset[0];
					gf.y += gfoffset[1];
					
					add(gf);
					add(camHUD);
			}
		});

		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
		
	}
	function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return exInterp.createScriptClassInstance(classname, args);
	}
	function makeHaxeExState(usehaxe:String, path:String, filename:String)
	{
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseModule(FNFAssets.getHscript(path + filename));
		trace("set stuff");
		exInterp.registerModule(program);

		trace('executed');
	}
	#end
	override public function create() {
		// this is unused fuck off
	}