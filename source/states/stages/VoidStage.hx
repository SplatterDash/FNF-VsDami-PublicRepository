package states.stages;

import backend.Highscore;
import cutscenes.DialogueBox;
import flixel.FlxBasic;
import flixel.addons.effects.FlxTrail;
import flixel.graphics.FlxGraphic;
import objects.Character;
import states.stages.objects.*;
import substates.GameOverSubstate;

class VoidStage extends BaseStage
{
	var bg:BGSprite;
	var changedBG:Bool = false;
	var graphic:FlxGraphic;
	var aidan:Character;
	var warning:FlxSprite = null;

	var falling:FlxSprite = null;
	var rock:BGSprite = null;

	final thePath:String = "Void/";
	final daSong:String = Paths.formatToSongPath(PlayState.SONG.song);
	override function create()
	{
		switch (daSong) {
			case 'domination':
				bg = new BGSprite(thePath + "domination", -800, -400, 1, 1);
				bg.setGraphicSize(Std.int(bg.width * 2));
				bg.updateHitbox();
				bg.active = false;
				add(bg);
			case 'reawaken':
				bg = new BGSprite(thePath + "Reawaken/void", -300, -150, 1, 1);
				bg.setGraphicSize(Std.int(bg.width * 1.5));
				bg.updateHitbox();
				bg.active = false;
				bg.scrollFactor.set(0.1, 0.1);
				add(bg);

				rock = new BGSprite(thePath + "Reawaken/dwayne", 1250, 625, 1, 1);
				rock.active = false;
				add(rock);
		}
	}
	override function createPost()
	{
		switch (daSong) {
			case 'domination':
				gfGroup.y += 625;
				game.gf.flipX = false;
				gfGroup.kill();

				aidan = new Character(gfGroup.x - 300, gfGroup.y + gf.y - 725, 'aidan');
				aidan.forceIdle = true;
				aidan.flipX = false;
				addBehindDad(aidan);
				aidan.playAnim('domination', true);
				aidan.alpha = 0.0000001;

				aidan.kill();
			case 'reawaken':
				gfGroup.x += 200;
				boyfriendGroup.y -= 25;
				gf.scrollFactor.set(1, 1);

				aidan = new Character(gfGroup.x - 50, gfGroup.y + gf.y - 425, 'aidan');
				aidan.forceIdle = true;
				aidan.flipX = false;
				addBehindGF(aidan);
				aidan.playAnim('fight', true);
				aidan.danceEveryNumBeats = 2;

				if(!ClientPrefs.data.lowQuality) {
					falling = new FlxSprite(0, 0);
					falling.frames = Paths.getSparrowAtlas('Void/Reawaken/falling');
					falling.animation.addByPrefix("idle", "falling idle", 24, true);
					addInFrontOfBF(falling);
					falling.cameras = [camHUD];
				}

				final bfOffset:Array<Float> = game.boyfriendCameraOffset;
				game.boyfriendCameraOffset = [bfOffset[0], bfOffset[1] + 75];
				gf.idleSuffix = '-fall';
				gf.dance();

				if(falling != null) falling.animation.play('idle');
		}

		if(isStoryMode) {
			if (!seenCutscene)
				game.startCallback = videoHandler;
			if (daSong == 'reawaken')
				game.endCallback = endVideoHandler;
		}
	}

	function videoHandler() {
		var file:String = Paths.video('cutscenes/$daSong');
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			if (daSong == 'domination' && Highscore.getScore('domination') == 0) game.openSubState(new substates.GimmickSubState(() -> {startCountdown();})) else startCountdown();
			return;
		}

