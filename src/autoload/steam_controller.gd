class_name SteamConnector
extends Node2D

class SteamUser:
	var steam_id: int
	var name: String

	func _init(steam_id_: int, username: String):
		steam_id = steam_id_
		name = username

var _stats: SteamStatsAndAchievementManager
var _leaderboard: SteamLeaderboardManager
var _user: SteamUser

var _words_this_session: int = 0
var _quest_streak: int = 0

func get_leaderboard(start: int, end: int) -> Array[SteamLeaderboardManager.LeaderboardEntry]:
	return await _leaderboard.get_leaderboard(start, end)

func get_user() -> SteamUser:
	return _user

func _ready() -> void:
	Steam.steamInit()
	
	var isSteamRunning = Steam.isSteamRunning()
	
	if !isSteamRunning:
		queue_free()
		return

	_stats = SteamStatsAndAchievementManager.new()
	_leaderboard = SteamLeaderboardManager.new("BookWormLeaderboard")
	_user = _fetch_user()
	
	_reset_progress() # TODO: Remove this once I'm done testing

	Game.completed_word.connect(_on_completed_word)
	Game.moved.connect(_on_moved)
	Game.game_over.connect(_on_game_over)
	Game.golden_changed.connect(_on_golden_changed)

func _process(_delta: float) -> void:
	Steam.run_callbacks() # This is necessary to get the callbacks from Steam (like leaderboards)

func _fetch_user():
	var steamID = Steam.getSteamID()
	var username = Steam.getFriendPersonaName(steamID)
	var user = SteamUser.new(steamID, username)
	return user

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

	await _leaderboard.post_score(score)

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
