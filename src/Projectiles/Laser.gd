extends Area2D

export var speed = 350
export var steer_force = 50.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null
var w1_damage = 1
var w1_crit_chance = 0.5

func start(_transform, _target):
	global_transform = _transform	
	rotation += rand_range(-0.09, 0.09)
	velocity = transform.x * speed	
	target = _target		
	$LaserShoot.play()		
	$Lifetime.wait_time = get_node("/root/Main/Player").get("w1_duration")
	$Lifetime.start()

func seek():
	var steer = Vector2.ZERO
	if is_instance_valid(target):		
		var desired = (target.position - position).normalized() * speed		
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _physics_process(delta):
	acceleration += seek()
	velocity += acceleration * delta	
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	position += velocity * delta

func _on_Laser_body_entered(body):
	if body.has_method("hit"):
		var randomNumber = rand_range(0,1)
		if randomNumber <= w1_crit_chance:
			body.hit(w1_damage * 2, true)
		else:
			body.hit(w1_damage, false)
	explode()

func _on_Lifetime_timeout():
	explode()

func explode():
	#$Particles2D.emitting = false
	set_physics_process(false)
	#$AnimationPlayer.play("explode")
	#yield($AnimationPlayer, "animation_finished")
	queue_free()



