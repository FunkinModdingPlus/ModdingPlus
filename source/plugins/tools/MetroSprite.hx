package plugins.tools;

import flixel.FlxSprite;
// utility sprite that handles dancing for you
class MetroSprite extends DynamicSprite {
    var danceDir:Bool = false;
    public var danceInPlace:Bool = false;
    /**
     * Create a MetroSprite
     * @param x X Position
     * @param y Y Position
     * @param danceInPlace If true, acts like bf, otherwise acts like gf. 
     */
    public function new (x:Float, y:Float, danceInPlace:Bool) {
        super(x, y);
        this.danceInPlace = danceInPlace;
    }
    /**
     * Handles playing animations automatically. You still have to call this every  beat!
     * @param beat The current beat. Unused. 
     */
    public function dance(beat:Int):Void {
        danceDir = !danceDir;
        if (danceInPlace) {
            animation.play("idle", true);
        } else if (danceDir) {
            animation.play("danceRight", true);
        } else {
            animation.play("danceLeft", true);
        }
    }
 }