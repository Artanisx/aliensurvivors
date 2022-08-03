class_name DialogueManager
extends Node

const DIALOGUE_SCENE := preload("res://src/UI/Dialogue.tscn")

onready var opacity_tween := get_node("OpacityTween") as Tween

signal message_requested
signal message_completed
signal finished

var _messages := []
var _active_dialogue_offset := 0
var _is_active := false
var cur_dialogue_instance: Dialogue
var has_hidden_already := false

func show_messages(message_list: Array, position: Vector2) -> void:
	## Only trigger this if it's not currently showing something
	
	if _is_active:
		return
		
	_is_active = true
	
	# let the dialogue instance be hidden since it's a new message list
	has_hidden_already = false
	
	_messages = message_list
	_active_dialogue_offset = 0
	
	# create a dialogue instnace
	var _dialogue = DIALOGUE_SCENE.instance()
	
	## instance the node
	get_tree().get_root().add_child(_dialogue)
	
	_dialogue.modulate.a = 0
	_dialogue.rect_global_position = position
	_dialogue.connect("message_completed", self, "_on_message_completed")
	
	cur_dialogue_instance = _dialogue
	
	var _inter = opacity_tween.interpolate_property(
		_dialogue, "modulate:a", 0.0, 1.0, 0.2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
	)
	
	var _check = opacity_tween.start()
	yield(opacity_tween, "tween_all_completed")
	
	_show_current()
	
func _show_current() -> void:
	emit_signal("message_requested")
	var _msg := _messages[_active_dialogue_offset] as String
	cur_dialogue_instance.update_message(_msg)
	
func get_input() -> void:
	if Input.is_action_pressed("ui_select") or Input.is_action_pressed("ui_accept"): 
		# move to the next message
		if cur_dialogue_instance.is_message_fully_visible():
			if _active_dialogue_offset < _messages.size() - 1 and cur_dialogue_instance.is_message_fully_visible():
				_active_dialogue_offset += 1
				_show_current()
			else:
				_hide()	# no more messages, goodbye			

func _process(_delta):
	get_input()

func _hide() -> void:
	if has_hidden_already == true:
		return
		
	print ("hiding, this should happen only once")		
	has_hidden_already = true
	cur_dialogue_instance.disconnect(
		"message_completed",
		self,
		"_on_message_completed"
	)
	
	var _inter = opacity_tween.interpolate_property(
		cur_dialogue_instance, "modulate:a", 1.0, 0.0, 0.2,
		Tween.TRANS_SINE, Tween.EASE_IN_OUT
		)
	
	var _check = opacity_tween.start()
	yield(opacity_tween, "tween_all_completed")
	
	cur_dialogue_instance.queue_free()
	cur_dialogue_instance = null
	_is_active = false
	emit_signal("finished")	
	
func _on_message_completed() -> void:
	emit_signal("message_completed")
