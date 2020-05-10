extends Node


onready var scene_tree: SceneTree = get_tree()
onready var score_label: Label = $Score
onready var pause_overlay: ColorRect = $PauseOverlay
onready var title_label: Label = $PauseOverlay/Title
onready var main_screen_button: Button = $PauseOverlay/PauseMenu/MainScreenButton
onready var retry_button : Button = $PauseOverlay/PauseMenu/RetryResumeButton

const MESSAGE_DIED := "You died"
const BUTTON_DIED := "Retry"

var paused: = false setget set_paused


func _ready() -> void:
	PlayerData.connect("updated", self, "update_interface")
	PlayerData.connect("died", self, "_on_Player_died")
	PlayerData.connect("reset", self, "_on_Player_reset")
	PlayerData.connect("pause", self, "_on_Player_pause")
	update_interface()


func _on_Player_died() -> void:
	self.paused = true
	title_label.text = MESSAGE_DIED
	retry_button.text = BUTTON_DIED


func _on_Player_reset() -> void:
	self.paused = false


func _on_Player_pause(value: bool) -> void:
	self.paused = value


func update_interface() -> void:
	score_label.text = "Score: %s" % PlayerData.score


func set_paused(value: bool) -> void:
	paused = value
	scene_tree.paused = value
	pause_overlay.visible = value


func _resumeretry_pressed():
	if BUTTON_DIED == retry_button.text:
		PlayerData.score = 0
		get_tree().paused = false
		get_tree().reload_current_scene()
	else:
		self.paused = false
		PlayerData.emit_signal("pause", false)
