package;

import flixel.system.frontEnds.CameraFrontEnd;
import flixel.system.frontEnds.BitmapFrontEnd;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSoundGroup;
import flixel.system.frontEnds.SoundFrontEnd;
import openfl.display.DisplayObject;
import flixel.input.keyboard.FlxKeyboard;
import flixel.system.frontEnds.InputFrontEnd;
import flixel.math.FlxRect;
import flixel.FlxState;
import openfl.display.Stage;
import flixel.FlxGame;
import flixel.input.gamepad.FlxGamepadManager;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.addons.effects.FlxTrail;
import plugins.tools.MetroSprite;
import FNFAssets.HScriptAssets;
import hscript.InterpEx;
import hscript.Interp;
import flixel.FlxG;

class PluginManager {
    public static var interp = new InterpEx();
    public static var hscriptClasses:Array<String> = [];
	@:access(hscript.InterpEx)
    public static function init() {
        var filelist = hscriptClasses = CoolUtil.coolTextFile("assets/scripts/plugin_classes/classes.txt");
		interp = addVarsToInterp(interp);
        HscriptGlobals.init();
        for (file in filelist) {
            if (FNFAssets.exists("assets/scripts/plugin_classes/" + file + ".hx")) {
				interp.addModule(FNFAssets.getText("assets/scripts/plugin_classes/" + file + '.hx'));
            }
        }
        trace(InterpEx._scriptClassDescriptors);
    }
    /**
     * Create a simple interp, that already added all the needed shit
     * This is what has all the default things for hscript.
     * @see https://github.com/TheDrawingCoder-Gamer/Funkin/wiki/HScript-Commands
     * @return Interp
     */
    public static function createSimpleInterp():Interp {
        var reterp = new Interp();
        reterp = addVarsToInterp(reterp);
        return reterp;
    }
    public static function addVarsToInterp<T:Interp>(interp:T):T {
		interp.variables.set("Conductor", Conductor);
		interp.variables.set("FlxSprite", DynamicSprite);
		interp.variables.set("FlxSound", DynamicSound);
		interp.variables.set("FlxAtlasFrames", DynamicSprite.DynamicAtlasFrames);
		interp.variables.set("FlxGroup", flixel.group.FlxGroup);
		interp.variables.set("FlxAngle", flixel.math.FlxAngle);
		interp.variables.set("FlxMath", flixel.math.FlxMath);
		interp.variables.set("TitleState", TitleState);
		interp.variables.set("makeRangeArray", CoolUtil.numberArray);
		interp.variables.set("FNFAssets", HScriptAssets);
		// : )
		interp.variables.set("FlxG", HscriptGlobals);
		interp.variables.set("FlxTimer", flixel.util.FlxTimer);
		interp.variables.set("FlxTween", flixel.tweens.FlxTween);
		interp.variables.set("Std", Std);
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("MetroSprite", MetroSprite);
		interp.variables.set("FlxTrail", FlxTrail);
		interp.variables.set("FlxEase", FlxEase);
		interp.variables.set("Reflect", Reflect);
		interp.variables.set("Character", Character);
		interp.variables.set("OptionsHandler", OptionsHandler);
		#if debug
		interp.variables.set("debug", true);
		#else
		interp.variables.set("debug", false);
		#end
        return interp;
    }
}
class HscriptGlobals {
    public static var VERSION = FlxG.VERSION;
    public static var autoPause(get, set):Bool;
    public static var bitmap(get, never):BitmapFrontEnd;
    // no bitmapLog
    public static var camera(get ,set):FlxCamera;
    public static var cameras(get, never):CameraFrontEnd;
    // no console frontend
    // no debugger frontend
    public static var drawFramerate(get, set):Int;
    public static var elapsed(get, never):Float;
    public static var fixedTimestep(get, set):Bool;
    public static var fullscreen(get, set):Bool;
    public static var game(get, never):FlxGame;
    public static var gamepads(get, never):FlxGamepadManager;
    public static var height(get, never):Int;
    public static var initialHeight(get, never):Int;
    public static var initialWidth(get, never):Int;
    public static var initialZoom(get, never):Float;
    public static var inputs(get, never):InputFrontEnd;
    public static var keys(get, never):FlxKeyboard;
    // no log
    public static var maxElapsed(get, set):Float;
    public static var mouse = FlxG.mouse;
    // no plugins
    public static var random= FlxG.random;
    public static var renderBlit(get, never):Bool;
    public static var renderMethod(get, never):FlxRenderMethod;
    public static var renderTile(get, never):Bool;
    // no save because there are other ways to access it and i don't trust you guys
    public static var sound(default, null):HscriptSoundFrontEndWrapper;
    public static var stage(get, never):Stage;
    public static var state(get, never):FlxState;
    // no swipes because no mobile : )
    public static var timeScale(get, set):Float;
    // no touch because no mobile : )
    public static var updateFramerate(get,set):Int;
    // no vcr : )
    // no watch : )
    public static var width(get, never):Int;
    public static var worldBounds(get, never):FlxRect;
    public static var worldDivisions(get, set):Int;
    public static function init() {
        sound = new HscriptSoundFrontEndWrapper(FlxG.sound);
    }
    static function get_bitmap() {
        return FlxG.bitmap;
    }
    static function get_cameras() {
        return FlxG.cameras;
    }
    static function get_autoPause():Bool {
        return FlxG.autoPause;
    }
    static function set_autoPause(b:Bool):Bool {
        return FlxG.autoPause = b;
    }
	static function get_drawFramerate():Int
	{
		return FlxG.drawFramerate;
	}

