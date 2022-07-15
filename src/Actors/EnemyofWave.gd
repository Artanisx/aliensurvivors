extends "res://src/Actors/Enemy.gd"

#Enemy of Wave doesn't chase the player, it just go towards its direction
var fixed_player_pos
var distance_where_stop = 500
var direction


func _ready():		
	# Change the color of the enemy spawned tint
	original_tint = Color(1,0,1)
	$AnimatedSprite.self_modulate = original_tint	
	#$AnimatedSprite.set_speed_scale(3)
	fixed_player_pos = player.position
	direction = position.direction_to(fixed_player_pos).normalized()		
	original_tint = Color(1,0,1)
	$Lifetime.wait_time = 10	#after tot sevonds an enemy par tof a spawn will die
	$Lifetime.start()
		
func movement(delta):		
	velocity = direction * enemySpeed 
	velocity = move_and_slide(velocity)

func _on_Lifetime_timeout():
	queue_free()
