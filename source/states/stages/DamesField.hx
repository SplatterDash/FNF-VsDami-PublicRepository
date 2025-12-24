package states.stages;

class DamesField extends BaseStage
{
	var charsBack:FlxTypedSpriteGroup<BGSprite>;
	var charsFront:FlxTypedSpriteGroup<BGSprite>;
	override function create()
	{
		var bg:BGSprite = new BGSprite('field', -1250, -975, 1, 1);
		bg.active = false;
		add(bg);

		if (!ClientPrefs.data.lowQuality)
		{
			charsBack = new FlxTypedSpriteGroup<BGSprite>();
			add(charsBack);

			var char47:BGSprite = new BGSprite('chars', -700, -450, 1, 1, ['-1minus bg chars sprites/back chars']);
			char47.scale.set(1.25, 1.25);
			char47.updateHitbox();
			charsBack.add(char47);
			char47.antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function createPost()
	{
		var bush:BGSprite = new BGSprite('bush', -1250, 344, 1, 1);
		bush.active = false;
		add(bush);

		if (!ClientPrefs.data.lowQuality)
		{
			charsFront = new FlxTypedSpriteGroup<BGSprite>();
			add(charsFront);

			var char47:BGSprite = new BGSprite('chars', -625, 500, 1, 1, ['-1minus bg chars sprites/front chars'], false, "minus bg chars");
			char47.scale.set(1.1, 1.1);
			char47.updateHitbox();
			charsFront.add(char47);
			char47.antialiasing = ClientPrefs.data.antialiasing;
		}
	}

	override function beatHit()
		{
			if(charsBack != null) for(char in charsBack.members) char.dance(true);
			if(charsFront != null) for(char in charsFront.members) char.dance(true);
		}
}