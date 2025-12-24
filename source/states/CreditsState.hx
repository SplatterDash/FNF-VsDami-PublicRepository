package states;

import objects.AttachedSprite;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:FlxColor;
	var descBox:AttachedSprite;

	var allowMouse:Bool = ClientPrefs.data.mouseUI;

	var offsetThing:Float = -75;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		FlxG.sound.playMusic(Paths.music('menu_credits'), 1);

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menubackgrounds/backgroundDesat'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		add(bg);
		bg.screenCenter();
		
		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		for (mod in Mods.parseList().enabled) pushModCreditsToList(mod);
		#end

		/**
		 * Of the final people needed for the credits list:
		 * Jann - ASKED, AWAITING
		 * Happo - ASKED, AWAITING
		 * Fueg0 - ASKED, AWAITING
		 */
		var defaultList:Array<Array<String>> = [ //Name - Icon name - Description - Link - BG Color
			["Vs Dami Team"],
			["DamiNation",          "dami",									"Director, Sprite Artwork, Concept Artwork, Scenic Artwork, Sprite Animation, VA [Dami, Reverie, Shunkly]",																	"https://x.com/DamiNation2020",                	 			"0723FA"],
			["ItsAudity",			"audity",								"Co-Director, Sprite Animation, VA [Audity], Music",																														"https://twitter.com/ItsAudity",							"bb476b"],
			["KayDoodles",			"kaydoods",								"Co-Director, Sprite Animation, Cutscene Animation",																														"https://twitter.com/KayDoodles_",							"89CFF0"],
			["No7e",				"note",									"Co-Director, Music, VA [BF]",																																				"https://twitter.com/memory_dancer",						"679add"],
			["SplatterDash",		"thismanshouldbekilledbyfiringsquad",	"Co-Director, Coding, Music [Gettin' Freaky (Vs. Dami Mix), Pause Theme, Credits, Game Over], Killed By Amber's Firing Squad [Rip Bozo], Kris Get The Banana [Potassium]",	"https://splatterdash.newgrounds.com/",						"1D6FF2"],
			["Vanillanomas",		"vanilla",								"Cutscene Animation, Music [Freeplay]",																																		"https://x.com/Vanillanomas",								"FFEFE4"],
			["Ant0niaVA",			"ant0nia",								"Cutscene Animation",																																						"https://x.com/Ant0niaVA",									"ff287d"],
			["Dotimation_124",		"dot",									"Cutscene Artwork",																																							"https://x.com/dotimate124",								"f76313"],
			["Awacc",				"awacc",								"Cutscene Artwork",																																							"https://x.com/alienwacc?s=21",								"ffffff"],
			["AsuraTheMassive0",	"asura",								"Cutscene Editor, Trailer Editor",																																			"https://twitter.com/AsuraTM0",								"ffa500"],
			["BoltTheLegend",		"bolt",									"Scenic Artwork",																																							"https://youtube.com/@boltthelegends?si=GPNGdkCuGJ2GjEeO",	"2afeb7"],
			["Aleto", 				"aleto", 								"Scenic Artwork",																																							"https://twitter.com/aletomento",							"ffa500"],
			["Andy/AZ", 			"blue",									"Scenic Artwork\nHe is blue.",																																				"https://x.com/Andy_ChillArtz",								"000080"],
			["Astro",	 			"astrobox",								"Scenic Artwork\nDon't mind Nyx, he's just aurafarming in the back.",																										"https://x.com/box_png",									"4f678f"],
			["omoberries",			"berries",								"Scenic Artwork",																																							"https://x.com/omoberries",									"95cef9"],
			["GingerKitt",			"jaygk",								"Scenic Artwork",																																							"https://linktr.ee/GingerKitt",								"8686ff"],
			["Mallohollow",			"hollow",								"Scenic Artwork",																																							"https://x.com/MalloHollow",								"CC252C"],
			["87MysteryArtist",		"mysteryartist",						"UI Artwork",																																								"https://x.com/Mysteryrtist",								"812abe"],
			["Stepbro Ice",			"broice",								"UI Artwork, Scenic Artwork, Music [Options]",																																"https://x.com/StepbroIce",									"87FFFF"],
			["JohnnyAnimates",		"johnny",								"Sprite Animation",																																							"https://x.com/JAnimatess23081",							"90ccd6"],
			["Ice Cube",			"cubeice",								"Sprite Animation",																																							"https://youtube.com/@stepbroice?si=3b5PhV7US5z47_74",		"00b3fa"],
			["Noer",				"noer",									"Charting [Tutorial, Dami-Nate, DOMINATION, Blister]",																														"https://twitter.com/Thisisnoerlol",						"1abc9c"],
			["amberthesilly",		"amber",								"Charting [Bussin, Dami-Nate (ERECT Remix), Entitled]",																														"https://x.com/amberthealt",								"FFD1DC"],
			["ShomiNexus",			"shomi",								"Charting [Affliction, Backstreets], Modcharting [Affliction]",																												"https://youtube.com/channel/UCF8TMvPWYtAjS7ammQhvwEQ",		"8bdf6f"],
			["Jannthejuicebox",		"jann",									"Charting [Reawaken]",																																						"https://x.com/JannTheJuicebox",							""],
			["N21XL",				"nitro",								"Charting [Improbable Outset (Dami Mix)]",																																	"https://twitter.com/tswnitro",								"32a852"],
			["Happo",				"happo",								"VA [Daddy Dearest]",																																						"",""],
			["Kurry",				"kurryyy",								"VA [Mommy Mearest]",																																						"https://x.com/KurrysKookup",								"ad00f2"],
			["Neon Shikaro",		"neonshikaro",							"VA [GF]",																																									"https://twitter.com/NeonShikaro",							"5ee8d3"],
			["KumaToast",			"kuumster",								"VA [Bouncer]",																																								"https://x.com/kuma_toast",									"0f0fff"],
			["Kye_VL",				"kyevl",								"VA [Pico]",																																								"https://x.com/Kye_VL",										"0000c8"],
			["Colossi Productions", "colossi",								"VA [Aidan]",																																				/**NO LINK**/	"",															"00CEC8"],
			["ItsAlibi",			"itsalibi",								"VA [ItsAlibi]",																																							"https://www.drpepper.com/s/",								"b907fa"],
			["Genkei-Dama",			"dagenkei",								"VA [Bouncer], Cutscene Sound Designer",																																	"https://x.com/GenkeiDamaVA",								"273ec4"],
			["Aar0npkt",			"aaronstinky",							"Chromatic Maker",																																							"https://twitter.com/AaromKT",								"80ffea"],
			["Fueg0",				"fueg0",								"Music",																																									"",""],
			["MegaFreedom1274",		"megafreedom",							"Music",																																									"https://twitter.com/MegaFreedom1274",						"9d1454"],
			["Coal Cheese",			"dacheesey",							"THE GOAAAAT THE GOOOOOOOOOAAAAAAAAAAAAATTTTTTT",																															"https://www.mousehousecheese.co.uk/shop/black-as-coal/",	"000000"],
			[""],
			["Psych Engine Team"],
			["Shadow Mario",		"shadowmario",							"Main Programmer and Head of Psych Engine",																																	"https://ko-fi.com/shadowmario",							"444444"],
			["Riveren",				"riveren",								"Main Artist/Animator of Psych Engine",																																		"https://x.com/riverennn",									"14967B"],
			[""],
			["Former Engine Members"],
			["bb-panzu",			"bb",									"Ex-Programmer of Psych Engine",																																			"https://x.com/bbsub3",										"3E813A"],
			[""],
			["Engine Contributors"],
			["crowplexus",			"crowplexus",							"Linux Support, HScript Iris, Input System v3, and Other PRs",																												"https://twitter.com/IamMorwen",							"CFCFCF"],
			["Kamizeta",			"kamizeta",								"Creator of Pessy, Psych Engine's mascot.",																																	"https://www.instagram.com/cewweey/",						"D21C11"],
			["MaxNeton",			"maxneton",								"Loading Screen Easter Egg Artist/Animator.",																																"https://bsky.app/profile/maxneton.bsky.social",			"3C2E4E"],
			["Keoiki",				"keoiki",								"Note Splash Animations and Latin Alphabet",																																"https://x.com/Keoiki_",									"D2D2D2"],
			["SqirraRNG",			"sqirra",								"Crash Handler and Base code for\nChart Editor's Waveform",																													"https://x.com/gedehari",									"E1843A"],
			["EliteMasterEric",		"mastereric",							"Runtime Shaders support and Other PRs",																																	"https://x.com/EliteMasterEric",							"FFBD40"],
			["MAJigsaw77",			"majigsaw",								".MP4 Video Loader Library (hxvlc)",																																		"https://x.com/MAJigsaw77",									"5F5F5F"],
			["iFlicky",				"flicky",								"Composer of Psync and Tea Time\nAnd some sound effects",																													"https://x.com/flicky_i",									"9E29CF"],
			["KadeDev",				"kade",									"Fixed some issues on Chart Editor and Other PRs",																															"https://x.com/kade0912",									"64A250"],
			["superpowers04",		"superpowers04",						"LUA JIT Fork",																																								"https://x.com/superpowers04",								"B957ED"],
			["CheemsAndFriends",	"cheems",								"Creator of FlxAnimate",																																					"https://x.com/CheemsnFriendos",							"E1E1E1"],
			[""],
			["Funkin' Crew"],
			["ninjamuffin99",		"ninjamuffin99",						"Programmer of Friday Night Funkin'",																																		"https://x.com/ninja_muffin99",								"CF2D2D"],
			["PhantomArcade",		"phantomarcade",						"Animator of Friday Night Funkin'",																																			"https://x.com/PhantomArcade3K",							"FADC45"],
			["evilsk8r",			"evilsk8r",								"Artist of Friday Night Funkin'",																																			"https://x.com/evilsk8r",									"5ABD4B"],
			["kawaisprite",			"kawaisprite",							"Composer of Friday Night Funkin'",																																			"https://x.com/kawaisprite",								"378FC7"],
			[""],
			["Psych Engine Discord"],
			["Join the Psych Ward!","discord", 								"",																																											"https://discord.gg/2ka77eMXDv",							"5165F6"]
		];
		
		for(i in defaultList)
			creditsStuff.push(i);
	
		for (i => credit in creditsStuff)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, credit[0], !isSelectable);
			if(isSelectable) for (letter in optionText.letters) letter.setColorTransform(0, 0, 0, 1, 255, 255, 255);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable)
			{
				if(credit[5] != null)
					Mods.currentModDirectory = credit[5];

				var str:String = 'credits/missing_icon';
				if(credit[1] != null && credit[1].length > 0)
				{
					var fileName = 'credits/' + credit[1];
					if (Paths.fileExists('images/$fileName.png', IMAGE)) str = fileName;
					else if (Paths.fileExists('images/$fileName-pixel.png', IMAGE)) str = fileName + '-pixel';
				}

				var icon:AttachedSprite = new AttachedSprite(str);
				if(str.endsWith('-pixel')) icon.antialiasing = false;
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
				icon.ID = i;
	
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Mods.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else optionText.alignment = CENTERED;
		}
		
		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP || (allowMouse && FlxG.mouse.wheel > 0))
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP || (allowMouse && FlxG.mouse.wheel < 0))
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}

				if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
				{
					FlxG.mouse.visible = true;
					timeNotMoving = 0;

					for (item in iconArray)
						if(FlxG.mouse.pressed && (FlxG.mouse.overlaps(item) || FlxG.mouse.overlaps(item.sprTracker))
							&& curSelected != item.ID) changeSelection(iconArray[curSelected].ID, true);
				}
				else
				{
					timeNotMoving += elapsed;
					if(timeNotMoving > 2) FlxG.mouse.visible = false;
				}
			}

			if((controls.ACCEPT || (allowMouse && FlxG.mouse.pressed && (FlxG.mouse.overlaps(iconArray[curSelected]) || FlxG.mouse.overlaps(iconArray[curSelected].sprTracker))))
				&& (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				FlxG.sound.playMusic(Paths.music('menu_v1'), 0.7);
				FlxG.sound.music.loopTime = 8727;
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}
		
		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = Math.exp(-elapsed * 12);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(item.x - 70, lastX, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(200 + -40 * Math.abs(item.targetY), item.x, lerpVal);
				}
			}
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0, force:Bool = false)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected = FlxMath.wrap(force ? change : (curSelected + change), 0, creditsStuff.length - 1);
		}
		while(unselectableCheck(curSelected));

		var newColor:FlxColor = CoolUtil.colorFromString(creditsStuff[curSelected][4]);
		//trace('The BG color is: $newColor');
		if(newColor != intendedColor)
		{
			intendedColor = newColor;
			FlxTween.cancelTweensOf(bg);
			FlxTween.color(bg, 1, bg.color, intendedColor);
		}

		for (num => item in grpOptions.members)
		{
			item.targetY = num - curSelected;
			if(!unselectableCheck(num)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		if(descText.text.trim().length > 0)
		{
			descText.visible = descBox.visible = true;
			descText.y = FlxG.height - descText.height + offsetThing - 60;
	
			if(moveTween != null) moveTween.cancel();
			moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});
	
			descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
			descBox.updateHitbox();
		}
		else descText.visible = descBox.visible = false;
	}

	#if MODS_ALLOWED
	function pushModCreditsToList(folder:String)
	{
		var creditsFile:String = Paths.mods(folder + '/data/credits.txt');
		
		#if TRANSLATIONS_ALLOWED
		//trace('/data/credits-${ClientPrefs.data.language}.txt');
		var translatedCredits:String = Paths.mods(folder + '/data/credits-${ClientPrefs.data.language}.txt');
		#end

		if (#if TRANSLATIONS_ALLOWED (FileSystem.exists(translatedCredits) && (creditsFile = translatedCredits) == translatedCredits) || #end FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
	}
	#end

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
