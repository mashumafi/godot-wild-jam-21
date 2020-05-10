extends KinematicBody2D

onready var movement :Tween= $Movement

func _ready():
	movement.interpolate_property(self, "position", position, position + Vector2.RIGHT * 200, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	movement.interpolate_property(self, "position", position + Vector2.RIGHT * 200, position, 3, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 3)
	movement.start()
