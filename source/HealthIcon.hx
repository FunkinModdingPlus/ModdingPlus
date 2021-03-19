package;

import flixel.FlxSprite;
import lime.system.System;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;
class HealthIcon extends FlxSprite
{
	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		super();
		#if sys
		var charJson:Dynamic = CoolUtil.parseJson(FNFAssets.getContent(Paths.file('custom_chars/custom_chars.json', 'custom')));
		#end
		antialiasing = true;
		// check if there is an icon file
		if (FNFAssets.exists(Paths.file('custom_chars/$char/icons.png', 'custom')))
		{
			var rawPic:BitmapData = BitmapData.fromFile(Paths.file('custom_chars/$char/icons.png', 'custom'));
			loadGraphic(rawPic, true, 150, 150);
			animation.add('icon', Reflect.field(charJson, char).icons, false, isPlayer);
		}
		else
		{
			loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
			animation.add('icon', Reflect.field(charJson, char).icons, false, isPlayer);
		}
		animation.play('icon');
		scrollFactor.set();

	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
