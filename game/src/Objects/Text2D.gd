extends Node2D

export(String) var text := ""
export(Font) var font

func _draw():
	draw_string(font, Vector2.ZERO, text)
