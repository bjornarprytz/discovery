class_name SteamConnector
extends Node2D

class Stats:
    var _stat_cache: Dictionary = {}
    var _achievement_cache: Dictionary = {}
    
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
    
    func clearAchievement(achievementKey: String):
        Steam.clearAchievement(achievementKey)

    func save():
        Steam.storeStats()

var _stats: Stats = Stats.new()

func _ready() -> void:
    Steam.steamInit()
    
    var isSteamRunning = Steam.isSteamRunning()
    
    assert(isSteamRunning, "Steam is not running!")
    
    _reset_progress() # TODO: Remove this once I'm done testing

    Game.completed_word.connect(_on_completed_word)
    Game.moved.connect(_on_moved)

func _on_moved(_prev_pos: int, _current_pos: int, _direction: Vector2, _score_change: int):
    _stats.increment_stat("letters_typed")
    _stats.save()

func _on_completed_word(_word: String, was_quest: bool):
    _stats.complete_achievement("FirstWord")
    _stats.increment_stat("words_completed")
    if was_quest:
        _stats.complete_achievement("FirstQuest")
        _stats.increment_stat("quests_completed")
    
    _stats.save()

func _reset_progress():
    var stats = [
        "letters_typed",
        "words_completed",
        "quests_completed"
        ]
    var achievements = [
        "FirstWord",
        "Letters_10",
        "Letters_100",
        "Letters_500",
        "Letters_1000",
        "Letters_10000",
        "FirstQuest"
    ]

    for stat in stats:
        _stats.set_stat(stat, 0)
    
    for achievement in achievements:
        _stats.clearAchievement(achievement)
    
    _stats.save()