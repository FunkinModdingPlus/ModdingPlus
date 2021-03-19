package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;

#end
import lime.ui.FileDialog;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.ui.FileDialogType;
using StringTools;

class NewCharacterState extends MusicBeatState
{
	var addCharUi:FlxUI;
	var nameText:FlxUIInputText;
	var mainPngButton:FlxButton;
	var mainXmlButton:FlxButton;
	var deadPngButton:FlxButton;
	var deadXmlButton:FlxButton;
	var crazyPngButton:FlxButton;
	var crazyXmlButton:FlxButton;
	var iconButton:FlxButton;
	var likeText:FlxUIInputText;
	var iconAlive:FlxUINumericStepper;
	var iconDead:FlxUINumericStepper;
	var iconPoison:FlxUINumericStepper;
	var finishButton:FlxButton;
	var coolFile:FileReference;
	var coolData:ByteArray;
	var epicFiles:Dynamic;
	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	override function create()
	{
		addCharUi = new FlxUI();
		FlxG.mouse.visible = true;
		epicFiles = {
			"charpng": null,
			"charxml":null,
			"deadpng":null,
			"deadxml":null,
			"crazyxml":null,
			"crazypng":null,
			"icons": null
		};
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue', 'preload'));
		add(bg);
		mainPngButton = new FlxButton(10,10,"char.png",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				epicFiles.charpng = path;
			});
		});
		iconButton = new FlxButton(10,300,"icons",function():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function(path:String):Void
			{
				epicFiles.icons = path;
			});
		});
		likeText = new FlxUIInputText(100, 10, 70,"bf");
		nameText = new FlxUIInputText(100,50,70,"template");
		var aliveText = new FlxText(100,70,"Alive Icon");
		iconAlive = new FlxUINumericStepper(100, 90,1,0,0,49);
		var deadText = new FlxText(100,120,"Dead Icon");
		iconDead = new FlxUINumericStepper(100, 140,1,1,0,49);
		var poisonText = new FlxText(100,170,"Poison Icon");
		iconPoison = new FlxUINumericStepper(100, 190,1,24,0,49);
		add(nameText);
		add(likeText);
		add(iconAlive);
		add(iconDead);
		add(iconPoison);
		add(poisonText);
		add(deadText);
		add(aliveText);
		add(mainPngButton);
		add(iconButton);
		mainXmlButton = new FlxButton(10,60,"char.xml/txt",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				epicFiles.charxml = path;
			});
		});
		add(mainXmlButton);
		deadPngButton = new FlxButton(10,110,"dead.png",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				epicFiles.deadpng = path;
			});
		});
		crazyPngButton = new FlxButton(10,170,"crazy.png",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				epicFiles.crazypng = path;
			});
		});
		deadXmlButton = new FlxButton(10,220,"dead.xml",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				epicFiles.deadxml = path;
			});
		});
		crazyXmlButton = new FlxButton(10,260,"crazy.xml",function ():Void {
			var coolDialog = new FileDialog();
			coolDialog.browse(FileDialogType.OPEN);
			coolDialog.onSelect.add(function (path:String):Void {
				epicFiles.crazyxml = path;
			});
		});
		finishButton = new FlxButton(FlxG.width - 170, FlxG.height - 50, "Finish", function():Void {
			writeCharacters();
			FlxG.switchState(new SaveDataState());
		});
		var cancelButton = new FlxButton(FlxG.width - 300, FlxG.height - 50, "Cancel", function():Void
		{
			// go back
			FlxG.switchState(new SaveDataState());
		});
		add(crazyXmlButton);
		add(deadXmlButton);
		add(deadPngButton);
		add(finishButton);
		add(cancelButton);
		add(crazyPngButton);
		super.create();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

	}
	function writeCharacters() {
		// check to see if directory exists
		#if sys
		if (!FNFAssets.exists(Paths.file('custom_chars/'+nameText.text, 'custom'))) {
			FNFAssets.createDirectory(Paths.file('custom_chars/' + nameText.text, 'custom'));
		}
		trace(epicFiles.charpng);
		trace("hello");
		FNFAssets.copy(epicFiles.charpng,Paths.file('custom_chars/'+nameText.text+'/char.png', 'custom'));
		// if it was an xml file save it as one
		// otherwise save it as txt
		if (StringTools.endsWith(epicFiles.charxml,"xml"))
			FNFAssets.copy(epicFiles.charxml,Paths.file('custom_chars/'+nameText.text+'/char.xml', 'custom'));
		else
			FNFAssets.copy(epicFiles.charxml,Paths.file('custom_chars/'+nameText.text+'/char.txt', 'custom'));
		if (epicFiles.deadpng != null) {
			FNFAssets.copy(epicFiles.deadpng,Paths.file('custom_chars/'+nameText.text+'/dead.png', 'custom'));
			FNFAssets.copy(epicFiles.deadxml,Paths.file('custom_chars/'+nameText.text+'/dead.xml', 'custom'));
		}
		if (epicFiles.crazypng != null) {
			FNFAssets.copy(epicFiles.crazypng,Paths.file('custom_chars/'+nameText.text+'/crazy.png', 'custom'));
			FNFAssets.copy(epicFiles.crazyxml,Paths.file('custom_chars/'+nameText.text+'/crazy.xml', 'custom'));
		}
		if (epicFiles.icons != null ) {
			FNFAssets.copy(epicFiles.icons,Paths.file('custom_chars/'+nameText.text+'/icons.png', 'custom'));
		}
		trace("hello");
		var epicCharFile:Dynamic =CoolUtil.parseJson(Assets.getText(Paths.file('custom_chars/'+nameText.text+'/custom_chars.json', 'custom')));
		trace("parsed");
		Reflect.setField(epicCharFile,nameText.text,{like:likeText.text,icons: [Std.int(iconAlive.value),Std.int(iconDead.value),Std.int(iconPoison.value)]});

		FNFAssets.saveText(Paths.file('custom_chars/'+nameText.text+'/custom_chars.json', 'custom'), CoolUtil.stringifyJson(epicCharFile));
		trace("cool stuff");
		#else
		do a lot of errors lol 
		;;;;
		trace('no semicolon lol')
		efafaf
		#end
	}
}
