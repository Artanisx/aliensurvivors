extends ColorRect

onready var _transition_rect := $SceneTransictionRect

const SAVE_VAR := "user://sav1.sav"

var dim_load_game = false

func _ready():
	## check if a save exists	
	
	#Open a file
	var file := File.new()	
	
	var error := file.open_encrypted_with_pass (SAVE_VAR, File.READ, "dioMaialinoCoraggioso")
	
	if error == OK:
		## We have a save file, so CONTINUE should appear bright		
		dim_load_game = false
		$MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Load.modulate = Color( 1, 1, 1, 1 )
	else:
		## No save present,, so CONTINUE should appear dim
		dim_load_game = true
		$MarginContainer/HBoxContainer/VBoxContainer/MenuOptions/Load.modulate = Color( 1, 1, 1, 0.4)

func _on_NewGame_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			_transition_rect.transition_to("res://src/Main/Main.tscn")

func _on_Quit_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			get_tree().quit()	

func _on_Load_gui_input(event):
	if dim_load_game == true:
		return
		
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:		
			Globals.set_loaded_true()
			_transition_rect.transition_to("res://src/Main/Main.tscn")	

func _on_Options_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:	
			print("Options pressed. In the next version, a dialogue will appear to inform there is no options implemented!")
