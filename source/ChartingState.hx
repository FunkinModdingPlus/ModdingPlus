package;

import Section.SwagSection;
import Song.SwagSong;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import tjson.TJSON;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end

using StringTools;

class ChartingState extends MusicBeatState
{
	//var _file:FileReference;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dadbattle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	var player1TextField:FlxInputText;
	var player2TextField:FlxInputText;
	var gfTextField:FlxInputText;
	var cutsceneTextField:FlxInputText;
	var uiTextField:FlxInputText;
	var stageTextField:FlxInputText;
	var isAltNoteCheck:FlxUICheckBox;
	
	var playerText:FlxText;
	var gfText:FlxText;
	var enemyText:FlxText;
	var stageText:FlxText;
	var uiText:FlxText;
	var cutsceneText:FlxText;
	
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	var tempBpm:Float = 0;

	var vocals:FlxSound;

	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;

	var useLiftNote:Bool = false;

	override function create()
	{




		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				stage: 'stage',
				gf: 'gf',
				isHey: false,
				speed: 1,
				isSpooky: false,
				isMoody: false,
				cutsceneType: "none",
				uiType: 'normal',
				isCheer: false,
				preferredNoteAmount: 4,
				forceJudgements: false,
				convertMineToNuke: false,
				mania: 0
			};
		}

		FlxG.mouse.visible = true;
		//FlxG.save.bind('save1', 'bulbyVR');
		// i don't know why we need to rebind our save
		tempBpm = _song.bpm;


		var tabs = [
			{name: "Song", label: 'Song'},
			{name: "Char", label: 'Char'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addCharsUI();

		add(curRenderedNotes);
		add(curRenderedSustains);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSongJson:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});
		var isSpookyCheck = new FlxUICheckBox(10, 280,null,null,"Is Spooky", 100);
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);

		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 1, 1, 1, 339, 0);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';


		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(80, 100, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		stageTextField = new FlxUIInputText(80, 120, 70, _song.stage, 8);
		cutsceneTextField = new FlxUIInputText(80, 140, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);
		var isMoodyCheck = new FlxUICheckBox(10, 220, null, null, "Is Moody", 100);
		var isHeyCheck = new FlxUICheckBox(10, 250, null, null, "Is Hey", 100);
		var isCheerCheck = new FlxUICheckBox(100, 250, null, null, "Is Cheer", 100);
		isMoodyCheck.name = "isMoody";
		isHeyCheck.name = "isHey";
		isCheerCheck.name = "isCheer";
		isSpookyCheck.name = 'isSpooky';
		isMoodyCheck.checked = _song.isMoody;
		isSpookyCheck.checked = _song.isSpooky;
		isHeyCheck.checked = _song.isHey;
		isCheerCheck.checked = _song.isCheer;
		var curStage = _song.stage;
		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);

		tab_group_song.add(check_voices);
		tab_group_song.add(check_mute_inst);
		tab_group_song.add(isMoodyCheck);
		tab_group_song.add(isSpookyCheck);
		tab_group_song.add(isHeyCheck);
		tab_group_song.add(isCheerCheck);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperSpeed);

		UI_box.addGroup(tab_group_song);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	function addCharsUI():Void
	{
		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(120, 100, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gf, 8);
		stageTextField = new FlxUIInputText(120, 120, 70, _song.stage, 8);
		cutsceneTextField = new FlxUIInputText(120, 140, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);

		playerText = new FlxText(player1TextField.x + 70, player1TextField.y, 0, "Player", 8, false);
		enemyText = new FlxText(player2TextField.x + 70, player2TextField.y, 0, "Enemy", 8, false);
		gfText = new FlxText(gfTextField.x + 70, gfTextField.y, 0, "GF", 8, false);
		stageText = new FlxText(stageTextField.x + 70, stageTextField.y, 0, "Stage", 8, false);
		cutsceneText = new FlxText(cutsceneTextField.x + 70, uiTextField.y, 0, "Cutscene", 8, false);
		uiText = new FlxText(uiTextField.x + 70, uiTextField.y, 0, "UI", 8, false);

		var curStage = _song.stage;

		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";

		tab_group_char.add(playerText);
		tab_group_char.add(enemyText);
		tab_group_char.add(gfText);
		tab_group_char.add(stageText);
		tab_group_char.add(cutsceneText);
		tab_group_char.add(uiText);
		tab_group_char.add(uiTextField);
		tab_group_char.add(cutsceneTextField);
		tab_group_char.add(stageTextField);
		tab_group_char.add(gfTextField);
		tab_group_char.add(player1TextField);
		tab_group_char.add(player2TextField);

		UI_box.addGroup(tab_group_char);
		UI_box.scrollFactor.set();
	}





	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/*
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);

		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case "Is Moody":
					_song.isMoody = check.checked;
				case "Is Spooky":
					_song.isSpooky = check.checked;
				case "Is Hey":
					_song.isHey = check.checked;
				case 'Is Cheer':
					_song.isCheer = check.checked;
				}
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
	function lengthBpmBullshit():Float
	{
		if (_song.notes[curSection].changeBPM)
			return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
		else
			return _song.notes[curSection].lengthInSteps;
	}*/

	function sectionStartTime():Float
	{
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...curSection)
		{
			if (_song.notes[i].changeBPM) {
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;
		_song.player1 = player1TextField.text;
		_song.player2 = player2TextField.text;
		_song.gf = gfTextField.text;
		_song.stage = stageTextField.text;
		_song.cutsceneType = cutsceneTextField.text;
		_song.uiType = uiTextField.text;
		

		

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			if (_song.needsVoices) {
				vocals.stop();
			}
			FlxG.mouse.visible = false;
			LoadingState.loadAndSwitchState(new PlayState());
		}
		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}
		var shiftThing:Int = 1;

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */




		super.update(elapsed);
	}













	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = CoolUtil.stringifyJson(json);

		if ((data != null) && (data.length > 0))
		{
			/*
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
			*/ 
			FNFAssets.askToSave(_song.song.toLowerCase() + '.json', data);
		}
	}
}
