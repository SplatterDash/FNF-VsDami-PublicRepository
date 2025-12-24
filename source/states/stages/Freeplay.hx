package states.stages;

import objects.Character;

class Freeplay extends BaseStage
{
	var bg:BGSprite;
	var changedBG:Bool = false;
	var bgChars:BGSprite = null;
	var frontChars:BGSprite = null;

	var overlay:FlxSprite = null;
	var bfFrame:FlxSprite = null;
	var damiFrame:FlxSprite = null;
	var pico:Character = null;
	var belched:Bool = false;
	var specialMove:Bool = false;

	final daSong:String = Paths.formatToSongPath(PlayState.SONG.song);
	override function create()
	{
		switch (daSong) {
			case 'dami-nate-erect-remix':
				bg = new BGSprite("ERECT/bg", -560, -660, 1, 1);
				bg.scale.set(1.55, 1.55);
				bg.updateHitbox();
				bg.active = false;
				add(bg);

				final lights:BGSprite = new BGSprite("ERECT/lights", -560, -660, 1, 1);
				lights.scale.set(1.55, 1.55);
				lights.updateHitbox();
				lights.active = false;
				add(lights);

				if(!ClientPrefs.data.lowQuality) {
					bgChars = new BGSprite("ERECT/bgchars", -525, 150, 1, 1, ["- 1sprites/back chars"], false, "erect bg chars");
					bgChars.scale.set(1.5, 1.5);
					bgChars.updateHitbox();
					add(bgChars);
					bgChars.antialiasing = ClientPrefs.data.antialiasing;
				}

				defaultCamZoom = currentCamZoom = 0.65;
				PlayState.instance.songTimeOffset = 72793;
		}
	}
	override function createPost()
	{
		switch (daSong) {
			case 'dami-nate-erect-remix':
				gfGroup.x += 25;
				gfGroup.y += 50;

				pico = new Character(gfGroup.x - 200, gfGroup.y + gf.y - 1200, 'erectpico');
				addBehindGF(pico);

				if(!ClientPrefs.data.lowQuality) {
					frontChars = new BGSprite("ERECT/bgchars", -550, 550, 1, 1, ["- 1sprites/front chars"], false, "erect bg chars");
					frontChars.scale.set(1.5, 1.5);
					frontChars.updateHitbox();
					add(frontChars);
					frontChars.antialiasing = ClientPrefs.data.antialiasing;
				}

				dadGroup.x -= 100;
				dadGroup.y += 125;
				boyfriendGroup.x += 100;
				boyfriendGroup.y += 125;
				dad.danceEveryNumBeats = 1;
				boyfriend.danceEveryNumBeats = 1;
				pico.danceEveryNumBeats = 1;
		}
	}

