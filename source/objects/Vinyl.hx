package objects;

import shaders.ColorOverlay;

class Vinyl extends FlxTypedSpriteGroup<FlxSprite>
{
    public var spinning(default, set):Bool = false;
	public var isNew(default, set):Bool = false;
	public var song(default, set):String = '';
	public var overrideText:String = '';
	public var daScale(default, set):Float = 1.0;

	public var onTransform:()->Void;

    var spinTween:FlxTween = null;
	var size:Float = 0;
	final vinylText:FlxSprite = new FlxSprite();
	final newText:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menus/freeplay/vinyl/new'));
	final transShader:ColorOverlay = new ColorOverlay(FlxColor.WHITE, 0);

    public override function new(X:Float, Y:Float, song:String, ?newSong:Bool = false, ?overrideText:String = '')
    {
        super(X, Y);
        this.overrideText = overrideText;
		isNew = newSong;
		this.song = song;

		add(vinylText);
		add(newText);

		size = vinylText.height;
    }

    public function getVinylTexture(songName:String, ?overrideText:String = '')
	{
		var discScore:String = '';
		if(overrideText != '') discScore = overrideText
			else discScore = CoolUtil.getRatingTexture(songName);

		var theText:String = '';
		switch(songName)
		{
			case 'dami-nate' | 'bussin' | 'affliction' | 'dami-nate-erect-remix': theText = 'dami';
			case 'domination' | 'reawaken' if (discScore != 'plain'): theText = 'dami';
			case 'backstreets': theText = 'minus';
			case 'improbable-outset-dami-mix': theText = 'tricky';
			case _: theText = songName;
		}

		vinylText.loadGraphic(Paths.image('menus/freeplay/vinyl/${discScore}/${theText}'));
	}

	public function transform()
	{
		vinylText.shader = transShader;
		FlxTween.tween(transShader.alpha, {value: 1}, 1.5, {onComplete: function(twn:FlxTween) {
			getVinylTexture(song);
			FlxTween.tween(transShader.alpha, {value: 1}, 1.5, {onComplete: function(twn:FlxTween) {
				vinylText.shader = null;
				onTransform();
			}});
		}});
	}

	public function checkForNew()
	{
		if (backend.Highscore.getScore(song) == 0 && vinylText.color != FlxColor.BLACK) isNew = true
			else isNew = false;
	}

    function set_spinning(spin:Bool):Bool
    {
        if(spin)
        {
			vinylText.centerOffsets();
            spinTween = FlxTween.angle(vinylText, 0, 360, 4, { type: LOOPING });
        } else {
			spinTween.cancel();
            spinTween = null;
            vinylText.angle = 0;
        }
		spinning = spin;
        return spin;
    }

	function set_isNew(isNewest:Bool):Bool
	{
		newText.visible = isNewest;
		isNew = isNewest;
		return isNewest;
	}

	function set_song(song:String):String
	{
		getVinylTexture(song, overrideText);
		this.song = song;
		return song;
	}

	function set_daScale(sumScale:Float):Float
	{
		vinylText.scale.set(sumScale, sumScale);
		vinylText.updateHitbox();

		newText.scale.set(sumScale, sumScale);
		newText.updateHitbox();

		newText.y = vinylText.y;

		daScale = sumScale;
		return sumScale;
	}
}