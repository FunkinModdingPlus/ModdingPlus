package;

import flixel.input.gamepad.mappings.XInputMapping;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
class ControlsState extends MusicBeatState {
    var askToBind:FlxTypedSpriteGroup<FlxSprite>;
    var bindTxt:FlxText;
    var askingToBind:Bool = false;
    var grpBind:FlxTypedGroup<Alphabet>;
    var awaitingFor:Int = -1;
    var curSelected:Int = 0;
    override function create() {
        
        FlxG.mouse.visible = true;
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/menuBG.png');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.18;
		bg.setGraphicSize(Std.int(bg.width * 1.2));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg); 
        askToBind = new FlxTypedSpriteGroup<FlxSprite>();
        var askGraphic = new FlxSprite().makeGraphic(Std.int(FlxG.width/2),Std.int(FlxG.height/2), FlxColor.YELLOW);
        bindTxt = new FlxText(60, 20, 0, "Waiting for input");
        bindTxt.setFormat(null, 24, FlxColor.BLACK);
        askToBind.add(askGraphic);
        askToBind.add(bindTxt);
        askToBind.visible = false;
        askToBind.x = 500;
        askToBind.y = 80;
        grpBind = new FlxTypedGroup<Alphabet>();
        add(grpBind);

        for (i in 0...4) {
            var coolText = switch (i) {
                case 0:
                    'Left: ${cast (FlxG.save.data.keys.left : String)}';
                case 1: 
				'Down: ${cast (FlxG.save.data.keys.down : String)}';
                case 2:
				'Up: ${cast (FlxG.save.data.keys.up : String)}';
                case 3:
				'Right: ${cast (FlxG.save.data.keys.right : String)}';
                default:
                    'how did we get here';
            }
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, coolText, true, false, false, null, null, null, true);
			songText.itemType = "Classic";
			songText.isMenuItem = true;
			songText.targetY = i;
			grpBind.add(songText);
        }
        add(askToBind);
        super.create();
    }
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play('assets/sounds/custom_menu_sounds/'
			+ CoolUtil.parseJson(FNFAssets.getText("assets/sounds/custom_menu_sounds/custom_menu_sounds.json")).customMenuScroll
			+ '/scrollMenu'
			+ TitleState.soundExt,
			0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = 3;
		if (curSelected >= 4)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		// comment out because lag?
		// if (!soundTest)
		//	FlxG.sound.playMusic(FNFAssets.getSound("assets/music/"+songs[curSelected].songName+"_Inst"+TitleState.soundExt), 0);
		var bullShit:Int = 0;

		for (item in grpBind.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
		/*
			var dealphaedColors:Array<FlxColor> = [];
			for (color in (Reflect.field(charJson,songs[curSelected].songCharacter).colors : Array<String>)) {
				var newColor = FlxColor.fromString(color);
				newColor.alphaFloat = 0.5;
				dealphaedColors.push(newColor);
		}*/
		// remove(curOverlay);
		// curOverlay = FlxGradient.createGradientFlxSprite(FlxG.width, FlxG.height, dealphaedColors);
		// insert(1, curOverlay);
	}
    override function update(elapsed:Float) {
        super.update(elapsed);
        if (!askingToBind) {
			if (controls.ACCEPT)
			{
				awaitingFor = curSelected;
				// SUS?
				askingToBind = true;
                askToBind.visible = true;
			}
            if (controls.UP_MENU) {
                changeSelection(-1);
            } else if (controls.DOWN_MENU) {
                changeSelection(1);
            }
            if (controls.BACK) {
                LoadingState.loadAndSwitchState(new SaveDataState());
            }
        } else {
            if (FlxG.keys.firstJustPressed() != -1) {
                // blush 
                // bind the first key pressed
                switch (awaitingFor) {
                    case 0:
                        FlxG.save.data.keys.left = FlxG.keys.firstJustPressed();
                    case 1:
                        FlxG.save.data.keys.down = FlxG.keys.firstJustPressed();
                    case 2:
                        FlxG.save.data.keys.up = FlxG.keys.firstJustPressed();
                    case 3:
                        FlxG.save.data.keys.right = FlxG.keys.firstJustPressed();
                }
				var coolText = switch (awaitingFor)
				{
					case 0:
						'Left: ${cast (FlxG.save.data.keys.left : String)}';
					case 1:
						'Down: ${cast (FlxG.save.data.keys.down : String)}';
					case 2:
						'Up: ${cast (FlxG.save.data.keys.up : String)}';
					case 3:
						'Right: ${cast (FlxG.save.data.keys.right : String)}';
					default:
						'how did we get here';
				}
                FlxG.save.flush();
                grpBind.members[awaitingFor].text = coolText;
                grpBind.members[awaitingFor].addText();
                // then reeset everything
                awaitingFor = -1;
                askingToBind = false;
                askToBind.visible= false;
            }
        }
        
    }
}