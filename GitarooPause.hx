package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class GitarooPause extends MusicBeatState
{
	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;

	public function new():Void
	{
		super();
	}

	override function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var bg:FlxSprite = new FlxSprite().loadGraphic('assets/images/pauseAlt/pauseBG.png');
		add(bg);

		var bf:FlxSprite = new FlxSprite(0, 30);
		bf.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/bfLol.png', 'assets/images/pauseAlt/bfLol.xml');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		add(bf);
		bf.screenCenter(X);

		replayButton = new FlxSprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/pauseUI.png', 'assets/images/pauseAlt/pauseUI.xml');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = FlxAtlasFrames.fromSparrow('assets/images/pauseAlt/pauseUI.png', 'assets/images/pauseAlt/pauseUI.xml');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		add(cancelButton);

		changeThing();

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.LEFT_MENU || controls.RIGHT_MENU)
			changeThing();

		if (controls.ACCEPT)
		{
			if (replaySelect)
			{
				LoadingState.loadAndSwitchState(new PlayState());
			}
			else
			{
				LoadingState.loadAndSwitchState(new MainMenuState());
			}
		}

		super.update(elapsed);
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
		}
	}
}
