extends Node


var player_pool: Array[AudioStreamPlayer] = []


func _ready():
	init_pool(10)


func init_pool(size: int) -> void:
	for i in size:
		var player = AudioStreamPlayer.new()
		add_child(player)
		player_pool.append(player)


func _play(path: String, volume: float = 1.0, loop: bool = false, bus_name: String = "Master") -> int:
	var player = get_available_player()
	if player:
		var stream:AudioStream = load(path)
		player.stream = stream
		player.bus = bus_name
		player.volume_db = linear_to_db(volume)
		# Set loop on the stream, not the player
		if stream is AudioStreamWAV:
			stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
		elif stream is AudioStreamOggVorbis:
			stream.loop = loop
		player.play()
		# return id
		return player_pool.find(player)
	return -1


func play_sfx(sound_data: Dictionary, volume: float = 1.0, loop: bool = false) -> int:
	return _play(sound_data.path, volume, loop, "SFX")


func play_music(sound_data: Dictionary, volume: float = 1.0, loop: bool = true) -> int:
	return _play(sound_data.path, volume, loop, "Music")


func stop(id: int) -> void:
	var player: AudioStreamPlayer = player_pool[id]
	if player.playing:
		player.stop()


func stop_all():
	for player in player_pool:
		if player.playing:
			player.stop()


func get_available_player() -> AudioStreamPlayer:
	for player in player_pool:
		if not player.playing:
			return player
	return null
