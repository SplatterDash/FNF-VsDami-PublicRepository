package backend;

class Highscore
{
	public static var weekScores:Map<String, Int> = new Map();
	public static var songScores:Map<String, Int> = new Map<String, Int>();
	public static var songRating:Map<String, Float> = new Map<String, Float>();
	public static var songClears:Map<String, String> = new Map<String, String>();
	public static final clearOps:Array<String> = ['SFC', 'GFC', 'FC', 'SDCB', 'Clear'];

	public static function resetSong(song:String):Void
	{
		var daSong:String = formatSong(song);
		setScore(daSong, 0);
		setRating(daSong, 0);
		songClears.remove(daSong);
	}

	public static function resetWeek(week:String):Void
	{
		var daWeek:String = formatSong(week);
		setWeekScore(daWeek, 0);
	}

	public static function saveScore(song:String, score:Int = 0, ?rating:Float = -1, clear:String = "Clear"):Void
	{
		if(song == null) return;
		var daSong:String = formatSong(song);

		if (songScores.exists(daSong))
		{
			if (songScores.get(daSong) < score || clearOps.indexOf(songClears.get(daSong)) > clearOps.indexOf(clear))
			{
				setScore(daSong, score);
				if(rating >= 0) setRating(daSong, rating);
				setClears(daSong, clear);
			}
		}
		else
		{
			setScore(daSong, score);
			if(rating >= 0) setRating(daSong, rating);
			setClears(daSong, clear);
		}
	}

	public static function saveWeekScore(week:String, score:Int = 0):Void
	{
		var daWeek:String = formatSong(week);

		if (weekScores.exists(daWeek))
		{
			if (weekScores.get(daWeek) < score)
				setWeekScore(daWeek, score);
		}
		else setWeekScore(daWeek, score);
	}

	/**
	 * YOU SHOULD FORMAT SONG WITH formatSong() BEFORE TOSSING IN SONG VARIABLE
	 */
	static function setScore(song:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songScores.set(song, score);
		FlxG.save.data.songScores = songScores;
		FlxG.save.flush();
	}
	static function setWeekScore(week:String, score:Int):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		weekScores.set(week, score);
		FlxG.save.data.weekScores = weekScores;
		FlxG.save.flush();
	}

	static function setRating(song:String, rating:Float):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songRating.set(song, rating);
		FlxG.save.data.songRating = songRating;
		FlxG.save.flush();
	}

	static function setClears(song:String, rating:String):Void
	{
		// Reminder that I don't need to format this song, it should come formatted!
		songClears.set(song, rating);
		FlxG.save.data.songClears = songClears;
		FlxG.save.flush();
	}

	public static function formatSong(song:String):String
	{
		return Paths.formatToSongPath(song);
	}

	public static function getScore(song:String):Int
	{
		var daSong:String = formatSong(song);
		if (!songScores.exists(daSong))
			setScore(daSong, 0);

		return songScores.get(daSong);
	}

	public static function getRating(song:String):Float
	{
		var daSong:String = formatSong(song);
		if (!songRating.exists(daSong))
			setRating(daSong, 0);

		return songRating.get(daSong);
	}

	public static function getWeekScore(week:String):Int
	{
		var daWeek:String = formatSong(week);
		if (!weekScores.exists(daWeek))
			setWeekScore(daWeek, 0);

		return weekScores.get(daWeek);
	}

	public static function getClear(song:String):String
	{
		var daSong:String = formatSong(song);
		if (!songClears.exists(daSong)) return ""
			else return songClears.get(daSong);
	}

	public static function load():Void
	{
		if (FlxG.save.data.weekScores != null)
			weekScores = FlxG.save.data.weekScores;

		if (FlxG.save.data.songScores != null)
			songScores = FlxG.save.data.songScores;

		if (FlxG.save.data.songRating != null)
			songRating = FlxG.save.data.songRating;

		if (FlxG.save.data.songClears != null)
			songClears = FlxG.save.data.songClears;
	}

	public static function checkForCompletion()
	{
		var count:Int = 0;
		for(key in songScores.keys())
			if(songScores[key] > 0) count++;
		if(count == 11) states.FreeplayState.finale = true;
	}
}