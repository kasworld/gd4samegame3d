extends Node3D

var ball_grid :Array # [x][y]

func _ready() -> void:
	set_walls()
	reset_camera_pos()
	add_balls()

func set_walls() -> void:
	$WallBox.mesh.size = Config.WorldSize
	$WallBox.position = Config.WorldSize/2 - Vector3(0.5,0.5,0)
	$OmniLight3D.position = Config.WorldSize/2

func add_balls() -> void:
	ball_grid = []
	for y in Config.WorldSize.y:
		ball_grid.append([])
		for x in Config.WorldSize.x:
			var ball_num = randi_range(0,Config.tex_array.size()-1)
			var b = preload("res://ball.tscn").instantiate().set_ballinfo(ball_num+9, "%d,%d" %[x,y]
				).set_material(Config.tex_array[ball_num])
			b.position = Vector3(x,y,0.5)
			$BallContainer.add_child(b)
			ball_grid[-1].append(b)
	print(ball_grid)
	
var camera_move = false
func _process(delta: float) -> void:
	var t = Time.get_unix_time_from_system() /-3.0
	if camera_move:
		$Camera3D.position = Vector3(sin(t)*Config.WorldSize.x/2, cos(t)*Config.WorldSize.y/2, Config.WorldSize.length()*0.4 ) + Config.WorldSize/2
		$Camera3D.look_at(Config.WorldSize/2)

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
	$Camera3D.position = Vector3(Config.WorldSize.x/2, Config.WorldSize.y/2, Config.WorldSize.length()*0.55 )
	$Camera3D.look_at(Config.WorldSize/2)
	$Camera3D.far = Config.WorldSize.length()
