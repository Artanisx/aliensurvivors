extends KinematicBody2D

export (int) var enemyHealth = 2
export (int) var enemyArmor = 0
export (int) var enemySpeed = 100
export (int) var enemyTouchDamage = 5
export (float) var enemyChanceToDropExp = 1.0 #50%

var velocity = Vector2.ZERO
var player = null
var ExpCrystal = load ("res://src/Items/ExperienceCrystal.tscn")
var original_tint = Color(1,1,1)

func _ready():
	$AnimatedSprite.playing = true
	player = get_node("/root/Main/Player")
	
func _physics_process(delta):
	movement(delta)	

func movement(delta):
	# Chase player
	velocity = Vector2.ZERO
	
	if player:
		velocity = position.direction_to(player.position) * enemySpeed
	
	velocity = move_and_slide(velocity)	

func get_touch_damage():
	return enemyTouchDamage
	
func drop_crystal():
	#this has a chance to drop a crystal
	var randomNumber = rand_range(0,1)
	if randomNumber <= enemyChanceToDropExp: # 1.0 = 100% chance 0.5 = 50%
		var MainNode = get_node("/root/Main")	
		var eC = ExpCrystal.instance()
		MainNode.add_child(eC)
		eC.position = position	
	
func hit(w1_damage, crit):	
	enemyHealth -= w1_damage
	$FCTManager.show_value(w1_damage, crit)
	$Hurt.play()
	# Tint red
	$AnimatedSprite.self_modulate = Color(1,0,0)	
	$ResetTint.start()
	if (enemyHealth <= 0):
		print("Enemy dies!")		
		yield($Hurt, "finished")
		queue_free()
		drop_crystal()	
		

func _on_ResetTint_timeout():		
	# Reset tint
	$AnimatedSprite.self_modulate = original_tint	