	static function set_drawFramerate(b:Int):Int
	{
		return FlxG.drawFramerate = b;
	}
    static function get_elapsed():Float {
        return FlxG.elapsed;
    }
	static function get_fixedTimestep():Bool
	{
		return FlxG.fixedTimestep;
	}

	static function set_fixedTimestep(b:Bool):Bool
	{
		return FlxG.fixedTimestep = b;
	}
	static function get_fullscreen():Bool
	{
		return FlxG.fullscreen;
	}

	static function set_fullscreen(b:Bool):Bool
	{
		return FlxG.fullscreen = b;
	}
    static function get_height():Int {
        return FlxG.height;
    }
    static function get_initialHeight():Int {
        return FlxG.initialHeight;
    }
    static function get_camera():FlxCamera {
        return FlxG.camera;
    }
    static function set_camera(c:FlxCamera):FlxCamera {
        return FlxG.camera = c;
    }
    static function get_game():FlxGame {
        return FlxG.game;
    }
    static function get_gamepads():FlxGamepadManager {
        return FlxG.gamepads;
    }
    static function get_initialWidth():Int {
        return FlxG.initialWidth;
    }
    static function get_initialZoom():Float {
        return FlxG.initialZoom;
    }
    static function get_inputs() {
        return FlxG.inputs;
    }
    static function get_keys() {
        return FlxG.keys;
    }
    static function set_maxElapsed(s) {
        return FlxG.maxElapsed = s;
    }
    static function get_maxElapsed() {
        return FlxG.maxElapsed;
    }
    static function get_renderBlit() {
        return FlxG.renderBlit;
    }
    static function get_renderMethod() {
        return FlxG.renderMethod;
    }
    static function get_renderTile() {
        return FlxG.renderTile;
    }
    static function get_stage() {
        return FlxG.stage;
    }
    static function get_state() {
        return FlxG.state;
    }
    static function set_timeScale(s) {
        return FlxG.timeScale = s;
    }
    static function get_timeScale() {
        return FlxG.timeScale;
    }
    static function set_updateFramerate(s) {
        return FlxG.updateFramerate = s;
    }
    static function get_updateFramerate() {
        return FlxG.updateFramerate;
    }
    static function get_width() {
        return FlxG.width;
    }
    static function get_worldBounds() {
        return FlxG.worldBounds;
    }
    static function get_worldDivisions() {
        return FlxG.worldDivisions;
    }
	static function set_worldDivisions(s)
	{
		return FlxG.worldDivisions = s;
	}

