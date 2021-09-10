package;

import flixel.addons.api.FlxGameJolt;
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
#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import sys.FileSystem;
import flash.media.Sound;

#end
import lime.ui.FileDialog;
import lime.app.Event;
import haxe.Json;
import tjson.TJSON;
import openfl.net.FileReference;
import openfl.utils.ByteArray;
import lime.ui.FileDialogType;
using StringTools;

class GameJoltState
{
    var loginButton = new FlxButton(100, -30, "login", function()
    {
            gUser = gjUser.text;
            gToken = gjToken.text;
            FlxGameJolt.authUser(gUser, gToken, callbackWorked());
    });
    var gjUser = new FlxUIInputText(100,50,70,"username");
    var gjToken = new FlxUIInputText(100,10,70,"token");
    public var gUser:String;
    public var gToken:String;
    public var curAcc:FlxText = new FlxText(5, FlxG.height - 16, 0, "Logged in as" + GameJoltState.gUser, 12);
	curAcc.scrollFactor.set();
	curAcc.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
	add(curAcc);
    add(gjUser);
    add(gjToken);
    add(loginButton);
    function callbackWorked()
    {
        LoadingState.loadAndSwitchState(new SaveDataState());
    }
    if (Controls.BACK){
        LoadingState.loadAndSwitchState(new SaveDataState());
    }
}