import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;
// lol
// doesn't actually load anything except fixing menus
class LoadingState extends FlxState {
    public static function loadAndSwitchState(target:FlxState, ?allowDjkf:Bool) {

		PlayerSettings.player1.controls.setKeyboardScheme(Solo(false));
        if ((target is ChartingState) && !OptionsHandler.options.skipDebugScreen) {
            FlxG.switchState(new LoadingState());
        } else {
			FlxG.switchState(target);
        }
        
    }
    override function create() {
		var titletext = new FlxText(0, 20, 0, "Yo!", 64);
		titletext.screenCenter(X);
		var paragraph = new FlxText(0, 120, FlxG.width / 1.5,
			'charting is a bit broken rn im workin on it, basicly im aiming for fnf vortex but not ass in the game debug menu\npress enter to continue',
			32);
        add(titletext);
        paragraph.screenCenter(X);
        add(paragraph);
    }
    override function update(elapsed:Float) {
        if (FlxG.keys.justPressed.SPACE) {
            FlxG.switchState(new ChartingState());
        }
    }
}