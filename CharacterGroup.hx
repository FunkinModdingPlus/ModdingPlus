package;

import flixel.util.typeLimit.OneOfTwo;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
/**
 * A group specifaclly for characters, built for conveneince. 
 * Includes important functions from chracter, which calls it on all characters in a group.
 */
class CharacterGroup extends FlxTypedSpriteGroup<Character> {
    public var activeChar:Int = 0;
    public function currentCharacter():Character {
        return members[activeChar];
    }
    public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void {
        forEachAlive(function (char:Character) {
            char.playAnim(AnimName, Force, Reversed, Frame);
        });
    }
    public function dance() {
        forEachAlive(function (char:Character) {
            char.dance();
        });
    }
    public function sing(direction:Int, ?miss:Bool=false, ?alt:Int = 0) {
        forEachAlive(function (char:Character) {
            char.sing(direction, miss, alt);
        });
    }
    public function setActive(char:OneOfTwo<Int, Character>) {
        if ((char is Int)) {
            forEach(function (charee) {
                charee.active = false;
                charee.alive = false;
            });
            activeChar = char;
            members[char].active = true;
            members[char].alive = true;
        }
        if ((char is Character)) {
            // we have to find it
			if (members.indexOf(char) == -1)
				return;
            forEach(function(charee) {
                charee.active = false;
                charee.alive = false;
            });
            var goodChar = members[members.indexOf(char)];
			activeChar = members.indexOf(char);
            goodChar.active = true;
            goodChar.alive = true;

        }
        
    }
    public function setMultipleActive(chars:Array<OneOfTwo<Int, Character>>) {
		forEach(function(charee)
		{
			charee.active = false;
			charee.alive = false;
		});
        for (char in chars) {
			if ((char is Int))
			{
				
				members[char].active = true;
				members[char].alive = true;
                activeChar = char;
			}
			if ((char is Character))
			{
				// we have to find it
				if (members.indexOf(char) == -1)
					continue;
				
				var goodChar = members[members.indexOf(char)];
				goodChar.active = true;
				goodChar.alive = true;
                activeChar = members.indexOf(char);
			}
        }
    }
}