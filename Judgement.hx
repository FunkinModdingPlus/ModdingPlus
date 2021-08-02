import flixel.FlxSprite;

// the thing that pops up when you hit a note
typedef TUI = {
	var isPixel:Bool;
	var builtInJudgement:Bool;
	var uses:String;
};
class Judgement extends FlxSprite {
	public static var uiJson:Dynamic;
    public function new(X:Float, Y:Float, Judged:String, Display:String, early:Bool, isPixel:Bool) {
        super(X, Y);
		var curUItype:TUI = Reflect.field(uiJson, PlayState.SONG.uiType);
        // fnf
		if (!curUItype.builtInJudgement) {
			if (FNFAssets.exists('assets/images/judgements/$Display/$Judged.png'))
			{
				if (isPixel && FNFAssets.exists('assets/images/judgements/$Display/$Judged-pixel.png'))
				{
					var lord = FNFAssets.getBitmapData('assets/images/judgements/$Display/$Judged-pixel.png');
					loadGraphic(lord);
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;
				}
				else
				{
					var lord = FNFAssets.getBitmapData('assets/images/judgements/$Display/$Judged.png');
					loadGraphic(lord);
				}
			}
			else if (FNFAssets.exists('assets/images/judgements/$Display/judgement 1x6.png'))
			{
				// etterna
				var bitmapThingy = FNFAssets.getBitmapData('assets/images/judgements/$Display/judgement 1x6.png');
				loadGraphic(bitmapThingy, true, bitmapThingy.width, Std.int(bitmapThingy.height / 6));
				setGraphicSize(0, 131);

				var judgementFrame = switch (Judged)
				{
					case 'wayoff':
						4;
					case 'shit':
						3;
					case 'bad':
						2;
					case 'good':
						1;
					case "sick":
						0;
					case 'miss':
						5;
					case _:
						0;
				}
				animation.add('judgement', [judgementFrame]);
				animation.play('judgement');

				updateHitbox();
				setGraphicSize(Std.int(width / 1.5));
			}
			else if (FNFAssets.exists('assets/images/judgements/$Display/judgement 2x6.png'))
			{
				var bitmapThingy = FNFAssets.getBitmapData('assets/images/judgements/$Display/judgement 2x6.png');
				loadGraphic(bitmapThingy, true, Std.int(bitmapThingy.width / 2), Std.int(bitmapThingy.height / 6));
				setGraphicSize(0, 131);
				var judgementFrame = 0;
				if (early)
				{
					judgementFrame = switch (Judged)
					{
						case 'wayoff':
							8;
						case 'shit':
							6;
						case 'sick':
							0;
						case 'good':
							2;
						case 'bad':
							4;
						case 'miss':
							10;
						case _:
							0;
					}
				}
				else
				{
					judgementFrame = switch (Judged)
					{
						case 'wayoff':
							9;
						case 'shit':
							7;
						case 'sick':
							1;
						case 'good':
							3;
						case 'bad':
							5;
						case 'miss':
							11;
						case _:
							0;
					}
				}
				animation.add('judgement', [judgementFrame]);
				animation.play('judgement');
				updateHitbox();
				setGraphicSize(Std.int(width / 1.5));
			}
			else
			{
				// hehe
				if (isPixel && FNFAssets.exists('assets/images/judgements/normal/$Judged-pixel.png'))
				{
					loadGraphic('assets/images/judgements/normal/$Judged-pixel.png');
					setGraphicSize(Std.int(width * PlayState.daPixelZoom));
					updateHitbox();
					antialiasing = false;
				}
				else
				{
					loadGraphic('assets/images/judgements/normal/$Judged.png');
				}
			}
		} else {
			// assume that it does have it and pray
			// if this is set it should already exist so not my problem :hueh:
			if (isPixel && FNFAssets.exists('assets/images/custom_ui/ui_packs/${curUItype.uses}/$Judged-pixel.png'))
			{
				var lord = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/${curUItype.uses}/$Judged-pixel.png');
				loadGraphic(lord);
				setGraphicSize(Std.int(width * PlayState.daPixelZoom));
				updateHitbox();
				antialiasing = false;
			}
			else
			{
				var lord = FNFAssets.getBitmapData('assets/images/custom_ui/ui_packs/${curUItype.uses}/$Judged.png');
				loadGraphic(lord);
			}
		}
        
		updateHitbox();
    }
}