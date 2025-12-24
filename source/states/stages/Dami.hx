package states.stages;

import cutscenes.DialogueBoxPsych;
import objects.Character;

class Dami extends BaseStage
{
	var bg:BGSprite;
	var bgCharsBack:FlxTypedSpriteGroup<BGSprite>;
	var bgCharsFront:FlxTypedSpriteGroup<BGSprite>;
	var aidan:Character = null;
	var specialMove:Bool = false;

	var theChars:Map<String, Array<String>> = [
		'dami-nate' => ['3272023_vs_dami_background_character_animations', 'back_croud', 'front_croud', "-500", "200", "-400", "500"],
		'bussin' => ['bussinchars', '-1bussin sprites/back chars', '-1bussin sprites/front chars', "-390", "125", "-650", "625", 'bussin bg chars'],
		'affliction' => ['afflictionchars', '-1sprites/back chars', '-1sprites/front chars', "-600", "100", "-500", "600", "affliction bg chars"] 
	];

	final path:String = 'Dami/';
	final daSong:String = Paths.formatToSongPath(PlayState.SONG.song);
	override function create()
	{
		bg = new BGSprite(path + "bgfull", -550, -500, 1, 1);
		bg.active = false;
		add(bg);

		FlxG.camera.setScrollBounds(bg.x, bg.x + bg.width, bg.y, bg.y + bg.height);

		if(!ClientPrefs.data.lowQuality) {
			bgCharsBack = new FlxTypedSpriteGroup<BGSprite>();
			add(bgCharsBack);

			if(daSong != 'dami-nate') {
				var chars:BGSprite = new BGSprite(path + theChars.get(daSong)[0], Std.parseInt(theChars.get(daSong)[3]), Std.parseInt(theChars.get(daSong)[4]), 1, 1, [theChars.get(daSong)[1]], false, theChars.get(daSong)[7]);
				chars.scale.set(daSong == 'bussin' ? 0.57 : 0.85, daSong == 'bussin' ? 0.57 : 0.85);
				chars.updateHitbox();
				bgCharsBack.add(chars);
				chars.antialiasing = ClientPrefs.data.antialiasing;
			} else {
				var chars:BGSprite = new BGSprite(path + theChars.get(daSong)[0], Std.parseInt(theChars.get(daSong)[3]), Std.parseInt(theChars.get(daSong)[4]), 1, 1, [], false);
				chars.animation.addByPrefix("danceLeft", theChars.get(daSong)[1] + "_left", 24, false);
				chars.animation.addByPrefix("danceRight", theChars.get(daSong)[1] + "_right", 24, false);
				@:privateAccess {
					chars.idleAnim = 'dance';
					chars.directionalDance = true;
				}
				chars.setGraphicSize(Std.int(chars.width * 1.3));
				chars.updateHitbox();
				bgCharsBack.add(chars);
				chars.antialiasing = ClientPrefs.data.antialiasing;
				chars.animation.play('danceLeft', true);
			}
		}
	}
	override function createPost()
	{
		if(!ClientPrefs.data.lowQuality) {
			bgCharsFront = new FlxTypedSpriteGroup<BGSprite>();
			add(bgCharsFront);
			var chars2:BGSprite = new BGSprite(path + theChars.get(daSong)[0], Std.parseInt(theChars.get(daSong)[5]), Std.parseInt(theChars.get(daSong)[6]), 1, 1, [theChars.get(daSong)[2]], false, daSong != 'dami-nate' ? theChars.get(daSong)[7] : null);
			if(daSong != 'dami-nate') {
				chars2.scale.set(daSong == 'bussin' ? 0.65 : 0.8, daSong == 'bussin' ? 0.65 : 0.8);
				chars2.updateHitbox();
			} else {
				chars2.setGraphicSize(Std.int(chars2.width * 1.2));
				chars2.updateHitbox();
			}
			bgCharsFront.add(chars2);
			chars2.antialiasing = ClientPrefs.data.antialiasing;
		}

		aidan = new Character(gfGroup.x - 850, gfGroup.y + gf.y - 100, 'aidan');
		aidan.forceIdle = true;
		aidan.flipX = false;
		addBehindGF(aidan);
		aidan.playAnim(daSong == 'affliction' ? 'affliction' : 'idle');

		if(isStoryMode && !seenCutscene) PlayState.instance.startCallback = cutsceneHandler;

		if(daSong == 'affliction')
			gf.idleSuffix = '-sc';
	}

