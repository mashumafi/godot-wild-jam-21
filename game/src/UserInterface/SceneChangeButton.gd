tool
extends Button


export(String, FILE) var next_scene_path: = ""


func _get_configuration_warning() -> String:
	return "The property Next Level can't be empty" if next_scene_path == "" else ""


func _pressed():
	PlayerData.reset()
	get_tree().change_scene(next_scene_path)
