import flixel.FlxState;
import flixel.FlxG;
// lol
// doesn't actually load anything except fixing menus
class LoadingState {
    public static function loadAndSwitchState(target:FlxState, ?allowDjkf:Bool) {

		PlayerSettings.player1.controls.setKeyboardScheme(Solo(false));
        FlxG.switchState(target);
    }
}