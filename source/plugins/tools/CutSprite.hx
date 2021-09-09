package plugins.tools;

import flixel.FlxSprite;
// utility sprite that handles dancing for you
class CutSprite extends DynamicSprite {
    /**
     * Create a CutSprite
     * @param x X Position
     * @param y Y Position
     * @param location The Location of the Shit
     * @param animName The Animation Name of the Shit
     */
    public function new (x:Float, y:Float, location:String, animName:String){
        super(x, y);
        var theShit = new FlxSprite(x, y);
        var thePng = FNFAssets.getBitmapData(location + '.png');
        var theXml = FNFAssets.getText(location + '.xml');

        theShit.frames = FlxAtlasFrames.fromSparrow(thePng, theXml);
        theShit.animation.addByPrefix('cut', animName, 24, false);
    }
    public function play():Void {
        theShit.animation.play('cut');
        if (theShit.animation.finished){
            theShit.remove();
        }
    }
 }