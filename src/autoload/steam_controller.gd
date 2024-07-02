class_name SteamConnector
extends Node2D

class SteamUser:
	var steam_id: int
	var name: String

	func _init(steam_id_: int, username: String):
		steam_id = steam_id_
		name = username

class SessionTracking:
	var words_this_session: int
	var quest_streak: int
	var _white_rabbit_progress: Array[String] = []

	func check_for_white_rabbit(word: String) -> bool:
		if _white_rabbit_progress.size() < 2 and (word.nocasecmp_to("white") == 0 or word.nocasecmp_to("rabbit") == 0):
			if not _white_rabbit_progress.has(word):
				_white_rabbit_progress.append(word)
			
			if _white_rabbit_progress.size() == 2:
				return true
		
		return false
	
	func check_longest_word(word: String) -> bool:
		return word.length() == Corpus.lengthOfLongestWord

var _stats: SteamStatsAndAchievementManager
var _leaderboard: SteamLeaderboardManager
var _user: SteamUser
var _session: SessionTracking

var _is_initialized: bool = false

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
	_session = SessionTracking.new()
	_user = _fetch_user()
	
	# _reset_progress() # Use this to test the achievements

	Game.completed_word.connect(_on_completed_word)
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

func _on_moved(_prev_pos: int, current_pos: int, _direction: Vector2, _score_change: int):
	_stats.increment_stat("letters_typed")
	_stats.save()

	if _current_scene_name == "Main":
		Steam.setRichPresence("CORPUS", Corpus.get_chapter_at(current_pos).title)
		Steam.setRichPresence("SCORE", str(Game.score))
		Steam.setRichPresence("steam_display", "#Playing")

func _on_completed_word(word: String, was_quest: bool):
	_stats.complete_achievement("FirstWord")
	_stats.increment_stat("words_completed")
	if was_quest:
		_stats.complete_achievement("FirstQuest")
		_stats.increment_stat("quests_completed")
		_session.quest_streak += 1
		match _session.quest_streak:
			2:
				_stats.complete_achievement("QuestStreak_2")
			4:
				_stats.complete_achievement("QuestStreak_4")
			8:
				_stats.complete_achievement("QuestStreak_8")
			16:
				_stats.complete_achievement("QuestStreak_16")
	
	_session.words_this_session += 1 # This counts the "easter egg" retry menu, but that's fine

	match _session.words_this_session:
		10:
			_stats.complete_achievement("WordsOneSession_10")
		20:
			_stats.complete_achievement("WordsOneSession_20")
		40:
			_stats.complete_achievement("WordsOneSession_40")
		100:
			_stats.complete_achievement("WordsOneSession_100")
	
	if _session.check_for_white_rabbit(word):
		_stats.complete_achievement("WhiteRabbit")
	
	if _current_scene_name == "Score" and word.to_lower() == "secret":
		_stats.complete_achievement("SecretEntrance")
		
	if _current_scene_name == "Game" and _session.check_longest_word(word):
		_stats.complete_achievement("LongestWord")

	if _stats.has_each_achievement(achievements.filter(func(a: String): return a != "AllAchievements")):
		_stats.complete_achievement("AllAchievements")

	_stats.save()

func _on_game_over(score: int):
	_session = SessionTracking.new()

	await _leaderboard.post_score(score)

func _on_golden_changed(_is_golden: bool):
	if !_is_golden:
		_session.quest_streak = 0

func _reset_progress():
	for stat in stats:
		_stats.set_stat(stat, 0)
	
	for achievement in achievements:
		_stats.clearAchievement(achievement)
	
	_stats.save()

var stats: Array[String] = [
		"letters_typed",
		"words_completed",
		"quests_completed"
		]
var achievements: Array[String] = [
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
	"LongestWord",
	"SecretEntrance",
	"WhiteRabbit",
	"AllAchievements"
]
