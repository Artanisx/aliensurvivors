extends CanvasLayer

var seconds_since_start = 0
var main

var button1_selection = 0
var button2_selection = 0
var button3_selection = 0

# player stats
var player_player_speed = 0
var player_player_max_health = 0
var player_w1_rate_of_fire = 0
var player_w1_projectiles = 0
var player_w1_duration = 0
var player_w1_crit_chance = 0
var player_w1_damage = 0

signal restart
signal power_up_selected(player_speed, player_max_health, w1_rate_of_fire, w1_projectiles, w1_duration, w1_crit_chance, w1_damage)

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

func _on_Player_level_up(player_speed, player_max_health, w1_rate_of_fire, w1_projectiles, w1_duration, w1_crit_chance, w1_damage):
	# Pause the game
	get_tree().paused = true
	
	# Store current player stats
	player_player_speed = player_speed
	player_player_max_health = player_max_health
	player_w1_rate_of_fire = w1_rate_of_fire
	player_w1_projectiles = w1_projectiles
	player_w1_duration = w1_duration
	player_w1_crit_chance = w1_crit_chance
	player_w1_damage = w1_damage
		
	# Roll a dice to select the first power button
	var button1 = select_power_up()	
	button1_selection = button1[0]
	var button1_text = button1[1]	
	
	var button2 = select_power_up()
	
	# Button 2 cna't be the same of button 1
	while (button2 == button1):		
		button2 = select_power_up()		# tryu again
		
	button2_selection = button2[0]
	var button2_text = button2[1]
	
	var button3 = select_power_up()
	
	# Button 3 cna't be the same of button 1 or 2
	while (button3 == button1 or button3 == button2):		
		button3 = select_power_up()		# tryu again
	
	button3_selection = button3[0]
	var button3_text = button3[1]
	
	# Set button text
	$LevelUpPopup/VBoxContainer/PowerUpButton1.text = button1_text
	$LevelUpPopup/VBoxContainer/PowerUpButton2.text = button2_text
	$LevelUpPopup/VBoxContainer/PowerUpButton3.text = button3_text
	
	# Set stats for StatPopup
	update_stat_panel()
	
	# Show
	$LevelUpPopup.show()
	
func select_power_up():
	var randomNumber = int(rand_range(0,6))		
	
	# We have 7 power ups available:
	# 1) Player Speed - Increases player_speed by 100
	# 2) Player Health - Increases player max_health by 100
	# 3) Weapon 1 Projectile - Increases w1_projectiles by 1
	# 4) Weapon 1 Duration - Increases w1_duration by 0.25
	# 5) Weapon 1 Crit Chance - Increases w1_crit_chance by 0.05 (5%)
	# 6) Weapon 1 Damage - Increases w1_damage by 0.05
	# 7) Weapon Ultra Power - Rare, incrases all w1stats
	
	# Each power up between 0 to 5 has equal chance
	match randomNumber:
		0:
			return [0, "Player Speed"]
		1: 
			return [1, "Player Health"]
		2:
			return [2, "Weapon 1 Projectile"]
		3: 
			return [3, "Weapon 1 Duration & Rate of Fire"]
		4:
			return [4, "Weapon 1 Crit Chance"]
		5: 
			return [5, "Weapon 1 Damage"]
		6:
			# This has to be more rare so roll the dice again
			var randomChance = int(rand_range(0,1))
			if randomChance <= 0.2: #20% chance
				return [6, "Weapon 1 Ultra Power"] #lucky bastard!
			else:
				return select_power_up() #nope, another roll

