package;

import Song.SwagSong;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
}
/**
 * Class that handles song position and timing. 
 */
class Conductor
{
	/**
	 *  Current song bpm.
	 */
	public static var bpm:Float = 100;
	/**
	 * Beats in milliseconds.
	 */
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	/**
	 * Steps in milliseconds.
	 */
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	/**
	 * Current song position
	 */
	public static var songPosition:Float;
	/**
	 * Updated every update (?) song position of last update
	 */
	public static var lastSongPos:Float;
	
	public static var offset:Float = 0;
	/**
	 * Time scale. Currently unused (?)
	 */
	public static var timeScale:Float = Conductor.safeZoneOffset /166;
	/**
	 * Unused (?)
	 */
	public static var safeFrames:Int = 10;
	/**
	 * unused ? 
	 */
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000; // is calculated in create(), is safeFrames in milliseconds
	/**
	 * map used during changing bpm
	 */
	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new()
	{
	}
	/**
	 * Map BPM changes of song.
	 * @param song Song to map. 
	 */
	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		var curBPM:Float = song.bpm;
		var totalSteps:Int = 0;
		var totalPos:Float = 0;
		for (i in 0...song.notes.length)
		{
			if(song.notes[i].changeBPM && song.notes[i].bpm != curBPM)
			{
				curBPM = song.notes[i].bpm;
				var event:BPMChangeEvent = {
					stepTime: totalSteps,
					songTime: totalPos,
					bpm: curBPM
				};
				bpmChangeMap.push(event);
			}

			var deltaSteps:Int = song.notes[i].lengthInSteps;
			totalSteps += deltaSteps;
			totalPos += ((60 / curBPM) * 1000 / 4) * deltaSteps;
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}
	/**
	 * Change bpm. also updated crochet. 
	 * @param newBpm New bpm.
	 */
	public static function changeBPM(newBpm:Float)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
