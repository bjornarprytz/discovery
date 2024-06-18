class_name SteamStatsAndAchievementManager
extends Resource

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

func has_each_achievement(achievementKeys: Array) -> bool:
    for achievementKey in achievementKeys:
        if !_achievement_cache.has(achievementKey):
            var achievement = Steam.getAchievement(achievementKey)
            
            if !achievement.ret:
                push_error("Achievement not found: " + achievementKey)
                return false
            
            _achievement_cache[achievementKey] = achievement

        if !_achievement_cache[achievementKey].achieved:
            return false
    
    return true

func clearAchievement(achievementKey: String):
    Steam.clearAchievement(achievementKey)

func save():
    Steam.storeStats()
