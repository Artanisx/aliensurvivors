extends Area2D

signal hit
signal pause
signal death
signal restart
signal save_game(file)
signal load_game(file)
signal level_up(player_speed, player_max_health, w1_rate_of_fire, w1_projectiles, w1_duration, w1_crit_chance, w1_damage)
signal go_to_main_menu

# Player Stats
var playerSpeed = 500
var playerHealth = 500
var playerExperience = 0
var playerLevel = 0
export var exp_per_crystal = 1
export var exp_per_level = 5
var max_health = base_max_health
const base_max_health = 500

# Player velocity vector
var velocity = Vector2()

# WEAPON 1 STATS [laser shoot]
const w1_starting_rate_of_fire = 1
const w1_starting_projectiles = 1
const w1_starting_duration = 2
const w1_starting_damage = 1
const w1_starting_crit_chance = 0.1
var w1_rate_of_fire = w1_starting_rate_of_fire
var w1_projectiles = w1_starting_projectiles
var w1_duration = w1_starting_duration
var w1_damage = w1_starting_damage
var w1_crit_chance = w1_starting_crit_chance
var w1_can_shoot = true
var Laser = load ("res://src/Projectiles/Laser.tscn")

# Screen size, used for clamping
var screen_size 
var world_size
var world_position

# nodes
var ui

const SAVE_VAR := "user://sav1.sav"

# DEBUGGING
const max_zoom_out = 10
export var god_mode = false
export var infinite_damage = false

func _ready():
	screen_size = get_viewport_rect().size
	world_size = get_node("/root/Main/Background").get_rect().size
	world_position = get_node("/root/Main/Background").get_position()
			
	# Checks if the starting position has been set
	if $StartingPosition.position == Vector2():
		# No starting position set, so put the player at the center of the world
		$StartingPosition.position.x = world_size.x / 2
		$StartingPosition.position.y = world_size.y / 2
		
	position = $StartingPosition.position
	
	# SETUP STARTING WEAPON
	setup_weapon_1()
	
	# get UI NODE
	ui = get_node("/root/Main/UI")
	

func get_input():
	velocity = Vector2()
	
	if Input.is_action_pressed("right"):
		velocity.x += 1
	
	if Input.is_action_pressed("left"):
		velocity.x -= 1
	
	if Input.is_action_pressed("down"):
		velocity.y += 1
	
	if Input.is_action_pressed("up"):
		velocity.y -= 1
		
	if Input.is_action_pressed("ui_select"):
		emit_signal("pause")	#(player_speed, player_max_health, w1_rate_of_fire, w1_projectiles, w1_duration, w1_crit_chance, w1_damage)	
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * playerSpeed
		$AnimatedSprite.animation = "idle"
		$AnimatedSprite.play()
	else:
		$AnimatedSprite.stop()			
		
	if Input.is_action_just_released("zoom_out"):		
		#mouse_wheel down, zoom out
		var cur_zoom = $Camera2D.get_zoom()
		
		if cur_zoom.x < max_zoom_out:
			 #we're not too much zoomed out
			cur_zoom = Vector2(cur_zoom.x + 1, cur_zoom.y + 1)
			$Camera2D.set_zoom(cur_zoom)
			
	if Input.is_action_just_released("zoom_in"):		
		#mouse_wheel up, zoom in
		var cur_zoom = $Camera2D.get_zoom()		
		
		if cur_zoom.x > 1:						
			 #we're not too much zoomed in
			cur_zoom = Vector2(cur_zoom.x - 1, cur_zoom.y - 1)
			$Camera2D.set_zoom(cur_zoom)			
			
	if Input.is_action_just_released("ui_cancel"):	
		emit_signal("restart")
		
	if Input.is_action_just_released("save"):
		save_game()		
		
	if Input.is_action_just_released("load"):
		load_game()		
	
	if Input.is_action_pressed("BackToMenu"):
		emit_signal("go_to_main_menu")
	
func save_game():
	print("Save request sent from Player...")
	
	# Save all player statuses
	save_player()
	
func load_game():
	print("Load request sent from Player...")
	
	# Load all player statuses
	load_player()
	
