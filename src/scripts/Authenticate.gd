extends Node

var network = NetworkedMultiplayerENet.new()
var port = 1911
var max_servers = 5


func _ready() -> void:
	randomize()
	StartServer()


func StartServer() -> void:
	network.create_server(port, max_servers)
	get_tree().set_network_peer(network)
	print("Auth server started")
	
	network.connect("peer_connected", self, "_peer_connected")
	network.connect("peer_disconnected", self, "_peer_disconnected")

remote func AuthenticatePlayer(username, password, peer_id) -> void:
	print("Auth request received")
	
	var token
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var hashed_password
	
	print("Starting authentication")
	if !PlayerData.player_data.has(username):
		print("User not recognized")
		result = false
	else:
		var retrieved_salt = PlayerData.player_data[username].Salt
		hashed_password = GenerateHashedPassword(password, retrieved_salt)
		if !PlayerData.player_data[username].Password == hashed_password:
			print("Incorrect password")
			result = false
		else:
			print("Succesful authentication")
			result = true
			token = str(randi()).sha256_text() + str(OS.get_unix_time())
			var gameserver = "GameServer1" # REPLACE WITH THE LOAD BALANCER
			
			GameServers.DistributeLoginToken(token, gameserver)
	
	print("Authentication result sent to gateway server")
	rpc_id(gateway_id, "AuthenticationResults", result, peer_id, token)

remote func Register(username, password, peer_id) -> void:
	var gateway_id = get_tree().get_rpc_sender_id()
	var result
	var message
	
	if PlayerData.player_data.has(username):
		result = false
		message = 2
	else:
		result = true
		message = 3
		var salt = GenerateSalt()
		var hashed_password = GenerateHashedPassword(password, salt)
		
		PlayerData.player_data[username] = {"Password": hashed_password, "Salt": salt}
		PlayerData.save_player_data()
	rpc_id(gateway_id, "RegisterResults", result, peer_id, message)

func GenerateSalt() -> String:
	return str(randi()).sha256_text()

func GenerateHashedPassword(password, salt) -> String:
	var hashed_password = password
	var rounds = pow(2, 18)
	while rounds > 0:
		hashed_password = (hashed_password + salt).sha256_text()
		rounds -= 1
	return hashed_password


func _peer_connected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " connected")

func _peer_disconnected(gateway_id) -> void:
	print("Gateway " + str(gateway_id) + " disconnected")
