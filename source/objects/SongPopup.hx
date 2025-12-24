package objects;

import objects.Vinyl;

class SongPopup extends flixel.group.FlxSpriteGroup
{
    public var X(default, set):Float = -750;
    public var Y:Float = 350;

    var banner:FlxSprite;
    var vinyl:Vinyl;
    var text1:FlxText;
    var text2:FlxText;
    var text3:FlxText;

    static var bannerOffset:Int = -15;
    static var vinylOffset:Int = 435;
    static var textOffset:Int = -125;

    var text1Offset:Float = -400;

    public override function new(title:String, musician:String, charter:String)
    {
        super();

        final searchTitle:String = Paths.formatToSongPath(title);

        banner = new FlxSprite(X + bannerOffset, Y).loadGraphic(getBannerGraphic(searchTitle));
        banner.active = false;

        vinyl = new Vinyl(X + vinylOffset, Y - 45, searchTitle, false, 'plain');
        vinyl.spinning = true;

        var theText:String;
        var subText:String = null;
        if(title.indexOf(" (") >= 0) {
            theText = title.substring(0, title.indexOf(" (")).trim();
            subText = title.substr(title.indexOf(" (")).trim();
        } else
            theText = title;
        
        text1 = new FlxText(X + textOffset, Y + 15, banner.width + 400, theText);
        text1.setFormat(Paths.font('vipnagorgialla.bold.otf'), 54, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
        text1.borderSize = 3;
        if(text1.text.length > 10) {
            text1.scale.set(0.5, 1);
            text1.updateHitbox();
            text1Offset = 75;
        }
        text1.x += text1Offset;

        if(subText != null) {
            text2 = new FlxText(X + textOffset, Y + 60, banner.width, subText);
            text2.setFormat(Paths.font('vipnagorgialla.bold.otf'), 30, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
            text2.borderSize = 2;
        }

        text3 = new FlxText(X + textOffset, Y + 125, banner.width, 'Music: ${musician}\nChart: ${charter}');
        text3.setFormat(Paths.font('vipnagorgialla.regular.otf'), 27, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);

        add(banner);
        add(text1);
        if(text2 != null) add(text2);
        add(text3);
        add(vinyl);
    }

    function getBannerGraphic(songTitle:String):flixel.graphics.FlxGraphic
    {
        var theText:String = '';
		switch(songTitle)
		{
			case 'dami-nate' | 'bussin' | 'affliction': theText = 'dami';
			case 'backstreets': theText = 'minus';
			case 'improbable-outset-dami-mix': theText = 'tricky';
			case _: theText = songTitle;
		}

		return Paths.image('songbanners/' + theText);
    }

    function set_X(newX:Float):Float
    {
        banner.x = newX + bannerOffset;
        vinyl.x = newX + vinylOffset;
        text1.x = newX + textOffset + text1Offset;
        if(text2 != null) text2.x = newX + textOffset;
        text3.x = newX + textOffset;

        return newX;
    }
}