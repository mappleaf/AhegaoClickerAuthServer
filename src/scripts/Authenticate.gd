extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5


func _ready() -> void:
	StartServer()


func StartServer() -> void:
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Auth server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

remote func AuthenticatePlayer(username, password, peer_id) -> void:
	print("Auth request received")
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	
	print("Starting authentication")
	if !PlayerData.player_data.has(username):
		print("User not recognized")
		result = false
	elif !PlayerData.player_data[username].Password == password:
		print("Incorrect password")
		result = false
	else:
		print("Succesful authentication")
		result = true
	
	print("Authentication result sent to gateway server")
	rpc_id(gateway_id, "AuthenticationResults", result, peer_id)


func _peer_connected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " connected")

func _peer_disconnected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " disconnected")
