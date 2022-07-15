extends PopupDialog

signal asked_for_resume

func _process(delta):
	get_input()

func get_input():
	if Input.is_action_pressed("ui_enter"):
		emit_signal("asked_for_resume")
