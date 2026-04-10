extends Node

@onready var Animacao_trancicao = $Trancicao/AnimationPlayer

func _ready() -> void:
	MusicaTema.play_music_level()

func _process(delta: float) -> void:
	if !Global.playerAlive:
		Global.GameStart = false
		Animacao_trancicao.play("fade_in")
		await  get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://cenas/tela_de_morte.tscn")


func _on_porta_body_entered(body: Node2D) -> void:
	if body is Player:
		Global.GameStart = true
		Animacao_trancicao.play("fade_in")
		await  get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_file("res://cenas/level_2.tscn")
