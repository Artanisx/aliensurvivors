extends Node

export(PackedScene) var enemy_scene
export(PackedScene) var enemy_of_wave_scene

const safe_range = 1000 #mobs won't spawn closer than 300 pixel from the player

var milliseconds_since_start = 0
var seconds_since_start = 0
var starting_spawn_time = 2
var number_of_enemies_per_spawn = number_of_enemies_per_spawn_start
var spawn_level = 0

const number_of_enemies_per_spawn_start = 1

func _init():
	OS.min_window_size = OS.window_size
	OS.max_window_size = OS.get_screen_size()
	
func _ready():
	$SpawnEnemiesTimer.wait_time = starting_spawn_time
	randomize()

func _unhandled_input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen		

func _process(delta):	
	#milliseconds_since_start = Time.get_ticks_msec()	
	#seconds_since_start = milliseconds_since_start / 1000	
	seconds_since_start += delta
	increase_spawns(int(seconds_since_start))	
	
func increase_spawns(seconds_since_start):
	match seconds_since_start:
		10:	
			if (spawn_level == 0):		
				$SpawnEnemiesTimer.wait_time -= starting_spawn_time/10	
				number_of_enemies_per_spawn += 1
				spawn_level += 1
				spawn_wave_of_enemy(10)	#spawn a wave of 10 enemies
				print("10 seconds elapsed, spawn up")			
		30:	
			if (spawn_level == 1):	
				$SpawnEnemiesTimer.wait_time -= starting_spawn_time/10	
				number_of_enemies_per_spawn += 1
				spawn_level += 1
				spawn_wave_of_enemy(15)
				print("30 seconds elapsed, spawn up")			
		60:
			if (spawn_level == 2):	
				$SpawnEnemiesTimer.wait_time -= starting_spawn_time/10	
				number_of_enemies_per_spawn += 1
				spawn_level += 1
				spawn_wave_of_enemy(20)
				print("60 seconds elapsed, spawn up")			
		90:
			if (spawn_level == 3):	
				$SpawnEnemiesTimer.wait_time -= starting_spawn_time/10	
				number_of_enemies_per_spawn += 1
				spawn_level += 1
				spawn_wave_of_enemy(30)
				print("90 seconds elapsed, spawn up")
				
	if seconds_since_start >= 120 and spawn_level == 4: # real valuyes >= 120 and spawn_level 4
		spawn_level = 5 #exectute this only once
		automatically_incrase_spawn()
			
func automatically_incrase_spawn():
	$SpawnAutoIncreaseTimer.start()	 #this timer ticks each 30 seconds and increases cruelly the spawns

func _on_SpawnEnemiesTimer_timeout():
	# Spawn an enemy each time the timer clicks
	print("Spawning enemy...")
	spawn_enemy(number_of_enemies_per_spawn)
	
func spawn_wave_of_enemy(wave_size: int):
	# Create a wave_size int of enemies all in a group
	print("creating spawn of enemies! " + str(wave_size)) 
	
	var position: Vector2 = Vector2.ZERO
	
	for _i in range(wave_size):
		var new_enemy = enemy_of_wave_scene.instance()
		if (position == Vector2.ZERO):	#first enemy of the wave
			new_enemy.global_position = get_random_spawn_position()			
			new_enemy.enemySpeed *= 4	#enemy of a wave has triple speed
			add_child(new_enemy)
			position = new_enemy.get_global_position()
			print("FIRST Enemy part of wave spawned")			
		else:
			var enemy_size = new_enemy.get_node("AnimatedSprite").frames.get_frame("moving", 0).get_size().x
			
			new_enemy.global_position = get_random_close_spawn_position(position, enemy_size)	# creaste the enemy closeby to first enemy position
			new_enemy.enemySpeed *= 4	#enemy of a wave has triple speed
			add_child(new_enemy)		
			print("other Enemy part of wave spawned")
		
	
func spawn_enemy(enemy_number: int):
	# Create enemy_number new instances of the enemy	
	for _i in range(enemy_number):
		# instantiate a new enemy
		var new_enemy = enemy_scene.instance()
		# set a random position just outside of the screen
		new_enemy.global_position = get_random_spawn_position()
		# add the new enemy as a child of the main scene
		add_child(new_enemy)
		print("Enemy spawned at...")
		print(new_enemy.global_position)
		
func get_random_close_spawn_position(close_to: Vector2, enemy_size: int):
	# create a random position closeby to the passed position
	var first_enemy_pos = close_to
	var offset = enemy_size
	var padding = 10
	
	var min_x_pos = first_enemy_pos.x - offset + padding
	var max_x_pos = first_enemy_pos.x + offset + padding
	var min_y_pos = first_enemy_pos.y - offset + padding
	var max_y_pos = first_enemy_pos.y + offset + padding
	
	var spawn_pos = Vector2(rand_range(min_x_pos, max_x_pos), rand_range(min_y_pos, max_y_pos))
	
	return spawn_pos

func get_random_spawn_position():
	#var world_size = $ColorRect.get_size()
	#print(world_size)
	var player_pos = $Player.get_position()
	#print(player_pos)
	var screen_size = $Player.screen_size
	#print(screen_size)
	
	var min_x_pos = player_pos.x - screen_size.x
	var max_x_pos = player_pos.x + screen_size.x
	var min_y_pos = player_pos.y - screen_size.y
	var max_y_pos = player_pos.y + screen_size.y
	
	var spawn_pos = Vector2(rand_range(min_x_pos, max_x_pos), rand_range(min_y_pos, max_y_pos))
	# the below spawns simply inside the whole world (kind of)
	#var spawn_pos = Vector2(rand_range(0, world_size.x), rand_range(0, world_size.y))
	#print(spawn_pos)
	#print(safe_range)
	
	if spawn_pos.distance_to(player_pos) < safe_range: 
		#we are too close to the player
		spawn_pos = get_random_spawn_position()	 # try again
	return spawn_pos

func restart():
	print("Restarting the game")	
	
	# reset spawn levels
	spawn_level = 0
	number_of_enemies_per_spawn = number_of_enemies_per_spawn_start
	$SpawnEnemiesTimer.wait_time = starting_spawn_time
	$SpawnEnemiesTimer.stop()	
	$SpawnAutoIncreaseTimer.stop()
	# detroy all enemies and pickups	
	
	for node_enemy in self.get_children():
		if node_enemy.is_in_group("enemies"):			
			node_enemy.queue_free()
	
	for node_projectile in self.get_children():
		if node_projectile.is_in_group("projectiles"):			
			node_projectile.queue_free()
			
	for node_items in self.get_children():
		if node_items.is_in_group("items"):	
			node_items.queue_free()
	
	$SpawnEnemiesTimer.start()

func _on_UI_restart():
	restart()

func _on_Player_restart():
	restart()

func _on_SpawnAutoIncreaseTimer_timeout():
	number_of_enemies_per_spawn += 1
	spawn_wave_of_enemy(30)	
	print("another 30 seconds have passed, automatically increase spawns and spawn wave")
