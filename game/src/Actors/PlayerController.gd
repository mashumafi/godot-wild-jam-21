extends Control
class_name PlayerController

enum Type { Tutorial, Normal }
enum State {	None,
				YellowRight,
				YellowLeft,
				BlueUp,
				BlueDown,
				BlueVYellowHV,
				BlueHVYellowH,
				BlueHVYellowHV
}
func get_next_state(state: int) -> int:
	match state:
		State.YellowRight:
			return State.YellowLeft
		State.YellowLeft:
			if players.has(Player.Movement.Vertical):
				return State.BlueUp
			else:
				return State.YellowRight
		State.BlueUp:
			return State.BlueDown
		State.BlueDown:
			if players.has(Player.Movement.Horizontal):
				return State.YellowRight
			else:
				return State.BlueUp
		State.BlueVYellowHV, State.BlueHVYellowH, State.BlueHVYellowHV:
			return state
	return State.None

var state : int = State.None setget set_state, get_state
func set_state(new_state: int) -> void:
	print("state:", new_state)
	state = new_state
	render_state()
func get_state() -> int:
	return state


func get_camera_focus() -> int:
	match state:
		State.YellowRight, State.YellowLeft:
			return Player.Movement.Horizontal
		State.BlueUp, State.BlueDown:
			return Player.Movement.Vertical
	return Player.Movement.Both

onready var btn1_vertical = $button1/vertical
onready var btn1_horizontal = $button1/horizontal
onready var btn2_vertical = $button2/vertical
onready var btn2_horizontal = $button2/horizontal
func render_state():
	if not btn1_vertical or not btn1_horizontal:
		return
	if not btn2_vertical or not btn2_horizontal:
		return

	match state:
		State.YellowRight:
			btn1_vertical.visible = false
			btn1_horizontal.visible = true
			btn1_horizontal.flip_h = true

			btn2_vertical.visible = false
			btn2_horizontal.visible = true
			btn2_horizontal.flip_h = false
		State.YellowLeft:
			var has_blue := players.has(Player.Movement.Vertical)
			btn1_vertical.visible = has_blue
			btn1_vertical.flip_v = false
			btn1_horizontal.visible = not has_blue
			btn1_horizontal.flip_h = false

			btn2_vertical.visible = false
			btn2_horizontal.visible = true
			btn2_horizontal.flip_h = true
		State.BlueUp:
			btn1_horizontal.visible = false
			btn1_vertical.visible = true
			btn1_vertical.flip_v = true

			btn2_horizontal.visible = false
			btn2_vertical.visible = true
			btn2_vertical.flip_v = false
		State.BlueDown:
			var has_yellow := players.has(Player.Movement.Horizontal)
			btn1_horizontal.visible = has_yellow
			btn1_horizontal.flip_h = false
			btn1_vertical.visible = not has_yellow
			btn1_vertical.flip_v = false
			
			btn2_horizontal.visible = false
			btn2_vertical.visible = true
			btn2_vertical.flip_v = true
		State.BlueVYellowHV:
			btn1_horizontal.visible = false
			btn1_horizontal.flip_h = false
			btn1_vertical.visible = true
			btn1_vertical.flip_v = false
			btn1_vertical.modulate = Color.yellow

			btn2_horizontal.visible = true
			btn2_horizontal.flip_h = false
			btn2_vertical.visible = true
			btn2_vertical.flip_v = false
		State.BlueHVYellowH:
			btn1_horizontal.visible = true
			btn1_horizontal.modulate = Color.blue
			btn1_horizontal.flip_h = false
			btn1_vertical.visible = false
			btn1_vertical.flip_v = false

			btn2_horizontal.visible = true
			btn2_horizontal.flip_h = false
			btn2_vertical.visible = true
			btn2_vertical.flip_v = false
		State.BlueHVYellowHV:
			btn1_horizontal.visible = true
			btn1_horizontal.flip_h = false
			btn1_horizontal.modulate = Color.blue
			btn1_vertical.visible = true
			btn1_vertical.flip_v = false
			btn1_vertical.modulate = Color.yellow

			btn2_horizontal.visible = true
			btn2_horizontal.flip_h = false
			btn2_vertical.visible = true
			btn2_vertical.flip_v = false

onready var button1 = $button1

export(Type) var type = Type.Normal setget set_type, get_type
func set_type(new_type: int) -> void:
	type = new_type
	if button1:
		match type:
			Type.Normal:
				button1.visible = true
			Type.Tutorial:
				button1.visible = false
func get_type() -> int:
	return type


var players := {}


func _ready():
	set_type(type)
	PlayerData.connect("died", self, "_died")
	PlayerData.connect("pause", self, "_pause")


func _pause(value: bool):
	visible = not value


func _died():
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if Type.Normal == type and event.is_action_pressed("button1"):
		self.state = get_next_state(state)


func register(player: int) -> void:
	match player:
		Player.Movement.Horizontal:
			players[player] = [player]
			self.state = State.YellowRight
		Player.Movement.Vertical:
			players[player] = [player]
			self.state = State.BlueUp


func buff(index: int, buff: int) -> void:
	players[index].push_back(buff)
	update_state()


func update_state():
	match players[Player.Movement.Horizontal]:
		[Player.Movement.Horizontal]:
			match players[Player.Movement.Vertical]:
				[Player.Movement.Vertical]:
					self.state = State.YellowRight
				[Player.Movement.Vertical, Player.Movement.Horizontal]:
					self.state = State.BlueHVYellowH
		[Player.Movement.Horizontal, Player.Movement.Vertical]:
			match players[Player.Movement.Vertical]:
				[Player.Movement.Vertical]:
					self.state = State.BlueVYellowHV
				[Player.Movement.Vertical, Player.Movement.Horizontal]:
					self.state = State.BlueHVYellowHV


func nerf(index: int, nerf: int) -> void:
	var player = players[index]
	player.remove(player.find(nerf))
	update_state()


func get_move(index: int) -> float:
	match state:
		State.YellowLeft:
			return -Input.get_action_strength("button2") if Player.Movement.Horizontal == index else 0.0
		State.YellowRight, State.BlueVYellowHV:
			return Input.get_action_strength("button2") if Player.Movement.Horizontal == index else 0.0
		State.BlueHVYellowHV:
			match index:
				Player.Movement.Horizontal:
					return Input.get_action_strength("button2")
				Player.Movement.Vertical:
					return Input.get_action_strength("button1")
		State.BlueHVYellowH:
			match index:
				Player.Movement.Horizontal:
					return Input.get_action_strength("button2")
				Player.Movement.Vertical:
					return Input.get_action_strength("button1")

	return 0.0


func is_jump_pressed(index: int) -> bool:
	match state:
		State.BlueUp, State.BlueHVYellowH:
			return Input.is_action_pressed("button2") and Player.Movement.Vertical == index
		State.BlueHVYellowHV:
			match index:
				Player.Movement.Horizontal:
					return Input.is_action_pressed("button1")
				Player.Movement.Vertical:
					return Input.is_action_pressed("button2")
		State.BlueVYellowHV:
			match index:
				Player.Movement.Horizontal:
					return Input.is_action_pressed("button1")
				Player.Movement.Vertical:
					return Input.is_action_pressed("button2")

	return false


func can_drop(index: int) -> bool:
	match state:
		State.BlueDown:
			return Input.is_action_pressed("button2")

	return false


func _replay_pressed():
	PlayerData.score = 0
	get_tree().paused = false
	get_tree().reload_current_scene()


func _pause_pressed():
	PlayerData.emit_signal("pause", true)
