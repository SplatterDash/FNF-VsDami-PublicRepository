package objects;

import flixel.group.FlxGroup;
import flixel.ui.FlxBar;
import flixel.util.FlxStringUtil;

import states.FreeplayState;

/**
 * Music player used for Freeplay
 */
@:access(states.FreeplayState)
class MusicPlayer extends FlxGroup 
{
	public var instance:FreeplayState;
	public var controls:Controls;

	public var playing(get, never):Bool;

	public var playingMusic:Bool = false;
	public var curTime:Float;

	public var goLeft(default, set):Bool = false;
	public var goRight(default, set):Bool = false;

	var buttCollection:FlxTypedSpriteGroup<MenuButton> = new FlxTypedSpriteGroup<MenuButton>();
	var buttSelected:Int = 0;

	var songBG:FlxSprite;
	var songTxt:FlxText;
	var timeTxt:FlxText;
	var progressBar:FlxBar;
	var playbackBG:FlxSprite;
	var playbackSymbols:Array<FlxText> = [];
	var playbackTxt:FlxText;

	var wasPlaying:Bool;

	var holdPitchTime:Float = 0;
	var playbackRate(default, set):Float = 1;

	final directory:String = "menus/freeplay/";

	public function new(instance:FreeplayState)
	{
		super();

		this.instance = instance;
		this.controls = instance.controls;

		var xPos:Float = FlxG.width * 0.7;

		songBG = new FlxSprite(xPos - 6, 0).makeGraphic(1, 100, 0xFF000000);
		songBG.alpha = 0.6;
		add(songBG);

		playbackBG = new FlxSprite(xPos - 6, 0).makeGraphic(1, 100, 0xFF000000);
		playbackBG.alpha = 0.6;
		add(playbackBG);

		songTxt = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		songTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(songTxt);

		timeTxt = new FlxText(xPos, songTxt.y + 60, 0, "", 32);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		add(timeTxt);

		for (i in 0...2)
		{
			var text:FlxText = new FlxText();
			text.setFormat(Paths.font('vcr.ttf'), 32, FlxColor.WHITE, CENTER);
			text.text = '^';
			if (i == 1)
				text.flipY = true;
			text.visible = false;
			playbackSymbols.push(text);
			add(text);
		}

		progressBar = new FlxBar(timeTxt.x, timeTxt.y + timeTxt.height, LEFT_TO_RIGHT, Std.int(timeTxt.width), 8, null, "", 0, Math.POSITIVE_INFINITY);
		progressBar.createFilledBar(FlxColor.WHITE, FlxColor.BLACK);
		add(progressBar);

		playbackTxt = new FlxText(FlxG.width * 0.6, 20, 0, "", 32);
		playbackTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE);
		add(playbackTxt);

		add(buttCollection);

		final ffButt:MenuButton = new MenuButton(874, 625, directory + "button-ff", function() {
			goRight = true;
		}, function(da:Bool) {
			if(goRight) goRight = false;
		});
		ffButt.useDefaultHover = true;
		buttCollection.add(ffButt);

		final rwButt:MenuButton = new MenuButton(702, 625, directory + "button-rewind", function() {
			goLeft = true;
		}, function(da:Bool) {
			if(goLeft) goLeft = false;
		});
		rwButt.useDefaultHover = true;
		buttCollection.add(rwButt);
	
		buttCollection.add(new MenuButton(516, 625, directory + "button-play", function() {
			if(FlxG.sound.music.playing) return;
			pauseOrResume(true);
		}));

		buttCollection.add(new MenuButton(341, 625, directory + "button-pause", function() {
			if(!FlxG.sound.music.playing) return;
			pauseOrResume();
		}));

