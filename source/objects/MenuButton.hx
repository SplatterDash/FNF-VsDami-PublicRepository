package objects;

class MenuButton extends FlxSprite
{
    public var selected(default, set):Bool = false;
    public var pressed(default, set):Bool = false;
    public var locked(default, set):Bool = false;
    public var onSelect:()->Void = null;
    public var onHover:(Bool)->Void;
    public var scaleTween:FlxTween;
    public var useDefaultHover:Bool = false;

    private var baseImage:String = '';

    override public function new(x:Float, y:Float, image:String, ?onSelect:()->Void, ?onHover:(Bool)->Void)
    {
        super(x, y);
        loadGraphic(Paths.image(image));
        if(onSelect != null) this.onSelect = onSelect;
        if(onHover != null) this.onHover = onHover else this.onHover = defaultHover;
        if(image.endsWith('-unselect')) {
            baseImage = image.substr(0, image.length-8);
            Paths.image(baseImage + 'select');
            //trace(baseImage);
        }
    }

    function defaultHover(select:Bool):Void
    {
        if(!select && (scale.x != 1 || scaleTween != null)) {
            if(baseImage != '') loadGraphic(Paths.image(baseImage + 'unselect'));
            if(scaleTween != null) scaleTween.cancel();
            scaleTween = FlxTween.tween(scale, { x: 1, y: 1 }, 0.4, {ease: FlxEase.elasticOut, onComplete: function(twn:FlxTween) {scaleTween = null;}});
        } else if(select && (scale.x != 1.2 || scaleTween != null)) {
            if(baseImage != '') loadGraphic(Paths.image(baseImage + 'select'));
            if(scaleTween != null) scaleTween.cancel();
            scaleTween = FlxTween.tween(scale, { x: 1.2, y: 1.2 }, 0.4, {ease: FlxEase.elasticOut, onComplete: function(twn:FlxTween) {scaleTween = null;}});
        }
        return;
    }

    public function set_selected(select:Bool):Bool
    {
        if(!locked) {
            onHover(select);
            if(useDefaultHover) defaultHover(select);
        }
        selected = select;
        return select;
    }

    public function set_pressed(press:Bool):Bool
    {
        if(!locked) {
            if(press && (scale.x != 0.8 || scaleTween != null)) {
                if(scaleTween != null) scaleTween.cancel();
                scale.set(0.8, 0.8);
            } else if(!press && (scale.x == 0.8 || scaleTween != null)) {
                if(scaleTween != null) scaleTween.cancel();
                scale.set(selected ? 1.2 : 1, selected ? 1.2 : 1);
            }
        }
        return press;
    }

    public function set_locked(lock:Bool):Bool
    {
        if(lock) {
            pressed = false;
            onSelect();
        }
        return lock;
    }
}