func save_player() -> void:
	# Open a file
	var file:= File.new()
	#file.open(SAVE_VAR, File.WRITE)
	var _error = file.open_encrypted_with_pass (SAVE_VAR, File.WRITE, "dioMaialinoCoraggioso")
	
	# Save what we need to save	 (order is important, or loading won't work)	
	
	# Player Stats
	file.store_line(var2str(playerSpeed))
	file.store_line(var2str(playerHealth))
	file.store_line(var2str(playerExperience))
	file.store_line(var2str(playerLevel))
	file.store_line(var2str(max_health))
	
	# Player position
	file.store_line(var2str(position))
	
	# Weapon Stats
	file.store_line(var2str(w1_rate_of_fire))
	file.store_line(var2str(w1_projectiles))
	file.store_line(var2str(w1_duration))
	file.store_line(var2str(w1_damage))
	file.store_line(var2str(w1_crit_chance))	
		
	print("Saved player.")	
	
	# We have saved the player stats, now emit the save_game signal so MAIN can also save what needs to be saved
	emit_signal("save_game", file)

func load_player() -> void:
	#Open a file
	var file := File.new()
	#var error := file.open(SAVE_VAR, File.READ)
	var error := file.open_encrypted_with_pass (SAVE_VAR, File.READ, "dioMaialinoCoraggioso")
	
	if not error == OK:
		print("Could not load file at " + str(SAVE_VAR))
		return
		
	# Player Stats
	playerSpeed = str2var(file.get_line())
	playerHealth = str2var(file.get_line())
	playerExperience = str2var(file.get_line())
	playerLevel = str2var(file.get_line())
	max_health = str2var(file.get_line())
	
	# Player position
	position = str2var(file.get_line())
	
	# Weapon Stats
	w1_rate_of_fire = str2var(file.get_line())
	w1_projectiles = str2var(file.get_line())
	w1_duration = str2var(file.get_line())
	w1_damage = str2var(file.get_line())
	w1_crit_chance = str2var(file.get_line())
	
	# update ui
	ui.update_level_label(playerLevel)
	ui.update_exp_bar(playerExperience)	
	$HealthDisplay.reset_max_health(max_health)
	$HealthDisplay.update_healthbar(playerHealth)	
		
	print("Loaded player.")	
	
	# We have loaded the player stats, now emit the load_game signal so MAIN can also load what needs to be loaded
	emit_signal("load_game", file)

func _physics_process(delta):
	get_input()
	position += velocity * delta
	
	# Make sure the player doesn't exit the screen	
	#var player_size = $AnimatedSprite.frames.get_frame("idle", 0).get_size()		
	
	#player must  ALMOST be able to reach the limit of the world, but just enough that the camera doesn't show outside of the world itself
	position.x = clamp(position.x, world_position.x + screen_size.x / 2, world_position.x + world_size.x - screen_size.x / 2)
	position.y = clamp(position.y, world_position.y + screen_size.y / 2, world_position.y + world_size.y - screen_size.y / 2)
	
	#this makes sure the player can't exit the world, but the camera will show gray area
	#position.x = clamp(position.x, world_position.x + player_size.x / 2, world_position.x + world_size.x - player_size.x / 2)
	#position.y = clamp(position.y, world_position.y + player_size.y / 2, world_position.y + world_size.y - player_size.y / 2)
	
	#position.x = clamp(position.x, player_size.x / 2, screen_size.x - player_size.x / 2)
	#position.y = clamp(position.y, player_size.y / 2, screen_size.y - player_size.y / 2)
	
	#print(world_position)
	#print(world_size)
	
	# Check for enemy collision for damaging purposes
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies"):
			damage_player(body)
			
func damage_player(node):
	if god_mode:
		return
				
	var damage = node.get_touch_damage()
	playerHealth -= damage
	$HealthDisplay.update_healthbar(playerHealth)
	if (playerHealth <= 0):
		player_death()	

func player_death():
	print("I'm dead")
	emit_signal("death")
	# Stop collision and hide (TEMP)
	$CollisionShape2D.disabled = true
	hide()	

func setup_weapon_1():
	# This function sets the starting weapon
	w1_rate_of_fire = w1_starting_rate_of_fire
	w1_projectiles = w1_starting_projectiles
	w1_duration = w1_starting_duration
	w1_damage = w1_starting_damage
	w1_crit_chance = w1_starting_crit_chance
	
	w1_can_shoot = true
	
	$Weapon1Timer.stop()
	$Weapon1Timer.wait_time = w1_rate_of_fire
	$Weapon1Timer.start()

# Something collided with the player
func _on_Player_body_entered(body):
	if body.is_in_group("enemies"):
		emit_signal("hit")	
		# Tint red
		$AnimatedSprite.self_modulate = Color(1,0,0)
		#After one hit we disable the collision so we don't trigger hit signal more than once
		#$CollisionShape2D.set_deferred("disabled", true)

