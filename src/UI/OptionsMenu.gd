extends ColorRect

onready var _transition_rect := $SceneTransictionRect
onready var _dialogue_manager := $DialogueManager
onready var _dialogue_position := $DialoguePosition

var _messages := [
	"Welcome to the [rainbow freq=0.8 sat=10 val=20]Options Screen[/rainbow]!",
	"I know you can't wait to do [wave amp=50 freq=4]awesome things[/wave] in here.",
	"And in truth, I understand the [tornado radius=5 freq=6]need[/tornado] to do so!",
	"However, there is no options to be set currently.\n[shake rate=9 level=10]SORRY!!![/shake]"
]

func _on_BackToMenu_pressed():
	_transition_rect.transition_to("res://src/UI/MainMenu.tscn")
	
func _ready():
	## wait one second before spawning the dialogue
	yield(get_tree().create_timer(1.0), "timeout")
	
	_dialogue_manager.show_messages(_messages, _dialogue_position.position)
