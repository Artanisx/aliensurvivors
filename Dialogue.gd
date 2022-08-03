class_name Dialogue
extends Control

onready var content := get_node("Text") as RichTextLabel
onready var type_timer := get_node("TypeTimer") as Timer
onready var voice_player := get_node("DialogueVoicePlayer") as AudioStreamPlayer

signal message_completed

var _playing_voice := false

func update_message(message: String) -> void:
	content.bbcode_text = message
	content.visible_characters = 0
	type_timer.start()
	_playing_voice = true
	voice_player.play(0)


func _on_TypeTimer_timeout():
	if content.visible_characters < content.text.length():		
		content.visible_characters += 1
	else:
		_playing_voice = false
		type_timer.stop()	
		emit_signal("message_completed")


func _on_DialogueVoicePlayer_finished():
	if _playing_voice:
		voice_player.play(0) # Loop
		
func is_message_fully_visible() -> bool:
	if content.visible_characters >= content.text.length():
		return true
	else:
		return false
