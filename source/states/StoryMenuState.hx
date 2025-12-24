package states;

import backend.Highscore;
import backend.Song;
import backend.StageData;
import backend.WeekData;
import flixel.effects.FlxFlicker;
import options.GameplayChangersSubstate;
import states.editors.content.Prompt;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var scoreText:FlxText;

	var tracksTitle:FlxText;

	private static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpLeft:FlxTypedSpriteGroup<FlxSprite>;
	var grpRight:FlxTypedSpriteGroup<FlxSprite>;

	var albumCover:FlxSprite;
	var albumSelectors:FlxTypedSpriteGroup<FlxSprite>;
	var upArrow:FlxSprite;
	var downArrow:FlxSprite;

	var circle:FlxSprite;

	var allowMouse:Bool = ClientPrefs.data.mouseUI; //Turn this off to block mouse movement in menus

	var loadedWeeks:Array<WeekData> = [];

	public static var congrats:Bool = false;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		persistentUpdate = persistentDraw = true;
		PlayState.isStoryMode = true;
		WeekData.reloadWeekFiles(true);

		FlxG.mouse.visible = allowMouse;

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR STORY MODE\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		if(curWeek >= WeekData.weeksList.length) curWeek = 0;

		scoreText = new FlxText(650, 495, 0, Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]), 36);
		scoreText.setFormat(Paths.font("Stand-7MLA.ttf"), 26, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');

		var num:Int = 0;
		for (i in 0...WeekData.weeksList.length)
		{
			var weekFile:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var isLocked:Bool = weekIsLocked(WeekData.weeksList[i]);
			if(!isLocked || !weekFile.hiddenUntilUnlocked)
			{
				loadedWeeks.push(weekFile);
				WeekData.setDirectoryFromWeek(weekFile);
				num++;
			}
		}

		add(new FlxSprite().loadGraphic(Paths.image('menubackgrounds/background')));

		grpLeft = new FlxTypedSpriteGroup<FlxSprite>(-630);
		add(grpLeft);

		grpRight = new FlxTypedSpriteGroup<FlxSprite>(678);
		add(grpRight);

		albumCover = new FlxSprite(18, 42);
		albumCover.scale.set(0.8, 0.8);
		albumCover.antialiasing = ClientPrefs.data.antialiasing;
		grpLeft.add(albumCover);

		WeekData.setDirectoryFromWeek(loadedWeeks[0]);
		albumSelectors = new FlxTypedSpriteGroup<FlxSprite>();
		grpLeft.add(albumSelectors);

		upArrow = new FlxSprite(320, 0);
		upArrow.frames = ui_tex;
		upArrow.animation.addByPrefix('idle', "arrow left");
		upArrow.animation.addByPrefix('press', "arrow push left");
		upArrow.animation.play('idle');
		upArrow.angle = 90;
		albumSelectors.add(upArrow);

		downArrow = new FlxSprite(320, 633);
		downArrow.frames = ui_tex;
		downArrow.animation.addByPrefix('idle', "arrow right");
		downArrow.animation.addByPrefix('press', "arrow push right");
		downArrow.animation.play('idle');
		downArrow.angle = 90;
		albumSelectors.add(downArrow);

		grpRight.add(circle = new FlxSprite(602).loadGraphic(Paths.image('menus/story/circol')));
		
		tracksTitle = new FlxText(800, 130, 0, Language.getPhrase('story_track_title', 'Tracks') + ":");
		tracksTitle.setFormat(Paths.font('Stand-7MLA.ttf'), 68, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);

		txtTracklist = new FlxText(470, 200, 1000, "");
		txtTracklist.setFormat(Paths.font('vipnagorgialla.bold.otf'), 48, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		
		grpRight.add(tracksTitle);

		grpRight.insert(1, txtTracklist);
		grpRight.add(scoreText);

		changeWeek(curWeek, true);

		super.create();

		FlxTween.tween(grpLeft, { x: 0 }, 1.8, {ease: FlxEase.quintOut});
		FlxTween.tween(grpRight, { x: 0 }, 1.8, {ease: FlxEase.quintOut});

		if (congrats) {
			openSubState(new states.editors.content.Prompt("CONGRATULATIONS!\n\nNow try your hand at five more songs in Freeplay!",
				() -> {}, null, null,
				null, true));
				congrats = false;
		}
	}

	override function closeSubState() {
		persistentUpdate = true;
		changeWeek(curWeek, true);
		super.closeSubState();
	}

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
		{
			if (controls.BACK && !movedBack && !selectedWeek)
			{
				FlxG.sound.play(Paths.sound('cancelMenu'));
				movedBack = true;
				MusicBeatState.switchState(new MainMenuState());
			}
			super.update(elapsed);
			return;
		}

		// scoreText.setFormat(Paths.font("vcr.ttf"), 32);
		if(intendedScore != lerpScore)
		{
			lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 30)));
			if(Math.abs(intendedScore - lerpScore) < 10) lerpScore = intendedScore;
	
			scoreText.text = Language.getPhrase('week_score', 'WEEK SCORE: {1}', [lerpScore]);
		}

		// FlxG.watch.addQuick('font', scoreText.font);

		if (!movedBack && !selectedWeek)
		{
			var changeDiff = false;
			if (controls.UI_UP_P)
			{
				changeWeek(-1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_DOWN_P)
			{
				changeWeek(1);
				FlxG.sound.play(Paths.sound('scrollMenu'));
			}

			if (controls.UI_UP) {
				upArrow.animation.play('press');
				if(upArrow.scale.x != 0.8) upArrow.scale.set(0.8, 0.8);
			} else {
				upArrow.animation.play('idle');
				if(upArrow.scale.x != 1) upArrow.scale.set(1, 1);
			}

			if (controls.UI_DOWN) {
				downArrow.animation.play('press');
				if(downArrow.scale.x != 0.8) downArrow.scale.set(0.8, 0.8);
			} else {
				downArrow.animation.play('idle');
				if(downArrow.scale.x != 1) downArrow.scale.set(1, 1);
			}

			if(allowMouse) {
				if(FlxG.mouse.wheel != 0)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
					changeWeek(-FlxG.mouse.wheel);
				}

				for(item in albumSelectors) {
					if(FlxG.mouse.overlaps(item)) {
						if(item.scale.x != 1.2 && !FlxG.mouse.pressed) {
							item.scale.set(1.2, 1.2);
							item.animation.play('idle');
						} else if (item.scale.x != 0.8 && FlxG.mouse.pressed) {
								item.scale.set(0.8, 0.8);
								item.animation.play('press');
							}
					} else if(item.scale.x != 1) item.scale.set(1, 1);
				}

				if(FlxG.mouse.overlaps(albumCover)) {
					if(albumCover.scale.x != 0.9 && !FlxG.mouse.pressed) {
						albumCover.scale.set(0.9, 0.9);
					} else if (albumCover.scale.x != 0.6 && FlxG.mouse.pressed) {
							albumCover.scale.set(0.6, 0.6);
						}
				} else if(albumCover.scale.x != 0.8) albumCover.scale.set(0.8, 0.8);

				if(FlxG.mouse.overlaps(upArrow) && FlxG.mouse.justPressed) {
					changeWeek(-1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if(FlxG.mouse.overlaps(downArrow) && FlxG.mouse.justPressed) {
					changeWeek(1);
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if(FlxG.mouse.overlaps(albumCover) && FlxG.mouse.justPressed)
					selectWeek();

				if ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
				{
					if(!selectedWeek) FlxG.mouse.visible = true;
					timeNotMoving = 0;
				}
				else
				{
					timeNotMoving += elapsed;
					if(timeNotMoving > 2) FlxG.mouse.visible = false;
				}
			}

			if(FlxG.keys.justPressed.CONTROL)
			{
				persistentUpdate = false;
				openSubState(new GameplayChangersSubstate());
			}
			else if(controls.RESET)
			{
				persistentUpdate = false;
				openSubState(new ResetScoreSubState('', '', curWeek));
				//FlxG.sound.play(Paths.sound('scrollMenu'));
			}
			else if (controls.ACCEPT)
				selectWeek();
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			MusicBeatState.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (!weekIsLocked(loadedWeeks[curWeek].fileName))
		{
			// We can't use Dynamic Array .copy() because that crashes HTML5, here's a workaround.
			var songArray:Array<String> = [];
			var leWeek:Array<Dynamic> = loadedWeeks[curWeek].songs;
			for (i in 0...leWeek.length) {
				songArray.push(leWeek[i][0]);
			}

			// Nevermind that's stupid lmao
			try
			{
				PlayState.storyPlaylist = songArray;
				PlayState.isStoryMode = true;
				selectedWeek = true;
	
				Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase(), PlayState.storyPlaylist[0].toLowerCase());
				PlayState.campaignScore = 0;
				PlayState.campaignMisses = 0;
			}
			catch(e:Dynamic)
			{
				trace('ERROR! $e');
				return;
			}
			
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));
				albumCover.scale.set(0.9, 0.9);

				if(ClientPrefs.data.flashing) FlxFlicker.flicker(albumCover, 1.3, 0.15, false);

				FlxTween.tween(albumSelectors, { x: -630 }, 1.3, {ease: FlxEase.quintIn});
				FlxTween.tween(grpRight, { x: 678 }, 1.3, {ease: FlxEase.quintIn});

				stopspamming = true;
			}

			var directory = StageData.forceNextDirectory;
			LoadingState.loadNextDirectory();
			StageData.forceNextDirectory = directory;

			@:privateAccess
			if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
			{
				trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
				Paths.freeGraphicsFromMemory();
			}
			LoadingState.prepareToSong();
			new FlxTimer().start(1.3, function(tmr:FlxTimer)
			{
				FlxG.mouse.visible = false;
				#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
				LoadingState.loadAndSwitchState(new PlayState(), true);
				FreeplayState.destroyFreeplayVocals();
			});
			
			#if (MODS_ALLOWED && DISCORD_ALLOWED)
			DiscordClient.loadModRPC();
			#end
		}
		else {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			openSubState(new Prompt('LOCKED!\n\nComplete ${weekIsLocked(loadedWeeks[FlxMath.wrap(curWeek - 1, 0, loadedWeeks.length - 1)].fileName) ? '"?????"' : ('"' + loadedWeeks[FlxMath.wrap(curWeek - 1, 0, loadedWeeks.length - 1)].weekName + '"')} to unlock!',() -> {},null,"OK",null,true));
		}
	}

	var lerpScore:Int = 49324858;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0, force:Bool = false):Void
	{
		curWeek = FlxMath.wrap(force ? change : (curWeek + change), 0, loadedWeeks.length - 1);

		var leWeek:WeekData = loadedWeeks[curWeek];
		WeekData.setDirectoryFromWeek(leWeek);

		var locked:Bool = weekIsLocked(leWeek.fileName);

		
		if (locked)
			txtTracklist.text = "?????"
		else if(leWeek.weekName == 'Week 1')
			txtTracklist.text = 'Dami-Nate\nBussin\'\n?????'
		else {
			txtTracklist.text = '';
			for (i in 0...leWeek.songs.length) {
				txtTracklist.text += leWeek.songs[i][0] + '\n';
			}
		}

		albumCover.loadGraphic(Paths.image('menus/story/albums/' + (locked ? 'locked' : leWeek.fileName)));
		PlayState.storyWeek = curWeek;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		#if !switch
		intendedScore = Highscore.getWeekScore(loadedWeeks[curWeek].fileName);
		#end
	}

	function weekIsLocked(name:String):Bool {
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!weekCompleted.exists(leWeek.weekBefore) || !weekCompleted.get(leWeek.weekBefore)));
	}
}
