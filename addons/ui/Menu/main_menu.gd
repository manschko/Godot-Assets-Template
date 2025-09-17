extends Node2D

@export var settingsScene: PackedScene
@export var gameScene: PackedScene


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(gameScene)
	

func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_packed(settingsScene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
