package substates;

import backend.Highscore;
import backend.WeekData;
import flixel.FlxSubState;
import objects.HealthIcon;

class ResetScoreSubState extends MusicBeatSubstate
{
	var bg:FlxSprite;
	var alphabetArray:Array<Alphabet> = [];
	var icon:HealthIcon;
	var onYes:Bool = false;
	var yesText:Alphabet;
	var noText:Alphabet;

	var song:String;
	var week:Int;

	var allowMouse:Bool = ClientPrefs.data.mouseUI;

	// Week -1 = Freeplay
	public function new(song:String, character:String, week:Int = -1)
	{
		this.song = song;
		this.week = week;

		FlxG.mouse.visible = allowMouse;

		super();

		var name:String = song;
		if(week > -1) {
			name = WeekData.weeksLoaded.get(WeekData.weeksList[week]).weekName + '?';
		}

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var tooLong:Float = (name.length > 18) ? 0.8 : 1; //Fucking Winter Horrorland
		var text:Alphabet = new Alphabet(0, 180, Language.getPhrase('reset_score', 'Reset the score of'), true);
		text.screenCenter(X);
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);
		var text:Alphabet = new Alphabet(0, text.y + 90, name, true);
		text.scaleX = tooLong;
		text.screenCenter(X);
		if(week == -1) text.x += 60 * tooLong;
		alphabetArray.push(text);
		text.alpha = 0;
		add(text);
		if(week == -1) {
			icon = new HealthIcon(character);
			icon.setGraphicSize(Std.int(icon.width * tooLong));
			icon.updateHitbox();
			icon.setPosition(text.x - icon.width + (10 * tooLong), text.y - 30);
			icon.alpha = 0;
			add(icon);
		}

		yesText = new Alphabet(0, text.y + 150, Language.getPhrase('Yes'), true);
		yesText.screenCenter(X);
		yesText.x -= 200;
		add(yesText);
		noText = new Alphabet(0, text.y + 150, Language.getPhrase('No'), true);
		noText.screenCenter(X);
		noText.x += 200;
		add(noText);
		
		for(letter in yesText.letters) letter.color = FlxColor.RED;
		updateOptions();
	}

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		bg.alpha += elapsed * 1.5;
		if(bg.alpha > 0.6) bg.alpha = 0.6;

		for (i in 0...alphabetArray.length) {
			var spr = alphabetArray[i];
			spr.alpha += elapsed * 2.5;
		}
		if(week == -1) icon.alpha += elapsed * 2.5;

		if(allowMouse) {
			if((FlxG.mouse.overlaps(yesText) && !onYes) || (FlxG.mouse.overlaps(noText) && onYes)) {
				FlxG.sound.play(Paths.sound('scrollMenu'), 1);
				onYes = !onYes;
				updateOptions();
			}

			if(FlxG.mouse.overlaps(yesText)) {
				if(FlxG.mouse.pressed && yesText.scale.x != 0.8) yesText.scale.set(0.8, 0.8)
					else if(!FlxG.mouse.pressed && yesText.scale.x != 1.1) yesText.scale.set(1.1, 1.1);
			} else if(yesText.scale.x != 1) yesText.scale.set(1, 1);

			if(FlxG.mouse.overlaps(noText)) {
				if(FlxG.mouse.pressed && noText.scale.x != 0.8) noText.scale.set(0.8, 0.8)
					else if(!FlxG.mouse.pressed && noText.scale.x != 1.1) noText.scale.set(1.1, 1.1);
			} else if(noText.scale.x != 1) noText.scale.set(1, 1);

			if ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				FlxG.mouse.visible = true;
				timeNotMoving = 0;
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}
		}

		if(controls.UI_LEFT_P || controls.UI_RIGHT_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'), 1);
			onYes = !onYes;
			updateOptions();
		}
		if(controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		} else if(controls.ACCEPT || (allowMouse && (FlxG.mouse.overlaps(yesText) || FlxG.mouse.overlaps(noText)) && FlxG.mouse.justPressed)) {
			if(onYes) {
				if(week == -1) {
					Highscore.resetSong(song);
				} else {
					Highscore.resetWeek(WeekData.weeksList[week]);
				}
			}
			FlxG.sound.play(Paths.sound('cancelMenu'), 1);
			close();
		}
		super.update(elapsed);
	}

	function updateOptions() {
		var scales:Array<Float> = [0.75, 1];
		var alphas:Array<Float> = [0.6, 1.25];
		var confirmInt:Int = onYes ? 1 : 0;

		yesText.alpha = alphas[confirmInt];
		yesText.scale.set(scales[confirmInt], scales[confirmInt]);
		noText.alpha = alphas[1 - confirmInt];
		noText.scale.set(scales[1 - confirmInt], scales[1 - confirmInt]);
		if(week == -1) icon.animation.curAnim.curFrame = confirmInt;
	}
}