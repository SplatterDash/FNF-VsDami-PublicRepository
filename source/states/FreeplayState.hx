package states;

import backend.Highscore;
import backend.Song;
import backend.WeekData;
import flixel.math.FlxMath;
import flixel.util.FlxDestroyUtil;
import flxanimate.animate.FlxAnim.ButtonSettings;
import haxe.Json;
import objects.HealthIcon;
import objects.MenuButton;
import objects.MusicPlayer;
import objects.Vinyl;
import options.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class FreeplayState extends MusicBeatState
{
	public static var transform:String = '';

	var songs:Array<SongMetadata> = [];
	var vinylStats:Array<Array<Float>> = [
		[-300, 440, 0.5], //-450, 290
		[31, 440, 0.5],   //-119, 290
		[230, 387, 0.7],  //  80, 237
		[491, 264, 1.0],  // 341, 114
		[846, 387, 0.7],  // 696, 237
		[1109, 440, 0.5], // 959, 290
		[1280, 440, 0.5]  //1130, 290
	];

	static var curSelected:Int = 0;
	static var playSelected:Int = 0;

	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	var shiftMult:Int = 1;

	var instance:FreeplayState;

	var bg:FlxSprite;
	var vinylCollection:FlxTypedSpriteGroup<Vinyl> = new FlxTypedSpriteGroup<Vinyl>();
	var playCollection:Array<MenuButton> = new Array<MenuButton>();
	var scoreBG:FlxSprite;
	var scoreText:FlxText;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var bottomString:String;
	var bottomText:FlxText;
	var bottomBG:FlxSprite;

	var oppIcon:HealthIcon;
	var oppRender:FlxSprite;
	var playIcon:HealthIcon;
	var playRender:FlxSprite;

	var songTitle:FlxText;
	var songSubt:FlxText;
	var songComposer:FlxText;

	var player:MusicPlayer;

	var playButton:MenuButton;

	var canSelect:Bool = false;
	var allowMouse:Bool = ClientPrefs.data.mouseUI;

	final bgMusic:FlxSound = new FlxSound();
	final daSound:FlxSound = new FlxSound();

	final directory:String = "menus/freeplay/";

	public static var finale:Bool = false;

	override function create()
	{
		//Paths.clearStoredMemory();
		//Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		instance = this;

		FlxG.mouse.visible = allowMouse;

		if(WeekData.weeksList.length < 1)
		{
			FlxTransitionableState.skipNextTransIn = true;
			persistentUpdate = false;
			MusicBeatState.switchState(new states.ErrorState("NO WEEKS ADDED FOR FREEPLAY\n\nPress ACCEPT to go to the Week Editor Menu.\nPress BACK to return to Main Menu.",
				function() MusicBeatState.switchState(new states.editors.WeekEditorState()),
				function() MusicBeatState.switchState(new states.MainMenuState())));
			return;
		}

		for (i in 0...WeekData.weeksList.length)
		{
			//NOTE: when making certain songs unlock in Freeplay based on certain weeks (V1), modify this line:
			if(weekIsLocked(WeekData.weeksList[i])) continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<Array<String>> = [];

			for (j in 0...leWeek.songs.length)
			{
				leSongs.push(leWeek.songs[j][0]);
				leChars.push([leWeek.songs[j][1], leWeek.songs[j][2]]);
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
				addSong(song[0], i, song[1], song[2], song[3]);
		}
		Mods.loadTopMod();

		bg = new FlxSprite(151, 75);
		bg.active = false;
		add(bg);

		add(new FlxSprite().loadGraphic(Paths.image(directory + "bar-top")));
		members[1].active = false;

		add(new FlxSprite().loadGraphic(Paths.image(directory + "bar-left")));
		members[2].active = false;
		
		add(new FlxSprite(952).loadGraphic(Paths.image(directory + "bar-right")));
		members[3].active = false;

		for(i in 2...4) FlxTween.tween(members[i], { y: -1444 }, 45, { type:LOOPING });

		//-140, -60
		add(oppRender = new FlxSprite(-140, -60));
		members[4].active = false;

		//900, -60
		add(playRender = new FlxSprite(900, -60));
		members[5].active = false;
		
		add(vinylCollection);

		//vinyl placements
		for (i in 0...6)
		{
			var daStuff:Array<Float> = vinylStats[i + 1];
			var vinyl:Vinyl = new Vinyl(daStuff[0], daStuff[1], Paths.formatToSongPath(songs[FlxMath.wrap(curSelected + (i - 2), 0, songs.length - 1)].songName), false, (transform != '' && i == 2) ? transform : '');
			vinyl.daScale = daStuff[2];
			vinylCollection.add(vinyl);
		}
		
		playCollection.push(new MenuButton(429, 391, directory + "select-left", function() {
				changeSelection(-shiftMult);
		}));
		playCollection.push(new MenuButton(525, 476, directory + "enter", confirmSelection, function(sel:Bool) {
			FlxTween.completeTweensOf(playCollection[1]);
			FlxTween.tween(playCollection[1], {y: sel ? 406 : 476}, 0.3, {ease: FlxEase.cubeInOut});
		}));
		playCollection.push(new MenuButton(796, 399, directory + "select-right", function() {
				changeSelection(shiftMult);
		}));

		for(i in 0...3) add(playCollection[i]);

		add(new FlxSprite(0, 557).loadGraphic(Paths.image(directory + "bar-bottom")));
		members[10].active = false;

		playCollection.push(new MenuButton(0, 630, "exit-left", exitState));
		playCollection.push(playButton = new MenuButton(609, 625, directory + "button-play", handlePlayer));
		for(i in 3...5) add(playCollection[i]);

		add(oppIcon = new HealthIcon("bf"));
		oppIcon.setPosition(325, 125);

		add(playIcon = new HealthIcon("bf", true));
		playIcon.setPosition(805, 125);

		songTitle = new FlxText(0, 75, 500, "");
		songTitle.setFormat(Paths.font("Stand-7MLA.ttf"), 50, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		songTitle.borderSize = 2;
		songTitle.screenCenter(X);
		add(songTitle);

		songSubt = new FlxText(0, 200, 500, "");
		songSubt.setFormat(Paths.font("Stand-7MLA.ttf"), 25, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		songSubt.alpha = 0;
		songSubt.screenCenter(X);
		add(songSubt);

		songComposer = new FlxText(0, 225, 500, "");
		songComposer.setFormat(Paths.font("Stand-7MLA.ttf"), 32, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		songComposer.screenCenter(X);
		add(songComposer);

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 40, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		add(scoreText);

		missingTextBG = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		if(curSelected >= songs.length) curSelected = 0;
		
		player = new MusicPlayer(this);
		add(player);

		bottomBG = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		bottomBG.alpha = 0.6;
		add(bottomBG);

		var leText:String = Language.getPhrase("freeplay_tip", "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.");
		bottomString = leText;
		var size:Int = 16;
		bottomText = new FlxText(bottomBG.x, bottomBG.y + 4, FlxG.width, leText, size);
		bottomText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		bottomText.scrollFactor.set();
		add(bottomText);
		
		changeSelection();

		bgMusic.loadEmbedded(Paths.music('menu_freeplay'));
		FlxG.sound.list.add(bgMusic);
		bgMusic.looped = true;
		bgMusic.play();

		super.create();

		if(transform != '') transformDisc() else canSelect = true;

		if(finale) {
			openSubState(new states.editors.content.Prompt("THANK YOU FOR PLAYING VS DAMI DEMO!\n\nMake sure to check out the credits.\nWe'll see you in V1!", () -> {},null,null,null,true));
			FlxG.save.data.completedDemo = true;
			FlxG.save.flush();
			finale = false;
		}
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		vinylCollection.members[2].getVinylTexture(vinylCollection.members[2].song);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, songPlayer:String, composer:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, songPlayer, composer));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked && leWeek.weekBefore.length > 0 && (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var instPlaying:Int = -1;
	public static var vocals:FlxSound = null;
	public static var opponentVocals:FlxSound = null;
	var holdTime:Float = 0;

	var stopMusicPlay:Bool = false;
	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if(WeekData.weeksList.length < 1)
			return;

		if (FlxG.sound.music.volume < 0.7 && !daSound.playing)
			FlxG.sound.music.volume += 0.5 * elapsed;

		lerpScore = Math.floor(FlxMath.lerp(intendedScore, lerpScore, Math.exp(-elapsed * 24)));
		lerpRating = FlxMath.lerp(intendedRating, lerpRating, Math.exp(-elapsed * 12));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(CoolUtil.floorDecimal(lerpRating * 100, 2)).split('.');
		if(ratingSplit.length < 2) //No decimals, add an empty space
			ratingSplit.push('');
		
		while(ratingSplit[1].length < 2) //Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';

		if(FlxG.keys.pressed.SHIFT) shiftMult = 3 else shiftMult = 1;

		scoreText.text = Language.getPhrase('personal_best', 'PERSONAL BEST: {1} ({2}%)', [lerpScore, ratingSplit.join('.')]);
		positionHighscore();

		if (canSelect)
		{
			if (songs.length > 1)
			{
				if(FlxG.keys.justPressed.HOME)
				{
					curSelected = 0;
					changeSelection();
					holdTime = 0;	
				}
				else if(FlxG.keys.justPressed.END)
				{
					curSelected = songs.length - 1;
					changeSelection();
					holdTime = 0;	
				}
				if (controls.UI_RIGHT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeNavSelection();
					holdTime = 0;
				}

				if (controls.UI_LEFT_P) {
					FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
					changeNavSelection(false);
					holdTime = 0;
				}

				if (controls.ACCEPT) {
					navPress();
					holdTime = 0;
				}

				if(controls.UI_LEFT || controls.UI_RIGHT || controls.ACCEPT_H)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						if(!controls.ACCEPT && !controls.ACCEPT_H) changeNavSelection(controls.UI_RIGHT) else navPress();
				}

				if(allowMouse) {
					if((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed || FlxG.mouse.pressed) {
						FlxG.mouse.visible = true;
						timeNotMoving = 0;

						for(item in playCollection)
							if(FlxG.mouse.overlaps(item) && !item.selected)
								changeNavSelection(false, playCollection.indexOf(item));

						if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(playCollection[playSelected])) {
							navPress();
							holdTime = 0;
						}

						if(FlxG.mouse.pressed && FlxG.mouse.overlaps(playCollection[playSelected])) {
							var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
							holdTime += elapsed;
							var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

							if(holdTime > 0.5 && checkNewHold - checkLastHold > 0) navPress();
						}
					}
					else
					{
						timeNotMoving += elapsed;
						if(timeNotMoving > 2) FlxG.mouse.visible = false;
					}

					if(FlxG.mouse.wheel != 0)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
						changeSelection(shiftMult * FlxG.mouse.wheel, false);
					}
				}
			}
		}

		if (controls.BACK)
			exitState();

		if(FlxG.keys.justPressed.CONTROL && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new GameplayChangersSubstate());
		}

		else if(controls.RESET && !player.playingMusic)
		{
			persistentUpdate = false;
			openSubState(new ResetScoreSubState(songs[curSelected].songName, songs[curSelected].songCharacter));
			FlxG.sound.play(Paths.sound('scrollMenu'));
		}

		super.update(elapsed);
	}

	private inline function navPress(hold:Bool = false)
	{
		playCollection[playSelected].locked = true;
		navRelease();
	}

	private inline function navRelease()
	{
		playCollection[playSelected].locked = false;
	}

	function exitState()
	{
		if (player.playingMusic)
		{
			FlxG.sound.music.stop();
			destroyFreeplayVocals();
			FlxG.sound.music.volume = 0;
			instPlaying = -1;

			player.playingMusic = false;
			player.switchPlayMusic();

			bgMusic.resume();
			FlxTween.tween(FlxG.sound.music, {volume: 1}, 1);
			vinylCollection.members[2].spinning = false;
		}
		else 
		{
			persistentUpdate = false;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			bgMusic.stop();
			FlxG.sound.playMusic(Paths.music('menu_v1'), 0.7);
			FlxG.sound.music.loopTime = 8727;
			MusicBeatState.switchState(new MainMenuState());
		}
	}

	function handlePlayer()
	{
		if(instPlaying != curSelected && !player.playingMusic)
		{
			destroyFreeplayVocals();
			FlxG.sound.music.volume = 0;

			Mods.currentModDirectory = songs[curSelected].folder;
			var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase());
			Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
			if (PlayState.SONG.needsVoices)
			{
				vocals = new FlxSound();
				try
				{
					var playerVocals:String = getVocalFromCharacter(PlayState.SONG.player1);
					var loadedVocals = Paths.voices(PlayState.SONG.song, (playerVocals != null && playerVocals.length > 0) ? playerVocals : 'Player');
					if(loadedVocals == null) loadedVocals = Paths.voices(PlayState.SONG.song);
					
					if(loadedVocals != null && loadedVocals.length > 0)
					{
						vocals.loadEmbedded(loadedVocals);
						FlxG.sound.list.add(vocals);
						vocals.persist = vocals.looped = true;
						vocals.volume = 0.8;
						vocals.play();
						vocals.pause();
					}
					else vocals = FlxDestroyUtil.destroy(vocals);
				}
				catch(e:Dynamic)
				{
					vocals = FlxDestroyUtil.destroy(vocals);
				}
				
				opponentVocals = new FlxSound();
				try
				{
					//trace('please work...');
					var oppVocals:String = getVocalFromCharacter(PlayState.SONG.player2);
					var loadedVocals = Paths.voices(PlayState.SONG.song, (oppVocals != null && oppVocals.length > 0) ? oppVocals : 'Opponent');
					
					if(loadedVocals != null && loadedVocals.length > 0)
					{
						opponentVocals.loadEmbedded(loadedVocals);
						FlxG.sound.list.add(opponentVocals);
						opponentVocals.persist = opponentVocals.looped = true;
						opponentVocals.volume = 0.8;
						opponentVocals.play();
						opponentVocals.pause();
						//trace('yaaay!!');
					}
					else opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
				}
				catch(e:Dynamic)
				{
					//trace('FUUUCK');
					opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
				}
			}

			bgMusic.pause();

			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.8);
			FlxG.sound.music.pause();
			instPlaying = curSelected;

			player.playingMusic = true;
			player.curTime = 0;
			player.switchPlayMusic();
			player.pauseOrResume(true);

			vinylCollection.members[2].spinning = true;
		}
		else if (instPlaying == curSelected && player.playingMusic)
		{
			player.pauseOrResume(!player.playing);
		}
	}

	function changeNavSelection(left:Bool = true, ?force:Int = -1)
	{
		playCollection[playSelected].selected = false;
		playSelected = FlxMath.wrap(force != -1 ? force : playSelected + (1 * (left ? 1 : -1)), 0, playCollection.length - 1);
		playCollection[playSelected].selected = true;
	}

	function confirmSelection()
	{
		persistentUpdate = false;
		var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
		var poop:String = Highscore.formatSong(songLowercase);

		try
		{
			Song.loadFromJson(poop, songLowercase);
			PlayState.isStoryMode = false;

			trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
		}
		catch(e:haxe.Exception)
		{
			trace('ERROR! ${e.message}');

			var errorStr:String = e.message;
			if(errorStr.contains('There is no TEXT asset with an ID of')) errorStr = 'Missing file: ' + errorStr.substring(errorStr.indexOf(songLowercase), errorStr.length-1); //Missing chart
			else errorStr += '\n\n' + e.stack;

			missingText.text = 'ERROR WHILE LOADING CHART:\n$errorStr';
			missingText.screenCenter(Y);
			missingText.visible = true;
			missingTextBG.visible = true;
			FlxG.sound.play(Paths.sound('cancelMenu'));
			return;
		}

		@:privateAccess
		if(PlayState._lastLoadedModDirectory != Mods.currentModDirectory)
		{
			trace('CHANGED MOD DIRECTORY, RELOADING STUFF');
			Paths.freeGraphicsFromMemory();
		}
		LoadingState.prepareToSong();
		LoadingState.loadAndSwitchState(new PlayState());
		#if !SHOW_LOADING_SCREEN FlxG.sound.music.stop(); #end
		stopMusicPlay = true;

		destroyFreeplayVocals();
		#if (MODS_ALLOWED && DISCORD_ALLOWED)
		DiscordClient.loadModRPC();
		#end
	}

	function getVocalFromCharacter(char:String)
	{
		try
		{
			var path:String = Paths.getPath('characters/$char.json', TEXT);
			#if MODS_ALLOWED
			var character:Dynamic = Json.parse(File.getContent(path));
			#else
			var character:Dynamic = Json.parse(Assets.getText(path));
			#end
			return character.vocals_file;
		}
		catch (e:Dynamic) {}
		return null;
	}

	public static function destroyFreeplayVocals() {
		if(vocals != null) vocals.stop();
		vocals = FlxDestroyUtil.destroy(vocals);

		if(opponentVocals != null) opponentVocals.stop();
		opponentVocals = FlxDestroyUtil.destroy(opponentVocals);
	}

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (player.playingMusic)
			return;

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length-1);
		if(playSound) FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		for(i in vinylCollection.members) {
			FlxTween.completeTweensOf(i);
			var daInt:Int = vinylCollection.members.indexOf(i);
			i.song = Paths.formatToSongPath((songs[FlxMath.wrap(curSelected + (daInt < 5 ? (daInt - 2) : (3 * (change > 0 ? -1 : 1))), 0, songs.length-1)].songName));
			i.checkForNew();
		}

		var theText:String = '';
		switch(Paths.formatToSongPath(vinylCollection.members[2].song))
		{
			case 'dami-nate' | 'bussin' | 'affliction': theText = 'dami';
			case 'backstreets': theText = 'minus';
			case 'blister': theText = 'director';
			case _: theText = Paths.formatToSongPath(vinylCollection.members[2].song);
		}

		bg.loadGraphic(Paths.image(directory + "backgrounds/" + theText) != null ? Paths.image(directory + "backgrounds/" + theText) : Paths.image(directory + "backgrounds/dami"));

		if(change != 0) for (i in vinylCollection.members) {
			var daInt:Int = vinylCollection.members.indexOf(i) + 1;
			var stats:Array<Float> = vinylStats[daInt <= 5 ? (daInt + (change < 0 ? -1 : 1)) : (change < 0 ? 5 : 1)];

			i.setPosition(stats[0], stats[1]);
			i.daScale = stats[2];

			stats = vinylStats[daInt <= 5 ? daInt : (change < 0 ? 6 : 0)];
			FlxTween.tween(i, { x: stats[0], y: stats[1], daScale: stats[2]}, 0.3, {ease: FlxEase.cubeOut});
		}

		oppIcon.changeIcon(songs[curSelected].songCharacter);
		playIcon.changeIcon(songs[curSelected].songPlayer);
		var daBase:String = 'menus/freeplay/renders/';
		var daOpp:String = '';
		var daPlay:String = '';
		switch(songs[curSelected].songName.toLowerCase())
		{
			case "backstreets":
				daOpp = daBase + songs[curSelected].songCharacter.toLowerCase();
				daPlay = daBase + 'minusbf';
			case "tutorial" | "dami-nate" | "bussin'" | "affliction" | "domination" | "reawaken":
				daOpp = daBase + songs[curSelected].songCharacter.toLowerCase();
				daPlay = daBase + "bf-club";
			case "blister":
				daOpp = daBase + songs[curSelected].songCharacter.toLowerCase();
				daPlay = daBase + 'dami-dev';
			case _:
				daOpp = daBase + songs[curSelected].songCharacter.toLowerCase();
				daPlay = daBase + songs[curSelected].songPlayer.toLowerCase();
		}
		oppRender.loadGraphic(Paths.image(daOpp));
		playRender.loadGraphic(Paths.image(daPlay));

		if (songs[curSelected].songName.indexOf("(") >= 0) {
			var splitTitle:Array<String> = songs[curSelected].songName.split("(");
			songTitle.text = splitTitle[0].toUpperCase();
			songSubt.text = "(" + splitTitle[1].toUpperCase();
			songSubt.y = songTitle.y + songTitle.height - 10;
			songSubt.alpha = 1;
		} else {
			songTitle.text = songs[curSelected].songName.toUpperCase();
			songSubt.alpha = 0;
		}
		songComposer.text = songs[curSelected].composer;

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName);
		intendedRating = Highscore.getRating(songs[curSelected].songName);
		#end
		
		Mods.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;
		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
	}

	var _drawDistance:Int = 4;
	var _lastVisibles:Array<Int> = [];
	

	override function destroy():Void
	{
		super.destroy();
		FlxG.autoPause = ClientPrefs.data.autoPause;
		if(daSound != null && daSound.playing) daSound.stop();
		if (!FlxG.sound.music.playing && !stopMusicPlay) {
			FlxG.sound.playMusic(Paths.music('menu_v1'), 0.7);
			FlxG.sound.music.loopTime = 8727;
		}
	}

	function transformDisc()
	{
		FlxG.sound.music.volume = 0.4;
		vinylCollection.members[2].onTransform = () -> {
			vinylCollection.members[2].overrideText = '';
			transform = '';
			canSelect = true;
		}
		daSound.loadEmbedded(Paths.sound("disktrans-" + Paths.formatToSongPath(CoolUtil.getRatingTexture(vinylCollection.members[2].song))));
		daSound.play();
		vinylCollection.members[2].transform();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var songPlayer:String = "";
	public var composer:String = "";
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, songPlayer:String, composer:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.songPlayer = songPlayer;
		this.composer = composer;
		this.folder = Mods.currentModDirectory;
		if(this.folder == null) this.folder = '';
	}
}