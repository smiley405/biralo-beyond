extends Node


var _audio_cache: Dictionary = {}
var _player_pool: Array[AudioStreamPlayer] = []


func _ready():
	_init_pool(10)
	_preload_all_audio()


## Example: play_sfx(AudioManifest.SFX.JUMP) - this is for type safety.
## Returns current AudioStreamPlayer > id: int
func play_sfx(sound_data: Dictionary, volume: float = 1.0) -> int:
	var sound_name: String = Utils.get_object_key(sound_data, AudioManifest.SFX)
	return _play(sound_name, volume, "SFX")


## Example: play_music(AudioManifest.MUSIC.BOSS) - this is for type safety.
## Returns current AudioStreamPlayer > id: int
func play_music(sound_data: Dictionary, volume: float = 1.0) -> int:
	var sound_name: String = Utils.get_object_key(sound_data, AudioManifest.MUSIC)
	return _play(sound_name, volume, "Music")


## Pass current AudioStreamPlayer > id: int
func stop(id: int) -> void:
	var player: AudioStreamPlayer = _player_pool[id]
	if player.playing:
		player.stop()


func stop_all():
	for player in _player_pool:
		if player.playing:
			player.stop()


func _play(sound_name: String, volume: float = 1.0, bus_name: String = "Master") -> int:
	var player = _get_available_player()
	if not player:
		return -1

	var stream = _audio_cache.get(sound_name)

	if not stream:
		return -1

	player.stream = stream
	player.bus = bus_name
	player.volume_db = linear_to_db(volume)
	player.play()
	return _player_pool.find(player)


func _init_pool(size: int) -> void:
	for i in size:
		var player = AudioStreamPlayer.new()
		add_child(player)
		_player_pool.append(player)


func _preload_all_audio():
	_preload_audio_manifest(AudioManifest.SFX)
	_preload_audio_manifest(AudioManifest.MUSIC)
	_prepare_audio(_audio_cache)


## Prepares all preloaded audio streams by silently playing and stopping them once.
## This reduces lag during first-time playback, especially in web builds.
func _prepare_audio(cache: Dictionary):
	for key in cache.keys():
		var player: AudioStreamPlayer = _get_available_player()
		player.stream = cache[key]
		player.volume_db = -80
		player.play()
		player.stop()


func _preload_audio_stream(key: String, path: String, loop: bool):
	if not _audio_cache.has(key):
		var stream: AudioStream = ResourceLoader.load(path)
		if not stream:
			return

		if loop:
			if stream is AudioStreamWAV:
				stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
			elif stream is AudioStreamOggVorbis:
				stream.loop = true

		_audio_cache[key] = stream


func _preload_audio_manifest(manifest: Dictionary):
	for key in manifest.keys():
		var path = manifest[key].get("path", "")
		var loop = manifest[key].get("loop", false)
		if path != "":
			_preload_audio_stream(key, path, loop)


func _get_available_player() -> AudioStreamPlayer:
	for player in _player_pool:
		if not player.playing:
			return player
	return null
