package plugins;


import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.FlxSprite;
import flixel.FlxCamera;
// A plugin helper
@:keep
class CustomStage extends plugins.PlayStatePlugin {
    public var foregroundGroup:FlxTypedGroup<FlxBasic>;
    public var middleGroup:FlxTypedGroup<FlxBasic>;
    public var backgroundGroup:FlxTypedGroup<FlxBasic>;
    public function new () {
        super();
       foregroundGroup = new FlxTypedGroup<FlxBasic>();
       backgroundGroup = new FlxTypedGroup<FlxBasic>();
       middleGroup = new FlxTypedGroup<FlxBasic>();
    }
    override public function start(song) {
        super.start(song);
    }
    public function beatHit(beat) {}
    public function stepHit(step) {}
    public function playerTwoTurn() {}
    public function playerTwoMiss() {}
    public function playerTwoSing() {}
    public function playerOneTurn() {}
    public function playerOneMiss() {}
    public function playerOneSing() {}

}