func _on_Player_body_exited(body):
	if body.is_in_group("enemies"):		
		# Reset tint
		$AnimatedSprite.self_modulate = Color(1,1,1)
		#After one hit we disable the collision so we don't trigger hit signal more than once
		#$CollisionShape2D.set_deferred("disabled", true)	


func _on_Weapon1Timer_timeout():
	# Check if there's already enough projectile
	var w1_projectiles_in_scene = get_tree().get_nodes_in_group("laser_shots").size()
	
	# Too many projectiles, no shooty!
	if (w1_projectiles_in_scene >=  w1_projectiles):
		return
		
	# Check if there's an enemy in the screen
	var MainNode = get_node("/root/Main")	
	var enemies_in_scene = get_tree().get_nodes_in_group("enemies")
	
	if enemies_in_scene.size() > 0:
		# There's at least one enemy. Target the closest one.
		var closest_distance = 999999
		var closest_enemy = null
		
		for enemy in enemies_in_scene:
			var enemy_distance = position.distance_to(enemy.position)			
			if enemy_distance < closest_distance:
				closest_distance = enemy_distance
				closest_enemy = enemy
				#print("Found a close enemy")
				
		# At this point we have the closest_enemy
		var l = Laser.instance()
		
		if infinite_damage == true:
			l.w1_damage = 99999
		else:
			l.w1_damage = w1_damage	# make sure the laster has the proper damage 
			
		l.w1_crit_chance = w1_crit_chance #and crit chance
		MainNode.add_child(l)
		l.start($RightMuzzle.global_transform, closest_enemy)
		#if closest_enemy.position.x < position.x:						
			#l.get_node("Sprite").scale.y = -1
		#	l.start($LeftMuzzle.global_transform, closest_enemy)
		#else:						
			#l.get_node("Sprite").scale.y = 1
		#	l.start($RightMuzzle.global_transform, closest_enemy)


func _on_Player_area_entered(area):
	if area.is_in_group("items"):		
		playerExperience += exp_per_crystal
		ui.update_exp_bar(playerExperience)		
		if (playerExperience >= exp_per_level):
			playerExperience = 0
			ui.update_exp_bar(playerExperience)	
			level_up()			
		area.hide()
		area.get_node("LootSound").play()
		yield(area.get_node("LootSound"), "finished")		
		area.queue_free()

func level_up():			
	#Emute a level up signal passing all current values, letting the HUD figure it out
	emit_signal("level_up", playerSpeed, max_health, $Weapon1Timer.wait_time, w1_projectiles, w1_duration, w1_crit_chance, w1_damage)	
	playerLevel += 1	
	ui.update_level_label(playerLevel)

func restart_player():
	print("Restarting the player")
	# reset player levels and experience
	# Player Stats
	playerSpeed = 500
	max_health = base_max_health
	playerHealth = max_health
	$HealthDisplay.reset_max_health(max_health)
	$HealthDisplay.update_healthbar(playerHealth)	
	playerExperience = 0
	playerLevel = 0	
			
	# Checks if the starting position has been set
	if $StartingPosition.position == Vector2():
		# No starting position set, so put the player at the center of the world
		$StartingPosition.position.x = world_size.x / 2
		$StartingPosition.position.y = world_size.y / 2
		
	position = $StartingPosition.position
	
	# SETUP STARTING WEAPON
	setup_weapon_1()
	
	# Resume collision
	$CollisionShape2D.disabled = false
	
	# unhide player 
	show()

func _on_UI_restart():
	restart_player()

func _on_UI_power_up_selected(p_speed, p_max_health, w1_r_of_fire, w1_proj, w1_dur, w1_crit, w1_dmg):
	self.playerSpeed = p_speed
	
	if (p_max_health > self.max_health ):	#as an extra bonus, if we powered up max health get a full heal
		self.max_health = p_max_health
		self.playerHealth = max_health
		# update the HUD healthbar accordingly
		$HealthDisplay.reset_max_health(max_health)
		$HealthDisplay.update_healthbar(playerHealth)		
	
	self.w1_rate_of_fire = w1_r_of_fire
	$Weapon1Timer.wait_time = w1_r_of_fire
	self.w1_projectiles = w1_proj
	self.w1_duration = w1_dur
	self.w1_crit_chance = w1_crit
	self.w1_damage = w1_dmg
	
	var format_string = "Powering up speed: %d - health: %d - rateoffire: %d  - projectiles: %d - druation: %d - critchance: %d - damage: %d."
	var actual_string = format_string % [self.playerSpeed, self.max_health, self.w1_rate_of_fire, self.w1_projectiles, self.w1_duration, self.w1_crit_chance, self.w1_damage]
	print(actual_string)	
