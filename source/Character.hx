package;

import hscript.Expr;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import hscript.Interp;
import hscript.ParserEx;
import haxe.xml.Parser;
import hscript.InterpEx;
import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import lime.utils.Assets;
import flixel.FlxG;
import lime.system.System;
import lime.app.Application;
import flixel.system.FlxSound;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
#end
import haxe.Json;
import tjson.TJSON;
import haxe.format.JsonParser;
using StringTools;
enum abstract EpicLevel(Int) from Int to Int {
	var Level_NotAHoe = 0;
	var Level_Boogie = 1;
	var Level_Sadness = 2;
	var Level_Sing = 3;

	@:op(A > B) static function gt(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A >= B) static function gte(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A == B) static function equals(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A != B) static function nequals(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A < B) static function lt(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A <= B) static function lte(a:EpicLevel, b:EpicLevel):Bool;
}
typedef TCharacterRefJson = {
	var like:String;
	var icons:Array<Int>;
	var ?colors:Array<String>;
}
class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var altAnim:String = "";
	public var altNum:Int = 0;
	public var enemyOffsetX:Int = 0;
	public var enemyOffsetY:Int = 0;
	public var playerOffsetX:Int = 0;
	public var playerOffsetY:Int = 0;
	public var camOffsetX:Int = 0;
	public var camOffsetY:Int = 0;
	public var followCamX:Int = 150;
	public var followCamY:Int = -100;
	public var midpointX:Int = 0;
	public var midpointY:Int = 0;
	public var isCustom:Bool = false;
	public var holdTimer:Float = 0;
	public var animationNotes:Array<Dynamic> = [];
	public var like:String = "bf";
	public var beNormal:Bool = true;
	/**
	 * Color used by default for enemy, when not in duo mode or oppnt play.
	 */
	public var enemyColor:FlxColor = 0xFFFF0000;
	/**
	 * Color used by default for enemy in duo mode and oppnt play.
	 */
	public var opponentColor:FlxColor = 0xFFE7C53C;
	/**
	 * Color used by player while not in duo mode or oppnt play.
	 */
	public var playerColor:FlxColor = 0xFF66FF33;
	/**
	 * Color used by player when poisoned in fragile funkin.
	 */
	public var poisonColor:FlxColor = 0xFFA22CD1;
	/**
	 * Color used by enemy when poisoned in fragile funkin. 
	 */
	public var poisonColorEnemy:FlxColor = 0xFFEA2FFF;
	/**
	 * Color used by player in duo mode or oppnt play.
	 */
	public var bfColor:FlxColor = 0xFF149DFF;
	// sits on speakers, replaces gf
	public var likeGf:Bool = false;
	// uses animation notes
	public var hasGun:Bool = false;
	public var stunned(get, default):Bool = false;
	public var beingControlled:Bool = false;
	/**
	 * how many animations our current gf supports. 
	 * acts like a level meter, 0 means we aren't gf,
	 * 1 means we support the least animations (i think pixel-gf)
	 * 2 means we support the middle amount of animations (i think gf-tankmen)
	 * 3 means we support the full amount of animations (regular gf)
	 * you can have an epic level lower than your actual animations, 
	 * but the game will be safe and act like you don't have one.
	 */
	public var gfEpicLevel:EpicLevel = Level_NotAHoe;
	// like bf, is playable
	public var likeBf:Bool = false;
	public var isDie:Bool = false;
	public var isPixel:Bool = false;
	private var interp:Interp;
	function get_stunned():Bool {
		if (OptionsHandler.options.useMissStun){
			return stunned;
		}
		return false;
	}
	function callInterp(func_name:String, args:Array<Dynamic>) {
		if (interp == null) return;
		if (!interp.variables.exists(func_name)) return;
		var method = interp.variables.get(func_name);
		switch (args.length)
		{
			case 0:
				method();
			case 1:
				method(args[0]);
			case 2:
				method(args[0], args[1]);
		}
	}
	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		curCharacter = curCharacter.trim();
		trace(curCharacter);
		isCustom = true;
		if (StringTools.endsWith(curCharacter, "-dead"))
		{
			isDie = true;
			curCharacter = curCharacter.substr(0, curCharacter.length - 5);
		}
		trace(curCharacter);
		var charJson:Dynamic = null;
		var isError:Bool = false;
		charJson = CoolUtil.parseJson(Assets.getText('assets/images/custom_chars/custom_chars.jsonc'));
		interp = Character.getAnimInterp(curCharacter);
		callInterp("init", [this]);
		dance();

		if (isPlayer)
		{
			flipX = !flipX;
			// Doesn't flip for BF, since his are already in the right place???
			if (!likeBf && !isDie)
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}
	public function sing(direction:Int, ?miss:Bool=false, ?alt:Int=0) {
		var directName:String = "";
		var missName:String = "";
		switch (direction) {
			case 0:
				directName = "singLEFT";
			case 1:
				directName = "singDOWN";
			case 2:
				directName = "singUP";
			case 3:
				directName = "singRIGHT";
		}
		var missSupported:Bool = false;
		var missAltSupported:Bool = false;
		if (miss) {
			missName = "miss";
			if (animation.getByName(directName + missName) != null) {
				missSupported = true;
			}
			if (alt > 0)
			{
				if (alt == 1 && animation.getByName(directName + missName + '-alt') != null)
				{
					missAltSupported = true;
				}
				else if (alt > 1 && animation.getByName(directName + missName +"-" + alt + "alt") != null)
				{
					missAltSupported = true;
				}
			}
			if (missSupported && (alt == 0 || missAltSupported))
				directName += missName;
		} 
		if (alt > 0 && (!miss || missAltSupported))
		{
			if (alt == 1 && animation.getByName(directName + '-alt') != null)
			{
				directName += "-alt";
			}
			else if (alt > 1 && animation.getByName(directName + "-" + alt + "alt") != null)
			{
				directName += "-" + alt + "alt";
			}
		}
		// if we have to miss, but miss isn't supported...
		if (miss && !(missSupported)) {
			// first, we don't want to be using alt, which is already handled.
			// second, we don't want no animation to be played, which again is handled.
			// third, we want character to turn purple, which is handled here.
			color = 0xCFAFFF;
		}
		else if (color != FlxColor.WHITE)
		{
			color = FlxColor.WHITE;
		}
		if (alt > 0) {
			if (alt == 1 && animation.getByName(directName + '-alt') != null) {
				directName += "-alt";
			} else if (alt > 1 &&  animation.getByName(directName + "-" + alt + "alt") != null) {
				directName += "-" + alt + "alt";
			}
		}
		playAnim(directName, true);
	}
	override function update(elapsed:Float)
	{

		//curCharacter = curCharacter.trim();
		//var charJson:Dynamic = Json.parse(Assets.getText('assets/images/custom_chars/custom_chars.json'));
		//var animJson = File.getContent("assets/images/custom_chars/"+Reflect.field(charJson,curCharacter).like+".json");
		if (beingControlled)
		{
			if (!debugMode)
			{
				if (animation.curAnim.name.startsWith('sing'))
				{
					holdTimer += elapsed;
				}
				else
					holdTimer = 0;

				if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode && beNormal)
				{
					playAnim('idle', true, false, 10);
					trace("idle after miss");
				}

				if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
				{
					playAnim('deathLoop');
				}
			}
		}
		//if (!StringTools.contains(animJson, "firstDeath") && like != "bf-pixel") //supposed to fix note anim shit for bfs with unique jsons, currently broken
		if (!beingControlled)
		{
			if (animation.curAnim != null && animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;
	
			if (interp != null)
			{
				dadVar = interp.variables.get("dadVar");
			}
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}
		if (hasGun) {
			if (0 < animationNotes.length && Conductor.songPosition > animationNotes[0][0]) {
				var idkWhatThisISLol = 1;
				if (2 <= animationNotes[0][1]) {
					idkWhatThisISLol = 3;				
				}

				idkWhatThisISLol += FlxG.random.int(0, 1);
				playAnim("shoot" + idkWhatThisISLol, true);
				animationNotes.shift();
				
			}
			if (animation.curAnim != null && animation.curAnim.finished)
			{
				playAnim(animation.curAnim.name, false, false, animation.curAnim.frames.length - 3);
			}
		}
		if (animation.curAnim != null && animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');
		
		callInterp("update", [elapsed, this]);
		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		if (!debugMode && beNormal)
		{
			if (interp != null)
				callInterp("dance", [this]);
			else
				playAnim('idle');
			if (color != FlxColor.WHITE)
			{
				color = FlxColor.WHITE;
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);
		var animName = "";
		if (animation.curAnim == null) {
			// P A N I K
			if (isDie)
				animName = "firstDeath";
			else
				animName = "idle";
			trace("OH SHIT OH FUCK");
		} else {
			// kalm
			animName = animation.curAnim.name;
		}
		if (animOffsets.exists(animName))
		{
			var daOffset = animOffsets.get(animName);
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
		// should spooky be on this?
		if (likeGf)
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}
	public function loadMappedAnims() {
		// todo, make better
		var picoAnims = Song.loadFromJson(curCharacter, "stress").notes;
		for (anim in picoAnims) {
			// this code looks fucking awful because I am reading the compiled
			// html build
			for (note in anim.sectionNotes) {
				animationNotes.push(note);
			}
		} 
		animationNotes.sort(sortAnims);
	}
	function sortAnims(a, b) {
		var aThing = a[0];
		var bThing = b[0];
		return aThing < bThing ? -1 : 1;
	}
	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
	public static function getAnimInterp(char:String):Interp {
		var interp = PluginManager.createSimpleInterp();
		var parser = new hscript.Parser();
		var charJson = CoolUtil.parseJson(Assets.getText('assets/images/custom_chars/custom_chars.jsonc'));
		var program:Expr;
		if (FNFAssets.exists('assets/images/custom_chars/' + Reflect.field(charJson, char).like + '.hscript'))
			program = parser.parseString(FNFAssets.getText('assets/images/custom_chars/' + Reflect.field(charJson, char).like + '.hscript'));
		else
			program = parser.parseString(FNFAssets.getText('assets/images/custom_chars/jsonbased.hscript'));
		if (!FNFAssets.exists('assets/images/custom_chars/' + Reflect.field(charJson, char).like + '.hscript')) 
			interp.variables.set("charJson", CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_chars/'+Reflect.field(charJson, char).like+'.json')));
		else
			interp.variables.set("charJson", {});
		interp.variables.set("hscriptPath", 'assets/images/custom_chars/' + char + '/');
		interp.variables.set("charName", char);
		interp.variables.set("Level_NotAHoe", Level_NotAHoe);
		interp.variables.set("Level_Boogie", Level_Boogie);
		interp.variables.set("Level_Sadness", Level_Sadness);
		interp.variables.set("Level_Sing", Level_Sing);
		interp.variables.set("portraitOffset", [0, 0]);
		interp.variables.set("dadVar", 4.0);
		interp.variables.set("isPixel", false);
		interp.variables.set("colors", [FlxColor.CYAN]);
		interp.execute(program);
		trace(interp);
		return interp;
	}
}
