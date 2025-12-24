package objects;

import openfl.utils.Assets;
import flixel.util.FlxDestroyUtil;

class BGSprite extends FlxSprite
{
	private var idleAnim:String;
	public var isAnimateAtlas:Bool = false;
	private var directionalDance:Bool = false;
	public function new(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?animArray:Array<String> = null, ?loop:Bool = false, ?atlasName:String = null) {
		super(x, y);

		if (animArray != null) {
			#if flxanimate
			var animToFind:String = Paths.getPath('images/' + image + '/Animation.json', TEXT);
			if (#if MODS_ALLOWED FileSystem.exists(animToFind) || #end Assets.exists(animToFind)) {
				atlas = new FlxAnimate();
				atlas.showPivot = false;
				try
				{
					Paths.loadAnimateAtlas(atlas, image);
				}
				catch(e:Dynamic)
				{
					FlxG.log.warn('Could not load atlas ${image}: $e');
				}
				for(i in 0...animArray.length) {
					var anim:String = animArray[i];
					atlas.anim.addBySymbol(atlasName, anim, 24, loop);
					if(idleAnim == null) {
						//trace('Idle animation: ${anim}');
						idleAnim = anim;
						atlas.anim.play(anim);
					}
				}
				isAnimateAtlas = true;
				copyAtlasValues();
			} else {
				#end
				frames = Paths.getSparrowAtlas(image);
				for (i in 0...animArray.length) {
					var anim:String = animArray[i];
					animation.addByPrefix(anim, anim, 24, loop);
					if(idleAnim == null) {
						idleAnim = anim;
						animation.play(anim);
					}
				}
			#if flxanimate
			}
			#end
		} else {
			if(image != null) {
				loadGraphic(Paths.image(image));
			}
			active = false;
		}
		scrollFactor.set(scrollX, scrollY);
		antialiasing = ClientPrefs.data.antialiasing;
	}

	private var danced:Bool = false;
	public function dance(?forceplay:Bool = false) {
		if(idleAnim != null) {
			if(directionalDance) {
				if(!isAnimateAtlas) animation.play(idleAnim + (danced ? "Left" : "Right"), forceplay) else {
					atlas.anim.play(idleAnim + (danced ? "Left" : "Right"), forceplay);
				}
				danced = !danced;
			} else {
				if(!isAnimateAtlas) animation.play(idleAnim, forceplay) else atlas.anim.play(idleAnim, forceplay);
			}
		}
	}

	#if flxanimate
	public var atlas:FlxAnimate;
	override function update(elapsed:Float) {
		if(isAnimateAtlas) atlas.update(elapsed);
		super.update(elapsed);
	}

	public override function draw()
	{
		if(isAnimateAtlas)
		{
			copyAtlasValues();
			atlas.draw();
			return;
		}
		super.draw();
	}

	public function copyAtlasValues()
		{
			@:privateAccess
			{
				atlas.cameras = cameras;
				atlas.scrollFactor = scrollFactor;
				atlas.scale = scale;
				atlas.offset = offset;
				atlas.origin = origin;
				atlas.x = x;
				atlas.y = y;
				atlas.angle = angle;
				atlas.alpha = alpha;
				atlas.visible = visible;
				atlas.flipX = flipX;
				atlas.flipY = flipY;
				atlas.shader = shader;
				atlas.antialiasing = antialiasing;
				atlas.colorTransform = colorTransform;
				atlas.color = color;
			}
		}

		public override function destroy()
			{
				super.destroy();
				destroyAtlas();
			}
		
			public function destroyAtlas()
			{
				if (atlas != null)
					atlas = FlxDestroyUtil.destroy(atlas);
			}
		#end
}