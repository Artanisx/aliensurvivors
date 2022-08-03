extends ColorRect

onready var _transition_rect := $SceneTransictionRect

func _on_BackToMenu_pressed():
	_transition_rect.transition_to("res://src/UI/MainMenu.tscn")
