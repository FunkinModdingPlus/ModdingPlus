package;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end
import flixel.FlxG;
enum abstract AccuracyMode(Int) from Int to Int {
    var None = -1;
    var Simple;
    var Complex;
    var Binary;
}
/**
 * Avaliable options. 
 * 
 */
typedef TOptions = {
    var skipVictoryScreen:Bool;
    var skipModifierMenu:Bool;
    var alwaysDoCutscenes:Bool;
    var useCustomInput:Bool;
    // var DJFKKeys:Bool;
    var allowEditOptions:Bool;
    var downscroll:Bool;
    var useSaveDataMenu:Bool;
    var preferredSave:Int;
    var showSongPos:Bool;
    var style:Bool;
    var stressTankmen:Bool;
    // var ignoreShittyTiming:Bool;
    var ignoreUnlocks:Bool;
    var judge:Int;
    var preferJudgement:Int;
    var newJudgementPos:Bool;
    var emuOsuLifts:Bool;
    var skipDebugScreen:Bool;
    var showComboBreaks:Bool;
    var useKadeHealth:Bool;
    var useMissStun:Bool;
    var offset:Float;
    var accuracyMode:AccuracyMode;
}
/**
 * OptionsHandler Handles options : )
 */
class OptionsHandler {
    /**
     *  The options. On desktop it's read from file then cached. 
     */
    public static var options(get, set):TOptions;
    // Preformance!
    // We only read the file once...
    // As all calls to options should go through options handler
    // we can just cache the last options read until the file gets edited. 
    static var lastOptions:TOptions;
    static var needToRefresh:Bool = true;
    static function get_options() {
        #if sys
        // update the file
        if (needToRefresh) {
			lastOptions = CoolUtil.parseJson(FNFAssets.getJson('assets/data/options'));
            // sawee
            // i think this is for the best, to be a real rhythm game
            needToRefresh = false;
			
        }
		return lastOptions;
        #else
        if (!Reflect.hasField(FlxG.save.data, "options"))
			FlxG.save.data.options = CoolUtil.parseJson(FNFAssets.getJson('assets/data/options'));
        return FlxG.save.data.options;
        #end
    }
    static function set_options(opt:TOptions) {
        #if sys
        needToRefresh = true;
        File.saveContent('assets/data/options.json', CoolUtil.stringifyJson(opt));
        #else
        FlxG.save.data.options = CoolUtil.stringifyJson(opt);
        #end
        return opt;
    }
}