package states.stages;

class Bedroom extends BaseStage
{
	var bg:BGSprite;
	var onOpening:Bool = false;
	final daSong:String = Paths.formatToSongPath(PlayState.SONG.song);
	override function create()
	{
		bg = new BGSprite('bg', -950, -252, 1, 1);
		add(bg);

		var bed:BGSprite = new BGSprite('bed', -343, 191, 1, 1); //original: -950, -252
		add(bed);
	}

	override function update(elapsed:Float)
	{
		if(onOpening && PlayState.instance.camFollow.x != bg.getGraphicMidpoint().x) {
			PlayState.instance.camFollow.setPosition(bg.getGraphicMidpoint().x, bg.getGraphicMidpoint().y + 150);
			PlayState.instance.isCameraOnForcedPos = true;
			FlxG.camera.snapToTarget();
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
		{
			switch(event.event)
			{
				case "Opening Tutorial":
					FlxG.camera.zoom = PlayState.instance.currentCamZoom = 2;
					onOpening = true;
			}
		}

		override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
			{
				switch(eventName)
				{
					case "Opening Tutorial":
					PlayState.instance.cameraTwn = FlxTween.tween(FlxG.camera, {zoom: PlayState.instance.defaultCamZoom}, (Conductor.stepCrochet * 63 / 1000), {ease: FlxEase.quadInOut, onComplete:
						function (twn:FlxTween)
						{
							PlayState.instance.isCameraOnForcedPos = false;
							PlayState.instance.cameraTwn = null;
							onOpening = false;
						}
					});
					FlxG.camera.fade(FlxColor.BLACK, Conductor.stepCrochet * 63 / 1000, true);

					case "Tutorial Zoom":
						@:privateAccess
						PlayState.instance.keepTutZoomedIn = !PlayState.instance.keepTutZoomedIn;

					case "Snap To Center": 
						PlayState.instance.isCameraOnForcedPos = !PlayState.instance.isCameraOnForcedPos;
						if(PlayState.instance.isCameraOnForcedPos) camFollow.setPosition(bg.getMidpoint().x + (flValue1 != null ? flValue1 : 0), bg.getMidpoint().y + (flValue2 != null ? flValue2 : 0)) else moveCameraSection();
				}
			}
}