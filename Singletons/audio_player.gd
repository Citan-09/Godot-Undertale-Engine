extends Node

var audio_stream_players : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child: Node in get_children():
		if !child is AudioStreamPlayer:
			continue
		audio_stream_players[child.name] = child


func play(audio_name: String) -> void:
	var _player: AudioStreamPlayer = audio_stream_players.get(audio_name)
	if !_player:
		push_error("%s is not in audio_stream_players." % audio_name)
		return
	_player.play()


func stop_audio(audio_name: String) -> void:
	var _player: AudioStreamPlayer = audio_stream_players.get(audio_name)
	if !_player:
		return
	_player.stop()


func get_audio_stream_player(audio_name: String) -> AudioStreamPlayer:
	var _player: AudioStreamPlayer = audio_stream_players.get(audio_name)
	if !_player:
		return audio_stream_players.values()[0]
	return _player
