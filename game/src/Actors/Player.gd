extends Actor
class_name Player

export(float) var radius := 300
export(NodePath) var player_controller_path
onready var player_controller = get_node(player_controller_path)

onready var camera = $Camera2D

enum Movement { None, Horizontal, Vertical, Both }
var _movement : int
func opposite_movement(movement: int) -> int:
	match movement:
		Movement.Horizontal:
			return Movement.Vertical
		Movement.Vertical:
			return Movement.Horizontal
	return -1


var has_connection := false


func _ready():
	var area := Area2D.new()
	add_child(area)
	var collision := CollisionShape2D.new()
	collision.position.y = -48
	area.add_child(collision)
	var shape := CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape

	match _movement:
		Movement.Horizontal:
			area.collision_layer = 8
			area.collision_mask = 8
		Movement.Vertical:
			area.collision_layer = 4
			area.collision_mask = 4

	if player_controller:
		player_controller.register(_movement)


func _process(_delta: float):
	if player_controller.get_camera_focus() == _movement:
		camera.current = true


func set_connection(value: bool) -> void:
	has_connection = value

	if value:
		player_controller.buff(_movement, opposite_movement(_movement))
	else:
		player_controller.nerf(_movement, opposite_movement(_movement))


func _area_entered(area: CollisionObject2D) -> void:
	var player = area.get_parent() as Player
	print("collision:", area)
	if player and self != player:
		set_connection(true)

	if area.has_method("is_enemy") and area.is_enemy():
		die()


func _area_exited(area: CollisionObject2D) -> void:
	var player = area.get_parent() as Player
	if player and self != player:
		set_connection(false)


func get_move() -> float:
	return player_controller.get_move(_movement)


func is_jump_pressed() -> bool:
	return player_controller.is_jump_pressed(_movement)


func can_drop() -> bool:
	return player_controller.can_drop(_movement)


func _physics_process(_delta: float) -> void:
	if can_drop():
		position.y = position.y + 5
	var is_jump_interrupted := not is_jump_pressed() and _velocity.y < 0.0
	var direction: = get_direction()
	_velocity = calculate_move_velocity(_velocity, direction, speed, is_jump_interrupted)
	var snap: Vector2 = Vector2.DOWN * 60.0 if direction.y == 0.0 else Vector2.ZERO
	_velocity = move_and_slide_with_snap(
		_velocity, snap, FLOOR_NORMAL
	)


func get_direction() -> Vector2:
	return Vector2(
		get_move(),
		-1 if is_on_floor() and is_jump_pressed() else 0.0
	)


func calculate_move_velocity(
		linear_velocity: Vector2,
		direction: Vector2,
		speed: Vector2,
		is_jump_interrupted: bool
	) -> Vector2:
	var velocity: = linear_velocity
	velocity.x = speed.x * direction.x
	if direction.y != 0.0:
		velocity.y = speed.y * direction.y
	if is_jump_interrupted:
		velocity.y = 0.0
	return velocity


func die() -> void:
	PlayerData.deaths += 1
	queue_free()


func _draw() -> void:
	draw_circle(Vector2(0, -48), self.radius, Color(1, 1, 1, .5 if has_connection else .25))