func set_power_up_button(selection):
	#player_player_speed = player_speed
	#player_player_max_health = player_max_health
	#player_w1_rate_of_fire = w1_rate_of_fire
	#player_w1_projectiles = w1_projectiles
	#player_w1_duration = w1_duration
	#player_w1_crit_chance = w1_crit_chance
	#player_w1_damage = w1_damage
	
	#signal power_up_selected(player_speed, player_max_health, w1_rate_of_fire, w1_projectiles, w1_duration, w1_crit_chance, w1_damage)
	match selection:
		0:
			emit_signal("power_up_selected", player_player_speed + 100, player_player_max_health, player_w1_rate_of_fire, player_w1_projectiles, player_w1_duration, player_w1_crit_chance, player_w1_damage)
			# speed			
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause
		1: 
			emit_signal("power_up_selected", player_player_speed, player_player_max_health + 100, player_w1_rate_of_fire, player_w1_projectiles, player_w1_duration, player_w1_crit_chance, player_w1_damage)
			# health
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause
		2:
			emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire, player_w1_projectiles + 1, player_w1_duration, player_w1_crit_chance, player_w1_damage)
			#return [2, "Weapon 1 Projectile"]
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause
		3: 
			if (player_w1_rate_of_fire >= 0.1):
				emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire - 0.1, player_w1_projectiles, player_w1_duration + 0.25, player_w1_crit_chance, player_w1_damage)
			else:
				emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire, player_w1_projectiles, player_w1_duration + 0.25, player_w1_crit_chance, player_w1_damage)
			#return [3, "Weapon 1 Duration % Rate of fire"]
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause
		4:
			emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire, player_w1_projectiles, player_w1_duration, player_w1_crit_chance +0.05, player_w1_damage)
			#return [4, "Weapon 1 Crit Chance"]
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause
		5: 
			emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire, player_w1_projectiles, player_w1_duration, player_w1_crit_chance, player_w1_damage + 0.05)
			#pass  [5, "Weapon 1 Damage"]
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause
		6:
			if (player_w1_rate_of_fire >= 0.1):
				emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire - 0.1, player_w1_projectiles + 1, player_w1_duration + 0.25, player_w1_crit_chance + 0.05, player_w1_damage + 0.05)
			else:
				emit_signal("power_up_selected", player_player_speed, player_player_max_health, player_w1_rate_of_fire, player_w1_projectiles + 1, player_w1_duration + 0.25, player_w1_crit_chance + 0.05, player_w1_damage + 0.05)
			#SUPER POWER UP WEAPON
			$LevelUpPopup.hide()
			get_tree().paused = false # Restore from pause

func update_stat_panel():
	var text = "[u]Character Stats[/u]\n"
	text += "[img]res://assets/art/characters/ufoBlue_hit_0.png[/img]\n"	
	text += "[color=yellow][b]Player Max Health:[/b][/color] " + str(player_player_max_health) + "\n"
	text += "[color=yellow][b]Player Speed:[/b][/color] " + str(player_player_speed) + "\n"
	text += "\n[u]Weapon Stats[/u]\n"
	text += "[img]res://assets/art/projectiles/laserRed01.png[/img]\n"
	text += "[color=yellow][b]Weapon 1 RoF:[/b][/color] " + str(player_w1_rate_of_fire) + "\n"
	text += "[color=yellow][b]Weapon 1 Projectiles:[/b][/color] " + str(player_w1_projectiles) + "\n"
	text += "[color=yellow][b]Weapon 1 Duration:[/b][/color] " + str(player_w1_rate_of_fire) + "\n"
	text += "[color=yellow][b]Weapon 1 Crit Chance:[/b][/color] " + str(player_w1_crit_chance*100) + "%\n"
	text += "[color=yellow][b]Weapon 1 Damage:[/b][/color] " + str(player_w1_damage) + "\n"	
	
	$LevelUpPopup/StatPanel/VBoxContainer/RichTextLabel.bbcode_text = text

func _on_PowerUpButton1_pressed():
	set_power_up_button(button1_selection)	

func _on_PowerUpButton2_pressed():
	set_power_up_button(button2_selection)	

func _on_PowerUpButton3_pressed():
	set_power_up_button(button3_selection)	
