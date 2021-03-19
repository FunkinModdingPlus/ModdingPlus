package;
import lime.utils.Assets;
typedef TOptions = {
    var skipVictoryScreen:Bool;
    var skipModifierMenu:Bool;
    var alwaysDoCutscenes:Bool;
    var allowEditOptions:Bool;
    var useSaveDataMenu:Bool;
    var preferredSave:Int;
}
class OptionsHandler {
    public static var options(get, set):TOptions;
    static function get_options() {
        // update the file
        return CoolUtil.parseJson(Assets.getText(Paths.json('options', 'preload')));
    }
    static function set_options(opt:TOptions) {
		FNFAssets.saveText(Paths.json('options', 'preload'), CoolUtil.stringifyJson(opt));
        return opt;
    }
}