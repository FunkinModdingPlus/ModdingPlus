package plugins;

import Character.EpicLevel;
import lime.ui.Window;
import flixel.system.FlxSound;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import Song.SwagSong;
import PlayState.DisplayLayer;

/**
 * documentation for hscripts : )
 * Note that functions marked as "Dynamic" mean _you_ should define them
 */
 @:keep
@:publicFields
class ExamplePlugin {
    /**
     * Component of layer, behind GF. Can be binary OR'd `|` with other layers to combine them
     */
    public final BEHIND_GF:Int = DisplayLayer.BEHIND_GF;
	/**
	 * Component of layer, behind BF. Can be binary OR'd `|` with other layers to combine them
	 */
    public final BEHIND_BF:Int = DisplayLayer.BEHIND_BF;
	/**
	 * Component of layer, behind Enemy. Can be binary OR'd `|` with other layers to combine them
	 */
    public final BEHIND_DAD:Int = DisplayLayer.BEHIND_DAD;
	/**
	 * Component of layer, behind ALl. Can be binary OR'd `|` with other layers to combine them
	 */
    public final BEHIND_ALL:Int = DisplayLayer.BEHIND_ALL;
	/**
	 * Component of layer, behind None. Can be binary OR'd `|` with other layers to combine them
	 */
    public final BEHIND_NONE:Int = 0;
    /**
     * A number representing the difficulty. Not very useful, don't use
     */
    public var difficulty:Int;
    /**
     * Bpm of current song. 
     */
     @:deprecated('Use Conductor.bpm instead')
    public var bpm:Float;
    /**
     * Data of song. See swag song.
     */
    public var songData:SwagSong;
    /**
     * Name of current song.
     */
    public var curSong:String;
    /**
     * Cur beat
     */
    public var curBeat:Int;
    /**
     * Current step which is 1/4 of a beat
     */
    public var curStep:Int;
    /**
     * Camera used for UI elements
     */
    public var camHUD:FlxCamera;
    /**
     * Whether to only display notes and note strums.
     */
    public var showOnlyStrums:Bool;
    /**
     * Right side strums
     */
    public var playerStrums:FlxTypedGroup<FlxSprite>;
    /**
     * Left side strums
     */
    public var enemyStrums:FlxTypedGroup<FlxSprite>; 
    /**
     * Whether current note must be hit
     */
    public var mustHit:Bool;
    /**
     * Y Position of strumline
     */
    public var strumLineY:Int;
    /**
     * Path to directory that uasually contains files relating to your
     * hscript
     */
    public var hscriptPath:String;
    /**
     * Player 1 character
     */
    public var boyfriend:Character;
    /**
     * Gf Character
     */
    public var gf:Character;
    /**
     * player 2 character
     */
    public var dad:Character;
    /**
     * sound of vocals
     */
    public var vocals:FlxSound;
    /**
     * How fast gf goes. Higher numbers are slower.
     */
    public var gfSpeed:Float;
    /**
     * Tween the cam in
     */
    public function tweenCamIn():Void {}
    /**
     * True if in cutscene. Stops a lot of processes.
     */
    public var isInCutscene:Bool;
    /**
     * If cam is zooming in. 
     */
    public var camZooming:Bool;
    /**
     * Add a sprite
     * @param sprite the sprite
     * @param layer the layer, which is combos of the BEHIND things
     */
    public function addSprite(sprite:FlxSprite, layer:Int):Void {}
    /**
     * Set default zoom which is what is used by camZooming
     * @param zoom 
     */
    public function setDefaultZoom(zoom:Float):Void {}
    /**
     * Remove sprite
     * @param sprite Sprite to remove
     */
    public function removeSprite(sprite:FlxSprite):Void {}
    /**
     * Get an actor
     * @param name Name of actor. 
     * @return Dynamic The actor
     */
    public function getHaxeActor(name:String):Dynamic {throw 'sussy baka';}
    /**
     * current health
     */
    public var health:Float;
    /**
     * P1's Icon
     */
    public var iconP1:HealthIcon;
    /**
     * P2's Icon
     */
    public var iconP2:HealthIcon;
    /**
     * The current playstate
     */
    public var currentPlayState:PlayState;
    /**
     * The window. Can be moved around. Probably breaks on web : (
     */
    public var window:Window;
    public function scaleChar(char:String,amount:Float):Void {}
    /**
     * Swaps char out for char to. Handles creating it for you. 
     * @param char 
     * @param charTo 
     */
    public function swapChar(char:String, charTo:String):Void {}
    /**
     * Called at the start of the song.
     * @param song Name of the song
     */
    dynamic public function start(song:String):Void {}
    /**
     * Called when a beat is hit
     * @param beat Current Beat
     */
    dynamic public function beatHit(beat:Int):Void {}
    /**
     * Called every frame
     * @param elapsed Time since last frame, used for correcting animation. Multiplying a number by this will make the thing "per second".
     */
    dynamic public function update(elapsed:Float):Void {}
    /**
     * Called when a step is hit, which is 1/4 of a beat. 
     * @param step Current Step
     */
    dynamic public function stepHit(step:Int):Void {}
    /**
     * Called when the section switches to player 2. 
     */
    dynamic public function playerTwoTurn():Void {}
    /**
     * Called when player 2 misses a note. 
     */
    dynamic public function playerTwoMiss():Void {}
    /**
     * Called when player 2 hits a note. 
     */
    dynamic public function playerTwoSing():Void {}
    /**
     * Called when the section switches to player 1.
     */
    dynamic public function playerOneTurn():Void {}
    /**
     * Called when player 1 misses a note.
     */
    dynamic public function playerOneMiss():Void {}
    /**
     * Called when player 1 hits a note
     */
    dynamic public function playerOneSing():Void {}
    /**
     * Called when a note is hit
     * @param player1 Whether player 1 hit the note
     * @param note the note
     * @param goodHit whether the note was hit well
     */
    dynamic public function noteHit(player1:Bool, note:Null<Note>, goodHit:Bool):Void {}
}  
@:keep
class ExampleCharPlugin {
    public final Level_NotAHoe:EpicLevel = EpicLevel.Level_NotAHoe;
    public final Level_Boogie:EpicLevel = EpicLevel.Level_Boogie;
    public final Level_Sadness:EpicLevel = EpicLevel.Level_Sadness;
    public final Level_Sing:EpicLevel = EpicLevel.Level_Sing;
    public var portraitOffset:Array<Float>;
    /**
     * How long notes are held
     */
    public var dadVar:Float;
    /**
     * I forgor :skull:
     */
    public var isPixel:Bool;


    dynamic public function init(char:Character):Void {}
    dynamic public function update(elapsed:Float, char:Character):Void {}
    dynamic public function dance(char:Character):Void {}
}