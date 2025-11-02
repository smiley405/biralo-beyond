extends Node

var _audio_cache: Dictionary = {}
var _player_pool: Array[AudioStreamPlayer] = []


func _ready():
	_init_pool(10)
	_preload_all_audio()
	_prepare_audio()


func play_sfx(sound_data: Dictionary, volume: float = 1.0, loop: bool = false) -> int:
	var sound_name: String = Utils.get_object_key(sound_data, AudioManifest.SFX)
	return _play(sound_name, volume, loop, "SFX")


func play_music(sound_data: Dictionary, volume: float = 1.0, loop: bool = true) -> int:
	var sound_name: String = Utils.get_object_key(sound_data, AudioManifest.MUSIC)
	return _play(sound_name, volume, loop, "Music")


func stop(id: int) -> void:
	var player: AudioStreamPlayer = _player_pool[id]
	if player.playing:
		player.stop()


func stop_all():
	for player in _player_pool:
		if player.playing:
			player.stop()


func _init_pool(size: int) -> void:
	for i in size:
		var player = AudioStreamPlayer.new()
		add_child(player)
		_player_pool.append(player)


func _play(sound_name: String, volume: float = 1.0, loop: bool = false, bus_name: String = "Master") -> int:
	var player = _get_available_player()
	if player and _audio_cache.has(sound_name):
		var stream: AudioStream = _audio_cache[sound_name]
		# In web builds, reusing the same stream object across multiple players can cause issues.
		# Try duplicating the stream. i.e Use a fresh instance of the stream
		var new_stream: AudioStream = stream.duplicate()
		player.stream = new_stream
		player.bus = bus_name
		player.volume_db = linear_to_db(volume)
		# Set loop on the stream, not the player
		if new_stream is AudioStreamWAV:
			new_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
		elif new_stream is AudioStreamOggVorbis:
			new_stream.loop = loop
		player.play()
		# return id
		return _player_pool.find(player)
	return -1


func _preload_all_audio():
	_preload_audio_manifest(AudioManifest.SFX)
	_preload_audio_manifest(AudioManifest.MUSIC)


## Prepares all preloaded audio streams by silently playing and stopping them once.
## This reduces lag during first-time playback, especially in web builds.
func _prepare_audio():
	for key in _audio_cache.keys():
		var player: AudioStreamPlayer = _get_available_player()
		player.stream = _audio_cache[key]
		# Silent
		player.volume_db = -80
		player.play()
		player.stop()


func _preload_audio_stream(key: String, path: String):
	if not _audio_cache.has(key):
		var stream: Resource = ResourceLoader.load(path)
		if stream:
			_audio_cache[key] = stream


func _preload_audio_manifest(manifest: Dictionary):
	for key in manifest.keys():
		var path = manifest[key].get("path", "")
		if path != "":
			_preload_audio_stream(key, path)


func _get_available_player() -> AudioStreamPlayer:
	for player in _player_pool:
		if not player.playing:
			return player
	return null
