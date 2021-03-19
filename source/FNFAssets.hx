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
        try {
			if (!OpenFLAssets.exists(id, type))
			{
				return FileSystem.exists(id);
			}
			return OpenFLAssets.exists(id, type);
        } catch (error:Dynamic) 
            return FileSystem.exists(id);
        
    }
    public static function getBitmapData(id:String, useCache:Bool = true):Null<BitmapData> {
        var coolFlReturn = OpenFLAssets.getBitmapData(id, useCache);
        if (coolFlReturn == null)
        {
            if (FileSystem.exists(id))
            {
                return BitmapData.fromFile(id);
            }
        }
        return coolFlReturn;
    }
    public static function getFont(id:String, useCache:Bool = true):Null<Font> {
        var coolReturnFl = OpenFLAssets.getFont(id, useCache);
        if (coolReturnFl == null)
        {
            if (FileSystem.exists(id))
            {
                return Font.fromFile(id);
            }
        }
        return coolReturnFl;
        
        
    }
    public static function getContent(id:String):String {
        return getText(id);
    }
    public static function createDirectory(path:String):Void {
        FileSystem.createDirectory(path);
    }
    public static function copy(id1:String, id2:String) {
        File.copy(id1, id2);
    }
    public static function getBytes(id:String) {
        return File.getBytes(id);
    }
    public static function saveBytes(id:String, content:Dynamic) {
        File.saveBytes(id, content);
    }
    public static function getText(id:String):String {
        var coolFlReturn = OpenFLAssets.getText(id);
        if (coolFlReturn == null && FileSystem.exists(id)) {
            return File.getContent(id);
        }
        return coolFlReturn;
    }
    public static function getSound(id:String, useCache:Bool = true):Sound {
        trace('???');
        var coolReturn = OpenFLAssets.getSound(id);
        trace('uh');
        if (coolReturn == null && FileSystem.exists(id)) {
            Sound.fromFile(id);
        }
        return coolReturn;
    }
    /// A safe way of saving text. 
    public static function saveText(id:String, content:String):Void {
		var coolPath = id;
        if (FileSystem.exists(coolPath)) {
            File.saveContent(coolPath, content);
        }
    }
}