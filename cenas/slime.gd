extends CharacterBody2D

class_name slime

var speed = 20
var slime_persegue: bool = false

var vida = 100
var vida_max = 100
var vida_min = 0

var dead = false
var tomando_dano: bool = false
var dano_slime = 25
var dando_dano: bool = false

var dir: Vector2
const gravity = 14
var knockback = -25
var is_roaming: bool 

var player = null
var player_in_area = false 

@onready var deal_damege = $dealDemage
@onready var animacao = $animacao

func _process(delta: float) -> void:
	Global.slimeDamege = dano_slime
	Global.SlimeDamegeZone = $AreaAttack
	player = Global.playerBody 
	
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
	
	player = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	player = Global.playerBody
	if !dead:
		is_roaming = true
		if !slime_persegue:
			velocity += dir * speed * delta
		elif slime_persegue and !tomando_dano:
			if Global.playerAlive:
				var dir_to_player = position.direction_to(player.position) * speed
				velocity.x = dir_to_player.x
				dir.x = abs(velocity.x) / velocity.x
			else:
				velocity.x = 0
				position.x = 0
		elif tomando_dano:
			var knockback_dir = position.direction_to(player.position) * knockback
			velocity.x = knockback_dir.x
	elif  dead:
		velocity.x = 0
	elif !Global.playerAlive:
		velocity.x = 0
	move_and_slide()

func handle_animation():
	if !dead and !tomando_dano and !dando_dano:
		animacao.play("run")
		if dir.x == -1:
			animacao.flip_h = true
		elif dir.x == 1:
			animacao.flip_h = false
	elif !dead and tomando_dano and !dando_dano:
		animacao.play("hurt")
		await get_tree().create_timer(0.8).timeout
		tomando_dano = false
	elif dead and is_roaming:
		is_roaming = false
		animacao.play("death")
		await get_tree().create_timer(1.0).timeout
		handle_death()
	elif !dead and dando_dano:
		animacao.play("attack")

func handle_death():
	self.queue_free()

func _on_timer_timeout() -> void:
	$Timer.wait_time = choose([1.5, 2.0, 2.5])
	if !slime_persegue:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func _on_detective_area_body_entered(body):
	player = body
	slime_persegue = true

func _on_detective_area_body_exited(body):
	slime_persegue = false
	player = null

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area == Global.playerDamegeZone:
		var damege = Global.playerDamege
		take_demage(damege)

func take_demage(damege):
	vida -= damege
	tomando_dano = true
	if vida <= 0:
		vida = 0
		dead = true
	print(str(self), "current health is: ", vida)

func _on_area_attack_area_entered(area: Area2D) -> void:
	if area == Global.PlayerHitBox:
		dando_dano = true
		await get_tree().create_timer(1.5).timeout
		dando_dano = false
