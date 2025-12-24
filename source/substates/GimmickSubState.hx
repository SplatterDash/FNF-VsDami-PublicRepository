package substates;

class GimmickSubState extends MusicBeatSubstate
{
    var bgLoop:FlxSound;
    var completeFunction:Void->Void;

    override public function new(func:Null<Void->Void>)
    {
        this.completeFunction = func;
        super();
    }

    override function create()
    {
        final direct:String = 'Void/note-warning/';

        PlayState.instance.camOther.bgColor.alpha = 1;
		PlayState.instance.camOther.bgColor = FlxColor.BLACK;

        var bg:BGSprite = new BGSprite(direct + 'bg');
        bg.screenCenter();
        bg.active = false;
        add(bg);

		var vessel:BGSprite = new BGSprite(direct + 'vessel', 1550);
		vessel.active = false;
		add(vessel);

		var text:BGSprite = new BGSprite(direct + 'text', -568, 58);
		text.active = false;
		add(text);

		var confirm:FlxText = new FlxText(0, 650, 0, 'Press ${CoolUtil.getKey('accept')} to continue...');
        confirm.setFormat(Paths.font('vcr.ttf'), 50, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        confirm.screenCenter(X);
        confirm.active = false;
        confirm.alpha = 0;
        add(confirm);

        bgLoop = new FlxSound().loadEmbedded(Paths.sound('warning-ambience'), true);

		cameras = [PlayState.instance.camOther];
        super.create();

        FlxTween.tween(vessel, { x: 1280 - vessel.width }, 2.5, {ease: FlxEase.quadOut});
		FlxTween.tween(text, {x: 32}, 2.5, {ease: FlxEase.quadOut});
        FlxTween.tween(confirm, {alpha: 1}, 2.5, {startDelay: 2.5});

        bgLoop.play();
        bgLoop.fadeIn(2, 0, 0.7);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if(controls.ACCEPT) {
			FlxG.sound.play(Paths.sound('confirmMenu'));
            bgLoop.fadeOut(2.5, 0, (twn:FlxTween) -> {bgLoop.stop();});
            FlxTween.tween(PlayState.instance.camOther, {alpha: 0}, 2.5, {onComplete: (twn:FlxTween) -> {
                close();
                if(completeFunction != null) completeFunction();
            }});
        }
    }

    override public function close()
    {
		PlayState.instance.camOther.bgColor.alpha = 0;
        PlayState.instance.camOther.alpha = 1;
        super.close();
    }
}