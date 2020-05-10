extends Control

onready var camera := $Camera2D

func _input(event: InputEvent) -> void:
	var mouse_motion := event as InputEventMouseMotion
	if mouse_motion:
		camera.global_position = mouse_motion.position
