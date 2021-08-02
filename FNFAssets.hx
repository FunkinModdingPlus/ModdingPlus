package;

// NO NOT WEEK 7 THAT CAN FUCK OFF
// A helper class to make supporting web easier
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import haxe.io.Path;
import flixel.FlxG;
import flash.net.FileReference;
import flash.events.Event;
import openfl.events.IOErrorEvent;
import haxe.io.Bytes;
import openfl.utils.AssetType;
class FNFAssets {
    public static var _file:FileReference;
    /**
     * Get text content of a file. 
     * @param id Path to file.
     * @return String The file content. 
     */
    public static function getText(id:String):String {
        #if sys
            // if there a library strip it out..
            // future proofing ftw
			var path = Assets.exists(id) ? Assets.getPath(id) : null;
            if (path == null)
                path = id;
			else
				return Assets.getText(id);
			try {
			return File.getContent(path);
			} catch (e:Any) {
				throw 'File $path doesn\'t exist or cannot be read.';
			}
            
        #else
            // no need to strip it out... 
            // assets handles it
            return Assets.getText(id);
        #end
    }
	/**
	 * A safer way to get assets. Checks if the first asset exists and if not ALWAYS uses 2nd asset.
	 * This means backupID should be guarenteed to exist. 
	 * @param id The id wanting to be read
	 * @param backupID the id to read if wanted one does not exist
	 * @param type Type of the file 
	 * @return Dynamic The file, in the type requested.
	 */
	public static function getAssetWithBackup(id:String, backupID:String, type:AssetType):Dynamic {
		// backup id should always exist
		if (FNFAssets.exists(id)) {
			return FNFAssets.getAsset(id, type);
		}
		return FNFAssets.getAsset(backupID, type);
	} 
	/**
	 * Generic way to get assets
	 * @param id The path/id of the item.
	 * @param type The type of the object.
	 * @return Dynamic The file read in the type requested. 
	 */
	public static function getAsset(id:String, type:AssetType):Dynamic {
		switch (type) {
			case TEXT:
				return FNFAssets.getText(id);
			case BINARY:
				return FNFAssets.getBytes(id);
			case MUSIC | SOUND:
				return FNFAssets.getSound(id);
			case IMAGE:
				return FNFAssets.getBitmapData(id);
			default:
				throw "Unsure of how to get type " + type;
		}
	}
	public static function getBytes(id:String):Bytes
	{
		#if sys
		// if there a library strip it out..
		// future proofing ftw
			var path = Assets.exists(id) ? Assets.getPath(id) : null;
			if (path == null)
				path = id;
			else
				return Assets.getBytes(id);
			try {
			return File.getBytes(path);
			} catch (e:Any) {
			throw 'File $path doesn\'t exist or cannot be read.';
			}
			
		#else
		// no need to strip it out...
		// assets handles it
		return LimeAssets.getBytes(id);
		#end
	}
    /**
     * Check if the file exists.
     * @param id The file to check
     * @return Bool If file exists, true.
     */
    public static function exists(id:String):Bool {
        #if sys
            var path = Assets.exists(id) ? Assets.getPath(id) : null;
            if (path == null)
                path = id;
			else
				// if it _does_ exist then yeah of course  it works
				return true;
            return FileSystem.exists(path);
        #else
            return Assets.exists(id);
        #end
    }
    /**
     * Get bitmap data of a file.
     * @param id Path of file
     * @param useCache Whether to reuse assets if file was already requested. Only works on non-dynamically loaded assets.
     * @return BitmapData the data of the file.
     */
    public static function getBitmapData(id:String, ?useCache:Bool=true):BitmapData {
        #if sys
            // idk if this works lol
			var path = Assets.exists(id) ? Assets.getPath(id) : null;
            if (path == null)
                path = id;
			else return Assets.getBitmapData(id, useCache);
			try {
			return BitmapData.fromFile(path);
			} catch (e:Any) {
			throw 'File $path doesn\'t exist or cannot be read.';
			}
            
        #else
            return Assets.getBitmapData(id, useCache);
        #end
    }
    /**
     * Get sound from file.
     * @param id Path of file
     * @param useCache whether to reuse assets if file was already requested. Only works on non-dynamically loaded files.
	 * @return Sound The sound file.
     */
    public static function getSound(id:String, ?useCache:Bool=true):Sound {
        #if sys
			var path = Assets.exists(id) ? Assets.getPath(id) : null;
            if (path == null)
                path = id;
			else
				// prefer using assets as it uses a cache??
				return Assets.getSound(id, useCache);
		try
		{
			return Sound.fromFile(path);
		}
		catch (e:Any)
		{
			throw 'File $path doesn\'t exist or cannot be read.';
		}
        #else
            return Assets.getSound(id, useCache);
        #end
    }
    /**
     * Save content to a file. 
     * @param id File to save to. 
     * @param data Data to save.
     */
    public static function saveContent(id:String, data:String):Void {
        #if sys
			try {
				File.saveContent(id, data);
			}	catch(e:Any) {
				throw "Couldn't save to "+ id +". Is it in use?";
			}
           
        #else
            askToSave(id, data);
        #end
    }
	/**
	 * Save bytes to a file.
	 * @param id File to save to 
	 * @param data Bytes to save. 
	 */
	public static function saveBytes(id:String, data:Bytes)
	{
		#if sys
		try
		{
			File.saveBytes(id, data);
		}
		catch (e:Any)
		{
			throw "Couldn't save to " + id + ". Is it in use?";
		}
		#else
		askToSave(id, data);
		#end
	}
	/**
	 * Ask the user to pick a path to save to. Used on web when other save functions are called.
	 * @param id Path to save to.
	 * @param data Data. Can be anything. 
	 */
	public static function askToSave(id:String, data:Dynamic)
	{
		_file = new FileReference();

		_file.addEventListener(Event.COMPLETE, onSaveComplete);
		_file.addEventListener(Event.CANCEL, onSaveCancel);
		_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		var idSus = Path.withoutDirectory(id);
		_file.save(data, idSus);
	}
	static function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	};
	static function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	};
	static function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}

/**
 * This is what is passed to hscript. This only supports checking files for existance
 * and loading files, no writing. : ) 
 */
class HScriptAssets {
	public static function getText(id:String):String {
		return FNFAssets.getText(id);
	}
	public static function getBytes(id:String):Bytes {
		return FNFAssets.getBytes(id);
	}
	public static function exists(id:String):Bool {
		return FNFAssets.exists(id);
	}
	public static function getBitmapData(id:String):BitmapData {
		return FNFAssets.getBitmapData(id);
	}
	public static function getSound(id:String):Sound {
		return FNFAssets.getSound(id);
	}
}