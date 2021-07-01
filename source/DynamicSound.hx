import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
/**
 * FlxSound that automatically handles loading sound dynamically. 
 */
class DynamicSound extends FlxSound {
    override public function loadEmbedded(EmbeddedSound:FlxSoundAsset, Looped:Bool = false, AutoDestroy:Bool = false, ?OnComplete:() -> Void):FlxSound {
        if ((EmbeddedSound is String)) {
            var goodSound = FNFAssets.getSound(EmbeddedSound);
            return super.loadEmbedded(goodSound, Looped, AutoDestroy, OnComplete);
        }
        return super.loadEmbedded(EmbeddedSound, Looped, AutoDestroy, OnComplete);
    }
}