		switchPlayMusic();
	}

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!playingMusic)
		{
			return;
		}

		var songName:String = instance.songs[FreeplayState.curSelected].songName;
		if (playing && !wasPlaying)
			songTxt.text = Language.getPhrase('musicplayer_playing', 'PLAYING: {1}', [songName]);
		else
			songTxt.text = Language.getPhrase('musicplayer_paused', 'PLAYING: {1} (PAUSED)', [songName]);

		//if(FlxG.keys.justPressed.K) trace('Time: ${FreeplayState.vocals.time}, Playing: ${FreeplayState.vocals.playing}');

		if (controls.UI_LEFT_P)
			justPressed(true);
		
		if (controls.UI_RIGHT_P)
			justPressed();

		if(controls.UI_LEFT || controls.UI_RIGHT || goLeft || goRight)
		{
			var left:Bool = controls.UI_LEFT || goLeft;
			instance.holdTime += elapsed;
			if(instance.holdTime > 0.5)
			{
				curTime += 40000 * elapsed * (left ? -1 : 1);
			}

			var difference:Float = Math.abs(curTime - FlxG.sound.music.time);
			if(curTime + difference > FlxG.sound.music.length) curTime = FlxG.sound.music.length;
			else if(curTime - difference < 0) curTime = 0;

			FlxG.sound.music.time = curTime;
			setVocalsTime(curTime);
		}

		if(controls.UI_LEFT_R || controls.UI_RIGHT_R)
			justReleased();

		if (controls.UI_UP_P)
		{
			holdPitchTime = 0;
			playbackRate += 0.05;
			setPlaybackRate();
		}
		else if (controls.UI_DOWN_P)
		{
			holdPitchTime = 0;
			playbackRate -= 0.05;
			setPlaybackRate();
		}
		if (controls.UI_DOWN || controls.UI_UP)
		{
			holdPitchTime += elapsed;
			if (holdPitchTime > 0.6)
			{
				playbackRate += 0.05 * (controls.UI_UP ? 1 : -1);
				setPlaybackRate();
			}
		}

		if(instance.allowMouse)
		{
			if((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed || FlxG.mouse.pressed || FlxG.mouse.justReleased) {
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				for(item in buttCollection.members)
					if(FlxG.mouse.overlaps(item) && !item.selected)
						changeButtSelection(false, buttCollection.members.indexOf(item));

				if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(buttCollection.members[buttSelected]))
					navPress();

				if(FlxG.mouse.justReleased) navRelease();
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}

			if(FlxG.mouse.wheel != 0)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
				changeButtSelection(FlxG.mouse.wheel < 0);
			}
		}
	
		if (controls.RESET)
		{
			playbackRate = 1;
			setPlaybackRate();

			FlxG.sound.music.time = 0;
			setVocalsTime(0);
		}

		if (playing)
		{
			if(FreeplayState.vocals != null)
				FreeplayState.vocals.volume = (FreeplayState.vocals.length > FlxG.sound.music.time) ? 0.8 : 0;
			if(FreeplayState.opponentVocals != null)
				FreeplayState.opponentVocals.volume = (FreeplayState.opponentVocals.length > FlxG.sound.music.time) ? 0.8 : 0;

			if((FreeplayState.vocals != null && FreeplayState.vocals.length > FlxG.sound.music.time && Math.abs(FlxG.sound.music.time - FreeplayState.vocals.time) >= 25) ||
			(FreeplayState.opponentVocals != null && FreeplayState.opponentVocals.length > FlxG.sound.music.time && Math.abs(FlxG.sound.music.time - FreeplayState.opponentVocals.time) >= 25))
			{
				pauseOrResume();
				setVocalsTime(FlxG.sound.music.time);
				pauseOrResume(true);
			}
		}

		positionSong();
		updateTimeTxt();
		updatePlaybackTxt();
	}

	private inline function navPress()
	{
		buttCollection.members[buttSelected].locked = true;
	}

	private inline function navRelease()
	{
		for(butt in buttCollection.members) butt.locked = false;
		buttCollection.members[buttSelected].selected = true;
	}

	function justPressed(left:Bool = false)
	{
		if (playing)
			wasPlaying = true;

		pauseOrResume();

		curTime = FlxG.sound.music.time - (left ? 1000 : -1000);
		instance.holdTime = 0;

		if (curTime < 0 && left)
			curTime = 0;

		if (curTime > FlxG.sound.music.length && !left)
			curTime = FlxG.sound.music.length;

		FlxG.sound.music.time = curTime;
		setVocalsTime(curTime);
	}

	function justReleased()
	{
		FlxG.sound.music.time = curTime;
		setVocalsTime(curTime);

		if (wasPlaying)
		{
			pauseOrResume(true);
			wasPlaying = false;
		}
	}

	function changeButtSelection(left:Bool = true, ?force:Int = -1)
	{
		buttCollection.members[buttSelected].selected = false;
		buttSelected = FlxMath.wrap(force != -1 ? force : buttSelected + (1 * (left ? 1 : -1)), 0, buttCollection.members.length - 1);
		buttCollection.members[buttSelected].selected = true;
	}

	function setVocalsTime(time:Float)
	{
		if (FreeplayState.vocals != null && FreeplayState.vocals.length > time)
			FreeplayState.vocals.time = time;
		if (FreeplayState.opponentVocals != null && FreeplayState.opponentVocals.length > time)
			FreeplayState.opponentVocals.time = time;
	}

	public function pauseOrResume(resume:Bool = false) 
	{
		if (resume)
		{
			if(!FlxG.sound.music.playing)
				FlxG.sound.music.resume();

			if (FreeplayState.vocals != null && FreeplayState.vocals.length > FlxG.sound.music.time && !FreeplayState.vocals.playing)
				FreeplayState.vocals.resume();
			if (FreeplayState.opponentVocals != null && FreeplayState.opponentVocals.length > FlxG.sound.music.time && !FreeplayState.opponentVocals.playing)
				FreeplayState.opponentVocals.resume();
		}
		else 
		{
			FlxG.sound.music.pause();

			if (FreeplayState.vocals != null)
				FreeplayState.vocals.pause();
			if (FreeplayState.opponentVocals != null)
				FreeplayState.opponentVocals.pause();
		}
	}

	public function switchPlayMusic()
	{
		FlxG.autoPause = (!playingMusic && ClientPrefs.data.autoPause);
		active = visible = playingMusic;

		instance.scoreBG.visible = instance.scoreText.visible = instance.canSelect = !playingMusic; //Hide Freeplay texts and boxes if playingMusic is true
		songTxt.visible = timeTxt.visible = songBG.visible = playbackTxt.visible = playbackBG.visible = progressBar.visible = buttCollection.members[buttSelected].selected = playingMusic; //Show Music Player texts and boxes if playingMusic is true
		@:privateAccess
		instance.playButton.visible = !playingMusic;

		for (i in playbackSymbols)
			i.visible = playingMusic;
		
		holdPitchTime = 0;
		instance.holdTime = 0;
		playbackRate = 1;
		updatePlaybackTxt();

		if (playingMusic)
		{
			instance.bottomText.text = Language.getPhrase('musicplayer_tip', 'Press SPACE to Pause / Press ESCAPE to Exit / Press R to Reset the Song');
			positionSong();
			
			progressBar.setRange(0, FlxG.sound.music.length);
			progressBar.setParent(FlxG.sound.music, "time");
			progressBar.numDivisions = 1600;

			updateTimeTxt();
		}
		else
		{
			progressBar.setRange(0, Math.POSITIVE_INFINITY);
			progressBar.setParent(null, "");
			progressBar.numDivisions = 0;

			if(instance.bottomText != null) instance.bottomText.text = instance.bottomString;
			instance.positionHighscore();
		}
		progressBar.updateBar();
	}

	function updatePlaybackTxt()
	{
		var text = "";
		if (playbackRate is Int)
			text = playbackRate + '.00';
		else
		{
			var playbackRate = Std.string(playbackRate);
			if (playbackRate.split('.')[1].length < 2) // Playback rates for like 1.1, 1.2 etc
				playbackRate += '0';

			text = playbackRate;
		}
		playbackTxt.text = text + 'x';
	}

	function positionSong() 
	{
		var length:Int = instance.songs[FreeplayState.curSelected].songName.length;
		var shortName:Bool = length < 5; // Fix for song names like Ugh, Guns
		songTxt.x = FlxG.width - songTxt.width - 6;
		if (shortName)
			songTxt.x -= 10 * length - length;
		songBG.scale.x = FlxG.width - songTxt.x + 12;
		if (shortName) 
			songBG.scale.x += 6 * length;
		songBG.x = FlxG.width - (songBG.scale.x / 2);
		timeTxt.x = Std.int(songBG.x + (songBG.width / 2));
		timeTxt.x -= timeTxt.width / 2;
		if (shortName)
			timeTxt.x -= length - 5;

		playbackBG.scale.x = playbackTxt.width + 30;
		playbackBG.x = songBG.x - (songBG.scale.x / 2);
		playbackBG.x -= playbackBG.scale.x;

		playbackTxt.x = playbackBG.x - playbackTxt.width / 2;
		playbackTxt.y = playbackTxt.height;

		progressBar.setGraphicSize(Std.int(songTxt.width), 5);
		progressBar.y = songTxt.y + songTxt.height + 10;
		progressBar.x = songTxt.x + songTxt.width / 2 - 15;
		if (shortName)
		{
			progressBar.scale.x += length / 2;
			progressBar.x -= length - 10;
		}

		for (i in 0...2)
		{
			var text = playbackSymbols[i];
			text.x = playbackTxt.x + playbackTxt.width / 2 - 10;
			text.y = playbackTxt.y;

			if (i == 0)
				text.y -= playbackTxt.height;
			else
				text.y += playbackTxt.height;
		}
	}

	function updateTimeTxt()
	{
		var text = FlxStringUtil.formatTime(FlxG.sound.music.time / 1000, false) + ' / ' + FlxStringUtil.formatTime(FlxG.sound.music.length / 1000, false);
		timeTxt.text = '< ' + text + ' >';
	}

	function setPlaybackRate() 
	{
		FlxG.sound.music.pitch = playbackRate;
		if (FreeplayState.vocals != null)
			FreeplayState.vocals.pitch = playbackRate;
		if (FreeplayState.opponentVocals != null)
			FreeplayState.opponentVocals.pitch = playbackRate;
	}

	function get_playing():Bool 
	{
		return FlxG.sound.music.playing;
	}

	function set_goLeft(left:Bool):Bool
	{
		if(left) justPressed(true) else justReleased();
		goLeft = left;
		return left;
	}

	function set_goRight(right:Bool):Bool
	{
		if(right) justPressed() else justReleased();
		goRight = right;
		return right;
	}

	function set_playbackRate(value:Float):Float 
	{
		var value = FlxMath.roundDecimal(value, 2);
		if (value > 3) value = 3;
		else if (value <= 0.25) value = 0.25;
		return playbackRate = value;
	}
}