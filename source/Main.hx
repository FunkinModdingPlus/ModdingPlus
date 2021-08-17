package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleState, 1, OptionsHandler.options.fpsCap, OptionsHandler.options.fpsCap, true));

		var ourSource:String = "/assets/cutscenes/source.webm";
		
		#if desktop
		var str1:String = "WEBM SHIT"; 
		var webmHandle = new WebmHandler();
		webmHandle.source(ourSource);
		webmHandle.makePlayer();
		webmHandle.webm.name = str1;
		addChild(webmHandle.webm);
		GlobalVideo.setWebm(webmHandle);
		#end
		
		#if !mobile
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
