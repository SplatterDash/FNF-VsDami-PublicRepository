package states.stages;

import tjson.TJSON.FancyStyle;

class DamiverseOne extends BaseStage
{
	// General
	var bg:BGSprite;
	final daSong:String = Paths.formatToSongPath(PlayState.SONG.song);

	//Entitled
	var daBobm:FlxSprite;
	var shunkAnim:BGSprite;
	var shunkSky:BGSprite;
	var bgSprite:BGSprite = null;
	var fgSprite:BGSprite = null;
	var cloud:BGSprite;
	var cloudArray:Array<String> = [];
	var coverCloud:BGSprite;

	override function create()
	{
		switch (daSong.toLowerCase()) {
			case 'entitled':
				final addPath:String = 'Shunk/';

				// his name is "shruckly"

				bg = new BGSprite(addPath + 'ground', -260, -250);
				bg.setGraphicSize(Std.int(bg.width * 1.35));
				bg.updateHitbox();
				bg.active = false;
				add(bg);

				FlxG.camera.setScrollBounds(bg.x, bg.x + bg.width, bg.y, bg.y + bg.height);

				if(!ClientPrefs.data.lowQuality) {
					shunkAnim = new BGSprite(addPath + 'shunkly-speen', 2600, 0, 1, 1, ['speen idle'], true);
					shunkAnim.scale.set(0.6, 0.6);
					shunkAnim.updateHitbox();
					add(shunkAnim);
					FlxTween.tween(shunkAnim, { x: -600 }, 2, { loopDelay: 9, type: LOOPING });

					shunkSky = new BGSprite(addPath + 'shunkly-aerliens', 2600, 0, 1, 1, ['airline idle'], true);
					add(shunkSky);
					FlxTween.tween(shunkSky, { x: -600 }, 4, { loopDelay: 13, type: LOOPING });
					shunkSky.kill();

					bgSprite = new BGSprite(addPath + '2025_shunkly_bkgrnd', -135, -25, 1, 1, ['2_back_crowd']);
					bgSprite.animation.addByIndices("danceLeft", '2_back_crowd', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
					bgSprite.animation.addByIndices("danceRight", '2_back_crowd', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
					@:privateAccess {
						bgSprite.idleAnim = 'dance';
						bgSprite.directionalDance = true;
					}
					add(bgSprite);

					cloud = new BGSprite(addPath + 'cloud-reel', -50, (830 * -3) - 35, 0, 1);
					cloud.x = (bg.width / 2) - (cloud.width / 2) - 500;
					cloud.active = false;
					add(cloud);
					cloud.kill();
				}

				camGame.bgColor = FlxColor.WHITE;
			case 'improbable-outset-dami-mix':
				final addPath:String = 'Nevada/';

				bg = new BGSprite(addPath + 'bg', -250, -80, 1, 1);
				bg.active = false;
				add(bg);

				if(!ClientPrefs.data.lowQuality) {
					var rock1:BGSprite = new BGSprite(addPath + 'rocks/rock1', -95, 211, 1, 1);
					add(rock1);
					FlxTween.tween(rock1, { x: -105, y: 191 }, 1.3, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //-10, -20

					var rock2:BGSprite = new BGSprite(addPath + 'rocks/rock2', 170, 954, 1, 1);
					add(rock2);
					FlxTween.tween(rock2, { x: 130 }, 1.5, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //-40

					var rock3:BGSprite = new BGSprite(addPath + 'rocks/rock3', 505, 296, 1, 1);
					add(rock3);
					FlxTween.tween(rock3, { x: 495, y: 321 }, 1.8, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //-10, 25

					var rock4:BGSprite = new BGSprite(addPath + 'rocks/rock4', 2802, 36, 1, 1);
					add(rock4);
					FlxTween.tween(rock4, { x: 2787, y: 61 }, 1, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //-15, 25

					var rock5:BGSprite = new BGSprite(addPath + 'rocks/rock5', 2003, 230, 1, 1);
					add(rock5);
					FlxTween.tween(rock5, { x: 2013, y: 200 }, 3, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //10, -30

					var rock6:BGSprite = new BGSprite(addPath + 'rocks/rock6', 1027, 206, 1, 1);
					add(rock6);
					FlxTween.tween(rock6, { y: 181 }, 2.6, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //0, -25

					var rock7:BGSprite = new BGSprite(addPath + 'rocks/rock7', 769, 612, 1, 1);
					add(rock7);
					FlxTween.tween(rock7, { y: 744 }, 4, { type: PINGPONG, ease: FlxEase.smoothStepInOut }); //0, -25
				}

				var ground:BGSprite = new BGSprite(addPath + 'ground', -250, 997, 1, 1);
				ground.active = false;
				add(ground);
		}
	}
	
	override function createPost()
	{
		switch(daSong) {
			case 'entitled':
				if(!ClientPrefs.data.lowQuality) {
					fgSprite = new BGSprite('Shunk/2025_shunkly_bkgrnd', -300, 400, 1, 1, ['1_front_crowd']);
					add(fgSprite);

					daBobm = new FlxSprite();
					daBobm.frames = Paths.getSparrowAtlas('Shunk/shunkly-bobm');
					daBobm.animation.addByPrefix('bobm', 'bobm idle', 12, false);
					daBobm.screenCenter();
					daBobm.alpha = 0;
					add(daBobm);
					daBobm.cameras = [camHUD];
				}

				coverCloud = new BGSprite('Shunk/clouds/cloud_cover', 0, -950, 0, 1);
				coverCloud.scale.set(1.4, 1.4);
				coverCloud.updateHitbox();
				coverCloud.x = (camHUD.width / 2) - (coverCloud.width / 2);
				add(coverCloud);
				coverCloud.kill();
				coverCloud.cameras = [camHUD];

				boyfriendGroup.x -= 50;
				boyfriendGroup.y -= 200;
				dadGroup.x += 50;
				dadGroup.y -= 200;
				gfGroup.x -= 50;

				PlayState.instance.defaultCamZoom = PlayState.instance.currentCamZoom = 0.7;
				FlxG.camera.zoom = 0.7;
			case 'improbable-outset-dami-mix':
				boyfriendGroup.x += 445;
				boyfriendGroup.y += 350;
				dadGroup.x += 225;
				dadGroup.y += 380;

				gfGroup.visible = false;
				gfGroup.kill();
		}
	}

	// For events
	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "BG Event":
				if(daSong == 'entitled') switch (value1.toLowerCase())
				{
					case 'open':
						camFollow.setPosition(bg.x + (bg.width / 2), bg.y + 50);
						FlxG.camera.snapToTarget();
						FlxG.camera.zoom = 3;
						currentCamZoom = 2;
						PlayState.instance.isCameraOnForcedPos = true;
					case 'open-zoom':
						FlxTween.tween(camFollow, { y: bg.y + (bg.height / 2) }, Conductor.crochet * 0.02, { ease: FlxEase.cubeInOut });
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, Conductor.crochet * 0.02, {ease: FlxEase.cubeInOut, onComplete: function(twn:FlxTween) {
							currentCamZoom = defaultCamZoom;
							PlayState.instance.isCameraOnForcedPos = false;
						}});
					case 'zoom':
						bg.alpha = 0;
						bg.loadGraphic(Paths.image('Shunk/sky-pillars'));
						daBobm.kill();
						camHUD.flash(FlxColor.WHITE, 2);
						shunkAnim.kill();
						bgSprite.kill();
						fgSprite.kill();

						boyfriend.color = FlxColor.BLACK;
						dad.color = FlxColor.BLACK;
						gf.color = FlxColor.fromRGB(3, 3, 3);

						if(!ClientPrefs.data.lowQuality) {
							cloud.revive();
							FlxTween.tween(cloud, {y: 0}, 15, {type: LOOPING});
						}
					case _:
						coverCloud.revive();
						FlxTween.tween(coverCloud, { y: -50 }, (Conductor.stepCrochet / 1000) * 2, { onComplete: function(twn:FlxTween) {
							bg.alpha = 1;
							shunkSky.revive();
							if(!ClientPrefs.data.lowQuality) {
								FlxTween.cancelTweensOf(cloud);
								cloud.kill();
							}

							boyfriend.color = FlxColor.WHITE;
							gf.color = FlxColor.WHITE;
							dad.color = FlxColor.WHITE;
							FlxTween.tween(coverCloud, { y: 1050 }, (Conductor.stepCrochet / 1000) * 2, { onComplete: function(twn:FlxTween) {
								coverCloud.kill();
							}});
						}});
				}
			
			case "Shunkly Bobm":
				daBobm.alpha = 1;
				daBobm.animation.play('bobm');

			case "Snap To Center": 
				PlayState.instance.isCameraOnForcedPos = !PlayState.instance.isCameraOnForcedPos;
				if(PlayState.instance.isCameraOnForcedPos) camFollow.setPosition(bg.getMidpoint().x + (flValue1 != null ? flValue1 : 0), bg.getMidpoint().y + (flValue2 != null ? flValue2 : 0)) else moveCameraSection();
		}
	}
	override function beatHit()
	{
		if(bgSprite != null) bgSprite.dance();
		if(fgSprite != null) fgSprite.dance();
	}
	
}