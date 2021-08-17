package;

import flixel.FlxG;
import flixel.input.FlxInput;
import flixel.input.actions.FlxAction;
import flixel.input.actions.FlxActionInput;
import flixel.input.actions.FlxActionInputDigital;
import flixel.input.actions.FlxActionManager;
import flixel.input.actions.FlxActionSet;
import flixel.input.gamepad.FlxGamepadButton;
import flixel.input.gamepad.FlxGamepadInputID;
import flixel.input.keyboard.FlxKey;

#if (haxe >= "4.0.0")
enum abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var UP_MENU = "up-menu";
	var LEFT_MENU = "left-menu";
	var RIGHT_MENU = "right-menu";
	var DOWN_MENU = "down-menu";
	var UP_MENU_H = "up-menu-hold";
	var LEFT_MENU_H = "left-menu-hold";
	var RIGHT_MENU_H = "right-menu-hold";
	var DOWN_MENU_H = "down-menu-hold";
	var ACCEPT = "accept";
	var SECONDARY = "secondary";
	var TERTIARY = "tertiary";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
	var LEFT_TAB = "left-tab";
	var RIGHT_TAB = "right-tab";
}
#else
@:enum
abstract Action(String) to String from String
{
	var UP = "up";
	var LEFT = "left";
	var RIGHT = "right";
	var DOWN = "down";
	var UP_P = "up-press";
	var LEFT_P = "left-press";
	var RIGHT_P = "right-press";
	var DOWN_P = "down-press";
	var UP_R = "up-release";
	var LEFT_R = "left-release";
	var RIGHT_R = "right-release";
	var DOWN_R = "down-release";
	var ACCEPT = "accept";
	var BACK = "back";
	var PAUSE = "pause";
	var RESET = "reset";
	var CHEAT = "cheat";
}
#end

enum Device
{
	Keys;
	Gamepad(id:Int);
}

/**
 * Since, in many cases multiple actions should use similar keys, we don't want the
 * rebinding UI to list every action. ActionBinders are what the user percieves as
 * an input so, for instance, they can't set jump-press and jump-release to different keys.
 */
enum Control
{
	UP;
	LEFT;
	RIGHT;
	DOWN;
	RESET;
	ACCEPT;
	BACK;
	PAUSE;
	CHEAT;
	SECONDARY;
	TERTIARY;
	LEFT_MENU;
	RIGHT_MENU;
	UP_MENU;
	DOWN_MENU;
	LEFT_TAB;
	RIGHT_TAB;
}

enum KeyboardScheme
{
	Solo(dfjk:Bool);
	Duo(first:Bool);
	None;
	Custom;
}

/**
 * A list of actions that a player would invoke via some input device.
 * Uses FlxActions to funnel various inputs to a single action.
 */
 @:allow(PlayState)
class Controls extends FlxActionSet
{
	var _up = new FlxActionDigital(Action.UP);
	var _left = new FlxActionDigital(Action.LEFT);
	var _right = new FlxActionDigital(Action.RIGHT);
	var _down = new FlxActionDigital(Action.DOWN);
	var _upP = new FlxActionDigital(Action.UP_P);
	var _leftP = new FlxActionDigital(Action.LEFT_P);
	var _rightP = new FlxActionDigital(Action.RIGHT_P);
	var _downP = new FlxActionDigital(Action.DOWN_P);
	var _upR = new FlxActionDigital(Action.UP_R);
	var _leftR = new FlxActionDigital(Action.LEFT_R);
	var _rightR = new FlxActionDigital(Action.RIGHT_R);
	var _downR = new FlxActionDigital(Action.DOWN_R);
	var _menuLeft = new FlxActionDigital(Action.LEFT_MENU);
	var _menuRight = new FlxActionDigital(Action.RIGHT_MENU);
	var _menuUp = new FlxActionDigital(Action.UP_MENU);
	var _menuDown = new FlxActionDigital(Action.DOWN_MENU);
	var _menuLeftHold = new FlxActionDigital(Action.LEFT_MENU_H);
	var _menuRightHold = new FlxActionDigital(Action.RIGHT_MENU_H);
	var _menuUpHold = new FlxActionDigital(Action.UP_MENU_H);
	var _menuDownHold = new FlxActionDigital(Action.DOWN_MENU_H);
	var _accept = new FlxActionDigital(Action.ACCEPT);
	var _back = new FlxActionDigital(Action.BACK);
	var _pause = new FlxActionDigital(Action.PAUSE);
	var _reset = new FlxActionDigital(Action.RESET);
	var _cheat = new FlxActionDigital(Action.CHEAT);
	var _secondary = new FlxActionDigital(Action.SECONDARY);
	var _tertiary = new FlxActionDigital(Action.TERTIARY);
	var _leftTab = new FlxActionDigital(Action.LEFT_TAB);
	var _rightTab = new FlxActionDigital(Action.RIGHT_TAB);
	#if (haxe >= "4.0.0")
	var byName:Map<String, FlxActionDigital> = [];
	#else
	var byName:Map<String, FlxActionDigital> = new Map<String, FlxActionDigital>();
	#end

