package plugins;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxCamera;
import flixel.FlxSprite;
// a plugin that needs access to playstate variables, like bf and gf
@:keep
class PlayStatePlugin {
	public var showOnlyStrums:Bool = false;
	public var curStep:Int = 0;
	public var curBeat:Int = 0;
	public var gf:Character;
	public var boyfriend:Character;
	public var dad:Character;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var enemyStrums:FlxTypedGroup<FlxSprite>;
	public var camHUD:FlxCamera;
	public var mustHit:Bool = false;
	public var setDefaultZoom:Float->Void;
	public var hscriptPath:String = "";
    public function new() {}
	public function start(song)	{}
}