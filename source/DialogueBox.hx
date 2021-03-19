package;

import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.display.BitmapData;
import flixel.graphics.frames.FlxFrame;
import lime.system.System;
import flixel.system.FlxAssets.FlxSoundAsset;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end
import haxe.Json;
import haxe.format.JsonParser;
import tjson.TJSON;
using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	var acceptSound:FlxSoundAsset;
	var clickSounds:Array<Null<FlxSoundAsset>> = [null, null, null];
	public var finishThing:Void->Void;
	public var like:String = "senpai";
	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitCustom:FlxSprite;
	var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var isPixel:Array<Bool> = [true,true,true];
	var senpaiColor:FlxColor = FlxColor.WHITE;
	var textColor:FlxColor = 0xFF3F2021;
	var dropColor:FlxColor = 0xFFD89494;
	var rightHanded:Array<Bool> = [true, false];
	var font:String = "pixel.otf";
	var senpaiVisible = true;
	var sided:Bool = false;
	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();
		trace('hey guys');
		clickSounds[2] = Paths.sound('pixelText', 'shared');
		switch (PlayState.SONG.cutsceneType)
		{
			case 'senpai':
				FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'spirit':
				FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'angry-senpai':
				// do nothing
			default:
				// see if the song has one
				if (FNFAssets.exists(Paths.file(PlayState.SONG.song.toLowerCase()+'/Lunchbox.ogg', 'songs'))) {
					var lunchboxSound = FNFAssets.getSound(Paths.file(PlayState.SONG.song.toLowerCase() + '/Lunchbox.ogg', 'songs'));
					FlxG.sound.playMusic(lunchboxSound, 0);
					FlxG.sound.music.fadeIn(1,0,0.8);
				// otherwise see if there is an ogg file in the dialog
			} else if (FNFAssets.exists(Paths.file('dialog_boxes/'+PlayState.SONG.cutsceneType+'/Lunchbox.ogg', 'custom'))) {
					var lunchboxSound = FNFAssets.getSound(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/Lunchbox.ogg', 'custom'));
					FlxG.sound.playMusic(lunchboxSound, 0);
					FlxG.sound.music.fadeIn(1,0,0.8);
				}
		}

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);
		acceptSound = Paths.sound('clickText');
		new FlxTimer().start(0.83, function(tmr:FlxTimer)
		{
			bgFade.alpha += (1 / 5) * 0.7;
			if (bgFade.alpha > 0.7)
				bgFade.alpha = 0.7;
		}, 5);

		portraitLeft = new FlxSprite(-20, 40);
		switch (PlayState.SONG.player2)
		{
			case 'bf' | 'bf-car':
				portraitLeft.frames = Paths.getSparrowAtlas('bfPortrait', 'shared');
				isPixel[1] = false;
			case 'bf-christmas':
				portraitLeft.frames = Paths.getSparrowAtlas('bfPortraitXmas', 'shared');
				isPixel[1] = false;
			case 'pico':
				portraitLeft.frames = Paths.getSparrowAtlas('picoPortrait', 'shared');
				isPixel[1] = false;
			case 'spooky':
				portraitLeft.frames = Paths.getSparrowAtlas('spookyPortrait', 'shared');
				isPixel[1] = false;
			case 'gf':
				// cursed
				portraitLeft.frames = Paths.getSparrowAtlas('gfPortrait', 'shared');
				isPixel[1] = false;
			case 'dad':
				portraitLeft.frames = Paths.getSparrowAtlas('dadPortrait', 'shared');
				isPixel[1] = false;
			case 'mom' | 'mom-car':
				portraitLeft.frames = Paths.getSparrowAtlas('momPortrait', 'shared');
				isPixel[1] = false;
			case 'parents-christmas':
				portraitLeft.frames = Paths.getSparrowAtlas('parentsPortrait', 'shared');
				isPixel[1] = false;
			case 'monster-christmas':
				// haha santa hat
				portraitLeft.frames = Paths.getSparrowAtlas('monsterXmasPortrait', 'shared');
				isPixel[1] = false;
			case 'monster':
				portraitLeft.frames = Paths.getSparrowAtlas('monsterPortrait', 'shared');
				isPixel[1] = false;
			default:
				if (FNFAssets.exists(Paths.file('custom_chars/'+PlayState.SONG.player2+'/portrait.png', 'custom')))
				{
					var coolP2Json = Character.getAnimJson(PlayState.SONG.player2);
					isPixel[1] = if (Reflect.hasField(coolP2Json, "isPixel")) coolP2Json.isPixel else false;
					var rawPic = FNFAssets.getBitmapData(Paths.file('custom_chars/' + PlayState.SONG.player2 + '/portrait.png', 'custom'));
					var rawXml = FNFAssets.getText(Paths.file('custom_chars/' + PlayState.SONG.player2 + '/portrait.xml', 'custom'));
					portraitLeft.frames = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
				}
				else
				{
					portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait.png');
				}
				if (FNFAssets.exists(Paths.file('custom_chars/'+PlayState.SONG.player2+'/text.ogg', 'custom')))
				{
					clickSounds[1] = FNFAssets.getSound(Paths.file('custom_chars/' + PlayState.SONG.player2 + '/text.ogg', 'custom'));
				}
		}
		if (isPixel[1]) {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.9));
		}

		portraitLeft.updateHitbox();
		portraitLeft.scrollFactor.set();
		add(portraitLeft);
		portraitLeft.visible = false;

		portraitRight = new FlxSprite(0, 40);
		switch (PlayState.SONG.player1)
		{
			case 'bf' | 'bf-car':
				portraitLeft.frames = Paths.getSparrowAtlas('bfPortrait', 'shared');
				isPixel[0] = false;
			case 'bf-christmas':
				portraitLeft.frames = Paths.getSparrowAtlas('bfPortraitXmas', 'shared');
				isPixel[0] = false;
			case 'pico':
				portraitLeft.frames = Paths.getSparrowAtlas('picoPortrait', 'shared');
				isPixel[0] = false;
			case 'spooky':
				portraitLeft.frames = Paths.getSparrowAtlas('spookyPortrait', 'shared');
				isPixel[0] = false;
			case 'gf':
				// cursed
				portraitLeft.frames = Paths.getSparrowAtlas('gfPortrait', 'shared');
				isPixel[0] = false;
			case 'dad':
				portraitLeft.frames = Paths.getSparrowAtlas('dadPortrait', 'shared');
				isPixel[0] = false;
			case 'mom' | 'mom-car':
				portraitLeft.frames = Paths.getSparrowAtlas('momPortrait', 'shared');
				isPixel[0] = false;
			case 'parents-christmas':
				portraitLeft.frames = Paths.getSparrowAtlas('parentsPortrait', 'shared');
				isPixel[0] = false;
			case 'monster-christmas':
				// haha santa hat
				portraitLeft.frames = Paths.getSparrowAtlas('monsterXmasPortrait', 'shared');
				isPixel[0] = false;
			case 'monster':
				portraitLeft.frames = Paths.getSparrowAtlas('monsterPortrait', 'shared');
				isPixel[0] = false;
			default:
				if (FNFAssets.exists(Paths.file('custom_chars/' + PlayState.SONG.player1 + '/portrait.png', 'custom')))
				{
					var coolP1Json = Character.getAnimJson(PlayState.SONG.player1);
					isPixel[0] = if (Reflect.hasField(coolP1Json, "isPixel")) coolP1Json.isPixel else false;
					var rawPic = FNFAssets.getBitmapData(Paths.file('custom_chars/' + PlayState.SONG.player1 + '/portrait.png', 'custom'));
					var rawXml = FNFAssets.getText(Paths.file('custom_chars/' + PlayState.SONG.player1 + '/portrait.xml', 'custom'));
					portraitLeft.frames = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
				}
				else
				{
					portraitLeft.frames = Paths.getSparrowAtlas('weeb/senpaiPortrait.png');
				}
				if (FNFAssets.exists(Paths.file('custom_chars/' + PlayState.SONG.player2 + '/text.ogg', 'custom')))
				{
					clickSounds[1] = Sound.fromFile(Paths.file('custom_chars/' + PlayState.SONG.player2 + '/text.ogg', 'custom'));
				}
		}
		var gameingFrames:Array<FlxFrame> = [];
		var leftFrames:Array<FlxFrame> = [];
		trace('gay');
		for (frame in portraitRight.frames.frames)
		{
			if (frame.name != null && StringTools.startsWith(frame.name, 'Boyfriend portrait enter'))
			{
				gameingFrames.push(frame);
			}
		}
		for (frame in portraitLeft.frames.frames)
		{
			if (frame.name != null && StringTools.startsWith(frame.name, 'Boyfriend portrait enter'))
			{
				leftFrames.push(frame);
			}
		}
		if (gameingFrames.length == 0) {
			rightHanded[0] = false;
		}
		if (leftFrames.length > 0) {
			rightHanded[1] = true;
		}
		trace(rightHanded[0] + ' ' + rightHanded[1]);
		if (rightHanded[0]) {
			portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
		} else {
			portraitRight.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			portraitRight.flipX = true;
		}
		if (!rightHanded[1]) {
			portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
		} else {
			portraitLeft.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			portraitLeft.flipX = true;
		}
		// allow player to use non pixel portraits. this means the image size can be around 6 times the size, based on the pixel zoom
		if (isPixel[0]) {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
		} else {
			portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.9));
		}

		portraitRight.updateHitbox();
		portraitRight.scrollFactor.set();
		add(portraitRight);
		portraitRight.visible = false;
		
		box = new FlxSprite(-20, 45);

		switch (PlayState.SONG.cutsceneType)
		{
			case 'senpai':
				// taking no chances on the current week
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
				like = "senpai";
			case 'angry-senpai':
				FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));

				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
				senpaiVisible = false;
				like = "angry-senpai";
			case 'spirit':
				box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-evil');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
				textColor = FlxColor.WHITE;
				dropColor = FlxColor.BLACK;
				senpaiColor = FlxColor.BLACK;
				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image('weeb/spiritFaceForward'));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);
				like = "spirit";
			case 'none':
				// do nothing
			case 'monster':
				// do nothing
			default:
				if (FNFAssets.exists(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/box.xml', 'custom'))) {
					box.frames = FlxAtlasFrames.fromSparrow(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/box.png', 'custom'), Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/box.xml', 'custom'));
					var coolJsonFile:Dynamic = CoolUtil.parseJson(FNFAssets.getText(Paths.file('dialog_boxes/dialog_boxes.json', 'custom')));
					var coolAnimFile = CoolUtil.parseJson(FNFAssets.getText(Paths.file('dialog_boxes/'+Reflect.field(coolJsonFile,PlayState.SONG.cutsceneType).like+'.json', 'custom')));
					isPixel[2] = coolAnimFile.isPixel;
					senpaiVisible = coolAnimFile.senpaiVisible;
					sided = if (Reflect.hasField(coolAnimFile, 'sided')) coolAnimFile.sided else false;
					senpaiColor = FlxColor.fromString(coolAnimFile.senpaiColor);
					textColor = FlxColor.fromString(coolAnimFile.textColor);
					dropColor = FlxColor.fromString(coolAnimFile.dropColor);
					font = coolAnimFile.font;
					if (Reflect.hasField(coolAnimFile, "portraitOffset")) {
						portraitLeft.x += coolAnimFile.portraitOffset[0];
						portraitLeft.y += coolAnimFile.portraitOffset[1];
						portraitRight.x += coolAnimFile.portraitOffset[0];
						portraitRight.y += coolAnimFile.portraitOffset[1];
					}
					if (FNFAssets.exists(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/text.ogg', 'custom')))
						clickSounds[2] = Sound.fromFile(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/text.ogg', 'custom'));
					if (FNFAssets.exists(Paths.file('dialog_boxes/'+PlayState.SONG.cutsceneType+'/accept.ogg', 'custom')))
						acceptSound = Sound.fromFile(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/accept.ogg', 'custom'));
					if (coolAnimFile.like == "senpai") {
						box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
						box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
						like = "senpai";
					} else if (coolAnimFile.like == "senpai-angry") {
						// should i keep this?
						if (FNFAssets.exists(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/angry.ogg', 'custom'))) {
							// maybe it's just vsc but apparently interpolation isn't all powerful
							FlxG.sound.play(Paths.file('dialog_boxes/'+PlayState.SONG.cutsceneType+'/angry.ogg', 'custom'));
						} else {
							FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX', 'shared'));
						}
						
						box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
						box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);
						like = "angry-senpai";
					} else if (coolAnimFile.like == "spirit") {
						box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
						box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);
						if (FNFAssets.exists(Paths.file('dialog_boxes/' + PlayState.SONG.cutsceneType + '/face.png', 'custom'))) {
							var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.file('dialog_boxes/'+PlayState.SONG.cutsceneType+'/face.png', 'custom'));
							if (isPixel[2]) {
								face.setGraphicSize(Std.int(face.width * 6));
							}

							add(face);
						}
						// NO ELSE TO SUPPORT CUSTOM PORTRAITS
						like = "spirit";
					}
				}
		}

		this.dialogueList = dialogueList;
		

		// do nothing with it, so we can recycle later
		portraitCustom = new FlxSprite(0, 40);
		portraitCustom.visible = false;
		portraitRight.scrollFactor.set();
		box.animation.play('normalOpen');
		if (dialogueList[0].startsWith(':dad:') && sided) {
			box.flipX = true;
		}
		if (isPixel[2]) {
			box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
		} else {
			box.setGraphicSize(Std.int(box.width * 0.9));
		}
		if (clickSounds[0] == null)
			clickSounds[0] = clickSounds[2];
		if (clickSounds[1] == null)
			clickSounds[1] = clickSounds[2];
		box.updateHitbox();
		add(box);

		box.screenCenter(X);
		portraitLeft.screenCenter(X);

		handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('weeb/pixelUI/hand_textbox'));
		add(handSelect);


		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.setFormat(Paths.font(font), 32, dropColor);
		if (dropColor.alphaFloat != 1) 
			dropText.alpha = dropColor.alphaFloat;
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.setFormat(Paths.font(font), 32, textColor);
		if (textColor.alphaFloat != 1)
			swagDialogue.alpha = textColor.alphaFloat;
		swagDialogue.sounds = [FlxG.sound.load(clickSounds[2], 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// NOT HARD CODING CAUSE I BIG BBRAIN
		portraitLeft.color = senpaiColor;

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}
		// suss

		// when the music state is sus
		if (PlayerSettings.player1.controls.SECONDARY) 
		{
			// skip all this shit
			if (!isEnding)
			{
				isEnding = true;

				if (like == "senpai" || like == "spirit")
					FlxG.sound.music.fadeOut(2.2, 0);

				new FlxTimer().start(0.2, function(tmr:FlxTimer)
				{
					box.alpha -= 1 / 5;
					bgFade.alpha -= 1 / 5 * 0.7;
					portraitLeft.visible = false;
					portraitRight.visible = false;
					swagDialogue.alpha -= 1 / 5;
					dropText.alpha -= 1/5;
				}, 5);

				new FlxTimer().start(1.2, function(tmr:FlxTimer)
				{
					finishThing();
					kill();
				});
			}
		} else if (FlxG.keys.justPressed.ANY && dialogueStarted == true)
		{
			remove(dialogue);
				
			FlxG.sound.play(Paths.sound('clickText' ), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (like == "senpai" || like == "spirit")
						FlxG.sound.music.fadeOut(2.2, 0);

					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha -= 1 / 5;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}
		
		super.update(elapsed);
	}

	var isEnding:Bool = false;
	var oldChar:String = "dad";
	function startDialogue():Void
	{
		cleanDialog();
		// do it before the text starts
		var customHanded:Bool = false;
		var customPixel:Bool = false;
		// make it D R Y (don't repeat yourself)
		if (curCharacter != 'dad' && curCharacter != 'bf') {
			portraitCustom.scale = new FlxPoint(1, 1);
			portraitCustom.setPosition(0, 40);
			swagDialogue.sounds = [FlxG.sound.load(clickSounds[2], 0.6)];
			portraitCustom.flipX = false;
		}
		switch (curCharacter) {
			case 'dad':
				swagDialogue.sounds = [FlxG.sound.load(clickSounds[1], 0.6)];
			case 'bf':
				swagDialogue.sounds = [FlxG.sound.load(clickSounds[0], 0.6)];
			case 'char-bf':
				// we have to change the custom portrait
				portraitCustom.frames = Paths.getSparrowAtlas('bfPortrait', 'shared');
				customHanded = true;
			case 'char-dad':
				portraitCustom.frames =Paths.getSparrowAtlas('dadPortrait', 'shared');
			case 'char-gf':
				portraitCustom.frames = Paths.getSparrowAtlas('gfPortrait', 'shared');
				portraitCustom.flipX = true;
				customHanded = true;
			// TODO: Split into skid and pump
			case 'char-spooky':
				portraitCustom.frames = Paths.getSparrowAtlas('spookyPortrait', 'shared');
			case 'char-pico':
				portraitCustom.frames = Paths.getSparrowAtlas('picoPortrait', 'shared');
				portraitCustom.flipX = true;
				customHanded = true;
			case 'char-mom':
				portraitCustom.frames = Paths.getSparrowAtlas('momPortrait', 'shared');
			// TODO: Graphics
			case 'char-mom-xmas':
				portraitCustom.frames = Paths.getSparrowAtlas('momPortrait', 'shared');
			// TODO: Graphics
			case 'char-dad-xmas':
				portraitCustom.frames = Paths.getSparrowAtlas('dadPortrait', 'shared');
			case 'char-monster':
				portraitCustom.frames = Paths.getSparrowAtlas('monsterPortrait', 'shared');
			case 'char-monster-xmas':
				portraitCustom.frames = Paths.getSparrowAtlas('monsterXmasPortrait', 'shared');
			case 'char-gf-xmas':
				portraitCustom.frames = Paths.getSparrowAtlas('gfPortraitXmas', 'shared');
				portraitCustom.flipX = true;
				customHanded = true;
			case 'char-bf-xmas':
				portraitCustom.frames = Paths.getSparrowAtlas('bfPortraitXmas', 'shared');
				customHanded = true;
			case 'char-bf-pixel':
				portraitCustom.frames = Paths.getSparrowAtlas('weeb/bfPortrait', 'shared');
				customPixel = true;
				customHanded = true;
			default:
				var realChar = curCharacter.substr(5);
				portraitCustom = new FlxSprite(0, 40);
				if (FNFAssets.exists(Paths.file('custom_chars/$realChar/portrait.png', 'custom'))) {
					var coolCustomJson = Character.getAnimJson(realChar);
					customPixel = if (Reflect.hasField(coolCustomJson, "isPixel"))
						coolCustomJson.isPixel
					else
						false;
					var rawPic = FNFAssets.getBitmapData(Paths.file('custom_chars/$realChar/portrait.png', 'custom'));
					var rawXml = FNFAssets.getText(Paths.file('custom_chars/$realChar/portrait.xml', 'custom'));
					portraitCustom.frames = FlxAtlasFrames.fromSparrow(rawPic, rawXml);
				} else {
					portraitCustom.frames = Paths.getSparrowAtlas('weeb/bfPortrait', 'shared');
					customPixel = true;
				}
				for (frame in portraitCustom.frames.frames)
				{
					if (frame.name != null && StringTools.startsWith(frame.name, 'Boyfriend portrait enter'))
					{
						customHanded = true;
						break;
					}
				}
				if (FNFAssets.exists(Paths.file('custom_chars/$realChar/text.ogg', 'custom')))
				{
					swagDialogue.sounds = [FlxG.sound.load(Sound.fromFile(Paths.file('custom_chars/$realChar/text.ogg', 'custom')))];
				}
				
		}
		// swagDialogue.text = ;
		if (curCharacter != 'dad' && curCharacter != 'bf') {
			if (curCharacter != oldChar)
				portraitCustom.visible = false;
			if (customHanded)
				portraitCustom.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
			else
				portraitCustom.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
			if (customPixel)
				portraitCustom.setGraphicSize(Std.int(portraitCustom.width * 0.9 * PlayState.daPixelZoom));
			else
				portraitCustom.setGraphicSize(Std.int(portraitCustom.width * 0.9));
			portraitCustom.updateHitbox();
			
		}
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		switch (curCharacter)
		{
			case 'dad':
				portraitRight.visible = false;
				if (portraitCustom != null) {
					portraitCustom.visible = false;
				}
				if (sided) {
					box.flipX = true;
				}
				if (!portraitLeft.visible && senpaiVisible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
					trace(portraitLeft.animation.curAnim);
				}
			case 'bf':
				portraitLeft.visible = false;
				if (portraitCustom != null)
				{
					portraitCustom.visible = false;
				}
				// don't need to check for sided bc this changes nothing
				box.flipX = false;
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			default:
				portraitLeft.visible = false;
				portraitRight.visible = false;
				if (sided && !customHanded) {
					box.flipX = true;
				} else {
					box.flipX = false;
				}

				if (!portraitCustom.visible) {
					portraitCustom.visible = true;
					trace(portraitCustom.animation);
					trace(portraitCustom);
					portraitCustom.animation.play('enter');
				}
		}
		oldChar = curCharacter;
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
