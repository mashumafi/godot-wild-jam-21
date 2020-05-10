extends KinematicBody2D

onready var movement :Tween= $Movement

export(NodePath) var target_path
export(float) var duration

onready var target = get_node(target_path)

func _ready():
	movement.interpolate_property(self, "global_position", global_position, target.global_position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, 0)
	movement.interpolate_property(self, "global_position", target.global_position, global_position, duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT, duration)
	movement.start()
