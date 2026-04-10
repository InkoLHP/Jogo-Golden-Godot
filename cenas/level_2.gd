extends Node

@onready var Luz_player = $Dear/PointLight2D
@onready var Luz_Slime = $slime2/PointLight2D
@onready var Luz_Slime1 = $slime3/PointLight2D
@onready var Luz_Slime2 = $slime4/PointLight2D
@onready var Luz_Slime3 = $slime5/PointLight2D
@onready var Luz_Slime4 = $slime6/PointLight2D
@onready var Luz_Slime5 = $slime7/PointLight2D
@onready var Luz_Slime6 = $slime8/PointLight2D
@onready var Luz_Slime7 = $slime9/PointLight2D
@onready var Luz_Slime8 = $slime10/PointLight2D

func _ready() -> void:
	Luz_player.energy = 0
	Luz_Slime.energy = 0
	Luz_Slime1.energy = 0
	Luz_Slime2.energy = 0
	Luz_Slime3.energy = 0
	Luz_Slime4.energy = 0 
	Luz_Slime5.energy = 0 
	Luz_Slime6.energy = 0 
	Luz_Slime7.energy = 0 
	Luz_Slime8.energy = 0
	

func _process(delta: float) -> void:
	if !Global.playerAlive:
		Global.GameStart = false
		await  get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://cenas/tela_de_morte.tscn")


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if (body.name == "Dear"):
		get_tree().reload_current_scene()

func _on_porta_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.GameStart = true
		await  get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://cenas/tela_vitoria.tscn")