	override function update(elapsed:Float) {
		if(camFollow.x != (bg.x + (bg.width / 2)) && !specialMove) {
			camFollow.setPosition(bg.x + (bg.width / 2), bg.y + (bg.height / 2));
			camGame.snapToTarget();
			PlayState.instance.isCameraOnForcedPos = true;
		}
	}

	function cutsceneHandler() {
		if(daSong == 'bussin' || daSong == 'affliction') {
			var file:String = Paths.json('$daSong/dialogue');
			if(daSong == 'affliction') camGame.alpha = 0;

			#if MODS_ALLOWED
			if (!FileSystem.exists(file))
			#else
			if (!OpenFlAssets.exists(file))
			#end
			{
				startCountdown();
				return;
			}

			PlayState.instance.startDialogue(DialogueBoxPsych.parseDialogue(Paths.json('$songName/dialogue')));
		} else {
			var file:String = Paths.video('cutscenes/$daSong');
			#if MODS_ALLOWED
			if (!FileSystem.exists(file))
			#else
			if (!OpenFlAssets.exists(file))
			#end
			{
				trace('File not found: ${file}');
				startCountdown();
				return;
			}

			PlayState.instance.startVideo('cutscenes/$daSong');
		}
	}

	override function eventPushed(event:objects.Note.EventNote)
		{
			// used for preloading assets used on events
			switch(event.event)
			{
				case "DamiNate Intro":
					FlxG.camera.zoom = 1.6;
					PlayState.instance.isCameraOnForcedPos = true;
					specialMove = true;
					camFollow.setPosition(bg.getMidpoint().x + 450, bg.getMidpoint().y - 30);
					camGame.snapToTarget();
			}
		}

	override function eventCalled(eventName:String, value1:String, value2:String, flValue1:Null<Float>, flValue2:Null<Float>, strumTime:Float)
		{
			switch(eventName)
			{
				case "Erect BG": FlxTween.tween(bg, { alpha: (value1.toLowerCase() == 'reverse' ? 1 : 0.3) }, 0.1);
				case "DamiNate Intro":
					if(value1.toLowerCase() == 'final') {
						PlayState.instance.currentCamZoom = 0.8;
						PlayState.instance.isCameraOnForcedPos = false;
					} else if(value1.toLowerCase() == 'end') {
						specialMove = false;
						PlayState.instance.currentCamZoom = PlayState.instance.defaultCamZoom;
					} else {
						FlxG.camera.zoom = 1.6;
						PlayState.instance.cameraTwn = FlxTween.tween(camFollow, { x: dad.getMidpoint().x + dad.cameraPosition[0] + PlayState.instance.opponentCameraOffset[0], y: dad.getMidpoint().y - 100 + dad.cameraPosition[1] + PlayState.instance.opponentCameraOffset[1] }, (Conductor.stepCrochet * 40) / 1000, { ease: FlxEase.quadInOut, onStart: function(twn:FlxTween) {
							PlayState.instance.currentCamZoom = 1;
							FlxTween.tween(FlxG.camera, { zoom: 1 }, (Conductor.stepCrochet * 40) / 1000, { ease: FlxEase.quadInOut, onStart: function(twn:FlxTween) {
								FlxG.camera.fade(FlxColor.BLACK, 1.5, true);
							} });
						}, onComplete:
							function (twn:FlxTween)
							{
								PlayState.instance.cameraTwn = null;
							}
						});
					}

				case "Snap To Center": 
					PlayState.instance.isCameraOnForcedPos = !PlayState.instance.isCameraOnForcedPos;
					if(PlayState.instance.isCameraOnForcedPos) camFollow.setPosition(bg.getMidpoint().x + (flValue1 != null ? flValue1 : 0), bg.getMidpoint().y + (flValue2 != null ? flValue2 : 0)) else moveCameraSection();

				case "Aidan Anims":
					if(value1 == 'speen') 
						aidan.forceIdle = false;
					aidan.playAnim(value1, true);

				case "Toggle Special Move":
					specialMove = !specialMove;
					if(specialMove) {
						PlayState.instance.isCameraOnForcedPos = false;
					}
				
			}
		}

	override function beatHit()
	{
		if(bgCharsBack != null) for(char in bgCharsBack.members) char.dance(true);
		if(bgCharsFront != null) for(char in bgCharsFront.members) char.dance(true);
		if(aidan != null && (curBeat % aidan.danceEveryNumBeats == 0) && !aidan.getAnimationName().startsWith('speen'))
			if(daSong == 'affliction') aidan.playAnim('affliction', true) else aidan.dance();
	}
}