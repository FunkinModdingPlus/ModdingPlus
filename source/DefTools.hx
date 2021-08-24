package;

import openfl.display.BitmapData;
import flixel.FlxSprite;
import lime.utils.Assets;
import lime.system.System;
import tjson.TJSON;
using StringTools;


class DefTools {
    // init varibles
    static var discord = CoolUtil.parseJson(FNFAssets.getJson("assets/discord/presence/discord"));
    // do functions 
    public static function getDiscord(get) {
        return(discord.get);
    }
}