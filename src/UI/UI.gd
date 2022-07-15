extends CanvasLayer

var seconds_since_start = 0
var main

signal restart

func _ready():
	$TimerLabel.text = ""	
	main = get_node("/root/Main")

func _process(delta):
	seconds_since_start += delta
	format_seconds(seconds_since_start, true)	# pause compatible
	#update_timer(Time.get_ticks_msec())
	
func format_seconds(time : float, use_milliseconds : bool):
	var timer = ""
	var minutes  = time / 60
	var seconds = fmod(time, 60)
	if not use_milliseconds:
		timer =  "%02d:%02d" % [minutes, seconds]
	
	var milliseconds := fmod(time, 1) * 100
	timer = "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
	
	$TimerLabel.text = str(timer)
	

func update_timer(timer):
	var minutes = int(timer / 60 / 1000)
	var seconds = int(timer / 1000) % 60
	var miliseconds = int(timer) % 1000

	var time = ("%02d" % minutes) + (":%02d" % seconds) + (":%03d" % miliseconds)
	
	$TimerLabel.text = str(time)
	
func update_exp_bar(total_exp):
	# 5 = 10		
	$ProgressBar.value = total_exp*2	
	
func update_level_label(level):
	$LevelLabel.text = "Level " + str(level)

func _on_ResumeButton_pressed():
	if $PausePopup/ResumeButton.text != "Restart!":	
		$PausePopup.hide()
		get_tree().paused = false # Restore from pause
	else:
		emit_signal("restart")
		# We're not paused, we just hit a game over state instead
		# resume should restart the game and then unpause
		seconds_since_start = 0 #reset timer
		update_exp_bar(0)
		update_level_label(0)			
		$PausePopup.hide()
		get_tree().paused = false

func _on_Player_pause():
	get_tree().paused = true
	$PausePopup.show()

func _on_Player_death():
	$PausePopup/PopupLabel.text = "Game Over!"
	$PausePopup/ResumeButton.text = "Restart!"
	get_tree().paused = true
	$PausePopup.show()

func _on_PausePopup_asked_for_resume():
	_on_ResumeButton_pressed()

func _on_Player_restart():
	seconds_since_start = 0 #reset timer
	update_exp_bar(0)
	update_level_label(0)

