import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;
// lol
// doesn't actually load anything except fixing menus
class LoadingState extends FlxState {
    public static function loadAndSwitchState(target:FlxState, ?allowDjkf:Bool) {

		PlayerSettings.player1.controls.setKeyboardScheme(Solo(false));
        if ((target is ChartingState)) {
            FlxG.switchState(new LoadingState());
        } else {
			FlxG.switchState(target);
        }
        
    }
    override function create() {
        FlxG.switchState(new ChartingState());
    }
}