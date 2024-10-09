extends Node

const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 31400
const MAX_PLAYERS = 10

var players = {}
var self_data = {
	name = '', position = Vector2(0, -100),
	skin = "res://Skins/GodotSkin.tscn",
	name_color = Color.white,
}
func _ready():
	var _t = get_tree().connect("network_peer_connected", self, '_player_disconnected')
	
func create_server(player_name, skin, name_color):
	self_data.name = player_name
	self_data.skin = skin
	self_data.name_color = name_color
	players[1] = self_data
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(DEFAULT_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	
func connect_to_server(player_name, skin, name_color, ip_address):
	self_data.name = player_name
	self_data.skin = skin
	self_data.name_color = name_color
	var peer = NetworkedMultiplayerENet.new()
	if peer.create_client(ip_address, DEFAULT_PORT):
		printerr("Error Creating the Client")
	get_tree().set_network_peer(peer)
	if get_tree().connect("connected_to_server", self, '_connected_to_server'):
		printerr("Failed to connect connection to server broke")
	if get_tree().connect("connection_failed", self, '_connected_fail'):
		printerr("Failed to connect connection failed")
	if get_tree().connect("server_disconnected", self, '_server_disconnected'):
		printerr("Failed to connect server disconnected")


func _connected_to_server(room_id: int = 0):
	players[get_tree().get_network_unique_id()] = self_data
	rpc('_send_player_info', get_tree().get_network_unique_id(), self_data)

func _player_connected(id):
	rpc_id(id, "register_player", self_data)
	print("Player Connected: " + str(id))
	
remote func register_player(info):
	var id = get_tree().get_rpc_sender_id()
	players[id] = info

func _player_disconnected(id):
	players.erase(id)
	print("Player Disconnected: " + str(id))
	
remote func _send_player_info(id, info):
	if get_tree().is_network_server():
		for peer_id in players:
			rpc_id(id, '_send_player_info', peer_id, players[peer_id])
	players[id] = info
	
	var new_player = preload("res://Prefabs/Player.tscn").instance()
	new_player.name = str(id)
	new_player.set_network_master(id)
	get_tree().get_root().add_child(new_player)
	new_player.init(info.name, info.position, info.skin, info.name_color)
	
func update_position(id, position):
	players[id].position = position
