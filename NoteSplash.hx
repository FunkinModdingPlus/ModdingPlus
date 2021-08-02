package;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxG;
import Judgement.TUI;
class NoteSplash extends FlxSprite {
    public function new(xPos:Float,yPos:Float,?c:Int) {
        if (c == null) c = 0;
        super(xPos,yPos);
		var curUiType:TUI = Reflect.field(Judgement.uiJson, PlayState.SONG.uiType);
		frames = FlxAtlasFrames.fromSparrow('assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.png',
			'assets/images/custom_ui/ui_packs/${curUiType.uses}/noteSplashes.xml');
        animation.addByPrefix("note1-0", "note impact 1  blue", 24, false);
		animation.addByPrefix("note2-0", "note impact 1 green", 24, false);
		animation.addByPrefix("note0-0", "note impact 1 purple", 24, false);
		animation.addByPrefix("note3-0", "note impact 1 red", 24, false);

		animation.addByPrefix("note1-1", "note impact 2 blue", 24, false);
		animation.addByPrefix("note2-1", "note impact 2 green", 24, false);
		animation.addByPrefix("note0-1", "note impact 2 purple", 24, false);
		animation.addByPrefix("note3-1", "note impact 2 red", 24, false);
        setupNoteSplash(xPos,xPos,c);
    }
    public function setupNoteSplash(xPos:Float, yPos:Float, ?c:Int) {
        if (c == null) c = 0;
        setPosition(xPos, yPos);
        alpha = 0.6;
        animation.play("note"+c+"-"+FlxG.random.int(0,1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
        updateHitbox();
        offset.set(0.3 * width, 0.3 * height);
    }
    override public function update(elapsed) {
        if (animation.curAnim.finished) {
            // club pengiun is
            kill();
        }
        super.update(elapsed);
    }
}