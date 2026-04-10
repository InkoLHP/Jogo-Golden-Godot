extends Node

class_name no_music

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://cenas/level 1.tscn")

func _on_button_2_pressed() -> void:
	get_tree().quit()