	public var gamepadsAdded:Array<Int> = [];
	public var keyboardScheme = KeyboardScheme.None;

	public var UP_MENU(get, never):Bool;
	
	inline function get_UP_MENU()
		return _menuUp.check();

	public var DOWN_MENU(get, never):Bool;

	inline function get_DOWN_MENU()
		return _menuDown.check();

	public var LEFT_MENU(get, never):Bool;

	inline function get_LEFT_MENU()
		return _menuLeft.check();

	public var RIGHT_MENU(get, never):Bool;

	inline function get_RIGHT_MENU()
		return _menuRight.check();

	public var UP_MENU_H(get, never):Bool;

	inline function get_UP_MENU_H()
		return _menuUpHold.check();

	public var DOWN_MENU_H(get, never):Bool;

	inline function get_DOWN_MENU_H()
		return _menuDownHold.check();

	public var LEFT_MENU_H(get, never):Bool;

	inline function get_LEFT_MENU_H()
		return _menuLeftHold.check();

	public var RIGHT_MENU_H(get, never):Bool;

	inline function get_RIGHT_MENU_H()
		return _menuRightHold.check();

	public var UP(get, never):Bool;

	inline function get_UP()
		return _up.check();

	public var LEFT(get, never):Bool;

	inline function get_LEFT()
		return _left.check();

	public var RIGHT(get, never):Bool;

	inline function get_RIGHT()
		return _right.check();

	public var DOWN(get, never):Bool;

	inline function get_DOWN()
		return _down.check();

	public var UP_P(get, never):Bool;

	inline function get_UP_P()
		return _upP.check();

	public var LEFT_P(get, never):Bool;

	inline function get_LEFT_P()
		return _leftP.check();

	public var RIGHT_P(get, never):Bool;

	inline function get_RIGHT_P()
		return _rightP.check();

	public var DOWN_P(get, never):Bool;

	inline function get_DOWN_P()
		return _downP.check();

	public var UP_R(get, never):Bool;

	inline function get_UP_R()
		return _upR.check();

	public var LEFT_R(get, never):Bool;

	inline function get_LEFT_R()
		return _leftR.check();

	public var RIGHT_R(get, never):Bool;

	inline function get_RIGHT_R()
		return _rightR.check();

	public var DOWN_R(get, never):Bool;

	inline function get_DOWN_R()
		return _downR.check();

	public var ACCEPT(get, never):Bool;

	inline function get_ACCEPT()
		return _accept.check();

	public var BACK(get, never):Bool;

	inline function get_BACK()
		return _back.check();

	public var PAUSE(get, never):Bool;

	inline function get_PAUSE()
		return _pause.check();	
	public var SECONDARY(get, never):Bool;
	inline function get_SECONDARY()
		return _secondary.check();
	public var TERTIARY(get,never):Bool;
	inline function get_TERTIARY()
		return _tertiary.check();