	override function update(elapsed:Float) {
		if(bg != null && camFollow.x != (bg.x + (bg.width / 2)) && specialMove) {
			camFollow.setPosition(bg.x + (bg.width / 2), bg.y + (bg.height / 2));
			camGame.snapToTarget();
			PlayState.instance.isCameraOnForcedPos = true;
		}
	}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
	{
		switch(eventName)
		{
			case "Erect BG": FlxTween.tween(bg, { alpha: (value1.toLowerCase() == 'reverse' ? 1 : 0.3) }, 0.1);

			case "Pico Anims":
				if(value1 == 'fall') FlxTween.tween(pico, {y: pico.y + 710 }, 0.17, {onStart: function(twn:FlxTween) {
					pico.playAnim(value1, true);
				}})
				else if(value1 == 'belch') {
					belched = true;
					pico.playAnim(value1, true);
				}

			case "Fake-Out":
				FlxTween.tween(frontChars, { y: 650 }, 2, { ease: FlxEase.quadInOut });
				FlxTween.num(PlayState.instance.songTimeOffset, 0, 2, { ease: FlxEase.expoOut }, function(num:Float) {
					@:privateAccess
					PlayState.instance.songLength = FlxG.sound.music.length - num;
				});

			case "Toggle Special Move":
				specialMove = !specialMove;
				if(!specialMove) {
					PlayState.instance.isCameraOnForcedPos = false;
				}

			case "Erect Dialogue":
				FlxTween.tween(overlay, {alpha: 0.8}, (Conductor.crochet / 1000) * 5, {onComplete: function(twn:FlxTween) {
					damiFrame.reset(-677, 20);
					damiFrame.animation.play("angery", true);
					FlxTween.tween(damiFrame, { x: 20 }, (Conductor.crochet / 1000) * 3, {ease: FlxEase.quintOut});
					new FlxTimer().start((Conductor.stepCrochet / 1000) * 23, function(tmr:FlxTimer) {
						damiFrame.animation.pause();
						damiFrame.animation.curAnim.curFrame = 1;
						new FlxTimer().start((Conductor.stepCrochet / 1000) * 5, function(tmr:FlxTimer) {
							damiFrame.animation.play("mad", true);
							new FlxTimer().start((Conductor.stepCrochet / 1000) * 6, function(tmr:FlxTimer) {
								damiFrame.animation.pause();
								damiFrame.animation.curAnim.curFrame = 1;
								new FlxTimer().start((Conductor.stepCrochet / 1000) * 2, function(tmr:FlxTimer) {
									damiFrame.animation.play("brug", true);
									bfFrame.reset(1280, 20);
									FlxTween.tween(bfFrame, { x: 541 }, (Conductor.crochet / 1000) * 3, {ease: FlxEase.quintOut});
									new FlxTimer().start((Conductor.crochet / 1000) * 4, function(tmr:FlxTimer) {
										FlxTween.tween(damiFrame, { x: -677 }, (Conductor.crochet / 1000) * 1, {ease: FlxEase.quintIn});
										new FlxTimer().start((Conductor.crochet / 1000) * 3, function(tmr:FlxTimer) {
											damiFrame.animation.play("trans-freeze", true);
											FlxTween.tween(damiFrame, { x: 278 }, (Conductor.crochet / 1000) * 2, {ease: FlxEase.quintOut});
											FlxTween.tween(bfFrame, { x: 1280 }, (Conductor.crochet / 1000) * 2, {ease: FlxEase.quintOut});
											new FlxTimer().start((Conductor.stepCrochet / 1000) * 10, function(tmr:FlxTimer) {
												bfFrame.kill();
												damiFrame.animation.play("transform", true);
												new FlxTimer().start((Conductor.stepCrochet / 1000) * 5, function(tmr:FlxTimer) {
													FlxTween.tween(damiFrame, { x: -664 }, (Conductor.crochet / 1000) * 1, {ease: FlxEase.quintIn, onComplete: function(twn:FlxTween) {
														overlay.alpha = 0;
														damiFrame.kill();
													}});
												});
											});
										});
									});
								});
							});
						});
					});
				}});
		}
	}
	override function eventPushed(event:objects.Note.EventNote)
	{
		// used for preloading assets used on events
		switch(event.event)
		{			
			case "Erect Dialogue":
				insert(members.indexOf(PlayState.instance.comboGroup), overlay = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));
				overlay.active = false;
				overlay.alpha = 0;
				overlay.cameras = [PlayState.instance.camHUD];

				damiFrame = new FlxSprite();
				damiFrame.frames = Paths.getSparrowAtlas('ERECT/dami-erectdialogue');
				damiFrame.animation.addByPrefix('angery', 'angry initial', 5, true);
				damiFrame.animation.addByPrefix('mad', 'angry second', 5, true);
				damiFrame.animation.addByPrefix('brug', 'brug', 1, false);
				damiFrame.animation.addByPrefix('trans-freeze', 'transform still', 1, false);
				damiFrame.animation.addByPrefix('transform', 'transform full', 7, false);
				insert(members.indexOf(PlayState.instance.noteGroup), damiFrame);
				damiFrame.cameras = [PlayState.instance.camHUD];

				bfFrame = new FlxSprite();
				bfFrame.frames = Paths.getSparrowAtlas('ERECT/bf-erectdialogue');
				bfFrame.animation.addByPrefix('mock', 'mock-loop', 5);
				bfFrame.animation.addByPrefix('miss', 'mock-miss', 1, false);
				insert(members.indexOf(PlayState.instance.noteGroup), bfFrame);
				bfFrame.cameras = [PlayState.instance.camHUD];

				damiFrame.kill();
				bfFrame.kill();
		}
	}

	override function beatHit()
	{
		if(pico != null && (pico.holdTimer > Conductor.stepCrochet * (0.0011 #if FLX_PITCH / FlxG.sound.music.pitch #end) * pico.singDuration) && (curBeat % pico.danceEveryNumBeats == 0) && !pico.getAnimationName().startsWith('sing') && !belched)
			pico.dance();
		if(bgChars != null) bgChars.dance(true);
		if(frontChars != null) frontChars.dance(true);
	}

	override function noteMiss(note:objects.Note)
	{
		if(bfFrame != null && bfFrame.alive) bfFrame.animation.play('miss', true);
	}

	override function goodNoteHit(note:objects.Note)
	{
		if(bfFrame != null && bfFrame.alive && (bfFrame.animation.curAnim == null || bfFrame.animation.curAnim.name != ''))
			bfFrame.animation.play('mock');
	}
}