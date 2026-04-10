extends CharacterBody2D

class_name Player

var vida = 150
var vida_max = 150
var vida_min = 0
var can_take_damege: bool
var dead: bool

var attack_type: String
var current_attack: bool

const SPEED = 120.0
const JUMP_VELOCITY = -250.0

@onready var animacao = $animacao
@onready var deal_demage = $dealDemage

@onready var wall_slide_speed: float = 50.0
@onready var wall_jump_force: Vector2 = Vector2(250, -250)

@onready var left = $rayLeft
@onready var rigth = $rayRigth

var is_wall_sliding:bool = false
var wall_diraction: int = 0

var gravity = 900

func _ready() -> void:
	Global.playerBody = self
	current_attack = false
	dead = false
	can_take_damege = true
	Global.playerAlive = true


func _physics_process(delta: float) -> void:
	Global.playerDamegeZone = deal_demage
	Global.PlayerHitBox = $Playerhitbox
	
	if not is_on_floor():
		velocity.y += gravity * delta
	if !dead:
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if is_wall_sliding and Input.is_action_just_pressed("jump"):
			velocity = Vector2(wall_jump_force.x * wall_diraction, wall_jump_force.y)
			stop_wall_slide()
		
		var direction := Input.get_axis("left", "right")
		
		var is_touching_left_wall = left.is_colliding()
		var is_touching_rigth_wall = rigth.is_colliding()
		if (is_touching_left_wall or is_touching_rigth_wall) and not is_on_floor() and velocity.y >0:
			start_wall_slide(is_touching_left_wall, is_touching_rigth_wall)
		elif is_wall_sliding and not (is_touching_left_wall or is_touching_rigth_wall):
			stop_wall_slide()
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
		if !current_attack:
			if Input.is_action_just_pressed("attack") or Input.is_action_just_pressed("Attack_pessado"):
				current_attack = true
				if Input.is_action_just_pressed("attack") and is_on_floor():
					attack_type = "single"
				elif  Input.is_action_just_pressed("Attack_pessado") and is_on_floor():
					attack_type = "double"
				set_deamge(attack_type)
				handle_attack_animation(attack_type)
		
		handle_animation(direction)
		check_hitbox()
	move_and_slide()

func start_wall_slide(left, rigth):
	is_wall_sliding = true
	velocity.y = min(velocity.y, wall_slide_speed)
	wall_diraction = 1 if left else -1

func stop_wall_slide():
	is_wall_sliding = false
	wall_diraction = 0

func check_hitbox():
	var hitBox_area = $Playerhitbox.get_overlapping_areas()
	var damege: int
	if hitBox_area:
		var hitBox = hitBox_area.front()
		if hitBox.get_parent() is slime:
			damege = Global.slimeDamege
	
	if can_take_damege:
		take_damege(damege)


func take_damege(damege):
	if damege != 0:
		if vida > 0:
			vida -= damege
			print("Vida do player: ", vida)
		if vida <= 0:
			vida = 0
			dead = true
			handle_death_animation()
		take_damege_cooldown(1.0)

func take_damege_cooldown(wait_time):
	can_take_damege = false
	await  get_tree().create_timer(wait_time).timeout
	can_take_damege = true
	

func handle_death_animation():
	animacao.play("dead")
	velocity.x = 0
	velocity.y = 0
	$Camera2D.zoom.x = 5
	$Camera2D.zoom.y = 5
	await  get_tree().create_timer(3.5).timeout
	Global.playerAlive = false
	self.queue_free()

func handle_animation(dir):
	if is_on_floor() and !current_attack:
		if !velocity:
			animacao.play("idle")
		if velocity:
			animacao.play("run")
			toggle_flip_sprite(dir)
	elif !is_on_floor() and !current_attack:
		animacao.play("fall")
	

func toggle_flip_sprite(dir):
	if dir == 1:
		animacao.flip_h = false
		deal_demage.scale.x = 1
	if dir == -1:
		animacao.flip_h = true
		deal_demage.scale.x = -1

func handle_attack_animation(attack_type):
	if current_attack:
		var animation = str(attack_type, "_attack")
		animacao.play(animation)
		toggle_damage_colision(attack_type)

func toggle_damage_colision(attack_type):
	var damege_zone_colision= deal_demage.get_node("CollisionShape2D")
	var wait_time: float
	if attack_type == "single":
		wait_time = 0.5
	elif  attack_type == "double":
		wait_time = 0.8
	damege_zone_colision.disabled = false
	await  get_tree().create_timer(wait_time).timeout
	damege_zone_colision.disabled = true

func _on_animacao_animation_finished() -> void:
	current_attack = false

func set_deamge(attack_type):
	var current_damege: int
	if attack_type == "single":
		current_damege = 25
	elif attack_type == "double":
		current_damege = 50
	Global.playerDamege = current_damege
