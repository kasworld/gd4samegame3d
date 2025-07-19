extends Node3D

var ball_grid :Array # [x][y]

const MaxBallType = 3
var tex_list :Array

func _ready() -> void:
	set_walls()
	reset_camera_pos()
	tex_list = Config.tex_array.duplicate()
	tex_list.shuffle()
	tex_list = tex_list.slice(0,3)
	add_balls()

func set_walls() -> void:
	$WallBox.mesh.size = Config.WorldSize
	$WallBox.position = Config.WorldSize/2 - Vector3(0.5,0.5,0)
	$OmniLight3D.position = Config.WorldSize/2 + Vector3(0,0,Config.WorldSize.length()/2)
	$OmniLight3D.omni_range = Config.WorldSize.length()

func add_balls() -> void:
	ball_grid = []
	for y in Config.WorldSize.y:
		ball_grid.append([])
		for x in Config.WorldSize.x:
			var ball_num = randi_range(0,tex_list.size()-1)
			var b = preload("res://ball.tscn").instantiate().set_ballinfo(ball_num, Vector2i(x,y)
				).set_material(tex_list[ball_num]
				).set_radius(0.5)
			b.position = Vector3(x,y,0.5)
			b.ball_mouse_entered.connect(ball_mouse_entered)
			b.ball_mouse_exited.connect(ball_mouse_exited)
			$BallContainer.add_child(b)
			ball_grid[-1].append(b)
	#print(ball_grid)

var dir_list = [Vector2i(0,-1), Vector2i(-1,0), Vector2i(0, 1), Vector2i(1,0) ]
var selected_ball_list :Array[Ball]
func ball_mouse_entered(b :Ball) -> void:
	$"왼쪽패널/현재위치".text = "%s" % b
	if not selected_ball_list.is_empty():
		for n in selected_ball_list:
			n.stop_animation()
		print(selected_ball_list)
		selected_ball_list = []
		
	var visited_pos :Dictionary # vector2i 
	var to_visit_pos :Array # vector2i
	
	to_visit_pos.append(b.pos2d)
	selected_ball_list.append(b)
	while not to_visit_pos.is_empty():
		var current_pos = to_visit_pos.pop_front()
		visited_pos[current_pos] = true
		var current_ball = ball_grid[current_pos.x][current_pos.y]
		if current_ball.type_num == b.type_num:
			selected_ball_list.append(current_ball)
			for dir in dir_list:
				var to_pos = current_pos + dir
				if to_pos.x < 0 or to_pos.x >= Config.WorldSize.x or to_pos.y < 0 or to_pos.y >= Config.WorldSize.y:
					continue
				if visited_pos.has(to_pos) :
					continue
				to_visit_pos.append(to_pos)

	for n in selected_ball_list:
		n.start_animation()
	$"왼쪽패널/선택목록".text = array_to_multiline_text(selected_ball_list)

func ball_mouse_exited(b :Ball) -> void:
	pass
	#for n in selected_ball_list:
		#n.stop_animation()

func array_to_multiline_text(a :Array) -> String:
	var rtn = ""
	for n in a:
		rtn += "%s\n" %[n]
	return rtn

var camera_move = false
func _process(_delta: float) -> void:
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
