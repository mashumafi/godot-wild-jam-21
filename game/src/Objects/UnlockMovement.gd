extends Area2D


export(NodePath) var player_controller_path
export(NodePath) var text_path

onready var player_controller = get_node(player_controller_path)
onready var text = get_node(text_path)


func _area_entered(area):
	if player_controller:
		player_controller.type = PlayerController.Type.Normal

	if text:
		text.visible = true
