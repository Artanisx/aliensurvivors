extends Node

## Variable to let the main and player know if we're loading 
# from the main menu
var loaded_from_main_menu := false

func set_loaded_true(): 
	loaded_from_main_menu = true

func set_loaded_false(): 
	loaded_from_main_menu = false	
	
func is_game_being_loaded() -> bool:
	return loaded_from_main_menu