	public var LEFT_TAB(get, never):Bool;

	inline function get_LEFT_TAB()
		return _leftTab.check();

	public var RIGHT_TAB(get, never):Bool;

	inline function get_RIGHT_TAB()
		return _rightTab.check();
	public var RESET(get, never):Bool;

	inline function get_RESET()
		return _reset.check();

	public var CHEAT(get, never):Bool;

	inline function get_CHEAT()
		return _cheat.check();

	#if (haxe >= "4.0.0")
	public function new(name, scheme = None)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);
		add(_secondary);
		add(_tertiary);
		add(_menuDown);
		add(_menuDownHold);
		add(_menuLeft);
		add(_menuLeftHold);
		add(_menuRight);
		add(_menuRightHold);
		add(_menuUp);
		add(_menuUpHold);
		add(_leftTab);
		add(_rightTab);
		for (action in digitalActions)
			byName[action.name] = action;

		setKeyboardScheme(scheme, false);
	}
	#else
	public function new(name, scheme:KeyboardScheme = null)
	{
		super(name);

		add(_up);
		add(_left);
		add(_right);
		add(_down);
		add(_upP);
		add(_leftP);
		add(_rightP);
		add(_downP);
		add(_upR);
		add(_leftR);
		add(_rightR);
		add(_downR);
		add(_accept);
		add(_back);
		add(_pause);
		add(_reset);
		add(_cheat);

		for (action in digitalActions)
			byName[action.name] = action;

		if (scheme == null)
			scheme = None;
		setKeyboardScheme(scheme, false);
	}
	#end

	override function update()
	{
		super.update();
	}

	// inline
	public function checkByName(name:Action):Bool
	{
		#if debug
		if (!byName.exists(name))
			throw 'Invalid name: $name';
		#end
		return byName[name].check();
	}

	public function getDialogueName(action:FlxActionDigital):String
	{
		var input = action.inputs[0];
		return switch input.device
		{
			case KEYBOARD: return '[${(input.inputID : FlxKey)}]';
			case GAMEPAD: return '(${(input.inputID : FlxGamepadInputID)})';
			case device: throw 'unhandled device: $device';
		}
	}

	public function getDialogueNameFromToken(token:String):String
	{
		return getDialogueName(getActionFromControl(Control.createByName(token.toUpperCase())));
	}

	function getActionFromControl(control:Control):FlxActionDigital
	{
		return switch (control)
		{
			case UP: _up;
			case DOWN: _down;
			case LEFT: _left;
			case RIGHT: _right;
			case ACCEPT: _accept;
			case BACK: _back;
			case PAUSE: _pause;
			case RESET: _reset;
			case CHEAT: _cheat;
			case SECONDARY: _secondary;
			case TERTIARY: _tertiary;
			case UP_MENU: _menuUp;
			case DOWN_MENU: _menuDown;
			case LEFT_MENU: _menuLeft;
			case RIGHT_MENU: _menuRight;
			case RIGHT_TAB: _rightTab;
			case LEFT_TAB: _leftTab;
		}
	}

	static function init():Void
	{
		var actions = new FlxActionManager();
		FlxG.inputs.add(actions);
	}

	/**
	 * Calls a function passing each action bound by the specified control
	 * @param control
	 * @param func
	 * @return ->Void)
	 */
	function forEachBound(control:Control, func:FlxActionDigital->FlxInputState->Void)
	{
		switch (control)
		{
			case UP:
				func(_up, PRESSED);
				func(_upP, JUST_PRESSED);
				func(_upR, JUST_RELEASED);
			case LEFT:
				func(_left, PRESSED);
				func(_leftP, JUST_PRESSED);
				func(_leftR, JUST_RELEASED);
			case RIGHT:
				func(_right, PRESSED);
				func(_rightP, JUST_PRESSED);
				func(_rightR, JUST_RELEASED);
			case DOWN:
				func(_down, PRESSED);
				func(_downP, JUST_PRESSED);
				func(_downR, JUST_RELEASED);
			case ACCEPT:
				func(_accept, JUST_PRESSED);
			case BACK:
				func(_back, JUST_PRESSED);
			case PAUSE:
				func(_pause, JUST_PRESSED);
			case RESET:
				func(_reset, JUST_PRESSED);
			case CHEAT:
				func(_cheat, JUST_PRESSED);
			case SECONDARY:
				func(_secondary, JUST_PRESSED);
			case TERTIARY:
				func(_tertiary, JUST_PRESSED);
			case LEFT_MENU:
				func(_menuLeft, JUST_PRESSED);
				func(_menuLeftHold, PRESSED);
			case RIGHT_MENU:
				func(_menuRight, JUST_PRESSED);
				func(_menuRightHold, PRESSED);
			case UP_MENU:
				func(_menuUp, JUST_PRESSED);
				func(_menuUpHold, PRESSED);
			case DOWN_MENU:
				func(_menuDown, JUST_PRESSED);
				func(_menuDownHold, PRESSED);
			case LEFT_TAB:
				func(_leftTab, JUST_PRESSED);
			case RIGHT_TAB:
				func(_rightTab, JUST_PRESSED);
		}
	}

	public function replaceBinding(control:Control, device:Device, ?toAdd:Int, ?toRemove:Int)
	{
		if (toAdd == toRemove)
			return;

		switch (device)
		{
			case Keys:
				if (toRemove != null)
					unbindKeys(control, [toRemove]);
				if (toAdd != null)
					bindKeys(control, [toAdd]);

			case Gamepad(id):
				if (toRemove != null)
					unbindButtons(control, id, [toRemove]);
				if (toAdd != null)
					bindButtons(control, id, [toAdd]);
		}
	}

	public function copyFrom(controls:Controls, ?device:Device)
	{
		#if (haxe >= "4.0.0")
		for (name => action in controls.byName)
		{
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
					byName[name].add(cast input);
			}
		}
		#else
		for (name in controls.byName.keys())
		{
			var action = controls.byName[name];
			for (input in action.inputs)
			{
				if (device == null || isDevice(input, device))
				byName[name].add(cast input);
			}
		}
		#end

		switch (device)
		{
			case null:
				// add all
				#if (haxe >= "4.0.0")
				for (gamepad in controls.gamepadsAdded)
					if (!gamepadsAdded.contains(gamepad))
						gamepadsAdded.push(gamepad);
				#else
				for (gamepad in controls.gamepadsAdded)
					if (gamepadsAdded.indexOf(gamepad) == -1)
					  gamepadsAdded.push(gamepad);
				#end

				mergeKeyboardScheme(controls.keyboardScheme);

			case Gamepad(id):
				gamepadsAdded.push(id);
			case Keys:
				mergeKeyboardScheme(controls.keyboardScheme);
		}
	}

	inline public function copyTo(controls:Controls, ?device:Device)
	{
		controls.copyFrom(this, device);
	}

	function mergeKeyboardScheme(scheme:KeyboardScheme):Void
	{
		if (scheme != None)
		{
			switch (keyboardScheme)
			{
				case None:
					keyboardScheme = scheme;
				default:
					keyboardScheme = Custom;
			}
		}
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addKeys(action, keys, state));
		#else
		forEachBound(control, function(action, state) addKeys(action, keys, state));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindKeys(control:Control, keys:Array<FlxKey>)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeKeys(action, keys));
		#else
		forEachBound(control, function(action, _) removeKeys(action, keys));
		#end
	}

	inline static function addKeys(action:FlxActionDigital, keys:Array<FlxKey>, state:FlxInputState)
	{
		for (key in keys)
			action.addKey(key, state);
	}

	static function removeKeys(action:FlxActionDigital, keys:Array<FlxKey>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (input.device == KEYBOARD && keys.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}

	public function setKeyboardScheme(scheme:KeyboardScheme, reset = true)
	{
		if (reset)
			removeKeyboard();

		keyboardScheme = scheme;
		if (!Reflect.hasField(FlxG.save.data, "keys") || !(FlxG.save.data.keys.left is Array)) {
			FlxG.save.data.keys = {
				"left": [D],
				"down": [F],
				"up": [J],
				"right": [K]
			};
		}
		#if (haxe >= "4.0.0")
		switch (scheme)
		{
			// Keys are always rebinded before playstate starts. Note that this totally fucks up menuing lol.
			case Solo(false) | Solo(true):
				inline bindKeys(Control.UP, FlxG.save.data.keys.up);
				inline bindKeys(Control.DOWN, FlxG.save.data.keys.down);
				inline bindKeys(Control.LEFT, FlxG.save.data.keys.left);
				inline bindKeys(Control.RIGHT, FlxG.save.data.keys.right);
				inline bindKeys(Control.UP_MENU, [W, FlxKey.UP]);
				inline bindKeys(Control.DOWN_MENU, [S, FlxKey.DOWN]);
				inline bindKeys(Control.LEFT_MENU, [A, FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT_MENU, [D, FlxKey.RIGHT]);
				inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				inline bindKeys(Control.RESET, [R]);
				inline bindKeys(Control.SECONDARY, [E]);
				inline bindKeys(Control.TERTIARY,[Q]);
				inline bindKeys(Control.LEFT_TAB, [Q]);
				inline bindKeys(Control.RIGHT_TAB, [E]);
			case Duo(true):
				inline bindKeys(Control.UP, [W,K]);
				inline bindKeys(Control.DOWN, [S,J]);
				inline bindKeys(Control.LEFT, [A,H]);
				inline bindKeys(Control.RIGHT, [D,L]);
				inline bindKeys(Control.ACCEPT, [G, Z]);
				inline bindKeys(Control.BACK, [Q]);
				inline bindKeys(Control.PAUSE, [ONE]);
				inline bindKeys(Control.RESET, [R]);
				inline bindKeys(Control.SECONDARY, [E]);
				inline bindKeys(Control.TERTIARY, [T]);
				inline bindKeys(Control.UP_MENU, [W, FlxKey.UP]);
				inline bindKeys(Control.DOWN_MENU, [S, FlxKey.DOWN]);
				inline bindKeys(Control.LEFT_MENU, [A, FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT_MENU, [D, FlxKey.RIGHT]);
			case Duo(false):
				inline bindKeys(Control.UP, [FlxKey.UP,PERIOD]);
				inline bindKeys(Control.DOWN, [FlxKey.DOWN,C]);
				inline bindKeys(Control.LEFT, [FlxKey.LEFT,X]);
				inline bindKeys(Control.RIGHT, [FlxKey.RIGHT,SLASH]);
				inline bindKeys(Control.ACCEPT, [O]);
				inline bindKeys(Control.BACK, [P]);
				inline bindKeys(Control.PAUSE, [ENTER]);
				inline bindKeys(Control.RESET, [BACKSPACE]);
				inline bindKeys(Control.SECONDARY, [BACKSLASH]);
				inline bindKeys(Control.TERTIARY, [RBRACKET]);
				inline bindKeys(Control.UP_MENU, [W, FlxKey.UP]);
				inline bindKeys(Control.DOWN_MENU, [S, FlxKey.DOWN]);
				inline bindKeys(Control.LEFT_MENU, [A, FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT_MENU, [D, FlxKey.RIGHT]);
				inline bindKeys(Control.LEFT_TAB, [RBRACKET]);
				inline bindKeys(Control.RIGHT_TAB, [BACKSLASH]);
			case None: // nothing
			case Custom:
				inline bindKeys(Control.UP, FlxG.save.data.keys.up);
				inline bindKeys(Control.DOWN, FlxG.save.data.keys.down);
				inline bindKeys(Control.LEFT, FlxG.save.data.keys.left);
				inline bindKeys(Control.RIGHT, FlxG.save.data.keys.right);
				inline bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				inline bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				inline bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				inline bindKeys(Control.RESET, [R]);
				inline bindKeys(Control.SECONDARY, [E]);
				inline bindKeys(Control.TERTIARY,[Q]);
				inline bindKeys(Control.UP_MENU, [W, FlxKey.UP]);
				inline bindKeys(Control.DOWN_MENU, [S, FlxKey.DOWN]);
				inline bindKeys(Control.LEFT_MENU, [A, FlxKey.LEFT]);
				inline bindKeys(Control.RIGHT_MENU, [D, FlxKey.RIGHT]);
				inline bindKeys(Control.LEFT_TAB, [Q]);
				inline bindKeys(Control.RIGHT_TAB, [E]);
		}
		#else
		switch (scheme)
		{
			case Solo:
				bindKeys(Control.UP, [W, FlxKey.UP, K]);
				bindKeys(Control.DOWN, [S, FlxKey.DOWN, J]);
				bindKeys(Control.LEFT, [A, FlxKey.LEFT, H]);
				bindKeys(Control.RIGHT, [D, FlxKey.RIGHT, L]);
				bindKeys(Control.ACCEPT, [Z, SPACE, ENTER]);
				bindKeys(Control.BACK, [BACKSPACE, ESCAPE]);
				bindKeys(Control.PAUSE, [P, ENTER, ESCAPE]);
				bindKeys(Control.RESET, [R]);
			case Duo(true):
				bindKeys(Control.UP, [W]);
				bindKeys(Control.DOWN, [S]);
				bindKeys(Control.LEFT, [A]);
				bindKeys(Control.RIGHT, [D]);
				bindKeys(Control.ACCEPT, [G, Z]);
				bindKeys(Control.BACK, [H, X]);
				bindKeys(Control.PAUSE, [ONE]);
				bindKeys(Control.RESET, [R]);
			case Duo(false):
				bindKeys(Control.UP, [FlxKey.UP]);
				bindKeys(Control.DOWN, [FlxKey.DOWN]);
				bindKeys(Control.LEFT, [FlxKey.LEFT]);
				bindKeys(Control.RIGHT, [FlxKey.RIGHT]);
				bindKeys(Control.ACCEPT, [O]);
				bindKeys(Control.BACK, [P]);
				bindKeys(Control.PAUSE, [ENTER]);
				bindKeys(Control.RESET, [BACKSPACE]);
			case None: // nothing
			case Custom: // nothing
		}
		#end
	}

	function removeKeyboard()
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == KEYBOARD)
					action.remove(input);
			}
		}
	}

	public function addGamepad(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	inline function addGamepadLiteral(id:Int, ?buttonMap:Map<Control, Array<FlxGamepadInputID>>):Void
	{
		gamepadsAdded.push(id);

		#if (haxe >= "4.0.0")
		for (control => buttons in buttonMap)
			inline bindButtons(control, id, buttons);
		#else
		for (control in buttonMap.keys())
			bindButtons(control, id, buttonMap[control]);
		#end
	}

	public function removeGamepad(deviceID:Int = FlxInputDeviceID.ALL):Void
	{
		for (action in this.digitalActions)
		{
			var i = action.inputs.length;
			while (i-- > 0)
			{
				var input = action.inputs[i];
				if (input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID))
					action.remove(input);
			}
		}

		gamepadsAdded.remove(deviceID);
	}

	public function addDefaultGamepad(id):Void
	{
		#if !switch
		addGamepadLiteral(id, [
			Control.ACCEPT => [A],
			Control.BACK => [B],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, Y],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, A],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, X],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, B],
			Control.UP_MENU => [DPAD_UP, LEFT_STICK_DIGITAL_UP],
			Control.DOWN_MENU => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
			Control.LEFT_MENU => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
			Control.RIGHT_MENU => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			Control.SECONDARY => [RIGHT_SHOULDER],
			Control.TERTIARY => [LEFT_SHOULDER],
			Control.LEFT_TAB => [LEFT_SHOULDER],
			Control.RIGHT_TAB => [RIGHT_SHOULDER]
			// Control.RESET => [Y]
			// gamepads should not need to reset
		]);
		#else
		addGamepadLiteral(id, [
			//Swap A and B for switch
			Control.ACCEPT => [B],
			Control.BACK => [A],
			Control.UP => [DPAD_UP, LEFT_STICK_DIGITAL_UP, RIGHT_STICK_DIGITAL_UP],
			Control.DOWN => [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN, RIGHT_STICK_DIGITAL_DOWN],
			Control.LEFT => [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT, RIGHT_STICK_DIGITAL_LEFT],
			Control.RIGHT => [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT, RIGHT_STICK_DIGITAL_RIGHT],
			Control.PAUSE => [START],
			//Swap Y and X for switch
			Control.RESET => [Y],
			Control.CHEAT => [X]
		]);
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function bindButtons(control:Control, id, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, state) -> addButtons(action, buttons, state, id));
		#else
		forEachBound(control, function(action, state) addButtons(action, buttons, state, id));
		#end
	}

	/**
	 * Sets all actions that pertain to the binder to trigger when the supplied keys are used.
	 * If binder is a literal you can inline this
	 */
	public function unbindButtons(control:Control, gamepadID:Int, buttons)
	{
		#if (haxe >= "4.0.0")
		inline forEachBound(control, (action, _) -> removeButtons(action, gamepadID, buttons));
		#else
		forEachBound(control, function(action, _) removeButtons(action, gamepadID, buttons));
		#end
	}

	inline static function addButtons(action:FlxActionDigital, buttons:Array<FlxGamepadInputID>, state, id)
	{
		for (button in buttons)
			action.addGamepad(button, state, id);
	}

	static function removeButtons(action:FlxActionDigital, gamepadID:Int, buttons:Array<FlxGamepadInputID>)
	{
		var i = action.inputs.length;
		while (i-- > 0)
		{
			var input = action.inputs[i];
			if (isGamepad(input, gamepadID) && buttons.indexOf(cast input.inputID) != -1)
				action.remove(input);
		}
	}
	public static var controlsFromStringMap:Map<String, Control> = [
		"up" => UP,
		"down" => DOWN,
		"left" => LEFT,
		"right" => RIGHT,
		"up-menu" => UP_MENU,
		"left-menu" => LEFT_MENU,
		"down-menu" => DOWN_MENU,
		"right-menu" => RIGHT_MENU,
		"accept" => ACCEPT,
		"secondary" => SECONDARY,
		"tertiary" => TERTIARY,
		"back" => BACK,
		"pause"=> PAUSE,
		"reset" => RESET,
		"cheat" => CHEAT,
		"left-tab" => LEFT_TAB,
		"right-tab" => RIGHT_TAB
	];
	public function getInputsFor(control:Control, device:Device, ?list:Array<Int>):Array<Int>
	{
		if (list == null)
			list = [];

		switch (device)
		{
			case Keys:
				for (input in getActionFromControl(control).inputs)
				{
					if (input.device == KEYBOARD)
						list.push(input.inputID);
				}
			case Gamepad(id):
				for (input in getActionFromControl(control).inputs)
				{
					if (input.deviceID == id)
						list.push(input.inputID);
				}
		}
		return list;
	}

	public function removeDevice(device:Device)
	{
		switch (device)
		{
			case Keys:
				setKeyboardScheme(None);
			case Gamepad(id):
				removeGamepad(id);
		}
	}

	static function isDevice(input:FlxActionInput, device:Device)
	{
		return switch device
		{
			case Keys: input.device == KEYBOARD;
			case Gamepad(id): isGamepad(input, id);
		}
	}

	inline static function isGamepad(input:FlxActionInput, deviceID:Int)
	{
		return input.device == GAMEPAD && (deviceID == FlxInputDeviceID.ALL || input.deviceID == deviceID);
	}
}
