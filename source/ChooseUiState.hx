package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import DifficultyIcons;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.addons.ui.FlxUITabMenu;
import lime.system.System;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
import flixel.UI;
using StringTools;


class ChooseUiState extends MusicBeatState
{
    public static var uis:Array<String>;
    var ui:UI;
    var grpAlphabet:FlxTypedGroup<Alphabet>;

    var curSelected:Int = 0;
    var curUi:String = PlayState.SONG.uiType;

    override function create()
    {
        var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
        menuBG.color = 0xFFea71fd;
        grpAlphabet = new FlxTypedGroup<Alphabet>();
        menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
        menuBG.updateHitbox();
        menuBG.screenCenter();
        menuBG.antialiasing = true;
        add(menuBG);

        var uiJson:Dynamic = null;

        uiJson = CoolUtil.parseJson(FNFAssets.getJson('assets/images/custom_ui/ui_packs/ui'));

        if (uis == null) {
            // that is not how arrays work
            // uis = mergeArray(Reflect.fields(uiJson), Reflect.fields(regUis)); // this doesn't work, try to make this work or just ignore it
            // reg uis should be first
            uis = Reflect.fields(uiJson);
        }


        for(ui in 0...uis.length){ //add uis
            var awesomeUi = new Alphabet(0, 10, "   "+uis[ui], true, false, false);
            awesomeUi.isMenuItem = true;
            awesomeUi.targetY = ui;
            grpAlphabet.add(awesomeUi);
        }

        add(grpAlphabet);
        trace("it's 11 pm"); //it's 12 pm

        super.create();

    }
    // i'd recommend moving smth like this to coolutil but w/e
    function mergeArray(base:Dynamic, ext:Dynamic){ //need this to combine regular UIs and customs, CHANGE THIS if you know a better way
        var res = Reflect.copy(base);
        for(f in Reflect.fields(ext)) Reflect.setField(res,f,Reflect.field(res,f));
        return res;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (controls.BACK) {
			LoadingState.loadAndSwitchState(new ModifierState());
        }
        if (controls.UP_MENU)
        {
            changeSelection(-1);
        }
        if (controls.DOWN_MENU)
        {
            changeSelection(1);
        }

        if (controls.ACCEPT)
            chooseSelection();
    }

    function changeSelection(change:Int = 0)
    {

        FlxG.sound.play('assets/sounds/scrollMenu' + TitleState.soundExt, 0.4);

        curSelected += change;
        curUi = ui[curSelected].toString();

        if (curSelected < 0)
            curSelected = ui.length - 1;
        if (curSelected >= ui.length)
            curSelected = 0;


        var bullShit:Int = 0;

        for (item in grpAlphabet.members)
        {
            item.targetY = bullShit - curSelected;
            bullShit++;

            item.alpha = 0.6;
            // item.setGraphicSize(Std.int(item.width * 0.8));

            if (item.targetY == 0)
            {
                item.alpha = 1;
                // item.setGraphicSize(Std.int(item.width));
            }
        }
    }

    function chooseSelection()
    {
        PlayState.SONG.uiType = curUi;
        trace("UI is now " + curUi);
        if (curUi == null)
            curUi = "normal";
    }
    // well yeah it lags you are creating a new ui
}