    public static function addChildBelowMouse<T:DisplayObject>(Child:T, IndexModifier:Int = 0):T {
        return FlxG.addChildBelowMouse(Child, IndexModifier);
    }
    public static function addPostProcess(postProcess) {
        return FlxG.addPostProcess(postProcess);
    }
    public static function collide(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback) {
        return FlxG.collide(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback);
    }
    // no open url because i don't trust you guys

	public static function overlap(?ObjectOrGroup1, ?ObjectOrGroup2, ?NotifyCallback, ?ProcessCallback)
	{
		return FlxG.overlap(ObjectOrGroup1, ObjectOrGroup2, NotifyCallback, ProcessCallback);
	}
    public static function pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance = 255, ?Camera) {
        return FlxG.pixelPerfectOverlap(Sprite1, Sprite2, AlphaTolerance, Camera);
    }
    public static function removeChild<T:DisplayObject>(Child:T):T {
        return FlxG.removeChild(Child);
    }
    public static function removePostProcess(postProcess) {
        FlxG.removePostProcess(postProcess);
    }
    // no reset game or reset state because i don't trust you guys
    public static function resizeGame(Width, Height) {
        FlxG.resizeGame(Width, Height);
    }
    public static function resizeWindow(Width, Height) {
        FlxG.resizeWindow(Width, Height);
    }
    // no switch state because i don't trust you guys
}

class HscriptSoundFrontEndWrapper {

    var wrapping:SoundFrontEnd;
    public var defaultMusicGroup(get, set):FlxSoundGroup;
    public var defaultSoundGroup(get, set):FlxSoundGroup;
    public var list(get, never):FlxTypedGroup<FlxSound>;
    public var music (get, set):FlxSound;
    // no mute keys because why do you need that
    // no muted because i don't trust you guys
    // no soundtray enabled because i'm lazy 
    // no volume because i don't trust you guys
    function get_defaultMusicGroup() {
        return wrapping.defaultMusicGroup;
    }
    function set_defaultMusicGroup(a) {
        return wrapping.defaultMusicGroup = a;
    }
    function get_defaultSoundGroup() {
        return wrapping.defaultSoundGroup;
    }
    function set_defaultSoundGroup(a) {
        return wrapping.defaultSoundGroup = a;
    }
    function get_list() {
        return wrapping.list;
    }
    function get_music() {
        return wrapping.music;
    }
    function set_music(a) {
        return wrapping.music = a;
    }
    public function load(?EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = false, AutoPlay = false, ?URL, ?OnComplete) {
        if ((EmbeddedSound is String)) {
            var sound = FNFAssets.getSound(EmbeddedSound);
            return wrapping.load(sound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
        }
        return wrapping.load(EmbeddedSound, Volume, Looped, Group, AutoDestroy, AutoPlay, URL, OnComplete);
    }
    public function pause() {
        wrapping.pause();
    }
    public function play(EmbeddedSound:FlxSoundAsset, Volume = 1.0, Looped = false, ?Group, AutoDestroy = true, ?OnComplete) {
        if ((EmbeddedSound is String)) {
            var sound = FNFAssets.getSound(EmbeddedSound);
            return wrapping.play(sound, Volume, Looped, Group, AutoDestroy, OnComplete);
        }
        return wrapping.play(EmbeddedSound, Volume, Looped, Group, AutoDestroy, OnComplete);
    }

    public function playMusic(Music:FlxSoundAsset,Volume= 1.0, Looped = true, ?Group ) {
        if ((Music is String)) {
            var sound = FNFAssets.getSound(Music);
            wrapping.playMusic(sound, Volume, Looped, Group);
            return;
        }
        wrapping.playMusic(Music, Volume, Looped, Group);        

    }
    public function resume() {
        wrapping.resume();
    }
    public function new(wrap:SoundFrontEnd) {
        wrapping = wrap;
    }
}