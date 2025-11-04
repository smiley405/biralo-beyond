extends Node


var _base_music_playing: bool = false
var _boss_music_playing: bool = false
var _boss_music_id: int = -1


func _ready():
	call_deferred("_init_after_ready")


func _init_after_ready() -> void:
	SceneManager.reload_scene()
	Events.scene_changed.connect(_on_scene_changed)
	Events.boss_defeated.connect(_on_boss_defeated)


func update_music(scene_index: int) -> void:
	match scene_index:
		5, 8:
			if _boss_music_playing:
				return
			AudioManager.stop_all()
			await Utils.delay(1.3)
			_boss_music_id = AudioManager.play_music(AudioManifest.MUSIC.BOSS_BATTLE)
			_boss_music_playing = true
			_base_music_playing = false
		10:
			_on_game_finished()
		0:
			_reset_music_state()
		_:
			if _base_music_playing:
				return
			AudioManager.stop_all()
			_boss_music_id = -1
			await Utils.delay(0.3)
			AudioManager.play_music(AudioManifest.MUSIC.BASE_GAME)
			_base_music_playing = true
			_boss_music_playing = false


func _reset_music_state() -> void:
	_base_music_playing = false
	_boss_music_playing = false
	AudioManager.stop_all()


func _on_scene_changed() -> void:
	update_music(GameState.scene_index)


func _on_game_finished() -> void:
	_reset_music_state()
	await Utils.delay(0.1)
	AudioManager.play_music(AudioManifest.MUSIC.END_STAGE, 0.6)


func _on_boss_defeated() -> void:
	await Utils.delay(0.1)
	AudioManager.stop(_boss_music_id)
