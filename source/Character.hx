package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import lime.system.System;
import lime.app.Application;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
#end
import haxe.Json;
import tjson.TJSON;
import haxe.format.JsonParser;
using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var enemyOffsetX:Int = 0;
	public var enemyOffsetY:Int = 0;
	public var camOffsetX:Int = 0;
	public var camOffsetY:Int = 0;
	public var followCamX:Int = 0;
	public var followCamY:Int = 0;
	public var midpointX:Int = 0;
	public var midpointY:Int = 0;
	public var isCustom:Bool = false;
	public var holdTimer:Float = 0;
	public var canDance:Bool = false;
	public var likeBf:Bool = true;
	public var likeGf:Bool = false;
	public var canSing:Bool = true;
	public var usesChiptune:Bool = false;
	public var playerScale:Float = 1;
	public var isDie:Bool = false;
	public var holdLength:Float = 4;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		#if sys
		// assume it is a custom character. if not: oh well
		// protective ritual to protect against new lines
		curCharacter = curCharacter.trim();
		trace(curCharacter);
		isCustom = true;
		if (StringTools.endsWith(curCharacter, "-dead"))
		{
			isDie = true;
			curCharacter = curCharacter.substr(0, curCharacter.length - 5);
		}
		trace(curCharacter);

		// use assets, as it is less laggy
		// just use the static method we have
		var parsedAnimJson:Dynamic = Character.getAnimJson(curCharacter);

		var playerSuffix = 'char';
		if (isDie)
		{
			// poor programming but whatev
			playerSuffix = 'dead';
			parsedAnimJson.animation = parsedAnimJson.deadAnimation;
			parsedAnimJson.offset = parsedAnimJson.deadOffset;
		}
		var rawPic = Paths.file('custom_chars/$curCharacter/$playerSuffix.png', 'custom');
		var tex:FlxAtlasFrames;
		var rawXml:String;
		// die <3
		if (FNFAssets.exists(Paths.file('custom_chars/$curCharacter/$playerSuffix.txt', 'custom')))
		{
			rawXml = Paths.file('custom_chars/$curCharacter/$playerSuffix.txt', 'custom');
			tex = FlxAtlasFrames.fromSpriteSheetPacker(rawPic, rawXml);
		}
		else
		{
			rawXml = Paths.file('custom_chars/$curCharacter/$playerSuffix.xml', 'custom');
			tex = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
		}
		frames = tex;

		for (field in Reflect.fields(parsedAnimJson.animation))
		{
			var fps = 24;
			if (Reflect.hasField(Reflect.field(parsedAnimJson.animation, field), "fps"))
			{
				fps = Reflect.field(parsedAnimJson.animation, field).fps;
			}
			var loop = false;
			if (Reflect.hasField(Reflect.field(parsedAnimJson.animation, field), "loop"))
			{
				loop = Reflect.field(parsedAnimJson.animation, field).loop;
			}
			if (Reflect.hasField(Reflect.field(parsedAnimJson.animation, field), "flippedname") && !isPlayer)
			{
				// the double not is to turn a null into a false
				if (Reflect.hasField(Reflect.field(parsedAnimJson.animation, field), "indices"))
				{
					var indicesAnim:Array<Int> = Reflect.field(parsedAnimJson.animation, field).indices;
					animation.addByIndices(field, Reflect.field(parsedAnimJson.animation, field).flippedname, indicesAnim, "", fps,
						!!Reflect.field(parsedAnimJson.animation, field).loop);
				}
				else
				{
					animation.addByPrefix(field, Reflect.field(parsedAnimJson.animation, field).flippedname, fps,
						!!Reflect.field(parsedAnimJson.animation, field).loop);
				}
			}
			else
			{
				if (Reflect.hasField(Reflect.field(parsedAnimJson.animation, field), "indices"))
				{
					var indicesAnim:Array<Int> = Reflect.field(parsedAnimJson.animation, field).indices;
					animation.addByIndices(field, Reflect.field(parsedAnimJson.animation, field).name, indicesAnim, "", fps,
						!!Reflect.field(parsedAnimJson.animation, field).loop);
				}
				else
				{
					animation.addByPrefix(field, Reflect.field(parsedAnimJson.animation, field).name, fps,
						!!Reflect.field(parsedAnimJson.animation, field).loop);
				}
			}
		}
		for (field in Reflect.fields(parsedAnimJson.offset))
		{
			addOffset(field, Reflect.field(parsedAnimJson.offset, field)[0], Reflect.field(parsedAnimJson.offset, field)[1]);
		}
		camOffsetX = if (parsedAnimJson.camOffset != null) parsedAnimJson.camOffset[0] else 0;
		camOffsetY = if (parsedAnimJson.camOffset != null) parsedAnimJson.camOffset[1] else 0;
		enemyOffsetX = if (parsedAnimJson.enemyOffset != null) parsedAnimJson.enemyOffset[0] else 0;
		enemyOffsetY = if (parsedAnimJson.enemyOffset != null) parsedAnimJson.enemyOffset[1] else 0;
		followCamX = if (parsedAnimJson.followCam != null) parsedAnimJson.followCam[0] else 150;
		followCamY = if (parsedAnimJson.followCam != null) parsedAnimJson.followCam[1] else -100;
		midpointX = if (parsedAnimJson.midpoint != null) parsedAnimJson.midpoint[0] else 0;
		midpointY = if (parsedAnimJson.midpoint != null) parsedAnimJson.midpoint[1] else 0;
		flipX = if (parsedAnimJson.flipx != null) parsedAnimJson.flipx else false;
		likeBf = parsedAnimJson.likeBf;
		likeGf = parsedAnimJson.likeGf;
		usesChiptune = parsedAnimJson.usesChiptune;
		canSing = parsedAnimJson.canSing;
		canDance = parsedAnimJson.dances;
		holdLength = if (Reflect.hasField(parsedAnimJson, 'holdLength')) parsedAnimJson.holdLength else 4;
		antialiasing = if (Reflect.hasField(parsedAnimJson, 'antialiasing')) parsedAnimJson.antialiasing else true;
		if (Reflect.hasField(parsedAnimJson, 'scale'))
		{
			setGraphicSize(Std.int(width * 6));
			playerScale = parsedAnimJson.scale;
			updateHitbox();
		}
		if (parsedAnimJson.isPixel)
		{
			antialiasing = false;
			setGraphicSize(Std.int(width * 6));
			updateHitbox(); // when the hitbox is sus!
		}
		if (!isDie)
		{
			width += if (parsedAnimJson.size != null) parsedAnimJson.size[0] else 0;
			height += if (parsedAnimJson.size != null) parsedAnimJson.size[1] else 0;
		}
		playAnim(parsedAnimJson.playAnim);
		#else
		// lol
		throw('lol you\'re using html5?');
		#end



		dance();

		if (isPlayer)
		{
			flipX = !flipX;
			// Doesn't flip for BF, since his are already in the right place???
			// TODO: USE BF-ISH
			if (!likeBf)
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

	override function update(elapsed:Float)
	{

		//curCharacter = curCharacter.trim();
		

		//if (!StringTools.contains(animJson, "firstDeath") && like != "bf-pixel") //supposed to fix note anim shit for bfs with unique jsons, currently broken
		if (!likeBf)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			dadVar = holdLength;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				dance();
				holdTimer = 0;
			}
		}
		if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
			playAnim('danceRight');
		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		trace('boogie');
		if (!debugMode)
		{
			if (canDance)
			{
				if (!animation.curAnim.name.startsWith('hair'))
				{
					danced = !danced;
					trace(danced);
					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}
			else
			{
				playAnim('idle');
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		trace(AnimName);
		animation.play(AnimName, Force, Reversed, Frame);
		var animName = "";
		if (animation.curAnim == null) {
			// P A N I K
			animName = "idle";
			trace("OH SHIT OH FUCK");
		} else {
			// kalm
			animName = animation.curAnim.name;
		}
		var daOffset = animOffsets.get(animName);
		if (animOffsets.exists(animName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);
		// should spooky be on this?
		if (canDance && canSing)
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

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
	// wait one fucking minute this exists?
	// goddamn
	public static function getAnimJson(char:String):Dynamic {
		var charJson = CoolUtil.parseJson(FNFAssets.getText(Paths.file('custom_chars/custom_chars.json', 'custom')));
		var animJson = CoolUtil.parseJson(FNFAssets.getText(Paths.file('custom_chars/'+Reflect.field(charJson, char).like +'.json', 'custom')));
		return animJson;
	}
}
