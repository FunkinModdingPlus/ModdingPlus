package;

import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import flash.display.BitmapData;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;

import sys.FileSystem;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;
enum abstract IconState(Int) from Int to Int {
	var Normal;
	var Dying;
	var Poisoned;
	var Winning;
}
class HealthIcon extends FlxSprite
{
	var player:Bool = false;
	public var sprTracker:FlxSprite;
	public var iconState(default, set):IconState = Normal;
	function set_iconState(x:IconState):IconState {
		switch (x) {
			case Normal:
				animation.curAnim.curFrame = 0;
			case Dying:
				// if we set it out of bounds it doesn't realy matter as it goes to normal anyway
				animation.curAnim.curFrame = 1;
			case Poisoned:
				// same deal it will go to dying which is good enough
				animation.curAnim.curFrame = 2;
			case Winning:
				// we DO do it here here we want to make sure it isn't silly
				if (animation.curAnim.frames.length >= 4) {
					animation.curAnim.curFrame = 3;
				} else {
					animation.curAnim.curFrame = 0;
				}
		}
		return iconState = x;
	}
	public function new(char:String = 'bf', isPlayer:Bool = false)
	{
		player = isPlayer;
		super();
		antialiasing = true;
		switchAnim(char);
		scrollFactor.set();

	}
	public function switchAnim(char:String = 'bf') {
		var charJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_chars/custom_chars"));
		var iconJson:Dynamic = CoolUtil.parseJson(FNFAssets.getJson("assets/images/custom_chars/icon_only_chars"));
		var iconFrames:Array<Int> = [];
		if (Reflect.hasField(charJson, char))
		{
			iconFrames = Reflect.field(charJson, char).icons;
		}
		else if (Reflect.hasField(iconJson, char))
		{
			iconFrames = Reflect.field(iconJson, char).frames;
		}
		else
		{
			iconFrames = [0, 0, 0, 0];
		}
		if (FNFAssets.exists('assets/images/custom_chars/' + char + "/icons.png"))
		{
			var rawPic:BitmapData = FNFAssets.getBitmapData('assets/images/custom_chars/' + char + "/icons.png");
			loadGraphic(rawPic, true, 150, 150);
			animation.add('icon', iconFrames, false, player);
		}
		else
		{
			loadGraphic('assets/images/iconGrid.png', true, 150, 150);
			animation.add('icon', iconFrames, false, player);
		}
		animation.play('icon');
		animation.pause();
	}
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
