class_name SteamLeaderboardManager

class LeaderBoardEntry:
    var rank: int
    var steam_id: int
    var score: int

    func _init(entry: Dictionary) -> void:
        rank = entry["global_rank"]
        steam_id = entry["steam_id"]
        score = entry["score"]

var _leaderboardFound = false
var _leaderboardName: String

func _init(leaderboardName: String) -> void:
    _leaderboardName = leaderboardName

func _subscribe_to_leaderboard(leaderboardKey: String) -> bool:
    if !_leaderboardFound:
        Steam.findOrCreateLeaderboard(leaderboardKey, Steam.LEADERBOARD_SORT_METHOD_ASCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
        
        var result = await Steam.leaderboard_find_result as Array
        
        if result.size() < 2||result[1] != 1: # Found
            push_error("Leaderboard not found: " + leaderboardKey)
            return false
        
        var handle = result[0]

        print("Leaderboard found: " + str(handle))

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