package plugins;

import flixel.animation.FlxAnimationController;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.math.FlxPoint;
import flixel.FlxSprite;
// a sprite than is a composition sprite, 
// meaning instead of extending it includes a sprite
class FNFSprite {
    var sprite:FlxSprite;
    var x(get, set):Float;
    var y(get, set):Float;
    var visible(get, set):Bool;
    var flipX(get, set):Bool;
    var scrollFactor(get, never):FlxPoint;
    var antialiasing(get, set):Bool;
    var frames(get, set):FlxFramesCollection;
    var animation(get, never):FlxAnimationController;
    public function new (x:Float, y:Float) {
        sprite = new FlxSprite(x, y);
    }
    function set_x(val:Float):Float {
        return sprite.x = val;
    }
    function get_x():Float {
        return sprite.x;
    }
    function set_y(val:Float):Float {
        return sprite.y = val;
    }
    function get_y():Float {
        return sprite.y;
    }
    function get_visible():Bool {
        return sprite.visible;
    }
    function set_visible(val:Bool):Bool {
        return sprite.visible = val;
    }
    function get_flipX():Bool {
        return sprite.flipX;
    }
    function set_flipX(val:Bool):Bool {
        return sprite.flipX = val;
    }
    function get_scrollFactor():FlxPoint {
        return sprite.scrollFactor;
    }
    public function setGraphicSize(val:Int) {
        sprite.setGraphicSize(val);
    }
    public function updateHitbox() {
        sprite.updateHitbox();
    }
    function get_antialiasing():Bool {
        return sprite.antialiasing;
    }
    function set_antialiasing(val:Bool):Bool {
        return sprite.antialiasing = val;
    }
    function set_frames(val:FlxFramesCollection):FlxFramesCollection {
        return sprite.frames = val;
    }
    function get_frames():FlxFramesCollection {
        return sprite.frames;
    }
    function get_animation() {
        return sprite.animation;
    }
}