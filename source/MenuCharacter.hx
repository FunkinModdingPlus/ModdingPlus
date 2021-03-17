package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import lime.system.System;
import lime.utils.Assets;
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import flash.display.BitmapData;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var like:String;
	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		this.character = character;
		// use assets it is less laggy
		var parsedCharJson:Dynamic = CoolUtil.parseJson(Assets.getText(Paths.file('custom_menu_char/custom_ui_chars.json', 'custom')));
		if (!!Reflect.field(parsedCharJson,character).defaultGraphics) {
			// use assets, it is less laggy
			var tex = Paths.getSparrowAtlas('campaign_menu_UI_characters', 'preload');
			frames = tex;
		} else {
			var rawPic:BitmapData = BitmapData.fromFile(Paths.file('custom_menu_char/$character.png', 'custom'));
			var rawXml:String = File.getContent(Paths.file('custom_menu_char/$character.xml', 'custom'));
			var tex = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
			frames = tex;
		}

		// don't use assets because you can use custom like folders
		
		var animJson = CoolUtil.parseJson(File.getContent(Paths.file('custom_menu_char/'+Reflect.field(parsedCharJson,character).like+'.json', 'custom')));
		for (field in Reflect.fields(animJson)) {
			animation.addByPrefix(field, Reflect.field(animJson, field), 24, (field == "idle"));
		}
		this.like = Reflect.field(parsedCharJson,character).like;
		animation.play('idle');
		updateHitbox();
	}
}
