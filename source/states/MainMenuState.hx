package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import objects.MenuButton;
import options.OptionsState;
import states.editors.MasterEditorMenu;
import states.editors.content.Prompt;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '1.0.4'; // This is also used for Discord RPC
	public static var fnfVersion:String = '0.1.1'; // This is also also used for Discord RPC
	public static var curSelected:Int = 3;
	var allowMouse:Bool = ClientPrefs.data.mouseUI; //Turn this off to block mouse movement in menus

	var menuItems:FlxTypedSpriteGroup<MenuButton>;

	//Centered/Text options
	var optionShit:Array<Array<Dynamic>> = [
		['credits', 25, 360],
		['gallery', 19, 20],
		['damiverse', 182, 26],
		['story', 263, 36],
		['extras', 849, 385],
		['freeplay', 906, 5],
		['settoing', 1190, 7],
		['exit', 880, 610],
	];

	override function create()
	{
		super.create();

		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menubackgrounds/background'));
		bg.antialiasing = ClientPrefs.data.antialiasing;
		bg.screenCenter();
		add(bg);

		menuItems = new FlxTypedSpriteGroup<MenuButton>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:MenuButton = new MenuButton(optionShit[i][1], optionShit[i][2], 'menus/main/' + optionShit[i][0] + (i < 6 ? '-unselect' : ''));
			menuItem.onSelect = function() {
				if(i == 0 || i == 3 || (i == 5 && backend.Highscore.getWeekScore('week1') > 0) || (i > 5 && i < 7)) {
					FlxG.sound.play(Paths.sound('confirmMenu'));
					for(item in menuItems)
						if(menuItems.members.indexOf(item) != i) FlxTween.tween(item, { alpha: 0 }, 1) else if(ClientPrefs.data.flashing) FlxFlicker.flicker(item, 1.1, 0.15, false);
					new FlxTimer().start(1.5, function(tmr:FlxTimer) {
						switch(i) {
							case 3: MusicBeatState.switchState(new StoryMenuState());
							case 0:
								FlxG.sound.music.stop();
								MusicBeatState.switchState(new CreditsState());
							case 5:
								FlxG.sound.music.stop();
								MusicBeatState.switchState(new FreeplayState());
							case 6:
								FlxG.sound.music.stop();
								MusicBeatState.switchState(new OptionsState());
						}
					});
				} else {
					FlxG.sound.play(Paths.sound('cancelMenu'));
					switch(i) {
						case 1 | 2 | 4:
							openSubState(new Prompt("This is currently not available in the demo. Coming soon for V1!", closeSubState, null, 'OK', null, true));
						case 5:
							openSubState(new Prompt("Complete Story Mode Week 1 to unlock Freeplay!", closeSubState, null, 'OK', null, true));
						case 7:
							openSubState(new Prompt('Are you sure you want to quit Vs Dami?', () -> Sys.exit(0), closeSubState, 'Yes', 'No'));
					}
				}
			};
			menuItem.antialiasing = ClientPrefs.data.antialiasing;
			menuItems.add(menuItem);
		}

		var damiVer:FlxText = new FlxText(12, FlxG.height - 64, 0, "Vs Dami v" + Application.current.meta.get('version'), 12);
		damiVer.scrollFactor.set();
		damiVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(damiVer);
		var psychVer:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		psychVer.scrollFactor.set();
		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(psychVer);
		var fnfVer:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + fnfVersion, 12);
		fnfVer.scrollFactor.set();
		fnfVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(fnfVer);
		changeItem();
	}

	var selectedSomethin:Bool = false;

	var timeNotMoving:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume = Math.min(FlxG.sound.music.volume + 0.5 * elapsed, 0.8);

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P || controls.UI_LEFT_P || (allowMouse && FlxG.mouse.wheel > 0))
				changeItem(-1);

			if (controls.UI_DOWN_P || controls.UI_RIGHT_P || (allowMouse && FlxG.mouse.wheel < 0))
				changeItem(1);

			if (allowMouse && ((FlxG.mouse.deltaScreenX != 0 && FlxG.mouse.deltaScreenY != 0) || FlxG.mouse.justPressed)) //FlxG.mouse.deltaScreenX/Y checks is more accurate than FlxG.mouse.justMoved
			{
				FlxG.mouse.visible = true;
				timeNotMoving = 0;

				for(item in menuItems)
					if(!FlxG.mouse.overlaps(menuItems.members[curSelected])
						&& FlxG.mouse.overlaps(item)
						&& item.getPixelAtScreen(FlxG.mouse.getScreenPosition()) != FlxColor.TRANSPARENT
						&& !item.selected) changeItem(menuItems.members.indexOf(item), true);

				if(FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuItems.members[curSelected])) menuItems.members[curSelected].pressed = true;
			}
			else
			{
				timeNotMoving += elapsed;
				if(timeNotMoving > 2) FlxG.mouse.visible = false;
			}


			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT || (FlxG.mouse.justPressed && allowMouse))
			{
				selectedSomethin = true;
				menuItems.members[curSelected].locked = true;
			}
			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				FlxG.mouse.visible = false;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);
	}

	function changeItem(change:Int = 0, force:Bool = false)
	{
		if(force && menuItems.members[change].selected) return;
		menuItems.members[curSelected].selected = false;
		curSelected = FlxMath.wrap(force ? change : (curSelected + change), 0, optionShit.length - 1);
		FlxG.sound.play(Paths.sound('scrollMenu'));
		menuItems.members[curSelected].selected = true;
	}

	override public function openSubState(subState:flixel.FlxSubState)
	{
		persistentUpdate = false;
		super.openSubState(subState);
	}

	override public function closeSubState()
	{
		super.closeSubState();
		persistentUpdate = true;
		new FlxTimer().start(0.1, function(tmr:FlxTimer) {
			menuItems.members[curSelected].locked = false;
			menuItems.members[curSelected].selected = true;
			selectedSomethin = false;
		}, 1);
	}
}
