package states;

import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import objects.VideoSprite;
import shaders.ColorSwap;
import states.MainMenuState;
import states.StoryMenuState;

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Float;
	
	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxTypedGroup<Alphabet> = new FlxTypedGroup<Alphabet>();
	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var ngSpr:FlxSprite;
	
	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		Paths.clearStoredMemory();
		super.create();
		Paths.clearUnusedMemory();

		if(!initialized)
		{
			ClientPrefs.loadPrefs();
			Language.reloadPhrases();
		}

		curWacky = FlxG.random.getObject(getIntroTextShit());

		if(!initialized)
		{
			if(FlxG.save.data != null && FlxG.save.data.fullscreen)
			{
				FlxG.fullscreen = FlxG.save.data.fullscreen;
				//trace('LOADED FULLSCREEN SETTING!!');
			}
			persistentUpdate = true;
			persistentDraw = true;
		}

		if (FlxG.save.data.weekCompleted != null)
		{
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;
		}

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		if(FlxG.save.data.flashing == null && !FlashingState.leftState)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		}
		else
			startIntro();
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxText;
	var swagShader:ColorSwap = null;
	var theTimer:FlxTimer = null;
	var video:VideoSprite = null;

	static var introVideos:Array<String> = ["fall.", "dear all trick-or-treaters,", "you've been hit by", "onwards and upwards"];

	function startIntro()
	{
		persistentUpdate = true;
		if (!initialized && FlxG.sound.music == null) {
			FlxG.sound.playMusic(Paths.music('menu_v1'), 0);
			FlxG.sound.music.loopTime = 8727;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
		}

		loadJsonData();
		#if TITLE_SCREEN_EASTER_EGG easterEggData(); #end
		Conductor.bpm = musicBPM;

		logoBl = new FlxSprite(logoPosition.x, logoPosition.y);
		logoBl.frames = Paths.getSparrowAtlas('menus/title/logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;

		logoBl.animation.addByPrefix('bump', 'logobump', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(gfPosition.x, gfPosition.y);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;
		
		if(ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}
		
		gfDance.frames = Paths.getSparrowAtlas('menus/title/danceTitle');
		gfDance.animation.addByPrefix('idle', 'damiDance', 12, false);

		final bars:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('menus/title/bottom'));

		titleText = new FlxText(enterPosition.x, enterPosition.y, 1280, "PRESS ENTER TO BEGIN");
		titleText.setFormat(Paths.font('upheaval-pro-regular.ttf'), 108, FlxColor.fromString('0xFF33FFFF'), CENTER, OUTLINE, FlxColor.BLACK);
		titleText.borderSize = 3;
		titleText.updateHitbox();
		titleText.screenCenter(X);

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		add(gfDance);
		add(bars);
		add(titleText); //"Press Enter to Begin" text
		add(logoBl); //FNF Logo
		add(credGroup);
		add(ngSpr);

		if (initialized)
			skipIntro();
		else {
			if(introVideos.contains(curWacky[0].toLowerCase())) {
				final hideChars = ~/[.,'()"%?!]/g;
				video = new VideoSprite(Paths.video(hideChars.replace(curWacky[0].toLowerCase(), '')), true);
				video.alpha = 0.0000001;
				video.videoSprite.volumeAdjust = 0;
				add(video);
				video.finishCallback = () -> {
					if(!FlxG.sound.music.playing) {
						FlxG.sound.music.time = Conductor.crochet * 12;
						sickBeats = 12;
						FlxG.sound.music.volume = 1;
						FlxG.sound.music.resume();
					}
					if(video != null) video.destroy();
					video = null;
				}
				@:privateAccess
				if(video.videoSprite.load(video.videoName)) {
					video.videoSprite.volumeAdjust = 0;
					video.alpha = 0;
					video.play();
					video.pause();
					video.videoSprite.bitmap.position = 0;
					video.videoSprite.volumeAdjust = 1;
				}
			}
			initialized = true;
			if(!FlxG.sound.music.playing) FlxG.sound.music.play();
		}

		// credGroup.add(credTextShit);
	}

	// JSON data
	var characterImage:String = 'gfDanceTitle';
	var animationName:String = 'gfDance';

	var gfPosition:FlxPoint = FlxPoint.get(512, 40);
	var logoPosition:FlxPoint = FlxPoint.get(-150, -100);
	var enterPosition:FlxPoint = FlxPoint.get(100, 576);
	
	var useIdle:Bool = false;
	var musicBPM:Float = 102;
	var danceLeftFrames:Array<Int> = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
	var danceRightFrames:Array<Int> = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];

	function loadJsonData()
	{
		if(Paths.fileExists('images/gfDanceTitle.json', TEXT))
		{
			var titleRaw:String = Paths.getTextFromFile('images/gfDanceTitle.json');
			if(titleRaw != null && titleRaw.length > 0)
			{
				try
				{
					var titleJSON:TitleData = tjson.TJSON.parse(titleRaw);
					gfPosition.set(titleJSON.gfx, titleJSON.gfy);
					logoPosition.set(titleJSON.titlex, titleJSON.titley);
					enterPosition.set(titleJSON.startx, titleJSON.starty);
					musicBPM = titleJSON.bpm;
					
					if(titleJSON.animation != null && titleJSON.animation.length > 0) animationName = titleJSON.animation;
					if(titleJSON.dance_left != null && titleJSON.dance_left.length > 0) danceLeftFrames = titleJSON.dance_left;
					if(titleJSON.dance_right != null && titleJSON.dance_right.length > 0) danceRightFrames = titleJSON.dance_right;
					useIdle = (titleJSON.idle == true);
	
					if (titleJSON.backgroundSprite != null && titleJSON.backgroundSprite.trim().length > 0)
					{
						var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(titleJSON.backgroundSprite));
						bg.antialiasing = ClientPrefs.data.antialiasing;
						add(bg);
					}
				}
				catch(e:haxe.Exception)
				{
					trace('[WARN] Title JSON might broken, ignoring issue...\n${e.details()}');
				}
			}
			else trace('[WARN] No Title JSON detected, using default values.');
		}
		//else trace('[WARN] No Title JSON detected, using default values.');
	}

	function easterEggData()
	{
		if (FlxG.save.data.psychDevsEasterEgg == null) FlxG.save.data.psychDevsEasterEgg = ''; //Crash prevention
		var easterEgg:String = FlxG.save.data.psychDevsEasterEgg;
		switch(easterEgg.toUpperCase())
		{
			case 'SHADOW':
				characterImage = 'ShadowBump';
				animationName = 'Shadow Title Bump';
				gfPosition.x += 210;
				gfPosition.y += 40;
				useIdle = true;
			case 'RIVEREN':
				characterImage = 'ZRiverBump';
				animationName = 'River Title Bump';
				gfPosition.x += 180;
				gfPosition.y += 40;
				useIdle = true;
			case 'BBPANZU':
				characterImage = 'BBBump';
				animationName = 'BB Title Bump';
				danceLeftFrames = [14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27];
				danceRightFrames = [27, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13];
				gfPosition.x += 45;
				gfPosition.y += 100;
			case 'PESSY':
				characterImage = 'PessyBump';
				animationName = 'Pessy Title Bump';
				gfPosition.x += 165;
				gfPosition.y += 60;
				danceLeftFrames = [29, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
				danceRightFrames = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28];
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		#if MODS_ALLOWED
		var firstArray:Array<String> = Mods.mergeAllTextsNamed('data/introText.txt');
		#else
		var fullText:String = Assets.getText(Paths.txt('introText'));
		var firstArray:Array<String> = fullText.split(';\n');
		#end
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		titleTimer += FlxMath.bound(elapsed, 0, 1);
		if (titleTimer > 2) titleTimer -= 2;

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (!pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(ClientPrefs.data.flashing)
					FlxFlicker.flicker(titleText, 1, 0.15);

				FlxG.camera.flash(ClientPrefs.data.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null)
			{
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			if(credGroup.members.length == 6) {
				credGroup.remove(textGroup.members[0], true);
				textGroup.remove(textGroup.members[0], true);

				for(text in textGroup.members) text.y -= 60;
			}
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null)
		{
			danceLeft = !danceLeft;
			if(!useIdle)
			{
				if (danceLeft)
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}
			else gfDance.animation.play('idle', true);
		}

		if(!closedState && !skippedIntro)
		{
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('menu_v1'), 0);
					FlxG.sound.music.loopTime = 8727;
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createCoolText(FlxG.random.float(0, 1) <= 0.2 ? ['The Squaddy Nation'] : ['The VS Dami team']);
				case 4:
					addMoreText('presents');
				case 5:
					deleteCoolText();
				case 6:
					createCoolText(['With major love', 'to'], -40);
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					doTheFunny(curWacky[0]);
				case 12:
					doTheFunny(curWacky[1].replace(';',''), 1);
				case 13:
					if(video != null) video.finishCallback();
					FlxG.sound.music.volume = 0.7;
					deleteCoolText();
				case 14:
					addMoreText('Friday');
				case 15:
					addMoreText('Night');
				case 16:
					addMoreText('Funkin');

				case 17:
					skipIntro();
			}
		}
	}

	function doTheFunny(text:String, ?index:Int = 0):Void
	{
		switch(text.toLowerCase())
		{
			case "you've been hit by" | "onwards and upwards" | "dear all trick-or-treaters,":
				if(video == null) return;
				FlxG.sound.music.pause();
				video.alpha = 1;
				video.play();
			case "penis.":
				createCoolText(['']);
			case "balls even.":
				final soundBoom:FlxSound = new FlxSound().loadEmbedded(Paths.sound('vine-boom'));
				FlxG.sound.music.pause();
				addMoreText('penis.');
				soundBoom.play();
				new FlxTimer().start((Conductor.crochet / 1000) * 3, (tmr:FlxTimer) -> {
					final satBoom:FlxSound = new FlxSound().loadEmbedded(Paths.sound('saturated-vine-boom'));
					addMoreText(text);
					satBoom.play();
					FlxG.sound.music.volume = 0;
					FlxG.sound.music.resume();
					new FlxTimer().start(Conductor.crochet / 1000, (tmr:FlxTimer) -> {satBoom.stop();});
				});
			case "oh it doesn't matter":
				final howSpellSound:FlxSound = new FlxSound().loadEmbedded(Paths.sound('howyouspell'));
				FlxG.sound.music.pause();
				howSpellSound.play();
				createCoolText(['b']);
				new FlxTimer().start(0.308, function(tmr:FlxTimer) {
					deleteCoolText();
					createCoolText(['o']);
					new FlxTimer().start(0.316, function(tmr:FlxTimer)
					{
						deleteCoolText();
						createCoolText(['r']);
						new FlxTimer().start(0.351, function(tmr:FlxTimer)
						{
							deleteCoolText();
							createCoolText(['i']);
							new FlxTimer().start(0.412, function(tmr:FlxTimer)
							{
								deleteCoolText();
								createCoolText(['n']);
								new FlxTimer().start(0.389, function(tmr:FlxTimer)
								{
									deleteCoolText();
									createCoolText(['j']);
									new FlxTimer().start(0.309, function(tmr:FlxTimer)
									{
										deleteCoolText();
										createCoolText(['o']);
										new FlxTimer().start(0.703, function(tmr:FlxTimer)
										{
											deleteCoolText();
											createCoolText(['r']);
											new FlxTimer().start(0.321, function(tmr:FlxTimer)
											{
												deleteCoolText();
												createCoolText(['a']);
												new FlxTimer().start(0.409, function(tmr:FlxTimer)
												{
													deleteCoolText();
													createCoolText(['x']);
													new FlxTimer().start(1.073, function(tmr:FlxTimer)
													{
														deleteCoolText();
														createCoolText(['y']);
														new FlxTimer().start(0.382, function(tmr:FlxTimer)
														{
															deleteCoolText();
															createCoolText(['a']);
															new FlxTimer().start(0.438, function(tmr:FlxTimer)
															{
																deleteCoolText();
																createCoolText(['z']);
																new FlxTimer().start(0.427, function(tmr:FlxTimer)
																{
																	deleteCoolText();
																	createCoolText(['a']);
																	new FlxTimer().start(0.405, function(tmr:FlxTimer)
																	{
																		deleteCoolText();
																		createCoolText(['o']);
																		new FlxTimer().start(0.393, function(tmr:FlxTimer)
																		{
																			deleteCoolText();
																			createCoolText(['a']);
																			new FlxTimer().start(0.388, function(tmr:FlxTimer)
																			{
																				deleteCoolText();
																				createCoolText(['oh it doesn\'t matter']);
																				new FlxTimer().start(1.234, function(tmr:FlxTimer)
																				{
																					addMoreText('how you spell');
																					new FlxTimer().start(0.635, function(tmr:FlxTimer)
																					{
																						addMoreText('jborinjooraxxxyazaoa');
																						FlxG.sound.music.time = Conductor.crochet * 11;
																						sickBeats = 11;
																						FlxG.sound.music.volume = 0;
																						FlxG.sound.music.resume();
																					});
																				});
																			});
																		});
																	});
																});
															});
														});
													});
												});
											});
										});
									});
								});
							});
						});
					});
				});
			case "how you spell":
				// do nothing lol
			case "":
				if(video == null || index == 0) return;
				FlxG.sound.music.volume = 0;
				video.alpha = 1;
				video.play();
			case _: if(index == 0) createCoolText([text]) else addMoreText(text);
		}
	}

	var skippedIntro:Bool = false;
	var increaseVolume:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);

			skippedIntro = true;
		}
	}
}
