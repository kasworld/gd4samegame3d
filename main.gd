extends Node3D

var cabinet_size := Vector3(40,22,10)

func _ready() -> void:
	reset_camera_pos()
	$OmniLight3D.position = cabinet_size/2 + Vector3(0,0,cabinet_size.length())
	$OmniLight3D.omni_range = cabinet_size.length()*2

	$SameGame.game_ended.connect(game_ended)
	$SameGame.score_changed.connect(update_score_label)
	$SameGame.init(cabinet_size)

func game_ended(game :SameGame) -> void:
	$SameGame.init(cabinet_size)

func update_score_label(점수 :float) -> void:
	$"왼쪽패널/점수".text = "현재점수 %d" % 점수

var camera_move = false
func _process(_delta: float) -> void:
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*cabinet_size.x/2, cos(t)*cabinet_size.y/2, cabinet_size.length()*0.4 ) + cabinet_size/2
		$Camera3D.look_at(Vector3.ZERO)

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()

func _on_카메라변경_pressed() -> void:
	camera_move = !camera_move
	if camera_move == false:
		reset_camera_pos()

func reset_camera_pos()->void:
	$Camera3D.position = Vector3(0, 0, cabinet_size.x/2 *1.1)
	$Camera3D.look_at(Vector3.ZERO)
	$Camera3D.far = cabinet_size.length()
