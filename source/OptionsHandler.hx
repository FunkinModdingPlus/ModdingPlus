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
    var showComboBreaks:Bool;
    var useKadeHealth:Bool;
    var useMissStun:Bool;
    var offset:Float;
    var accuracyMode:AccuracyMode;
    var danceMode:Bool;
    var dontMuteMiss:Bool;
    //var moddingOptions:Bool;
    //var funnyOptions:Bool;
    var allowStoryMode:Bool;
    var allowFreeplay:Bool;
    var allowDonate:Bool;
    var hitSounds:Bool;
    var fpsCap:Int;
    var ignoreVile:Bool;
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
            needToRefresh = false;
			
        }
        // these are the canon options
        // if your options aren't these it isn't canon
        if (lastOptions.danceMode) {
            lastOptions.skipVictoryScreen = false;
			lastOptions.skipModifierMenu = true; // i'm going to use a special thing to do it
			lastOptions.alwaysDoCutscenes = false;
			lastOptions.useCustomInput = true;
            lastOptions.allowEditOptions = false;
            lastOptions.useSaveDataMenu = false;
            // lastOptions.downscroll // we are going to add this to a special new menu
            lastOptions.preferredSave = 0;
            lastOptions.style = true;
            lastOptions.stressTankmen = false; // sorry guys no funny songs  : (
            lastOptions.ignoreUnlocks = true; // If we are in an arcade a person won't have enough time to unlock everything
            // lastOptions.preferJudgement // going to the new menu
            // lastOptions.judge // new menu
			lastOptions.newJudgementPos = true;
			lastOptions.emuOsuLifts = false;
            // lastOptions.skipDebugScreen // i'm removing debug entirely in dance mode
            // lastOptions.showComboBreaks // i'm going to add this to the special new menu
            lastOptions.useKadeHealth = false;
            // lastOptions.offset // i'll remove it from options, but json can still be edited. perfect those things!
            lastOptions.useMissStun = false;
			lastOptions.accuracyMode = Simple;
            lastOptions.dontMuteMiss = true;
            //lastOptions.moddingOptions = true;
            //lastOptions.funnyOptions = true;
            lastOptions.allowStoryMode = true;
            lastOptions.allowFreeplay = true;
            lastOptions.allowDonate = false;
            lastOptions.hitSounds = false;
            lastOptions.fpsCap = 60;

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