		game.startVideo('cutscenes/$daSong');
		if(daSong == 'domination' && Highscore.getScore('domination') == 0) {
			function onEndVideo()
			{
				game.openSubState(new substates.GimmickSubState(() ->
				{
					game.videoCutscene = null;
					trace('bruhg');
					game.inCutscene = false;
					game.canPause = true;
					moveCameraSection();
					FlxG.camera.snapToTarget();
					startCountdown();
				}));
			}
			game.videoCutscene.finishCallback = onEndVideo;
			game.videoCutscene.onSkip = onEndVideo;
		}
	}

	function endVideoHandler()
	{
		game.endingSong = true;
		var file:String = Paths.video('cutscenes/${daSong}-post');
		#if MODS_ALLOWED
		if (!FileSystem.exists(file))
		#else
		if (!OpenFlAssets.exists(file))
		#end
		{
			@:privateAccess
			game.startAndEnd();
			return;
		}

		game.startVideo('cutscenes/${daSong}-post');
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Health Stop":
				game.stopHealthGain = !game.stopHealthGain;
			case "BG Event":
				if(daSong == 'domination')
				{
					if(value1.toLowerCase() == "thefullthing") {
						new FlxTimer().start(Conductor.crochet / 8000, function(tmr:FlxTimer) {
							if(tmr.elapsedLoops == 9) {
								defaultCamZoom = currentCamZoom = 0.5;
								game.isCameraOnForcedPos = false;
								moveCameraSection();
								for(member in PlayState.instance.opponentStrums.members) member.alpha = 1;
								game.iconP2.visible = true;
								bg.alpha = 1;
								boyfriendGroup.alpha = 1;
								aidan.alpha = 1;
								boyfriendGroup.x += 230;
								boyfriendGroup.y += 900;
								gfGroup.revive();
								boyfriend.cameraPosition = [boyfriend.cameraPosition[0] + 380, boyfriend.cameraPosition[1] - 250];
								dad.cameraPosition = [dad.cameraPosition[0] + 200, dad.cameraPosition[1]];
								FlxTween.tween(dad, { y: 50 }, 1.4, { ease: FlxEase.cubeInOut, type:PINGPONG });
								if (ClientPrefs.data.flashing) FlxG.camera.flash(FlxColor.WHITE, 4);
							} else
								if(ClientPrefs.data.flashing) dad.alpha = FlxMath.isEven(tmr.elapsedLoops) ? 1 : 0;
						}, 10);
					} else if(value1.toLowerCase() == "domination") {
						game.camHUD.fade(FlxColor.WHITE, Conductor.stepCrochet * 16 / 1000, false, function() {
							#if DISCORD_ALLOWED
							@:privateAccess {
								if(PlayState.isStoryMode) {
									game.detailsText = "Oh this guy fucked up.";
									game.resetRPC();
								}
							}
							#end
							game.isCameraOnForcedPos = true;
							camFollow.setPosition(dad.getGraphicMidpoint().x - 50, dad.getGraphicMidpoint().y + 60);
							game.iconP2.visible = false;
							FlxG.camera.snapToTarget();
							defaultCamZoom = currentCamZoom = 0.5;
							aidan.revive();
							boyfriendGroup.alpha = 0;
							if(warning != null) {
								warning.alpha = 1;
								FlxTween.tween(warning, { alpha: 0 }, 1, {startDelay: 15, onComplete: function(twn:FlxTween) { warning.kill(); }});
							}
							FlxG.camera.shake(0.01, Conductor.crochet * 0.008);
							new FlxTimer().start(Conductor.crochet * 0.016, function(tmr:FlxTimer) {
								FlxG.camera.shake(0.01, Conductor.crochet * 0.008);
							}, 1);
							for(member in PlayState.instance.opponentStrums.members) member.alpha = 0;
							game.camHUD.fade(FlxColor.WHITE, Conductor.stepCrochet * 24 / 1000, true, () -> {}, true);
						}, true);
					}
				}
				else
				{
					if(value1.toLowerCase() == 'reawaken1') {
						bg.loadGraphic(graphic);
						bg.setPosition(-950, -500);
						bg.setGraphicSize(Std.int(bg.width * 2.2));
						bg.updateHitbox();
						changedBG = true;
						dad.alpha = 1;
						if(ClientPrefs.data.flashing) new FlxTimer().start(Conductor.stepCrochet * 0.0005, function(tmr:FlxTimer) {
								FlxG.camera.alpha = camHUD.alpha = (1 - (tmr.elapsedLoops % 2));
						}, 16);
					}
					else if(value1.toLowerCase() == 'reawaken2') {
						FlxG.camera.zoom = 0.45;
						currentCamZoom = 0.45;
						dadGroup.x -= 650;
						FlxG.camera.snapToTarget();
					}
					else if(value1.toLowerCase() == 'reawaken3') {
						aidan.flipX = false;
						game.boyfriend.flipX = false;
						game.boyfriend.x -= 225;
						game.boyfriend.y += 50;
						aidan.x += 300;
						aidan.y -= 125;
					}
				}

			case "Snap To Center": 
				game.isCameraOnForcedPos = !game.isCameraOnForcedPos;
				if (game.isCameraOnForcedPos) camFollow.setPosition(bg.getMidpoint().x + (flValue1 != null ? flValue1 : 0), bg.getMidpoint().y + (flValue2 != null ? flValue2 : 0)) else moveCameraSection();

			case "Reawaken Scenes":
				switch(value1.toLowerCase())
				{
					case "calmer start":
						PlayState.instance.boyfriend.color = FlxColor.BLACK;
						PlayState.instance.gf.color = FlxColor.BLACK;
						aidan.color = FlxColor.BLACK;
						rock.color = FlxColor.BLACK;

						bg.visible = false;
						FlxG.camera.bgColor = FlxColor.WHITE;
						dadGroup.x -= 700;
						dad.alpha = 0.5;
					case "calmer move": FlxTween.tween(dadGroup, { x: dadGroup.x + 900 }, 13, {ease: FlxEase.cubeOut});
					case "calmer end":
						for (item in [game.boyfriend, game.gf, aidan, rock])
							FlxTween.tween(item, {alpha: 0}, Conductor.crochet * 0.003);
					case "finale":
						if (ClientPrefs.data.flashing) FlxG.camera.flash();
						PlayState.instance.boyfriend.color = FlxColor.BLACK;
						PlayState.instance.gf.color = FlxColor.BLACK;
						aidan.color = FlxColor.BLACK;
						rock.color = FlxColor.BLACK;

						aidan.flipX = true;
						PlayState.instance.boyfriend.flipX = true;
						PlayState.instance.boyfriend.x += 225;
						PlayState.instance.boyfriend.y -= 50;
						aidan.x -= 300;
						aidan.y += 125;

						game.dad.alpha = 0;
						FlxTween.tween(PlayState.instance.dad, { alpha: 1 }, 1, { startDelay: 0.6 });
					case "finale transition": FlxTween.tween(PlayState.instance.dad, {alpha: 0}, 1);
					case "reset":
						PlayState.instance.boyfriend.color = FlxColor.WHITE;
						PlayState.instance.gf.color = FlxColor.WHITE;
						aidan.color = FlxColor.WHITE;
						rock.color = FlxColor.WHITE;

						PlayState.instance.boyfriend.alpha = 1;
						PlayState.instance.gf.alpha = 1;
						aidan.alpha = 1;
						rock.alpha = 1;

						FlxG.camera.bgColor = FlxColor.BLACK;
						bg.visible = true;
						dad.alpha = 1;
				}

		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events
		switch(event.event)
		{
			case "BG Event":
				if(event.value1.toLowerCase() == "domination" && daSong == 'domination')
					bg.alpha = 0
				else if (event.value1.toLowerCase() == "reawaken1" && Paths.formatToSongPath(PlayState.SONG.song) == 'reawaken')
					graphic = Paths.image('Void/Reawaken/earth-cloud');
		}
	}

	override function update(elapsed:Float) {
		if(Paths.formatToSongPath(PlayState.SONG.song) == 'reawaken' && !changedBG) {
			bg.y -= 0.02;
		}
	}

	override function beatHit()
	{
		if(daSong == 'reawaken' && aidan != null && (curBeat % aidan.danceEveryNumBeats == 0) && !aidan.getAnimationName().startsWith('dodge'))
			if(daSong == 'reawaken') aidan.playAnim('fight', true);
	}
}