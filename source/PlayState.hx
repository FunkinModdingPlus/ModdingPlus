package;

import openfl.Lib;
import flixel.util.typeLimit.OneOfTwo;
import Character.EpicLevel;
import FNFAssets.HScriptAssets;
import flixel.ui.FlxButton.FlxTypedButton;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import openfl.geom.Matrix;
import flixel.FlxGame;
import flixel.FlxObject;
#if cpp
import Discord.DiscordClient;
#end
import DifficultyIcons;
import flixel.FlxSprite;
import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxSubState;
import flash.display.BitmapData;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import lime.system.System;
import openfl.media.Sound;
import flixel.group.FlxGroup;
import hscript.Interp;
import hscript.Parser;
import hscript.ParserEx;
import hscript.InterpEx;
import hscript.ClassDeclEx;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;

#end
import tjson.TJSON;
import Judgement.TUI;
using StringTools;
using CoolUtil.FlxTools;
typedef LuaAnim = {
	var prefix : String;
	@:optional var indices: Array<Int>;
	var name : String;
	@:optional var fps : Int;
	@:optional var loop : Bool;
}
enum abstract DisplayLayer(Int) from Int to Int {
	var BEHIND_GF = 1;
	var BEHIND_BF = 1 << 1;
	var BEHIND_DAD = 1 << 2;
	var BEHIND_ALL = BEHIND_GF | BEHIND_BF | BEHIND_DAD;
}
class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var defaultPlaylistLength = 0;
	public static var campaignScoreDef = 0;
	public static var ss:Bool = true;
	private var vocals:FlxSound;
	// use old bf
	private var oldMode:Bool = false;
	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Character;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;
	var totalNotesHit:Float = 0;
	var totalPlayed:Int =0;
	var totalNotesHitDefault:Float = 0;
	public var camFollow:FlxObject;
	private var player1Icon:String;
	private var player2Icon:String;
	public static var prevCamFollow:FlxObject;
	public static var misses:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	public static var sicks:Int = 0;
	public var songPosBar:FlxBar;
	public var songPosBG:FlxSprite;
	public var songPositionBar:Float = 0;
	var songLength:Float = 0.0;
	var songScoreDef:Int = 0;
	var nps:Int = 0;
	var currentTimingShown:FlxText;
	var playingAsRpc:String = "";
	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;
	private var playerComboBreak:FlxTypedGroup<FlxSprite>;
	private var enemyComboBreak:FlxTypedGroup<FlxSprite>;
	public var shitBreakColor:FlxColor = 0xFF175DB3;
	public var wayoffBreakColor:FlxColor = 0xFFAF0000;
	public var missBreakColor:FlxColor = 0xFFDD0A93;
	
	private var camZooming:Bool = false;
	private var curSong:String = "";
	private var strumming2:Array<Bool> = [false, false, false, false];
	private var strumming1:Array<Bool> = [false,false,false,false];

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	private var combo:Int = 0;
	public static var duoMode:Bool = false;
	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;
	//private var enemyColor:FlxColor = 0xFFFF0000;
	//private var opponentColor:FlxColor = 0xFFBC47FF;
	// private var playerColor:FlxColor = 0xFF66FF33;
	// private var poisonColor:FlxColor = 0xFFA22CD1;
	// private var poisonColorEnemy:FlxColor = 0xFFEA2FFF;
	// private var bfColor:FlxColor = 0xFF149DFF;
	private var barShowingPoison:Bool = false;
	private var pixelUI:Bool = false;
	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;
	/**
	 * Icon of player one
	 */
	public var iconP1:HealthIcon;
	/**
	 * Icon of player two
	 */
	public var iconP2:HealthIcon;
	/**
	 * HUD Camera (arrows, health)
	 */
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public var doof:DialogueBox;


	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var trueScore:Int = 0;
	var scoreTxt:FlxText;
	var healthTxt:FlxText;
	var accuracyTxt:FlxText;
	var difficTxt:FlxText;
	/**
	 * The total score of the week. Not a good idea to touch
	 * as it is a total and not divided until the end.
	 */
	public static var campaignScore:Int = 0;
	/**
	 * Total Accuracy of the week. Not a good idea to touch as it is a total. 
	 */
	public static var campaignAccuracy:Float = 0;
	public var defaultCamZoom:Float = 1.05;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	/**
	 * How big pixel assets are stretched
	 */
	public static var daPixelZoom:Float = 6;

	var bfoffset = [0.0, 0.0];
	var gfoffset = [0.0, 0.0];
	var dadoffset = [0.0, 0.0];
	var inCutscene:Bool = false;
	var alwaysDoCutscenes = false;
	var fullComboMode:Bool = false;
	var perfectMode:Bool = false;
	var practiceMode:Bool = false;
	public static var healthLossMultiplier:Float = 1;
	public static var healthGainMultiplier:Float = 1;
	var poisonExr:Bool = false;
	var poisonPlus:Bool = false;
	var beingPoisioned:Bool = false;
	var poisonTimes:Int = 0;
	var flippedNotes:Bool = false;
	var noteSpeed:Float = 0.45;
	var practiceDied:Bool = false;
	var practiceDieIcon:HealthIcon;
	private var regenTimer:FlxTimer;
	var sickFastTimer:FlxTimer;
	var accelNotes:Bool = false;
	var notesHit:Float = 0;
	var notesPassing:Int = 0;
	var vnshNotes:Bool = false;
	var invsNotes:Bool = false;
	var snakeNotes:Bool = false;
	var snekNumber:Float = 0;
	var drunkNotes:Bool = false;
	var alcholTimer:FlxTimer;
	var notesHitArray:Array<Date> = [];
	var alcholNumber:Float = 0;
	var inALoop:Bool = false;
	var useVictoryScreen:Bool = true;
	var demoMode:Bool = false;
	var downscroll:Bool = false;
	var luaRegistered:Bool = false;
	var currentFrames:Int = 0;
	var supLove:Bool = false;
	var loveMultiplier:Float = 0;
	var poisonMultiplier:Float = 0;
	var goodCombo:Bool = false;
	private var judgementList:Array<String> = [];
	private var preferredJudgement:String = '';
	/**
	 * If we are playing as opponent. 
	 */
	public static var opponentPlayer:Bool = false;
	/**
	 *  How much health is drained/regened with Supportive love 
	 * or Poison Fright
	 */
	 @:deprecated("REPLACED BY MODIFIER NUMBERS")
	public var drainBy:Float = 0.005;
	// this is just so i can collapse it lol
	#if true
	var hscriptStates:Map<String, Interp> = [];
	var exInterp:InterpEx = new InterpEx();
	var haxeSprites:Map<String, FlxSprite> = [];
	function callHscript(func_name:String, args:Array<Dynamic>, usehaxe:String) {
		// if function doesn't exist
		if (!hscriptStates.get(usehaxe).variables.exists(func_name)) {
			trace("Function doesn't exist, silently skipping...");
			return;
		}
		var method = hscriptStates.get(usehaxe).variables.get(func_name);
		switch(args.length) {
			case 0:
				method();
			case 1:
				method(args[0]);
		}
	}
	function callAllHScript(func_name:String, args:Array<Dynamic>) {
		for (key in hscriptStates.keys()) {
			callHscript(func_name, args, key);
		}
	}
	function setHaxeVar(name:String, value:Dynamic, usehaxe:String) {
		hscriptStates.get(usehaxe).variables.set(name,value);
	}
	function getHaxeVar(name:String, usehaxe:String):Dynamic {
		return hscriptStates.get(usehaxe).variables.get(name);
	}
	function setAllHaxeVar(name:String, value:Dynamic) {
		for (key in hscriptStates.keys())
			setHaxeVar(name, value, key);
	}
	function getHaxeActor(name:String):Dynamic {
		switch (name) {
			case "boyfriend" | "bf":
				return boyfriend;
			case "girlfriend" | "gf":
				return gf;
			case "dad":
				return dad;
			default:
				return strumLineNotes.members[Std.parseInt(name)];
		}
	}
	function makeHaxeState(usehaxe:String, path:String, filename:String) {
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseString(FNFAssets.getText(path + filename));
		var interp = PluginManager.createSimpleInterp();
		// set vars
		interp.variables.set("BEHIND_GF", BEHIND_GF);
		interp.variables.set("BEHIND_BF", BEHIND_BF);
		interp.variables.set("BEHIND_DAD", BEHIND_DAD);
		interp.variables.set("BEHIND_ALL", BEHIND_ALL);
		interp.variables.set("BEHIND_NONE", 0);
		interp.variables.set("difficulty", storyDifficulty);
		interp.variables.set("bpm", Conductor.bpm);
		interp.variables.set("songData", SONG);
		interp.variables.set("curSong", SONG.song);
		interp.variables.set("curStep", 0);
		interp.variables.set("curBeat", 0);
		interp.variables.set("camHUD", camHUD);
		interp.variables.set("showOnlyStrums", false);
		interp.variables.set("playerStrums", playerStrums);
		interp.variables.set("enemyStrums", enemyStrums);
		interp.variables.set("mustHit", false);
		interp.variables.set("strumLineY", strumLine.y);
		interp.variables.set("hscriptPath", path);
		interp.variables.set("boyfriend", boyfriend);
		interp.variables.set("gf", gf);
		interp.variables.set("dad", dad);
		interp.variables.set("vocals", vocals);
		interp.variables.set("gfSpeed", gfSpeed);
		interp.variables.set("tweenCamIn", tweenCamIn);
		interp.variables.set("health", health);
		interp.variables.set("iconP1", iconP1);
		interp.variables.set("iconP2", iconP2);
		interp.variables.set("currentPlayState", this);
		interp.variables.set("PlayState", PlayState);
		interp.variables.set("window", Lib.application.window);
		// give them access to save data, everything will be fine ;)
		interp.variables.set("isInCutscene", function () return inCutscene);
		trace("set vars");
		interp.variables.set("camZooming", false);
		// callbacks
		interp.variables.set("start", function (song) {});
		interp.variables.set("beatHit", function (beat) {});
		interp.variables.set("update", function (elapsed) {});
		interp.variables.set("stepHit", function(step) {});
		interp.variables.set("playerTwoTurn", function () {});
		interp.variables.set("playerTwoMiss", function () {});
		interp.variables.set("playerTwoSing", function () {});
		interp.variables.set("playerOneTurn", function()
		{
		});
		interp.variables.set("playerOneMiss", function()
		{
		});
		interp.variables.set("playerOneSing", function()
		{
		});
		interp.variables.set("noteHit", function(player1:Bool, note:Note) {});
		interp.variables.set("addSprite", function (sprite, position) {
			// sprite is a FlxSprite
			// position is a Int
			if (position & BEHIND_GF != 0)
				remove(gf);
			if (position & BEHIND_DAD != 0)
				remove(dad);
			if (position & BEHIND_BF != 0)
				remove(boyfriend);
			add(sprite);
			if (position & BEHIND_GF != 0)
				add(gf);
			if (position & BEHIND_DAD != 0)
				add(dad);
			if (position & BEHIND_BF != 0)
				add(boyfriend); 
		});
		interp.variables.set("add", add);
		interp.variables.set("remove", remove);
		interp.variables.set("insert", insert);
		interp.variables.set("switchCharacter", switchCharacter);
		interp.variables.set("setDefaultZoom", function(zoom) {defaultCamZoom = zoom;});
		interp.variables.set("removeSprite", function(sprite) {
			remove(sprite);
		});
		interp.variables.set("getHaxeActor", getHaxeActor);
		interp.variables.set("instancePluginClass", instanceExClass);
		trace("set stuff");
		interp.execute(program);
		hscriptStates.set(usehaxe,interp);
		callHscript("start", [SONG.song], usehaxe);
		trace('executed');
		
	}
	function instanceExClass(classname:String, args:Array<Dynamic> = null) {
		return exInterp.createScriptClassInstance(classname, args);
	}
	function makeHaxeExState(usehaxe:String, path:String, filename:String)
	{
		trace("opening a haxe state (because we are cool :))");
		var parser = new ParserEx();
		var program = parser.parseModule(FNFAssets.getText(path + filename));
		trace("set stuff");
		exInterp.registerModule(program);

		trace('executed');
	}
	#end
	var useCustomInput:Bool = false;
	var showMisses:Bool = false;
	var nightcoreMode:Bool = false;
	var daycoreMode:Bool = false;
	var useSongBar:Bool = true;
	var songName:FlxText;
	var uiSmelly:TUI;
	override public function create()
	{
		Note.specialNoteJson = null;
		if (FNFAssets.exists('assets/data/${SONG.song.toLowerCase()}/noteInfo.json')) {
			Note.specialNoteJson = CoolUtil.parseJson(FNFAssets.getText('assets/data/${SONG.song.toLowerCase()}/noteInfo.json'));
		}
		Judgement.uiJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_ui/ui_packs/ui.json'));
		uiSmelly = Reflect.field(Judgement.uiJson, SONG.uiType);
		misses = 0;
		bads = 0;
		goods = 0;
		sicks = 0;
		shits = 0;
		ss = true;
		// use current note amount
		Note.NOTE_AMOUNT = SONG.preferredNoteAmount;
		judgementList = CoolUtil.coolTextFile('assets/data/judgements.txt');
		preferredJudgement = judgementList[OptionsHandler.options.preferJudgement];
		if (preferredJudgement == 'none' || SONG.forceJudgements) {
			preferredJudgement = SONG.uiType;
			// if it is not using its own folder make preferred judgement
			if (Reflect.hasField(Judgement.uiJson, preferredJudgement) && Reflect.field(Judgement.uiJson, preferredJudgement).uses != preferredJudgement)
				preferredJudgement = Reflect.field(Judgement.uiJson, preferredJudgement).uses;
		}
		#if windows
		// Making difficulty text for Discord Rich Presence.
		// I JUST REALIZED THIS IS NOT VERY COMPATIBILE
		/*
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}
		*/
		storyDifficultyText = DifficultyManager.getDiffName(storyDifficulty);
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
		
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];
		persistentUpdate = true;
		persistentDraw = true;
		alwaysDoCutscenes = OptionsHandler.options.alwaysDoCutscenes;
		useCustomInput = OptionsHandler.options.useCustomInput;
		useVictoryScreen = !OptionsHandler.options.skipVictoryScreen;
		downscroll = OptionsHandler.options.downscroll;
		useSongBar = OptionsHandler.options.showSongPos;
		Judge.setJudge(cast OptionsHandler.options.judge);
		pixelUI = uiSmelly.isPixel;
		if (!OptionsHandler.options.skipModifierMenu) {
			fullComboMode = ModifierState.namedModifiers.fc.value;
			goodCombo = ModifierState.namedModifiers.gfc.value;
			perfectMode = ModifierState.namedModifiers.mfc.value;
			practiceMode = ModifierState.namedModifiers.practice.value;
			flippedNotes = ModifierState.namedModifiers.flipped.value;
			accelNotes = ModifierState.namedModifiers.accel.value;
			vnshNotes = ModifierState.namedModifiers.vanish.value;
			invsNotes = ModifierState.namedModifiers.invis.value;
			snakeNotes = ModifierState.namedModifiers.snake.value;
			drunkNotes = ModifierState.namedModifiers.drunk.value;
			// nightcoreMode = ModifierState.modifiers[18].value;
			// daycoreMode = ModifierState.modifiers[19].value;
			inALoop = ModifierState.namedModifiers.loop.value;
			duoMode = ModifierState.namedModifiers.duo.value;
			opponentPlayer = ModifierState.namedModifiers.oppnt.value;
			demoMode = ModifierState.namedModifiers.demo.value;
			if (ModifierState.namedModifiers.healthloss.value)
				healthLossMultiplier = ModifierState.namedModifiers.healthloss.amount;
			if (ModifierState.namedModifiers.healthgain.value)
				healthGainMultiplier = ModifierState.namedModifiers.healthgain.amount;
			if (ModifierState.namedModifiers.slow.value)
				noteSpeed = 0.3;
			if (accelNotes) {
				noteSpeed = 0.45;
				trace("accel arrows");
			}
			if (daycoreMode) {
				noteSpeed = 0.5;
			}


			if (ModifierState.namedModifiers.fast.value)
				noteSpeed = 0.9;
			if (ModifierState.namedModifiers.regen.value) {
				loveMultiplier = ModifierState.namedModifiers.regen.amount;
				supLove = true;
			}
			if (ModifierState.namedModifiers.degen.value) {
				poisonMultiplier = ModifierState.namedModifiers.degen.amount;
				poisonExr = true;
			}
			poisonPlus = ModifierState.namedModifiers.poison.value;
		} else {
			ModifierState.scoreMultiplier = 1;
		}
		// rebind always, to support djkf
		if (!opponentPlayer && !duoMode) {
			controls.setKeyboardScheme(Solo(false));
		}
		if (opponentPlayer) {
			controlsPlayerTwo.setKeyboardScheme(Solo(false));
		} else {
			controlsPlayerTwo.setKeyboardScheme(Duo(false));
		}
		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');
		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var sploosh = new NoteSplash(100, 100, 0);
		sploosh.alpha = 0.1;
		grpNoteSplashes.add(sploosh);
		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		var dialogSuffix = "";
		if (OptionsHandler.options.stressTankmen) {
			dialogSuffix = "-shit";
		}
		// if this is skipped when love is on, that means love is less than or equal to fright so
		else if (supLove && poisonMultiplier < loveMultiplier) {
			dialogSuffix = "-love";
		} else if (poisonExr && poisonMultiplier < 50) {
			dialogSuffix = "-uneasy";
		} else if (poisonExr && poisonMultiplier >= 50 && poisonMultiplier < 100) {
			dialogSuffix = "-scared";
		} else if (poisonExr && poisonMultiplier >= 100 && poisonMultiplier < 200) {
			dialogSuffix = "-terrified";
		} else if (poisonExr && poisonMultiplier >= 200) {
			dialogSuffix = "-depressed";
		} else if (practiceMode) {
			dialogSuffix = "-practice";
		} else if (perfectMode || fullComboMode || goodCombo) {
			dialogSuffix = "-perfect";
		}
		var filename:Null<String> = null;
		if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt'))
		{	
			filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog'+dialogSuffix+'.txt'))
				filename = 'assets/images/custom_chars/' + SONG.player1 + '/' + SONG.song.toLowerCase() + 'Dialog' + dialogSuffix + '.txt';
		}
		else if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt'))
		{
			filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog.txt';
			if (FNFAssets.exists('assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt')) {
				filename = 'assets/images/custom_chars/' + SONG.player2 + '/' + SONG.song.toLowerCase() + 'Dialog${dialogSuffix}.txt';
			}
			// if no player dialog, use default
		}
		else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog.txt'))
		{
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt'))
			{
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialog${dialogSuffix}.txt';
			}
		}
		else if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt'))
		{
			filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue.txt';
			if (FNFAssets.exists('assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt'))
			{
				filename = 'assets/data/' + SONG.song.toLowerCase() + '/dialogue${dialogSuffix}.txt';
			}
		}
		var goodDialog:String;
		if (filename != null) {
			goodDialog = FNFAssets.getText(filename);
		} else {
			goodDialog = ':dad: The game tried to get a dialog file but couldn\'t find it. Please make sure there is a dialog file named "dialog.txt".';
		}

		var gfVersion:String = 'gf';

		gfVersion = SONG.gf;
		trace(SONG.gf);
		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);
		if (duoMode || opponentPlayer)
			dad.beingControlled = true;
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			default:
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				camPos.x += dad.camOffsetX;
				camPos.y += dad.camOffsetY;
				if (dad.likeGf) {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
						function switchCharacter(charTo:String, charState:String) {
	    switch(charState) {
			case 'boyfriend':
			    remove(boyfriend);
				remove(iconP1);
				boyfriend = new Character(770, 450, charTo, true);
				var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
				camPos.x += boyfriend.camOffsetX;
				camPos.y += boyfriend.camOffsetY;
				boyfriend.x += boyfriend.playerOffsetX;
				boyfriend.y += boyfriend.playerOffsetY;
				if (boyfriend.likeGf) {
					boyfriend.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				} else if (!dad.likeGf) {
					gf.visible = true;
				}
				boyfriend.x += bfoffset[0];
				boyfriend.y += bfoffset[1];
				iconP1 = new HealthIcon(charTo, true);
				iconP1.y = healthBar.y - (iconP1.height / 2);
				iconP1.cameras = [camHUD];

				// Layering nonsense
				add(boyfriend);
				remove(healthBarBG);
				remove(healthBar);
				remove(iconP2);
				add(healthBarBG);
				add(healthBar);
				add(iconP1);
				add(iconP2);
			case 'dad':
				remove(dad);
				remove(iconP2);
				dad = new Character(100, 100, charTo);
				var camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
				dad.x += dad.enemyOffsetX;
				dad.y += dad.enemyOffsetY;
				camPos.x += dad.camOffsetX;
				camPos.y += dad.camOffsetY;
				if (dad.likeGf) {
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				} else if (!boyfriend.likeGf) {
					gf.visible = true;
				}
				dad.x += dadoffset[0];
		                dad.y += dadoffset[1];
				iconP2 = new HealthIcon(charTo, false);
				iconP2.y = healthBar.y - (iconP2.height / 2);
				iconP2.cameras = [camHUD];

				// Layering nonsense
				remove(boyfriend);
				add(dad);
				add(boyfriend);
				remove(healthBarBG);
				remove(healthBar);
				remove(iconP1);
				add(healthBarBG);
				add(healthBar);
				add(iconP1);
				add(iconP2);
			case 'gf':
				remove(gf);
				gf = new Character(400, 130, charTo);
				gf.scrollFactor.set(0.95, 0.95);
				gf.x += gfoffset[0];
				gf.y += gfoffset[1];

				// Layering nonsense
				remove(boyfriend);
				remove(dad);
				add(gf);
				add(dad);
				add(boyfriend);
		}
    }

					}
				}
		}



		boyfriend = new Character(770, 450, SONG.player1, true);
		if (!opponentPlayer && !demoMode)
			boyfriend.beingControlled = true;
		trace("newBF");
		switch (SONG.player1) // no clue why i didnt think of this before lol
		{
			default:
				//boyfriend.x += boyfriend.bfOffsetX; //just use sprite offsets
				//boyfriend.y += boyfriend.bfOffsetY;
				camPos.x += boyfriend.camOffsetX;
				camPos.y += boyfriend.camOffsetY;
				boyfriend.x += boyfriend.playerOffsetX;
				boyfriend.y += boyfriend.playerOffsetY;
				if (boyfriend.likeGf) {
					boyfriend.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (isStoryMode)
					{
						camPos.x += 600;
						tweenCamIn();
					}
				}
		}

		// REPOSITIONING PER STAGE
		boyfriend.x += bfoffset[0];
		boyfriend.y += bfoffset[1];
		gf.x += gfoffset[0];
		gf.y += gfoffset[1];
		dad.x += dadoffset[0];
		dad.y += dadoffset[1];
		trace('befpre spoop check');
		if (SONG.isSpooky) {
			trace("WOAH SPOOPY");
			var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
			evilTrail.framesEnabled = false;
			// evilTrail.changeValuesEnabled(false, false, false, false);
			// evilTrail.changeGraphic()
			trace(evilTrail);
			add(evilTrail);
		}
		add(gf);
		// Shitty layering but whatev it works LOL
		trace('dad');
		add(dad);
		trace('dy UWU');
		add(boyfriend);
		trace('bf cheeks');

		doof = new DialogueBox(false, goodDialog);
		trace('doofensmiz');
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		Conductor.songPosition = -5000;
		trace('prepare your strumlime');
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (downscroll) {
			strumLine.y = FlxG.height - 165;
		}
		playerComboBreak = new FlxTypedGroup<FlxSprite>();
		enemyComboBreak = new FlxTypedGroup<FlxSprite>();
		playerComboBreak.cameras = [camHUD];
		enemyComboBreak.cameras = [camHUD];
		add(playerComboBreak);
		add(enemyComboBreak);
		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		add(grpNoteSplashes);
		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();
		
		// startCountdown();
		trace('before generate');
		generateSong(SONG.song);

		// add(strumLine);
		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;
		trace('gay');
		if (useSongBar) {
			// todo, add options
			songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic('assets/images/healthBar.png');
		if (downscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
		if (duoMode)
			leftSideFill = dad.opponentColor;
		var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
		if (duoMode)
			rightSideFill = boyfriend.bfColor;
		healthBar.createFilledBar(leftSideFill, rightSideFill);
		// healthBar
		add(healthBar);

		scoreTxt = new FlxText(healthBarBG.x, healthBarBG.y + 40, 0, "", 200);
		scoreTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		healthTxt = new FlxText(healthBarBG.x + healthBarBG.width - 300, scoreTxt.y, 0, "", 200);
		healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		healthTxt.scrollFactor.set();
		healthTxt.visible = false;
		accuracyTxt = new FlxText(healthBarBG.x, scoreTxt.y, 0, "", 200);
		accuracyTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		accuracyTxt.scrollFactor.set();
		// shitty work around but okay
		accuracyTxt.visible = false;
		difficTxt = new FlxText(10, FlxG.height, 0, "", 150);
		
		difficTxt.setFormat("assets/fonts/vcr.ttf", 15, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		difficTxt.scrollFactor.set();
		difficTxt.y -= difficTxt.height;
		if (downscroll) {
			difficTxt.y = 0;
		}
		// screwy way of getting text
		difficTxt.text = DifficultyIcons.changeDifficultyFreeplay(storyDifficulty, 0).text + ' - M+ ${MainMenuState.version}';
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		practiceDieIcon = new HealthIcon('bf-old', false);
		practiceDieIcon.y = healthBar.y - (practiceDieIcon.height / 2);
		practiceDieIcon.x = healthBar.x - 130;
		practiceDieIcon.animation.curAnim.curFrame = 1;
		add(practiceDieIcon);
		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		practiceDieIcon.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		healthTxt.cameras = [camHUD];
		doof.cameras = [camHUD];
		accuracyTxt.cameras = [camHUD];
		difficTxt.cameras = [camHUD];
		practiceDieIcon.visible = false;

		add(scoreTxt);
		add(difficTxt);

		startingSong = true;
		trace('finish uo');
		
		
		var stageJson = CoolUtil.parseJson(FNFAssets.getText("assets/images/custom_stages/custom_stages.json"));
		makeHaxeState("stages", "assets/images/custom_stages/" + SONG.stage + "/", "../"+Reflect.field(stageJson, SONG.stage)+".hscript");
	if (alwaysDoCutscenes || isStoryMode )
		{

			switch (SONG.cutsceneType)
			{
				/*
				case "monster":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play('assets/sounds/Lights_Turn_On' + TitleState.soundExt);
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;
						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				*/
				case 'senpai':
					schoolIntro(doof);
				case 'angry-senpai':
					
					schoolIntro(doof);
				case 'none':
					startCountdown();
				default:
					// schoolIntro(doof);
					customIntro(doof);
			}
		}
		else
		{

			startCountdown();
		}

		super.create();

	}

	function customIntro(?dialogueBox:DialogueBox) {
		var goodJson = CoolUtil.parseJson(FNFAssets.getText('assets/images/custom_cutscenes/cutscenes.json'));
		if (!Reflect.hasField(goodJson, SONG.cutsceneType)) {
			schoolIntro(dialogueBox);
			return;
		}
		makeHaxeState("cutscene", "assets/images/custom_cutscenes/"+SONG.cutsceneType+'/', "../"+Reflect.field(goodJson, SONG.cutsceneType)+'.hscript');
		
	}
	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);
		/*
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		var senpaiSound:Sound;
		// try and find a player2 sound first
		if (FNFAssets.exists('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg')) {
			senpaiSound = FNFAssets.getSound('assets/images/custom_chars/'+SONG.player2+'/Senpai_Dies.ogg');
		// otherwise, try and find a song one
		} else if (FNFAssets.exists('assets/data/'+SONG.song.toLowerCase()+'/Senpai_Dies.ogg')) {
			senpaiSound = FNFAssets.getSound('assets/data/'+SONG.song.toLowerCase()+'Senpai_Dies.ogg');
		// otherwise, use the default sound
		} else {
			senpaiSound = FNFAssets.getSound('assets/sounds/Senpai_Dies.ogg');
		}
		var senpaiEvil:FlxSprite = new FlxSprite();
		// dialog box overwrites character
		if (FNFAssets.exists('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png')) {
			var evilImage = FNFAssets.getBitmapData('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.png');
			var evilXml = FNFAssets.getText('assets/images/custom_ui/dialog_boxes/'+SONG.cutsceneType+'/crazy.xml');
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		// character then takes precendence over default
		// will make things like monika way way easier
		} else if (FNFAssets.exists('assets/images/custom_chars/'+SONG.player2+'/crazy.png')) {
			var evilImage = FNFAssets.getBitmapData('assets/images/custom_chars/'+SONG.player2+'/crazy.png');
			var evilXml = FNFAssets.getText('assets/images/custom_chars/'+SONG.player2+'/crazy.xml');
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow(evilImage, evilXml);
		} else {
			senpaiEvil.frames = FlxAtlasFrames.fromSparrow('assets/images/weeb/senpaiCrazy.png', 'assets/images/weeb/senpaiCrazy.xml');
		}
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		if (dad.isPixel) {
			senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		}
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		*/
		if (SONG.cutsceneType == 'angry-senpai')
		{
			remove(black);
			/*
			if (SONG.cutsceneType == 'spirit')
			{
				add(red);
			}
			*/
		}
		
		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					// haha weeeee
					/*
					if (SONG.cutsceneType == 'spirit')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(senpaiSound, 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						
					}
					*/
					add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}
	function videoIntro(filename:String) {
		startCountdown();
		/*
		var b = new FlxSprite(-200, -200).makeGraphic(2*FlxG.width,2*FlxG.height, -16777216);
		b.scrollFactor.set();
		add(b);
		trace(filename);
		new FlxVideo(filename).finishCallback = function () {
			remove(b);
			FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.crochet / 1000) * 5, {ease: FlxEase.quadInOut});
			startCountdown();
		}*/
	}
	var startTimer:FlxTimer;
	var perfectModeOld:Bool = false;

	public function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);
		if (FNFAssets.exists("assets/data/" + SONG.song.toLowerCase() + "/modchart.hscript"))
		{
			makeHaxeState("modchart", "assets/data/" + SONG.song.toLowerCase() + "/", "modchart.hscript");
		}
		if (duoMode)
		{
			controls.setKeyboardScheme(Duo(true));
		}
		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (!duoMode || opponentPlayer)
				dad.dance();
			if (opponentPlayer)
				boyfriend.dance();
			gf.dance();


			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();

			for (field in Reflect.fields(Judgement.uiJson)) {
				if (Reflect.field(Judgement.uiJson, field).isPixel)
					introAssets.set(field, [
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/ready-pixel.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set-pixel.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses+'/date-pixel.png']);
				else
					introAssets.set(field, [
						'custom_ui/ui_packs/' + field + '/ready.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses + '/set.png',
						'custom_ui/ui_packs/' + Reflect.field(Judgement.uiJson, field).uses+'/go.png']);
			
			}

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";
			var intro3Sound:Sound;
			var intro2Sound:Sound;
			var intro1Sound:Sound;
			var introGoSound:Sound;
			for (value in introAssets.keys())
			{
				if (value == SONG.uiType)
				{
					introAlts = introAssets.get(value);
					// ok so apparently a leading slash means absolute soooooo
					if (pixelUI)
						altSuffix = '-pixel';
				}
			}

			// god is dead for we have killed him
			if (FNFAssets.exists("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg')) {
				intro3Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro3' + altSuffix + '.ogg');
				intro2Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro2' + altSuffix + '.ogg');
				intro1Sound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/intro1' + altSuffix + '.ogg');
				// apparently this crashes if we do it from audio buffer?
				// no it just understands 'hey that file doesn't exist better do an error'
				introGoSound = FNFAssets.getSound("assets/images/custom_ui/ui_packs/" + uiSmelly.uses + '/introGo' + altSuffix + '.ogg');
			} else {
				intro3Sound = FNFAssets.getSound('assets/sounds/intro3.ogg');
				intro2Sound = FNFAssets.getSound('assets/sounds/intro2.ogg');
				intro1Sound = FNFAssets.getSound('assets/sounds/intro1.ogg');
				introGoSound = FNFAssets.getSound('assets/sounds/introGo.ogg');
			}
	


			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(intro3Sound, 0.6);
				case 1:
					// my life is a lie, it was always this simple
					var sussyPath = 'assets/images/ready.png';
					if (FNFAssets.exists('assets/images/' + introAlts[0]))
						sussyPath = 'assets/images/' + introAlts[0];
					var readyImage = FNFAssets.getBitmapData(sussyPath);
					var ready:FlxSprite = new FlxSprite().loadGraphic(readyImage);
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (pixelUI)
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(intro2Sound, 0.6);
				case 2:
					var sussyPath = 'assets/images/set.png';
					if (FNFAssets.exists('assets/images/' + introAlts[1]))
						sussyPath = 'assets/images/' + introAlts[1];
					var setImage = FNFAssets.getBitmapData(sussyPath);
					// can't believe you can actually use this as a variable name
					var set:FlxSprite = new FlxSprite().loadGraphic(setImage);
					set.scrollFactor.set();

					if (pixelUI)
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(intro1Sound, 0.6);
				case 3:
					var sussyPath = 'assets/images/go.png';
					if (FNFAssets.exists('assets/images/' + introAlts[2]))
						sussyPath = 'assets/images/' + introAlts[2];
					var goImage = FNFAssets.getBitmapData(sussyPath);
					var go:FlxSprite = new FlxSprite().loadGraphic(goImage);
					go.scrollFactor.set();

					if (pixelUI)
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(introGoSound, 0.6);
				case 4:
					// what is this here for?
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
		/*
		regenTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			var bonus = drainBy;
			if (opponentPlayer) {
				bonus = -1 * drainBy;
			}
			if (poisonExr && !paused)
				health -= bonus;
			if (supLove && !paused)
				health +=  bonus;
		}, 0);
		*/
		sickFastTimer = new FlxTimer().start(2, function (tmr:FlxTimer) {
			if (accelNotes && !paused) {
				trace("tick:" + noteSpeed);
				noteSpeed += 0.01;
			}

		}, 0);
		var snekBase:Float = 0;
		var snekTimer = new FlxTimer().start(0.01, function (tmr:FlxTimer) {
			if (snakeNotes && !paused) {
				snekNumber = Math.sin(snekBase) * 100;
				snekBase += Math.PI/100;
			}

		}, 0);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;
		if (FlxG.sound.music != null) {
			// cuck lunchbox
			FlxG.sound.music.stop();
		}
		// : )
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;
		var useSong = "assets/music/" + SONG.song + "_Inst" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/music/" + SONG.song + "/Shit_Inst.ogg"))
			useSong = "assets/music/" + SONG.song + "/Shit_Inst.ogg";
		if (!paused)
			FlxG.sound.playMusic(FNFAssets.getSound(useSong), 1, false);
		songLength = FlxG.sound.music.length;

		if (useSongBar) // I dont wanna talk about this code :(
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0) {
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
		}
		FlxG.sound.music.onComplete = endSong;
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;
		var useSong = "assets/music/" + SONG.song + "_Voices" + TitleState.soundExt;
		if (OptionsHandler.options.stressTankmen && FNFAssets.exists("assets/music/" + SONG.song + "Shit_Voices.ogg"))
			useSong = "assets/music/" + SONG.song + "Shit_Voices.ogg";
		if (SONG.needsVoices) {
			#if sys
			var vocalSound = Sound.fromFile(useSong);
			vocals = new FlxSound().loadEmbedded(vocalSound);
			#else
			vocals = new FlxSound().loadEmbedded(useSong);
			#end
		}	else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		var customImage:Null<BitmapData> = null;
		var customXml:Null<String> = null;
		var arrowEndsImage:Null<BitmapData> = null;
		if (!pixelUI) {
			trace("has this been reached");
			customImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/NOTE_assets.png');
			customXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/NOTE_assets.xml');
		} else {
			customImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/arrows-pixels.png');
			arrowEndsImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses+'/arrowEnds.png');
		}
		

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + OptionsHandler.options.offset;
				var daNoteData:Int = Std.int(songNotes[1] % Note.NOTE_AMOUNT);
				var daLift:Bool = songNotes[4];
				var noteHeal:Float = songNotes[5] == null ? 1 : songNotes[5];
				var noteDamage:Float = songNotes[6] == null ? 1 : songNotes[6];
				var consitentNote:Bool = cast songNotes[7];
				var timeThingy:Float = songNotes[8] == null ? 1 : songNotes[8];
				// casting is not ok as default is true
				var shouldSing:Bool = if (songNotes[9] == null) true else songNotes[9];
				// casting is ok as null is falsey
				var ignoreHealthMods:Bool = cast songNotes[10];
				var animSuffix:Null<String> = songNotes[11];
				var gottaHitNote:Bool = section.mustHitSection;
				var altNote:Bool = false;
				if (songNotes[1] % 8 > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				/*
				if (songNotes[1] >= 8 && songNotes[1] < 16) {
					// sussy fire note support? :flushed:
					// Percent in decimal divided by health thingie
					noteHeal = 0.125 / 0.04;
					consitentNote = true;
					shouldSing = false;
					timeThingy = 0.5;
					noteDamage = 0;
					ignoreHealthMods = true;
					animSuffix = "lift";
				}
				*/
				if (songNotes[3] || section.altAnim)
				{
					altNote = true;
				}
				// force nuke notes : )
				if (songNotes[1] >= Note.NOTE_AMOUNT * 2 && songNotes[1] < Note.NOTE_AMOUNT * 4 && SONG.convertMineToNuke) {
					songNotes[1] += Note.NOTE_AMOUNT * 4;
				}
				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;
				// stand back i am a professional idiot
				var swagNote:Note = new Note(daStrumTime, songNotes[1], oldNote, false, customImage, customXml, arrowEndsImage, daLift, animSuffix);
				if (!swagNote.dontEdit && !swagNote.mineNote && !swagNote.nukeNote && !swagNote.isLiftNote) {
					swagNote.shouldBeSung = shouldSing;
					swagNote.ignoreHealthMods = ignoreHealthMods;
					swagNote.timingMultiplier = timeThingy;
					swagNote.healMultiplier = noteHeal;
					swagNote.damageMultiplier = noteDamage;
					swagNote.consistentHealth = consitentNote;
				}
				

				// altNote
				swagNote.altNote = altNote;
				swagNote.altNum = songNotes[3] == null ? (swagNote.altNote ? 1 : 0) : songNotes[3];
				// so much more complicated but makes playstation like shit work
				if (flippedNotes) {
					if (swagNote.animation.curAnim.name == 'greenScroll') {
						swagNote.animation.play('blueScroll');
					} else if (swagNote.animation.curAnim.name == 'blueScroll') {
						swagNote.animation.play('greenScroll');
					} else if (swagNote.animation.curAnim.name == 'redScroll') {
						swagNote.animation.play('purpleScroll');
					} else if (swagNote.animation.curAnim.name == 'purpleScroll') {
						swagNote.animation.play('redScroll');
					}
				}
				if (duoMode)
				{
					swagNote.duoMode = true;
				}
				if (opponentPlayer) {
					swagNote.oppMode = true;
				}
				if (demoMode)
					swagNote.funnyMode = true;
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);
				// when the imposter is sus XD
				if (susLength != 0) {
					for (susNote in 0...(Math.floor(susLength) + 2))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
						if (OptionsHandler.options.emuOsuLifts && susLength < susNote)
						{
							// simulate osu!mania holds by adding lifts at the end
							var liftNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, false,
								customImage, customXml, arrowEndsImage, true);
							if (duoMode)
								liftNote.duoMode = true;
							if (opponentPlayer)
								liftNote.oppMode = true;
							if (demoMode)
								liftNote.funnyMode = true;
							liftNote.scrollFactor.set();
							unspawnNotes.push(liftNote);
							liftNote.mustPress = gottaHitNote;
							if (liftNote.mustPress)
								liftNote.x += FlxG.width / 2;

							// how haxe works by default is exclusive?
						}
						else if (susLength > susNote)
						{
							var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote,
								true, customImage, customXml, arrowEndsImage);
							if (duoMode)
							{
								sustainNote.duoMode = true;
							}
							if (opponentPlayer)
							{
								sustainNote.oppMode = true;
							}
							if (demoMode)
								sustainNote.funnyMode = true;
							sustainNote.scrollFactor.set();
							unspawnNotes.push(sustainNote);
							sustainNote.shouldBeSung = shouldSing;
							sustainNote.ignoreHealthMods = ignoreHealthMods;
							sustainNote.timingMultiplier = timeThingy;
							sustainNote.healMultiplier = noteHeal;
							sustainNote.damageMultiplier = noteDamage;
							sustainNote.consistentHealth = consitentNote;
							sustainNote.mustPress = gottaHitNote;

							if (sustainNote.mustPress)
							{
								sustainNote.x += FlxG.width / 2; // general offset
							}
						}
					}
				}
				

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;
		// to get around how pecked up the note system is
		for (epicNote in unspawnNotes) {
			if (epicNote.isSustainNote) {
				if (flippedNotes) {
					if (epicNote.animation.curAnim.name == 'greenhold') {
						epicNote.animation.play('bluehold');
					} else if (epicNote.animation.curAnim.name == 'bluehold') {
						epicNote.animation.play('greenhold');
					} else if (epicNote.animation.curAnim.name == 'redhold') {
						epicNote.animation.play('purplehold');
					} else if (epicNote.animation.curAnim.name == 'purplehold') {
						epicNote.animation.play('redhold');
					} else if (epicNote.animation.curAnim.name == 'greenholdend') {
						epicNote.animation.play('blueholdend');
					} else if (epicNote.animation.curAnim.name == 'blueholdend') {
						epicNote.animation.play('greenholdend');
					} else if (epicNote.animation.curAnim.name == 'redholdend') {
						epicNote.animation.play('purpleholdend');
					} else if (epicNote.animation.curAnim.name == 'purpleholdend') {
						epicNote.animation.play('redholdend');
					}
				}
			}
		}
		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			if (!uiSmelly.isPixel)
			{
				var noteXml = FNFAssets.getText('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + "/NOTE_assets.xml");
				var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + "/NOTE_assets.png");
				babyArrow.frames = FlxAtlasFrames.fromSparrow(notePic, noteXml);
				babyArrow.animation.addByPrefix('green', 'arrowUP');
				babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
				babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
				babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
				if (flippedNotes)
				{
					babyArrow.animation.addByPrefix('blue', 'arrowUP');
					babyArrow.animation.addByPrefix('green', 'arrowDOWN');
					babyArrow.animation.addByPrefix('red', 'arrowLEFT');
					babyArrow.animation.addByPrefix('purple', 'arrowRIGHT');
				}
				babyArrow.antialiasing = true;
				babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

				switch (Math.abs(i))
				{
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.addByPrefix('static', 'arrowUP');
						babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						}
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
						babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						}
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.addByPrefix('static', 'arrowDOWN');
						babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						}
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.addByPrefix('static', 'arrowLEFT');
						babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
						babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}
				}
			}
			else
			{
				var notePic = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + "/arrows-pixels.png");
				babyArrow.loadGraphic(notePic, true, 17, 17);
				babyArrow.animation.add('green', [6]);
				babyArrow.animation.add('red', [7]);
				babyArrow.animation.add('blue', [5]);
				babyArrow.animation.add('purplel', [4]);
				if (flippedNotes)
				{
					babyArrow.animation.add('blue', [6]);
					babyArrow.animation.add('purplel', [7]);
					babyArrow.animation.add('green', [5]);
					babyArrow.animation.add('red', [4]);
				}
				babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
				babyArrow.updateHitbox();
				babyArrow.antialiasing = false;

				switch (Math.abs(i))
				{
					case 2:
						babyArrow.x += Note.swagWidth * 2;
						babyArrow.animation.add('static', [2]);
						babyArrow.animation.add('pressed', [6, 10], 12, false);
						babyArrow.animation.add('confirm', [14, 18], 12, false);
						if (flippedNotes)
						{
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 12, false);
						}
					case 3:
						babyArrow.x += Note.swagWidth * 3;
						babyArrow.animation.add('static', [3]);
						babyArrow.animation.add('pressed', [7, 11], 12, false);
						babyArrow.animation.add('confirm', [15, 19], 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						}
					case 1:
						babyArrow.x += Note.swagWidth * 1;
						babyArrow.animation.add('static', [1]);
						babyArrow.animation.add('pressed', [5, 9], 12, false);
						babyArrow.animation.add('confirm', [13, 17], 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						}
					case 0:
						babyArrow.x += Note.swagWidth * 0;
						babyArrow.animation.add('static', [0]);
						babyArrow.animation.add('pressed', [4, 8], 12, false);
						babyArrow.animation.add('confirm', [12, 16], 24, false);
						if (flippedNotes)
						{
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						}
				}
			}
			

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}
			
			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			} else {
				enemyStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);
			// does not need to be unique because it uses special thingies
			var comboBreakThing = new FlxSprite(babyArrow.x, 0).makeGraphic(Std.int(babyArrow.width), FlxG.height, FlxColor.WHITE);
			comboBreakThing.visible = false;
			comboBreakThing.alpha = 0.6;
			strumLineNotes.add(babyArrow);
			if (player == 1) {
				playerComboBreak.add(comboBreakThing);
			} else {
				enemyComboBreak.add(comboBreakThing);
			}
		}
	}
	function comboBreak(dir:Int, playerOne:Bool = true, rating:String = 'miss') {
	
		if (!OptionsHandler.options.showComboBreaks)
			return;
		var coolor = switch (rating) {
			case 'miss':
				missBreakColor;
			case 'wayoff':
				wayoffBreakColor;
			case 'shit':
				shitBreakColor;
			default:
				// just return, as we shouldn't even be here
				return;
		}
		var breakGroup = playerOne ? playerComboBreak : enemyComboBreak;
		dir = dir % 4;
		var thingToDisplay = breakGroup.members[dir];
		thingToDisplay.color = coolor;
		thingToDisplay.alpha = 1;
		thingToDisplay.visible = true;
		FlxTween.tween(thingToDisplay, {alpha: 0}, 1, {onComplete: function(_) {thingToDisplay.visible = false;}});
	}
	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}
			controls.setKeyboardScheme(Solo(false));
			#if windows
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC, null, null, playingAsRpc);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}
			if (!opponentPlayer && !duoMode)
			{
				controls.setKeyboardScheme(Solo(false));
			}
			if (duoMode) {
				controls.setKeyboardScheme(Duo(true));
			}
			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
			var currentIconState = "";
			if (opponentPlayer)
			{
				if (healthBar.percent > 80)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			else
			{
				if (healthBar.percent > 20)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			#if windows
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText
					+ " "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, true,
					songLength
					- Conductor.songPosition, playingAsRpc);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy), iconRPC,
					playingAsRpc);
			}
			#end
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		
		#if windows
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,
			playingAsRpc);
		#end
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectModeOld = false;
		#end
		setAllHaxeVar('camZooming', camZooming);
		setAllHaxeVar('gfSpeed', gfSpeed);
		setAllHaxeVar('health', health);
		callAllHScript('update', [elapsed]);
		
		if (hscriptStates.exists("modchart")) {
			if (getHaxeVar("showOnlyStrums", "modchart"))
			{
				healthBarBG.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}
			camZooming = getHaxeVar("camZooming", "modchart");
			gfSpeed = getHaxeVar("gfSpeed", "modchart");
			health = getHaxeVar("health", "modchart");

		}
		if (currentFrames == FlxG.save.data.fpsCap)
		{
			for (i in 0...notesHitArray.length)
			{
				var cock:Date = notesHitArray[i];
				if (cock != null)
					if (cock.getTime() + 2000 < Date.now().getTime())
						notesHitArray.remove(cock);
			}
			nps = Math.floor(notesHitArray.length / 2);
			currentFrames = 0;
		}
		else
			currentFrames++;
		super.update(elapsed);
		var properHealth = opponentPlayer ? 100 - Math.round(health*50) : Math.round(health*50);
		healthTxt.text = "Health:" + properHealth + "%";
		/*
		switch (OptionsHandler.options.accuracyMode) {
			case Simple | Binary | Complex: 
				if (notesPassing != 0)
					accuracy = HelperFunctions.truncateFloat((notesHit / notesPassing) * 100, 2);
				else
					accuracy = 100;
			case None:
				accuracy = 0;
		}*/
		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, accuracy);
		if (perfectMode && !Ratings.CalculateFullCombo(Sick))
		{
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		if (fullComboMode && !Ratings.CalculateFullCombo(Shit)) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		if (goodCombo && !Ratings.CalculateFullCombo(Good)) {
			if (opponentPlayer)
				health = 50;
			else
				health = -50;
		}
		accuracyTxt.text = "Accuracy:" + accuracy + "%";
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			#if windows
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
			LoadingState.loadAndSwitchState(new ChartingState());
		}
		if (FlxG.keys.justPressed.NINE) {
			oldMode = !oldMode;
			if (oldMode) {
				if (boyfriend.isPixel)
					iconP1.switchAnim("bf-pixel-old");
				else
					iconP1.switchAnim("bf-old");
			} else {
				iconP1.switchAnim(SONG.player1);
			}
		}
		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.50)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.50)));
		practiceDieIcon.setGraphicSize(Std.int(FlxMath.lerp(150, practiceDieIcon.width, 0.50)));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		practiceDieIcon.updateHitbox();
		var iconOffset:Int = 26;
		
		if (poisonTimes > 0 && !barShowingPoison) {
			var leftSideFill = opponentPlayer ? dad.poisonColorEnemy : dad.enemyColor;
			var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.poisonColor;
			healthBar.createFilledBar(leftSideFill, rightSideFill);
			barShowingPoison = true;
		} else if (poisonTimes == 0 && barShowingPoison) {
			var leftSideFill = opponentPlayer ? dad.opponentColor : dad.enemyColor;
			var rightSideFill = opponentPlayer ? boyfriend.bfColor : boyfriend.playerColor;
			if (duoMode) {
				leftSideFill = dad.opponentColor;
				rightSideFill = boyfriend.bfColor;
			}
			healthBar.createFilledBar(leftSideFill, rightSideFill);
			barShowingPoison = false;
		}

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
		player1Icon = SONG.player1;
		switch(SONG.player1) {
			case "bf-car":
				player1Icon = "bf";
			case "bf-christmas":
				player1Icon = "bf";
			case "bf-holding-gf":
				player1Icon = "bf";
			case "monster-christmas":
				player1Icon = "monster";
			case "mom-car":
				player1Icon = "mom";
			case "pico-speaker":
				player1Icon = "pico";
			case "gf-car":
				player1Icon = "gf";
			case "gf-christmas":
				player1Icon = "gf";
			case "gf-pixel":
				player1Icon = "gf";
			case "gf-tankman":
				player1Icon = "gf";
				
		}
		if (healthBar.percent < 20)
		{
			iconP1.iconState = Dying;
			iconP2.iconState = Winning;
			#if windows
			iconRPC = player1Icon + "-dead";
			#end
		}
		else
		{
			iconP1.iconState = Normal;
			#if windows
			iconRPC = player1Icon;
			#end
		}
		if (!opponentPlayer && poisonTimes != 0)
		{
			iconP1.iconState = Poisoned;
			#if windows
			iconRPC = player1Icon + "-dazed";
			#end
		}	
		
		// duo mode shouldn't show low health
		if (properHealth < 20 && !duoMode) {
			healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.RED, RIGHT, OUTLINE, FlxColor.BLACK);
		} else {
			healthTxt.setFormat("assets/fonts/vcr.ttf", 20, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		}	
		player2Icon = SONG.player2;
		switch (SONG.player2)
		{
			case "bf-car":
				player2Icon = "bf";
			case "bf-christmas":
				player2Icon = "bf";
			case "bf-holding-gf":
				player2Icon = "bf";
			case "monster-christmas":
				player2Icon = "monster";
			case "mom-car":
				player2Icon = "mom";
			case "pico-speaker":
				player2Icon = "pico";
			case "gf-car":
				player2Icon = "gf";
			case "gf-christmas":
				player2Icon = "gf";
			case "gf-pixel":
				player2Icon = "gf";
			case "gf-tankman":
				player2Icon = "gf";
		}

		if (healthBar.percent > 80) {
			iconP2.iconState = Dying;
			if (iconP1.iconState != Poisoned) {
				iconP1.iconState = Winning;
			}
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon + "-dead";
			#end
		}
		else {
			iconP2.iconState = Normal;
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon;
			#end
		}
		if (healthBar.percent < 20) {
			iconP2.iconState = Winning;
		}
		if (poisonTimes != 0 && opponentPlayer) {
			iconP2.iconState = Poisoned;
			#if windows
			if (opponentPlayer)
				iconRPC = player2Icon + "-dazed";
			#end
		}
		/* if (FlxG.keys.justPressed.NINE)
			LoadingState.loadAndSwitchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT) // stop checking for debug so i can fix my offsets!
			LoadingState.loadAndSwitchState(new AnimationDebug(SONG.player2, SONG.player1));
		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;
			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}
			setAllHaxeVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);
				callAllHScript("playerTwoTurn", []);
				if (dad.isCustom) {
					camFollow.y = dad.getMidpoint().y + dad.followCamY;
					camFollow.x = dad.getMidpoint().x + dad.followCamX;
				}
				vocals.volume = 1;
			}
			var currentIconState = "";
			if (opponentPlayer)
			{
				if (healthBar.percent > 80)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			else
			{
				if (healthBar.percent < 20)
				{
					currentIconState = "Dying";
				}
				else
				{
					currentIconState = "Playing";
				}
				if (poisonTimes != 0)
				{
					currentIconState = "Being Posioned";
				}
			}
			if (supLove) {
				health += loveMultiplier * (opponentPlayer ? -1 : 1) / 600000;
			}
			if (poisonExr) {
				health -= poisonMultiplier * (opponentPlayer ? -1 : 1)/ 700000;
			}
			playingAsRpc = "Playing as " + (opponentPlayer ? player2Icon : player1Icon) + " | " + currentIconState;
			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition((boyfriend.getMidpoint().x - 100 + boyfriend.followCamX), (boyfriend.getMidpoint().y - 100+boyfriend.followCamY));
				callAllHScript("playerOneTurn", []);
				switch (curStage)
				{
					// not sure that's how variable assignment works
					#if !windows
					case 'limo':
						camFollow.x = boyfriend.getMidpoint().x - 300 + boyfriend.followCamX; // why are you hard coded
					
					case 'mall':
						camFollow.y = boyfriend.getMidpoint().y - 200 + boyfriend.followCamY;
					#end
					case 'school':
						camFollow.x = boyfriend.getMidpoint().x - 200 + boyfriend.followCamX;
						camFollow.y = boyfriend.getMidpoint().y - 200 + boyfriend.followCamY;
					case 'schoolEvil':
						camFollow.x = boyfriend.getMidpoint().x - 200 + boyfriend.followCamX;
						camFollow.y = boyfriend.getMidpoint().y - 200 + boyfriend.followCamY;
				}
				
				/*
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
				*/
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		// now modchart
		/*
		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}*/
		// now mod chart
		/*
		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}*/
		// better streaming of shit

		// RESET = Quick Game Over Screen
		if (controls.RESET)
		{
			if (opponentPlayer)
				health = 2;
			else
				health = 0;
			trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			trace("User is cheating!");
		}

		if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceMode && !duoMode)
		{
			boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();
			
			if (inALoop) {
				FlxG.resetState();
			} else {
				// 1 / 1000 chance for Gitaroo Man easter egg
				if (FlxG.random.bool(0.1))
				{
					// gitaroo man easter egg
					LoadingState.loadAndSwitchState(new GitarooPause());
				}
				else
					openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				#if windows
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, null, null,
					playingAsRpc);
				#end

			}

			
			// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
		else if (((health <= 0 && !opponentPlayer) || (health >= 2 && opponentPlayer)) && !practiceDied && practiceMode) {
			practiceDied = true;
			practiceDieIcon.visible = true;
		}
		health = FlxMath.bound(health,0,2);
		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = !invsNotes;
					daNote.active = true;
				}
				var coolMustPress = daNote.mustPress;
				if (duoMode)
					coolMustPress = true;
				if (opponentPlayer)
					coolMustPress = !daNote.mustPress;
							
				if (!daNote.modifiedByLua) {
					if (downscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						else
							daNote.y = (enemyStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						if (daNote.isSustainNote)
						{
							// Remember = minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;
							
							if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								&& (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height) >= (strumLine.y + Note.swagWidth / 2)
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								// Clip to strumline
								// upon further inspection, this is purely visual :hueh:
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}

						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed,
									2));
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if ((daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
								&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)
								&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
							
						}
						}
					}
					/*
					if (downscroll) {
						daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
					} else {
						daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(SONG.speed, 2)));
					}
					
					// i am so fucking sorry for this if condition
					if (daNote.isSustainNote
						&& (((daNote.y + daNote.offset.y <= strumLine.y + Note.swagWidth / 2) && !downscroll)
						|| (downscroll && (daNote.y + daNote.offset.y >= strumLine.y + Note.swagWidth / 2)))
						&& (((!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && !opponentPlayer && !duoMode)
						|| ((daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))) && opponentPlayer)))
					{
						var swagRect = new FlxRect(0, strumLine.y + Note.swagWidth / 2 - daNote.y, daNote.width * 2, daNote.height * 2);
						swagRect.y /= daNote.scale.y;
						swagRect.height -= swagRect.y;
						daNote.clipRect = swagRect;
					}*/
				
				

				if (!daNote.mustPress && daNote.wasGoodHit && ((!duoMode && !opponentPlayer) || demoMode))
				{
					camZooming = true;
					dad.altAnim = "";
					dad.altNum = 0;
					if (daNote.altNote)
					{
						dad.altAnim = '-alt';
						dad.altNum = 1;
					}
					dad.altNum = daNote.altNum;
					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if ((SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0 && SONG.notes[Math.floor(curStep / 16)].altAnimNum != null) || SONG.notes[Math.floor(curStep / 16)].altAnim)
							// backwards compatibility shit
							if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1 || SONG.notes[Math.floor(curStep / 16)].altAnim || daNote.altNote)
								dad.altNum = 1;
							else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum != 0)
								dad.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
					}
					
					if (dad.altNum == 1) {
						dad.altAnim = '-alt';
					} else if (dad.altNum > 1) {
						dad.altAnim = '-' + dad.altNum + 'alt';
					}
					callAllHScript("playerTwoSing", []);
					// go wild <3
					if (daNote.shouldBeSung) {
						dad.sing(Std.int(Math.abs(daNote.noteData)), false, dad.altNum);
						enemyStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm');
								sustain2(spr.ID, spr, daNote);
							}
						});
						if (daNote.oppntSing != null) {
							boyfriend.sing(daNote.oppntSing.direction, daNote.oppntSing.miss, daNote.oppntSing.alt);
						}
					}
					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				} else if (daNote.mustPress && daNote.wasGoodHit && (opponentPlayer || demoMode)) {
					camZooming = true;
					callAllHScript("playerOneSing", []);
					if (daNote.shouldBeSung) {
						boyfriend.sing(Std.int(Math.abs(daNote.noteData % 4)));
						playerStrums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData % 4) == spr.ID)
							{
								spr.animation.play('confirm');
								sustain2(spr.ID, spr, daNote);
							}
						});
						if (daNote.oppntSing != null) {
							dad.sing(Std.int(Math.abs(daNote.oppntSing.direction % 4)), daNote.oppntSing.miss, daNote.oppntSing.alt);
							// don't strum it because there isn't actually a note
						}
					}
						
						
					boyfriend.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var neg = downscroll ? -1 : 1;
				if (drunkNotes) {
					daNote.y = (strumLine.y - neg * (Conductor.songPosition - daNote.strumTime) * ((Math.sin(songTime/400)/6)+0.5) * noteSpeed * FlxMath.roundDecimal(PlayState.SONG.speed, 2));
				} else {
					daNote.y = (strumLine.y - neg * (Conductor.songPosition - daNote.strumTime) * (noteSpeed * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));
				}
				if (vnshNotes) {
					if (downscroll) {
						daNote.alpha = FlxMath.remapToRange(-daNote.y, -strumLine.y,0 , 0, 1);
					} else {
						daNote.alpha = FlxMath.remapToRange(daNote.y, strumLine.y, FlxG.height, 0, 1);
					}
				}
					
				if (snakeNotes) {
					if (daNote.mustPress) {
						daNote.x = (FlxG.width/2)+snekNumber+(Note.swagWidth*daNote.noteData)+50;
					} else {
						daNote.x = snekNumber+(Note.swagWidth*daNote.noteData)+50;
					}
				}
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (((daNote.y < -daNote.height && !downscroll) || (daNote.y > FlxG.height + daNote.height && downscroll)) && !daNote.dontCountNote)
				{

						if ((daNote.tooLate || !daNote.wasGoodHit) /* && !daNote.isSustainNote */)
						{
							// always show the graphic/
							popUpScore(Conductor.songPosition, daNote, daNote.mustPress, true);
							
							vocals.volume = 0;
							if (poisonPlus && poisonTimes < 3)
							{
								poisonTimes += 1;
								var poisonPlusTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									if (opponentPlayer)
										health += 0.04;
									else
										health -= 0.04;
								}, 0);
								// stop timer after 3 seconds
								new FlxTimer().start(3, function(tmr:FlxTimer)
								{
									poisonPlusTimer.cancel();
									poisonTimes -= 1;
								});
							}
						}

						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
				}
				if ((!duoMode && !opponentPlayer) || demoMode) {
					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (strumming2[spr.ID])
						{
							spr.animation.play("confirm");
						}

						if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !daNote.isPixel)
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});
				} 
				if (opponentPlayer || demoMode) {
					playerStrums.forEach(function(spr:FlxSprite)
					{
						if (strumming1[spr.ID])
						{
							spr.animation.play("confirm");
						}

						if (spr.animation.curAnim.name == 'confirm' && !daNote.isPixel)
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});
				}
				
			});
		}

		if (!inCutscene && !demoMode) {
			// is that why it was crashing
			if (!opponentPlayer)
				keyShit(true);
			if (duoMode || opponentPlayer)
			{
				keyShit(false);
			}
		}
			

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}
	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
	{
		var length:Float = note.sustainLength;
		if (length > 0)
		{
			if (opponentPlayer)
				strumming1[strum] = true;
			else
				strumming2[strum] = true;
		}

		var bps:Float = Conductor.bpm / 60;
		var spb:Float = 1 / bps;

		if (!note.isSustainNote)
		{
			new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
			{
				if (opponentPlayer) {
					if (!strumming1[strum])
					{
						spr.animation.play("static", true);
					}
					else if (length > 0)
					{
						strumming1[strum] = false;
						spr.animation.play("static", true);
					}
				} else {
					if (!strumming2[strum])
					{
						spr.animation.play("static", true);
					}
					else if (length > 0)
					{
						strumming2[strum] = false;
						spr.animation.play("static", true);
					}
				}
				
			});
		}
	}
	function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		
		#if !switch
		if (!demoMode && ModifierState.scoreMultiplier > 0)
			Highscore.saveScore(SONG.song, songScore, storyDifficulty, accuracy/100, Ratings.CalculateFCRating(), OptionsHandler.options.judge);
		#end
		controls.setKeyboardScheme(Solo(false));
		if (isStoryMode)
		{
			campaignScore += songScore;
			campaignScoreDef += songScoreDef;
			campaignAccuracy += accuracy;
			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic('assets/music/freakyMenu' + TitleState.soundExt);

				if (!demoMode && ModifierState.scoreMultiplier > 0)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty, campaignAccuracy / defaultPlaylistLength);
				campaignAccuracy = campaignAccuracy / defaultPlaylistLength;
				if (useVictoryScreen) {
					#if windows	
					DiscordClient.changePresence("Reviewing Score -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, playingAsRpc);
					#end
					LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, gf.getScreenPosition().x, gf.getScreenPosition().y, campaignAccuracy, campaignScore, dad.getScreenPosition().x, dad.getScreenPosition().y));
				} else {
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					LoadingState.loadAndSwitchState(new StoryMenuState());
				}
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				difficulty = DifficultyIcons.getEndingFP(storyDifficulty);
				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play('assets/sounds/Lights_Shut_off' + TitleState.soundExt);
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
				}
				if (FNFAssets.exists('assets/data/'+PlayState.storyPlaylist[0].toLowerCase()+'/'+PlayState.storyPlaylist[0].toLowerCase()+difficulty+'.json'))
				  // do this to make custom difficulties not as unstable
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				else
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				LoadingState.loadAndSwitchState(new PlayState());
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			if (useVictoryScreen) {
				#if windows
				DiscordClient.changePresence("Reviewing Score -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC, playingAsRpc);
				#end
				LoadingState.loadAndSwitchState(new VictoryLoopState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, gf.getScreenPosition().x,gf.getScreenPosition().y, accuracy, songScore, dad.getScreenPosition().x, dad.getScreenPosition().y));
			} else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;
	var timeShown:Int = 0;
	private function popUpScore(strumtime:Float, daNote:Note, playerOne:Bool, forceMiss:Bool = false):Void
	{
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var noteDiffSigned:Float = Conductor.songPosition - daNote.strumTime;
		var wife:Float = HelperFunctions.wife3(noteDiffSigned, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		camZooming = true;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		
		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		if (daNote.mineNote)
			// make note diff sussy and harder to hit because mine notes are weird champ
			noteDiff *= 1.9;
		if (daNote.nukeNote)
			noteDiff *= 3;
		daNote.rating = Ratings.CalculateRating(noteDiff);
		daRating = daNote.rating;
		trace(daRating);
		var healthBonus = 0.0;
		// you can't really control how you hit sustains so always make em sick
		if (daNote.isSustainNote) {
			daRating = 'sick';
		}
		if (forceMiss) {
			daRating = 'miss';
		}
		if (OptionsHandler.options.accuracyMode == Complex)
			totalNotesHit += wife;
		
		// SHIT IS A COMBO BREAKER IN ETTERNA NERDS
		// GIT GUD
		var dontCountNote = daNote.dontCountNote;
		if (!daNote.mineNote) {
			switch (daRating)
			{
				case 'shit':
					if (!dontCountNote)
					{
						ss = false;
						shits++;
						
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						} 
						misses++;
						score = -300;
						combo = 0;
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'wayoff':
					if (!dontCountNote)
					{
						score = -300;
						combo = 0;
						misses++;
						ss = false;
						shits++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						}
					}

					// healthBonus -= 0.06 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'bad':
					if (!dontCountNote)
					{
						score = 0;
						ss = false;
						bads++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 0.50;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
					}
					daRating = 'bad';

					// healthBonus -= 0.03 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;

				case 'good':
					if (!dontCountNote)
					{
						score = 200;
						ss = false;
						goods++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 0.75;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
					}
					daRating = 'good';

					// healthBonus += 0.03 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;

				case 'sick':
					// healthBonus += 0.07 * if (daNote.ignoreHealthMods) 1 else healthGainMultiplier * daNote.healMultiplier;
					if (!dontCountNote)
					{
						// if it be binary or not
						// it shall be a 1
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit += 1;
						}
						else if (OptionsHandler.options.accuracyMode == Binary)
						{
							totalNotesHit += 1;
						}
						sicks++;
					}

					if (!daNote.isSustainNote)
					{
						var recycledNote = grpNoteSplashes.recycle(NoteSplash);
						recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
						grpNoteSplashes.add(recycledNote);
					}

				case 'miss':
					// noteMiss(daNote.noteData, playerOne);
					// healthBonus = -0.04 * if (daNote.ignoreHealthMods) 1 else healthLossMultiplier * daNote.damageMultiplier;
					if (!dontCountNote)
					{
						misses++;
						if (OptionsHandler.options.accuracyMode == Simple)
						{
							totalNotesHit -= 1;
						}
						ss = false;
						score = -5;
					}
			}
		}
		if (daNote.nukeNote && daRating != 'miss')
			// die <3
			healthBonus = -4;
		healthBonus = daNote.getHealth(daRating);
		if (daNote.dontEdit)
			trace(healthBonus);
		if (daNote.isSustainNote) {
			healthBonus  *= 0.2;
		}
		if (!playerOne)
			health -= healthBonus;
		else
			health += healthBonus;
		updateAccuracy();
		if (daNote.isSustainNote) {
			return;
		}
		if (notesHit > notesPassing) {
			notesHit = notesPassing;
		}
		if (!dontCountNote) {
			songScore += Math.round(ConvertScore.convertScore(noteDiff) * ModifierState.scoreMultiplier);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));
			trueScore += Math.round(ConvertScore.convertScore(noteDiff));
		}
		comboBreak(daNote.noteData % 4, playerOne, daRating);
		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';
		if (uiSmelly.isPixel) {
			pixelShitPart2 = '-pixel';
		}
		var ratingImage:BitmapData;
		ratingImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/' + daRating + pixelShitPart2 + ".png");
		trace(pixelUI);
		rating = new Judgement(0, 0, daRating, preferredJudgement,
			noteDiffSigned < 0, pixelUI);
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		if (OptionsHandler.options.newJudgementPos) {
			rating.cameras = [camHUD];
			rating.y = 0;
			rating.x = 0;
			if (!downscroll) {
				rating.y = FlxG.height - rating.height;
			}
			
		}
		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(ratingImage);
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		var msTiming = HelperFunctions.truncateFloat(noteDiffSigned, 3);
		if (FlxG.save.data.botplay)
			msTiming = 0;
		timeShown = 0;
		if (currentTimingShown != null)
			remove(currentTimingShown);

		currentTimingShown = new FlxText(0, 0, 0, "0ms");
		switch (daRating)
		{
			case 'miss':
				currentTimingShown.color = FlxColor.MAGENTA;
			case 'shit' | 'bad' | 'wayoff':
				currentTimingShown.color = FlxColor.RED;
			case 'good':
				currentTimingShown.color = FlxColor.GREEN;
			case 'sick':
				currentTimingShown.color = FlxColor.CYAN;
		}
		currentTimingShown.borderStyle = OUTLINE;
		currentTimingShown.borderSize = 1;
		currentTimingShown.borderColor = FlxColor.BLACK;
		currentTimingShown.text = msTiming + "ms";
		currentTimingShown.size = 20;


		if (currentTimingShown.alpha != 1)
			currentTimingShown.alpha = 1;

		if (!demoMode)
			add(currentTimingShown);
		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		currentTimingShown.screenCenter();
		currentTimingShown.x = comboSpr.x + 100;
		currentTimingShown.y = rating.y + 100;
		currentTimingShown.acceleration.y = 600;
		currentTimingShown.velocity.y -= 150;
		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numImage:BitmapData;
			if (FNFAssets.exists('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + Std.int(i) + pixelShitPart2 + ".png"))
				numImage = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/' + uiSmelly.uses + '/num' + Std.int(i) + pixelShitPart2 + ".png");
			else
				numImage = FNFAssets.getBitmapData('assets/images/num' + Std.int(i) + '.png');
			var numScore:FlxSprite = new FlxSprite().loadGraphic(numImage);
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!pixelUI)
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		currentTimingShown.cameras = [camHUD];
		/*
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001,
			onUpdate: function(tween:FlxTween)
			{
				if (currentTimingShown != null)
					currentTimingShown.alpha -= 0.02;
				timeShown++;
			},
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
				if (currentTimingShown != null && timeShown >= 20)
				{
					remove(currentTimingShown);
					currentTimingShown = null;
				}
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
		if (daNote.nukeNote && daRating != 'miss')
		{
			if (!playerOne)
				health = 69;
			else
				health = -69;
		}
	}
	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}
	private function keyShit(?playerOne:Bool=true):Void
	{
		// HOLDING
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var up = coolControls.UP;
		var right = coolControls.RIGHT;
		var down = coolControls.DOWN;
		var left = coolControls.LEFT;
		var holdArray = [left, down, up, right];
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		
		var upR = coolControls.UP_R;
		var rightR = coolControls.RIGHT_R;
		var downR = coolControls.DOWN_R;
		var leftR = coolControls.LEFT_R;
		var releaseArray = [leftR, downR, upR, rightR];
		var controlArray:Array<Bool> = [leftP, downP, upP, rightP];
		var pressArray = controlArray;
		// FlxG.watch.addQuick('asdfa', upP);
		var actingOn:Character = playerOne ? boyfriend : dad;
		// <3 easy way of doing it
		if (controlArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && !daNote.isLiftNote)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
								dumbNotes.push(daNote);
								break;
							} else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime) {
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					} else  {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}

				}
			});
			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...pressArray.length)
			{
				if (pressArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck)
			{
				var daNote = possibleNotes[0];

				if (!OptionsHandler.options.useCustomInput) {
					for (shit in 0...pressArray.length)
					{ // if a direction is hit that shouldn't be
						if (pressArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				
				// Jump notes
				for (coolNote in possibleNotes)
				{
					// even though IT SHOULD BE ABLE TO BE HIT we do this terrible ness
					if (pressArray[coolNote.noteData] && coolNote.canBeHit && !coolNote.tooLate)
					{
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote, playerOne);
					}
				}

			}
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, playerOne);
			}
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode) {
				if (mashViolations > 4)
				{
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				}
				else
					mashViolations++;
			}
		}
		// lift notes :)
		if (releaseArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			actingOn.holdTimer = 0;

			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];
			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				if (daNote.canBeHit && coolShouldPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.isLiftNote)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					if (directionList.contains(daNote.noteData))
					{
						for (coolNote in possibleNotes)
						{
							if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
							{
								dumbNotes.push(daNote);
								break;
							}
							else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
							{
								possibleNotes.remove(coolNote);
								possibleNotes.push(daNote);
								break;
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});
			for (note in dumbNotes)
			{
				FlxG.log.add("killing dumb ass note at " + note.strumTime);
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] && !directionList.contains(i))
					dontCheck = true;
			}
			if (possibleNotes.length > 0 && !dontCheck)
			{
				var daNote = possibleNotes[0];
				/*
				if (!OptionsHandler.options.useCustomInput)
				{
					for (shit in 0...releaseArray.length)
					{ // if a direction is hit that shouldn't be
						if (releaseArray[shit] && !directionList.contains(shit))
							noteMiss(shit, playerOne);
					}
				}
				*/
				//	 Jump notes
				for (coolNote in possibleNotes)
				{
					if (releaseArray[coolNote.noteData])
					{
						if (mashViolations != 0)
							mashViolations--;
						scoreTxt.color = FlxColor.WHITE;
						goodNoteHit(coolNote, playerOne);
					}
				}
			}
			/*
			else if (!OptionsHandler.options.useCustomInput)
			{
				for (shit in 0...releaseArray.length)
					if (releaseArray[shit])
						noteMiss(shit, playerOne);
			}
			*/
			// :shrug: idk what this for
			if (dontCheck && possibleNotes.length > 0 && OptionsHandler.options.useCustomInput && !demoMode)
			{
				if (mashViolations > 4)
				{
					trace('mash violations ' + mashViolations);
					scoreTxt.color = FlxColor.RED;
					noteMiss(0, playerOne);
				}
				else
					mashViolations++;
			}
		}
		if (holdArray.contains(true) && !actingOn.stunned && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var coolShouldPress = playerOne ? daNote.mustPress : !daNote.mustPress;
				var daRating = Ratings.CalculateRating(Math.abs(daNote.strumTime - Conductor.songPosition));
				// make sustain notes act
				// changing it to sick :blush:
				if (daNote.canBeHit && coolShouldPress && daNote.isSustainNote && ( daRating == 'sick'))
				{
					if (holdArray[daNote.noteData])
						goodNoteHit(daNote, playerOne);
				}
			});
		}
		if (actingOn.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !holdArray.contains(true))
		{
			if (actingOn.animation.curAnim.name.startsWith('sing') && !actingOn.animation.curAnim.name.endsWith('miss'))
			{
				actingOn.dance();
				trace("idle from non miss sing");
			}
		}
		var strums = playerOne ? playerStrums : enemyStrums;
		strums.forEach(function(spr:FlxSprite)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (releaseArray[spr.ID])
				spr.animation.play('static');
			
			if (spr.animation.curAnim != null && spr.animation.curAnim.name == 'confirm' && !pixelUI)
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}
	var mashing:Int = 0;
	var mashViolations:Int = 0;
	function noteMiss(direction:Int = 1, playerOne:Bool, ?note:Null<Note>):Void
	{
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		if (!actingOn.stunned)
		{
			misses += 1;
			
			var healthBonus = -0.04 * healthLossMultiplier;
			if (note != null) {
				healthBonus = note.getHealth('miss');
			}
			if (playerOne)
				health += healthBonus;
			else
				health -= healthBonus;
			if (combo > 5 && gf.gfEpicLevel >= EpicLevel.Level_Sadness)
			{
				gf.playAnim('sad');
			}
			updateAccuracy();
			combo = 0;
			if (!practiceMode) {
				songScore -= 5;

			}
			trueScore -= 5;
			FlxG.sound.play('assets/sounds/missnote' + FlxG.random.int(1, 3) + TitleState.soundExt, FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play('assets/sounds/missnote1' + TitleState.soundExt, 1, false);
			// FlxG.log.add('played imss note');

			actingOn.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				actingOn.stunned = false;
			});
			if (note == null || note.shouldBeSung) {
				actingOn.sing(direction, true);
				if (note != null && note.oppntSing != null) {
					onActing.sing(note.oppntSing.direction, note.oppntSing.miss, note.oppntSing.alt);
				}
			}
				
			if (playerOne) {
				callAllHScript("playerOneMiss", []);
			} else {
				callAllHScript("playerTwoMiss", []);
			}
		}
	}

	function badNoteCheck(?playerOne:Bool=true)
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var coolControls = playerOne ? controls : controlsPlayerTwo;
		var upP = coolControls.UP_P;
		var rightP = coolControls.RIGHT_P;
		var downP = coolControls.DOWN_P;
		var leftP = coolControls.LEFT_P;

		if (leftP)
			noteMiss(0, playerOne);
		if (downP)
			noteMiss(1, playerOne);
		if (upP)
			noteMiss(2,playerOne);
		if (rightP)
			noteMiss(3,playerOne);
	}

	function noteCheck(keyP:Bool, note:Note, playerOne:Bool):Void
	{
		var noteDiff:Float = Math.abs(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff);
		if (keyP)
			goodNoteHit(note,playerOne);
		else
		{
			badNoteCheck(playerOne);
		}
	}

	function goodNoteHit(note:Note, playerOne:Bool):Void
	{
		var actingOn = playerOne ? boyfriend : dad;
		var onActing = playerOne ? dad : boyfriend;
		if (!note.canBeHit || note.tooLate)
			return;
		if (!note.isSustainNote)
			notesHitArray.push(Date.now());
		if (!note.wasGoodHit)
		{
			trace("<3 was good hit");
			actingOn.altAnim = "";
			actingOn.altNum = 0;
			
			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (( SONG.notes[Math.floor(curStep / 16)].altAnimNum != null && SONG.notes[Math.floor(curStep / 16)].altAnimNum > 0)
					|| SONG.notes[Math.floor(curStep / 16)].altAnim)
					// backwards compatibility shit
					if (SONG.notes[Math.floor(curStep / 16)].altAnimNum == 1
						|| SONG.notes[Math.floor(curStep / 16)].altAnim)
						actingOn.altNum = 1;
					else if (SONG.notes[Math.floor(curStep / 16)].altAnimNum > 1)
						actingOn.altNum = SONG.notes[Math.floor(curStep / 16)].altAnimNum;
			}
			if (note.altNote)
				actingOn.altNum = 1;
			actingOn.altNum = note.altNum;
			if (actingOn.altNum == 1)
			{
				actingOn.altAnim = '-alt';
			}
			else if (actingOn.altNum > 1)
			{
				actingOn.altAnim = '-' + actingOn.altNum + 'alt';
			}
			// We pop it up even for sustains, just to update score. We don't actually show anything.
			trace("<3 pop up score");
			if (!note.dontCountNote)
				notesPassing += 1;
			popUpScore(note.strumTime, note, playerOne);
			combo += 1;
			
			/*
			if (note.noteData >= 0)
				health += 0.01 * healthGainMultiplier;
			else
				health += 0.005 * healthGainMultiplier;
			*/
			if (note.shouldBeSung) {
				actingOn.sing(note.noteData, false, actingOn.altNum);
				if (playerOne)
					callAllHScript("playerOneSing", []);
				else
					callAllHScript("playerTwoSing", []);
				var strums = playerOne ? playerStrums : enemyStrums;
				strums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});
				if (note.oppntSing != null) {
					onActing.sing(note.oppntSing.direction, note.oppntSing.miss, note.oppntSing.alt);
				}
			}
			callAllHScript("noteHit", [playerOne, note]);
			
				
				
		

			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
			
		}
	}


	override function stepHit()
	{
		super.stepHit();
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		setAllHaxeVar("curStep", curStep);
		callAllHScript("stepHit", [curStep]);

		songLength = FlxG.sound.music.length;

		if (useSongBar && songPosBar.max == 69695969) {
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic('assets/images/healthBar.png');
			if (downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBG.cameras = [camHUD];
			if (FlxG.sound.music.length == 0)
			{
				songLength = 69696969;
			}
			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			songPosBar.cameras = [camHUD];

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20, songPosBG.y, 0, SONG.song, 16);
			if (downscroll)
				songName.y -= 3;
			songName.setFormat("assets/fonts/vcr.ttf", 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
			songName.cameras = [camHUD];
			
		}
		#if windows
		// Song duration in a float, useful for the time left feature
		

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC,true,
			songLength
			- Conductor.songPosition, playingAsRpc);
		#end
	}


	override function beatHit()
	{
		super.beatHit();
		
		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);
			
			// Dad doesnt interupt his own notes
			if (!dad.animation.curAnim.name.startsWith("sing") && ((!duoMode && !opponentPlayer) || demoMode))
				dad.dance();
			if (!boyfriend.animation.curAnim.name.startsWith("sing") && (opponentPlayer || demoMode))
				boyfriend.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
		{
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		practiceDieIcon.setGraphicSize(Std.int(practiceDieIcon.width + 30));
		iconP1.updateHitbox();
		iconP2.updateHitbox();
		practiceDieIcon.updateHitbox();
		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (!boyfriend.animation.curAnim.name.startsWith("sing") && !opponentPlayer && !demoMode)
		{
			boyfriend.dance();
		}
		if (dad.animation.curAnim != null && !dad.animation.curAnim.name.startsWith("sing") && (duoMode || opponentPlayer) && !demoMode) {
			dad.dance();
		}
		if (curBeat % 8 == 7 && SONG.isHey)
		{
			boyfriend.playAnim('hey', true);

			
		}
		if (curBeat % 8 == 7 && SONG.isCheer && dad.gfEpicLevel >= Character.EpicLevel.Level_Sing)
		{
			dad.playAnim('cheer', true);
		}
		// gf should also cheer?
		if (curBeat % 8 == 7 && SONG.isCheer && gf.gfEpicLevel >= Character.EpicLevel.Level_Sing)
		{
			gf.playAnim('cheer', true);
		}

		setAllHaxeVar('curBeat', curBeat);
		callAllHScript('beatHit', [curBeat]);
	}

}