package states;

import flixel.FlxSubState;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import objects.VideoSprite;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var isYes:Bool = true;
	var texts:FlxTypedSpriteGroup<FlxText>;
	var bg:FlxSprite;
	var video:VideoSprite;
	var madeChoice:Bool = false;

	override function create()
	{
		super.create();

		//bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		//add(bg);

		texts = new FlxTypedSpriteGroup<FlxText>();
		texts.alpha = 0.0;
		add(texts);

		final warnText:FlxText = new FlxText(0, 0, FlxG.width - 20,
			'Hey you!\n
			Vs. Dami contains some flashing lights that may not be suitable for all audiences.\n
			Do you wish to disable them?\n\n');
		warnText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		texts.add(warnText);

		final keys = ["Yes", "No"];
		for (i in 0...keys.length) {
			final button = new FlxText(0, 0, FlxG.width, keys[i]);
			button.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
			button.y = (warnText.y + warnText.height) + 24;
			button.x += (128 * i) - 80;
			texts.add(button);
		}

		final directionText:FlxText = new FlxText(0, 0, FlxG.width,
			'(${CoolUtil.getKey('ui_left')} and ${CoolUtil.getKey('ui_right')} to navigate; ${CoolUtil.getKey('accept')} to accept.
			(You can also press ${CoolUtil.getKey('back')}, but you\'ll just keep getting this screen.)');
		directionText.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		directionText.screenCenter(Y);
		directionText.y = (texts.members[1].y + texts.members[1].height) + 24;
		texts.add(directionText);

		FlxTween.tween(texts, {alpha: 1.0}, 0.5, {
			onComplete: (_) -> updateItems()
		});
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			super.update(elapsed);
			return;
		}
		var back:Bool = controls.BACK;
		if(madeChoice) {
			if(controls.ACCEPT) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				if(!isYes) FlxFlicker.flicker(texts.members[0], 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							FlxTween.tween(texts, {alpha: 0}, 0.2, {
								onComplete: (_) -> completeSystem()
							});
						});
					})
					else FlxTween.tween(texts, {alpha: 0}, 1.7, {onComplete: function(twn:FlxTween) {
						completeSystem();
					}});
			}
		} else {
			if (controls.UI_LEFT_P || controls.UI_RIGHT_P) {
				FlxG.sound.play(Paths.sound("scrollMenu"), 0.7);
				isYes = !isYes;
				updateItems();
			}
			if (controls.ACCEPT || back) {
				if(!back) {
					ClientPrefs.data.flashing = !isYes;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					madeChoice = true;
					for (i in 0...texts.members.length) switch(i) {
						case 0:
							texts.members[i].text = 'Flashing lights are currently ${isYes ? 'DISABLED' : 'ENABLED'}.\n
							You will no longer see this screen at startup. If you change your mind at any point, remember you can ${isYes ? 'enable' : 'disable'} flashing lights in the Options menu, under the Visuals options.\n
							Press ${CoolUtil.getKey('accept')} to continue. Have fun!';
							texts.members[i].screenCenter(Y);
							continue;

						default:
							texts.members[i].alpha = 0;
					}
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(texts, {alpha: 0}, 1, {
						onComplete: (_) -> completeSystem()
					});
				}
			}
		}
		super.update(elapsed);
	}

	function completeSystem() {
		#if VIDEOS_ALLOWED
		video = new VideoSprite(Paths.video('viewerslikeyou'), false, false, false);
		video.finishCallback = () -> MusicBeatState.switchState(new TitleState());
		add(video);
		FlxG.save.data.firstTime = true;
		FlxG.save.flush();
		video.play();
		#else
		MusicBeatState.switchState(new TitleState());
		#end
	}
	function updateItems() {
		// it's clunky but it works.
		texts.members[1].alpha = isYes ? 1.0 : 0.6;
		texts.members[2].alpha = isYes ? 0.6 : 1.0;
	}
}
