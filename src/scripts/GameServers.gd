extends Node

var network = NetworkedMultiplayerENet.new()
var gateway_api = MultiplayerAPI.new()
var port = 1912
var max_players = 4095

var gameserverlist = {}


func _ready() -> void:
	StartServer()

func _process(_delta) -> void:
	if !custom_multiplayer.has_network_peer():
		return
	custom_multiplayer.poll()


func StartServer() -> void:
	network.create_server(port, max_players)
	set_custom_multiplayer(gateway_api)
	custom_multiplayer.set_root_node(self)
	custom_multiplayer.set_network_peer(network)
	print("GameServer hub started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

func DistributeLoginToken(token, gameserver) -> void:
	var gameserver_peer_id = gameserverlist[gameserver]
	rpc_id(gameserver_peer_id, "RecieveLoginToken", token)


func _peer_connected(gameserver_id) -> void:
	print("GameServer " + str(gameserver_id) + " connected")
	
	# TESTING!
	gameserverlist["GameServer1"] = gameserver_id

func _peer_disconnected(gameserver_id) -> void:
	print("GameServer " + str(gameserver_id) + " disconnected")
