package;
import sys.FileSystem;
import sys.io.File;
import openfl.utils.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
using StringTools;
class FNFAssets {
    public static function stripLibrary(id:String):String {
        if (id.contains(':')) {
			var colonIndex = id.indexOf(":");
			return id.substring(colonIndex + 1);
        }
		return id;
    }
    public static function exists(id:String):Bool {
        var openFLBool:Bool = Assets.exists(id);
        if (!openFLBool) {
            var path = stripLibrary(id);
            return FileSystem.exists(path);
        }
        return openFLBool;
    }
    public static function getText(id:String):String {
        if (Assets.exists(id)) {
            return Assets.getText(id);
        }
        var path = stripLibrary(id);
        if (FileSystem.exists(path))
            return File.getContent(path);
        return null;
    }
    public static function saveText(id:String, content:String):Bool {
        var path = stripLibrary(id);
        if (FileSystem.exists(path)) { 
            File.saveContent(path, content);
            return true;
        }
        return false;
    }
    public static function getBitmapData(id:String):BitmapData {
        if (Assets.exists(id)) {
            return Assets.getBitmapData(id);
        }
        var path = stripLibrary(id);
        if (FileSystem.exists(path)) {
            return BitmapData.fromFile(path);
        }
        return null;
    }
    public static function getSound(id:String):Sound {
        if (Assets.exists(id)) {
            return Assets.getSound(id);
        }
        var path = stripLibrary(id);
        if (FileSystem.exists(path)) {
            return Sound.fromFile(path);
        }
        return null;
    }
    public static function saveBitmapData(id:String, content:BitmapData):Bool {
        // lol 
        var path = stripLibrary(id);
        if (FileSystem.exists(path)) {
            File.saveBytes(path, content.image.data.toBytes());
            return true;
        }
        return false;
    }
}