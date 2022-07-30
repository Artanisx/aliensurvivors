extends MarginContainer

onready var _transition_rect := $SceneTransictionRect


func _on_NewGame_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_transition_rect.transition_to("res://src/Main/Main.tscn")


func _on_Quit_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			get_tree().quit()
