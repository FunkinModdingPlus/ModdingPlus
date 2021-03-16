package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
import flixel.util.FlxColor;

class MenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		var parsedWeekJson:Array<Array<String>> = CoolUtil.parseJson(File.getContent("assets/data/storySongList.json")).songs;
		var rawPic = BitmapData.fromFile('assets/images/campaign-ui-week/week'+weekNum+".png");
		var rawXml = File.getContent('assets/images/campaign-ui-week/week'+weekNum+".xml");
		var tex = FlxAtlasFrames.fromSparrow(rawPic, rawXml);

		week = new FlxSprite();
		week.frames = tex;
		// TUTORIAL IS WEEK 0
		trace(parsedWeekJson[weekNum][0]);
		week.animation.addByPrefix("default", parsedWeekJson[weekNum][0], 24);
		add(week);
		week.animation.play('default');
		week.animation.pause();
		week.updateHitbox();
	}

		
	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, 0.17);

		if (isFlashing)
			flashingInt += 1;

		if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 2))
			week.color = 0xFF33ffff;
		else
			week.color = FlxColor.WHITE;
	}
}
