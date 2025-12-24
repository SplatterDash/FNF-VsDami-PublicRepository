package states.stages;

class DirectorPark extends BaseStage
{
	override function create()
	{
		addSprite('stagebg', -1200, -600, 0.1, 1);

		if(!ClientPrefs.data.lowQuality)
			addSprite('frontbg', -1200, -600, 0.3, 1);

		addSprite('midtrees', -1200, -17, 0.8, 1); //original: -1200, -600
		addSprite('stageground', -1200, -600);
	}
	
	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality)
			addSprite('fgbushes', -1200, 492); //original: -1200, -600 1092
	}

	function addSprite(name:String, x:Float = -1200, y:Float = -600, xScroll:Float = 1, yScroll:Float = 1)
	{
		var sprite:BGSprite = new BGSprite(name, x, y, xScroll, yScroll);
		sprite.active = false;
		add(sprite);
	}
}