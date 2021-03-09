extends Node

var player_data = {}

func _ready() -> void:
	get_player_data()


func get_player_data() -> void:
	var player_data_file = File.new()
	player_data_file.open("res://Data/player_data.json", File.READ)
	player_data = parse_json(player_data_file.get_as_text())
	player_data_file.close()
