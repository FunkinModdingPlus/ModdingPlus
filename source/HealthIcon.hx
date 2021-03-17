package;

import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
import sys.FileSystem;
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
		var charJson:Dynamic = CoolUtil.parseJson(File.getContent(Paths.file('custom_chars/custom_chars.json', 'custom')));
		#end
		antialiasing = true;
		switch (char) {
			case 'bf':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [0, 1, 24], 0, false, isPlayer);
			case 'bf-car':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [0, 1,24], 0, false, isPlayer);
			case 'bf-christmas':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [0, 1,24], 0, false, isPlayer);
			case 'spooky':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [2, 3], 0, false, isPlayer);
			case 'pico':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [4, 5], 0, false, isPlayer);
			case 'mom':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [6, 7], 0, false, isPlayer);
			case 'mom-car':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [6, 7], 0, false, isPlayer);
			case 'tankman':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [8, 9], 0, false, isPlayer);
			case 'face':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [10, 11], 0, false, isPlayer);
			case 'dad':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [12, 13], 0, false, isPlayer);
			case 'bf-old':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [14, 15], 0, false, isPlayer);
			case 'gf':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [16, 16], 0, false, isPlayer);
			case 'parents-christmas':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [17,17], 0, false, isPlayer);
			case 'monster':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [19, 20], 0, false, isPlayer);
			case 'monster-christmas':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [19, 20], 0, false, isPlayer);
			case 'senpai':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [22, 22], 0, false, isPlayer);
			case 'senpai-angry':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [22, 22], 0, false, isPlayer);
			case 'spirit':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [23, 23], 0, false, isPlayer);
			case 'bf-pixel':
				loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
				animation.add('icon', [21, 21, 25], 0, false, isPlayer);
			default:
				// check if there is an icon file
				if (FileSystem.exists(Paths.file('custom_chars/$char/icons.png', 'custom'))) {
						var rawPic:BitmapData = BitmapData.fromFile(Paths.file('custom_chars/$char/icons.png', 'custom'));
					loadGraphic(rawPic, true, 150, 150);
					animation.add('icon', Reflect.field(charJson,char).icons, false, isPlayer);
				} else {
					loadGraphic(Paths.image('iconGrid', 'preload'), true, 150, 150);
					animation.add('icon', Reflect.field(charJson,char).icons, false, isPlayer);
				}
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
