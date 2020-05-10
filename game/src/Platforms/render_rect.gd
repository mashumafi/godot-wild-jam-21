extends CollisionShape2D

export(Color) var color

func _draw():
	var rect := shape as RectangleShape2D
	if rect:
		draw_rect(Rect2(-rect.extents, rect.extents * 2), color)
