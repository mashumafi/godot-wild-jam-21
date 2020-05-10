extends Camera2D


export(NodePath) var player_controller_path
onready var player_controller = get_node(player_controller_path)

func _process(_delta: float):
	if player_controller.get_camera_focus() == Player.Movement.Both:
		self.current = true
		var neighbors := get_neighbors()
		if 0 < neighbors.size():
			var sum := Vector2.ZERO
			var count := 0
			for neighbor in neighbors:
				var node := neighbor as Node2D
				if node:
					sum += node.global_position
					count += 1
			global_position = sum / count
				

func get_neighbors() -> Array:
	var children := []
	var parent : Node = get_parent()
	if parent:
		for i in range(parent.get_child_count()):
			var child := parent.get_child(i)
			if self != child:
				children.append(child)
	return children
