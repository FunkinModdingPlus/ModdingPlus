package;


import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxSprite;

class Tooltip extends FlxTypedSpriteGroup<FlxSprite> {
    var keycap:FnkButton;
    var text:FlxText;
    public function new(x:Float, y:Float, button:String, desc:String, ?platform:Platform=Keyboard, getFromControls:Bool=false) {
        super(x, y);
        keycap = new FnkButton(0, 0, platform, button, getFromControls);
        add(keycap);
        text = new FlxText(keycap.width + 10, 0, 0, desc, 20);
        add(text);
    }

}
enum Platform {
    PlayStation;
    Xbox;
    Keyboard;
    Switch;
}
class FnkButton extends FlxTypedSpriteGroup<FlxSprite> {
    var buttonImage:FlxSprite;
    public var text:FlxText;
    public function new(x:Float, y:Float, platform:Platform, button:String, getFromControls:Bool) {
        super(x, y); 
        buttonImage = new FlxSprite();
        var useText = button;
        if (getFromControls) {
            if (PlayerSettings.player1.controls.gamepadsAdded.length != 0) {
                var inputs = PlayerSettings.player1.controls.getInputsFor(Controls.controlsFromStringMap.get(button), Gamepad(0));
                useText = FlxGamepadInputID.toStringMap.get(inputs[0]);
            
                platform = Xbox;
            } else {
				var inputs = PlayerSettings.player1.controls.getInputsFor(Controls.controlsFromStringMap.get(button), Keys);
                
                useText = FlxKey.toStringMap.get(inputs[0]);
                trace(useText);
                platform = Keyboard;
            }
        }
		switch (platform)
		{
			case Keyboard:
				buttonImage.loadGraphic('assets/images/keycap.png');
			default:
				// waiting for assets
				buttonImage.loadGraphic('assets/images/keycap.png');
		}
		buttonImage.setGraphicSize(50);
		buttonImage.updateHitbox();

		text = new FlxText(17, 7, 0, useText, 20);
		text.setFormat(null, 16, FlxColor.WHITE, null, OUTLINE, FlxColor.BLACK);
		if (text.width > (buttonImage.width / 1.5))
		{
			buttonImage.setGraphicSize(Std.int(text.width + text.x * 3), 50);
			buttonImage.updateHitbox();
		}
		text.borderSize = 2;
		add(buttonImage);
        add(text);
    }
} 