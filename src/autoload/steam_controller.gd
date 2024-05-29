extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Steam.steamInit()
	
	var isSteamRunning = Steam.isSteamRunning()
	
	assert(isSteamRunning, "Steam is not running!")
