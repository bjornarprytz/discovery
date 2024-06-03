class_name SteamConnector
extends Node2D

class LeaderBoardEntry:
	var rank: int
	var steam_id: int
	var score: int

	func _init(entry: Dictionary) -> void:
		rank = entry["global_rank"]
		steam_id = entry["steam_id"]
		score = entry["score"]

class Stats:
	var _stat_cache: Dictionary = {}
	var _achievement_cache: Dictionary = {}
	var _leaderboardFound: bool
	
	func increment_stat(statKey: String, amount: int=1):
		if !_stat_cache.has(statKey):
			_stat_cache[statKey] = Steam.getStatInt(statKey)
		
		_stat_cache[statKey] += amount
		
		Steam.setStatInt(statKey, _stat_cache[statKey])
	
	func set_stat(statKey: String, value):
		if !_stat_cache.has(statKey):
			_stat_cache[statKey] = Steam.getStatInt(statKey)
		
		_stat_cache[statKey] = value
		
		Steam.setStatInt(statKey, _stat_cache[statKey])
	
	func complete_achievement(achievementKey: String):
		if !_achievement_cache.has(achievementKey):
			var achievement = Steam.getAchievement(achievementKey)
			
			if !achievement.ret:
				push_error("Achievement not found: " + achievementKey)
				return
			
			_achievement_cache[achievementKey] = achievement
		
		if !_achievement_cache[achievementKey].achieved:
			Steam.setAchievement(achievementKey)
			_achievement_cache[achievementKey].achieved = true
	
	func _subscribe_to_leaderboard(leaderboardKey: String) -> bool:
		if !_leaderboardFound:
			Steam.findOrCreateLeaderboard(leaderboardKey, Steam.LEADERBOARD_SORT_METHOD_ASCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
			
			var result = await Steam.leaderboard_find_result as Array
			
			if result.size() < 2||result[1] != 1: # Found
				push_error("Leaderboard not found: " + leaderboardKey)
				return false
			
			var handle = result[0]

			print("Leaderboard found: " + handle)

			_leaderboardFound = true
		return true
	
	func post_score(leaderboardKey: String, score: int):
		if !_leaderboardFound:
			_leaderboardFound = await _subscribe_to_leaderboard(leaderboardKey)

		Steam.uploadLeaderboardScore(score)
		
		var result = await Steam.leaderboard_score_uploaded

		if result.size() < 3||result[0] == false:
			push_error("Failed to upload score")
			return
	
	func get_leaderboard(start: int, end: int) -> Array[LeaderBoardEntry]:
		Steam.downloadLeaderboardEntries(start, end, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER)
		
		var result = await Steam.leaderboard_scores_downloaded as Array
		
		if result.size() < 3:
			push_error("Leaderboard not found")
			return []

		var entries: Array[LeaderBoardEntry] = []
		
		for entry in result[2]:
			entries.append(LeaderBoardEntry.new(entry))

		return entries

	func clearAchievement(achievementKey: String):
		Steam.clearAchievement(achievementKey)

	func save():
		Steam.storeStats()

var _stats: Stats = Stats.new()
var _words_this_session: int = 0
var _quest_streak: int = 0

func get_leaderboard() -> Array[LeaderBoardEntry]:
	return await _stats.get_leaderboard(0, 100)

func _ready() -> void:
	Steam.steamInit()
	
	var isSteamRunning = Steam.isSteamRunning()
	
	assert(isSteamRunning, "Steam is not running!")
	
	_reset_progress() # TODO: Remove this once I'm done testing

	Game.completed_word.connect(_on_completed_word)
	Game.moved.connect(_on_moved)
	Game.game_over.connect(_on_game_over)
	Game.golden_changed.connect(_on_golden_changed)

func _process(_delta: float) -> void:
	Steam.run_callbacks() # This is necessary to get the callbacks from Steam (like leaderboards)

func _on_moved(_prev_pos: int, _current_pos: int, _direction: Vector2, _score_change: int):
	_stats.increment_stat("letters_typed")
	_stats.save()

func _on_completed_word(_word: String, was_quest: bool):
	_stats.complete_achievement("FirstWord")
	_stats.increment_stat("words_completed")
	if was_quest:
		_stats.complete_achievement("FirstQuest")
		_stats.increment_stat("quests_completed")
		_quest_streak += 1
		match _quest_streak:
			2:
				_stats.complete_achievement("QuestStreak_2")
			4:
				_stats.complete_achievement("QuestStreak_4")
			8:
				_stats.complete_achievement("QuestStreak_8")
			16:
				_stats.complete_achievement("QuestStreak_16")
	
	_words_this_session += 1 # This counts the "easter egg" retry menu, but that's fine

	match _words_this_session:
		10:
			_stats.complete_achievement("WordsOneSession_10")
		20:
			_stats.complete_achievement("WordsOneSession_20")
		40:
			_stats.complete_achievement("WordsOneSession_40")
		100:
			_stats.complete_achievement("WordsOneSession_100")
	
	_stats.save()

func _on_game_over(score: int):
	_words_this_session = 0
	_quest_streak = 0
	_stats.post_score("BookWormLeaderboard", score)

func _on_golden_changed(_is_golden: bool):
	if !_is_golden:
		_quest_streak = 0

func _reset_progress():
	var stats = [
		"letters_typed",
		"words_completed",
		"quests_completed"
		]
	var achievements = [
		"FirstWord",
		"Words_1001",
		"Letters_10",
		"Letters_100",
		"Letters_500",
		"Letters_1000",
		"Letters_10000",
		"FirstQuest",
		"Quests_5",
		"Quests_10",
		"Quests_20",
		"Quests_50",
		"Quests_100",
		"WordsOneSession_10",
		"WordsOneSession_20",
		"WordsOneSession_40",
		"WordsOneSession_100",
		"QuestStreak_2",
		"QuestStreak_4",
		"QuestStreak_8",
		"QuestStreak_16",
	]

	for stat in stats:
		_stats.set_stat(stat, 0)
	
	for achievement in achievements:
		_stats.clearAchievement(achievement)
	
	_stats.save()
