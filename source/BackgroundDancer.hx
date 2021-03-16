package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import openfl.utils.Assets as OpenFLAssets;
import lime.system.System;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
#end
import haxe.Json;
import haxe.format.JsonParser;
class BackgroundDancer extends FlxSprite
{
	public function new(x:Float, y:Float, ?type:String = "normal")
	{
		super(x, y);
		if (type == "normal") {
			frames = Paths.getSparrowAtlas("limo/limoDancer", "week4");
		} else {
			// openfl is funny, it doesn't care about lime assets so i don't have to fuck with this shit
			// checked flixel source code and it uses openfl
			if (OpenFLAssets.exists(Paths.xml('custom_stages/$type/limo/limoDancer', "custom")))
				frames = Paths.getSparrowAtlas('custom_stages/$type/limo/limoDancer', "custom" );
			else 
				frames = Paths.getSparrowAtlas("limo/limoDancer", "week4");
		}

		animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		animation.play('danceLeft');
		antialiasing = true;
	}

	var danceDir:Bool = false;

	public function dance():Void
	{
		danceDir = !danceDir;

		if (danceDir)
			animation.play('danceRight', true);
		else
			animation.play('danceLeft', true);
	}
}
