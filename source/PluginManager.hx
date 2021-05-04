package;

import hscript.InterpEx;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
class PluginManager {
    public var interp:InterpEx;

    public function new() {
        var filelist = CoolUtil.coolTextFile("assets/scripts/plugin_classes/classes.txt");
        interp = new InterpEx();
        // process the basic classes first...
        for (file in filelist) {
			interp.addModule(FNFAssets.getText("assets/scripts/plugin_classes/" + file + ".hscript"));
        }
        var stageList = CoolUtil.coolTextFile("assets/scripts/custom_stages/classes.txt");
        // then process stages...
        for (file in stageList) {
            interp.addModule(FNFAssets.getText("assets/scripts/custom_stages/"+file+".hscript"));
        }
    }

    public function initStage(like:String, path:String, gf:Character, dad:Character, boyfriend:Character, p1Strums:FlxTypedGroup<FlxSprite>, p2Strums:FlxTypedGroup<FlxSprite>, hud:FlxCamera, setDefaultZoom:Float->Void) {
        var name = CoolUtil.capitilize(like);
        var stage = interp.createScriptClassInstance(name, []);
        stage.gf = gf;
        stage.dad = dad;
        stage.boyfriend = boyfriend;
        stage.playerStrums = p1Strums;
        stage.enemyStrums = p2Strums;
        stage.camHUD = hud;
        stage.hscriptPath = path;
        stage.setDefaultZoom = setDefaultZoom;
        stage.start(PlayState.SONG.song);
        return stage;
    }
}