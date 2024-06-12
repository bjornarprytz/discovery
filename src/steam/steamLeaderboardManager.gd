class_name SteamLeaderboardManager

class LeaderboardEntry:
    var rank: int
    var steam_id: int
    var name: String
    var score: int

    func _init(entry: Dictionary) -> void:
        rank = entry["global_rank"]
        steam_id = entry["steam_id"]
        score = entry["score"]

        name = Steam.getFriendPersonaName(steam_id)

var _leaderboardFound = false
var _leaderboardName: String

func get_leaderboard(start: int, end: int) -> Array[LeaderboardEntry]:
    if !_leaderboardFound:
        await _subscribe_to_leaderboard()

    Steam.downloadLeaderboardEntries(start, end, Steam.LEADERBOARD_DATA_REQUEST_GLOBAL_AROUND_USER)
    
    var entries = await _await_leaderboard_download_result()

    return entries

func post_score(score: int):
    if !_leaderboardFound:
        await _subscribe_to_leaderboard()

    Steam.uploadLeaderboardScore(score)
    
    var result = await Steam.leaderboard_score_uploaded

    if result.size() < 3 or result[0] == 0:
        push_error("Failed to upload score")
        return

func _init(leaderboardName: String) -> void:
    _leaderboardName = leaderboardName

func _subscribe_to_leaderboard():
    if !_leaderboardFound:
        Steam.findOrCreateLeaderboard(_leaderboardName, Steam.LEADERBOARD_SORT_METHOD_DESCENDING, Steam.LEADERBOARD_DISPLAY_TYPE_NUMERIC)
        
        var result = await Steam.leaderboard_find_result as Array
        
        if result.size() < 2||result[1] != 1: # Found
            push_error("Leaderboard not found: " + _leaderboardName)
            return

        _leaderboardFound = true
    return

func _await_leaderboard_download_result() -> Array[LeaderboardEntry]:
    var entries: Array[LeaderboardEntry] = []
    
    var result = await Steam.leaderboard_scores_downloaded as Array
    
    if result.size() < 3:
        push_error("Leaderboard not found")
        return []

    for entry in result[2]:
        entries.append(LeaderboardEntry.new(entry))

    return entries
