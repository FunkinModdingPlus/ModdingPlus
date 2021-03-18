package;
import sys.FileSystem;
import sys.io.File;
import openfl.utils.AssetType;
import openfl.text.Font;
import openfl.media.Sound;
import flash.display.BitmapData;
import openfl.utils.Assets as OpenFLAssets;
class FNFAssets {
    public static function exists(id:String, ?type:AssetType):Bool {
        // if it doesn't exist try using the file system
        if (!OpenFLAssets.exists(id, type)) {
            return FileSystem.exists(id);
        }
        return OpenFLAssets.exists(id, type);
    }
    public static function getBitmapData(id:String, useCache:Bool = true):BitmapData {
        var coolFlReturn = OpenFLAssets.getBitmapData(id, useCache);
        if (coolFlReturn == null) {
            if (FileSystem.exists(id)) {
                return BitmapData.fromFile(id);
            }
        }
        return coolFlReturn;
    }
    public static function getFont(id:String, useCache:Bool = true):Font {
        var coolReturnFl = OpenFLAssets.getFont(id, useCache);
        if (coolReturnFl == null) {
            if (FileSystem.exists(id)) {
                return Font.fromFile(id);
            }
        }
        return coolReturnFl;
    }
    public static function getText(id:String) {
        var coolFlReturn = OpenFLAssets.getText(id);
        if (coolFlReturn == null && FileSystem.exists(id)) {
            return File.getContent(id);
        }
        return coolFlReturn;
    }
    public static function getSound(id:String, useCache:Bool = true):Sound {
        var coolReturn = OpenFLAssets.getSound(id);
        if (coolReturn == null && FileSystem.exists(id)) {
            Sound.fromFile(id);
        }
        return coolReturn;
    }
    /// A safe way of saving text. 
    public static function saveText(id:String, content:String):Void {
        if (FileSystem.exists(id)) {
            File.saveContent(id, content);
        }
    }
}