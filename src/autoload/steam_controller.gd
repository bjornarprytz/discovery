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

var _is_initialized: bool = false

var _words_this_session: int = 0
var _quest_streak: int = 0

var _current_scene_name: String = ""

func is_initialized() -> bool:
	_try_initialize()
	
	return _is_initialized

func get_leaderboard(start: int, end: int, scope: Steam.LeaderboardDataRequest) -> Array[SteamLeaderboardManager.LeaderboardEntry]:
	_try_initialize()
	
	if !_is_initialized:
		return []
	
	return await _leaderboard.get_leaderboard(start, end, scope)

func get_user() -> SteamUser:
	_try_initialize()

	return _user

func _ready() -> void:
	_try_initialize()

func _try_initialize():
	if _is_initialized:
		return

	Steam.steamInit()
	
	var isSteamRunning = Steam.isSteamRunning()
	
	if !isSteamRunning:
		return

	_stats = SteamStatsAndAchievementManager.new()
	_leaderboard = SteamLeaderboardManager.new("BookWormLeaderboard")
	_user = _fetch_user()
	
	_reset_progress() # TODO: Remove this once I'm done testing

	Game.completed_word.connect(_on_completed_word)
	Game.new_quest.connect(_on_new_quest)
	Game.moved.connect(_on_moved)
	Game.game_over.connect(_on_game_over)
	Game.golden_changed.connect(_on_golden_changed)

	get_tree().tree_changed.connect(_on_tree_changed)

	_is_initialized = true

func _process(_delta: float) -> void:
	Steam.run_callbacks() # This is necessary to get the callbacks from Steam (like leaderboards)

func _fetch_user():
	var steamID = Steam.getSteamID()
	var username = Steam.getFriendPersonaName(steamID)
	var user = SteamUser.new(steamID, username)
	return user

func _on_tree_changed():
	var tree = get_tree()
	if tree == null:
		return
	
	var current_scene = tree.get_current_scene()
	if current_scene == null:
		return
	
	if current_scene.name == _current_scene_name:
		return
	
	_current_scene_name = current_scene.name

	if current_scene.name == "Options":
		Steam.setRichPresence("steam_display", "#Settings")
	elif current_scene.name == "Score":
		Steam.setRichPresence("steam_display", "#ScoreScreen")

func _on_new_quest(word: String):
	Steam.setRichPresence("CORPUS", "A Mad Tea-Party")
	Steam.setRichPresence("QUEST", word)
	Steam.setRichPresence("steam_display", "#Playing")

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
