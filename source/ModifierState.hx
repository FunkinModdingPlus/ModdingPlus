package;

import Controls.Control;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
#if sys
import sys.io.File;
#end
import haxe.Json;
using StringTools;
typedef TModifierNoName = {
	var value:Bool;
	var conflicts:Array<String>;
	var multi:Float;
	var ?times:Null<Bool>;
	var desc:String;
	var ?amount:Null<Float>;
	var ?defAmount:Null<Float>;
	var ?precision:Null<Float>;
	var ?minimum:Null<Float>;
	var ?maximum:Null<Float>;
	// used for things that give you points in both directions
	var ?absolute:Null<Bool>;
}
typedef TModifier = {
	> TModifierNoName,
	var name:String;
	var internName:String;
	
}
class ModifierState extends MusicBeatState
{

	// use only in this class
	public static var modifiers:Array<TModifier> = FNFAssets.getText("assets/data/modifier_menu.txt");
	var grpAlphabet:FlxTypedGroup<Alphabet>;
	var curSelected:Int = 1;
	var checkmarks:Array<FlxSprite> = [];
	var numberdisplays:Array<NumberDisplay> = [];
	var multiTxt:FlxText;
	public static var isStoryMode:Bool = false;
	public static var scoreMultiplier:Float = 1;
	var description:FlxText;
	public static var namedModifiers:Dynamic = {};
	public static function init() {
		for (modifier in 0...modifiers.length)
		{
			Reflect.setField(namedModifiers, modifiers[modifier].internName, modifiers[modifier]);
		}
	}
	override function create()
	{
		var menuBG:FlxSprite = new FlxSprite().loadGraphic('assets/images/menuDesat.png');
		menuBG.color = 0xFFea71fd;
		grpAlphabet = new FlxTypedGroup<Alphabet>();
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		multiTxt = new FlxText(800, 60, 0, "", 200);
		multiTxt.setFormat("assets/fonts/vcr.ttf", 40, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		multiTxt.text = "Multiplier: 1";
		multiTxt.scrollFactor.set();
		description = new FlxText(750, 150, 350, "", 90);
		description.setFormat("assets/fonts/vcr.ttf", 32, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		description.text = "Instantly fail when you don't get \"Sick\"";
		description.scrollFactor.set();
		for (modifier in 0...modifiers.length) {
			var swagModifier = new Alphabet(0, 10, "   "+modifiers[modifier].name, true, false, true);
			swagModifier.isMenuItem = true;
			swagModifier.targetY = modifier;
			var coolCheckmark:FlxSprite = new FlxSprite().loadGraphic('assets/images/checkmark.png');
			coolCheckmark.visible = modifiers[modifier].value;
			var displayNum:NumberDisplay = new NumberDisplay(0, 0, modifiers[modifier].defAmount, modifiers[modifier].precision, modifiers[modifier].minimum, modifiers[modifier].maximum);
			displayNum.visible = modifiers[modifier].amount != null;
			if (displayNum.visible)
				displayNum.value = modifiers[modifier].amount;
			displayNum.size = 90;
			checkmarks.push(coolCheckmark);
			numberdisplays.push(displayNum);
			displayNum.x += swagModifier.width + displayNum.width;
			swagModifier.add(coolCheckmark);
			swagModifier.add(displayNum);
			grpAlphabet.add(swagModifier);
			
			
			Reflect.setField(namedModifiers, modifiers[modifier].internName, modifiers[modifier]);
		}
		add(menuBG);
		add(grpAlphabet);
		add(multiTxt);
		add(description);
		calculateMultiplier();
		multiTxt.text = "Multiplier: "+scoreMultiplier;
		changeSelection(0);
		super.create();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		if (controls.BACK) {
			if (isStoryMode)
				LoadingState.loadAndSwitchState(new StoryMenuState());
			else
				LoadingState.loadAndSwitchState(new FreeplayState());
		}
		if (controls.UP_MENU)
		{
			changeSelection(-1);
		}
		if (controls.DOWN_MENU)
		{
			changeSelection(1);
		}
		if (controls.RIGHT_MENU) {
			changeAmount(true);
		}  else if (controls.LEFT_MENU) {
			changeAmount(false);
		}
		if (controls.ACCEPT)
			toggleSelection();
	}
	function changeAmount(increase:Bool=false) {
		if (!numberdisplays[curSelected].visible)
			// not meant to be here...
			return;
		numberdisplays[curSelected].changeAmount(increase);
		modifiers[curSelected].amount = numberdisplays[curSelected].value;
		if (numberdisplays[curSelected].value == numberdisplays[curSelected].useDefaultValue && modifiers[curSelected].value) {
			toggleSelection();
		}
		else if (numberdisplays[curSelected].value != numberdisplays[curSelected].useDefaultValue && !modifiers[curSelected].value) {
			toggleSelection();
		}
		calculateMultiplier();
	}
	function changeSelection(change:Int = 0)
	{

		FlxG.sound.play('assets/sounds/custom_menu_sounds/'
			+ CoolUtil.parseJson(FNFAssets.getJson("assets/sounds/custom_menu_sounds/custom_menu_sounds")).customMenuScroll+'/scrollMenu' + TitleState.soundExt, 0.4);

		curSelected += change;



		curSelected = Std.int(FlxMath.wrap(curSelected, 1, modifiers.length - 1));
		var bullShit:Int = 0;

		for (item in grpAlphabet.members)
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
		description.text = modifiers[curSelected].desc;
	}
	function calculateMultiplier() {
		scoreMultiplier = 1;
		var timesThings:Array<Float> = [];
		var i = 0;
		for (modifier in modifiers) {
			if (modifier.value) {
				if (modifier.times)
					timesThings.push(modifier.multi);
				else {
					trace(numberdisplays[i].changedBy);
					if (modifier.amount != null)
						scoreMultiplier += numberdisplays[i].changedBy * modifier.multi;
					else
						scoreMultiplier += modifier.multi;
				}
			}
			i++;
		}
		for (timesThing in timesThings) {
			scoreMultiplier *= timesThing;
		}
		if (scoreMultiplier <= 0 && timesThings.length == 0) {
			scoreMultiplier = 0.1;
		}
		multiTxt.text = "Multiplier: " + scoreMultiplier;
	}
	function toggleSelection() {			
		switch(modifiers[curSelected].internName) {
			case 'play':
				if (FlxG.sound.music != null)
					FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState(), true);
			case 'chart':
				LoadingState.loadAndSwitchState(new ChartingState());
			case 'charselect':
				LoadingState.loadAndSwitchState(new ChooseCharState(PlayState.SONG.player1));
			case 'antijank':
				// do nothi n
			default:
					checkmarks[curSelected].visible = !checkmarks[curSelected].visible;
					for (conflicting in modifiers[curSelected].conflicts)
					{
						var coolNum = 0;
						for (modifier in 0...modifiers.length) {
							if (modifiers[modifier].internName == conflicting) {
								coolNum = modifier;
							}
						}
						checkmarks[coolNum].visible = false;
						modifiers[coolNum].value = false;
					}
					calculateMultiplier();

					modifiers[curSelected].value = checkmarks[curSelected].visible;
				if (modifiers[curSelected].value
					&& modifiers[curSelected].amount != null
					&& numberdisplays[curSelected].value == numberdisplays[curSelected].useDefaultValue) {
						numberdisplays[curSelected].changeAmount(true);
					} else if (!modifiers[curSelected].value){
						numberdisplays[curSelected].resetValues();
					}
					calculateMultiplier();
					multiTxt.text = "Multiplier: " + scoreMultiplier;
		}
	}
}
