extends Node3D

var co3d_grid :Array # [x][y]

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
	co3d_grid = []
	for x in Config.WorldSize.x:
		co3d_grid.append([])
		for y in Config.WorldSize.y:
			var co3d_num = randi_range(0,tex_list.size()-1)
			var b = preload("res://ball.tscn").instantiate().set_type_num(co3d_num
				).set_material(tex_list[co3d_num]
				).set_radius(0.5)
			b.position = Vector3(x,y,0.5)
			b.co3d_mouse_entered.connect(co3d_mouse_entered)
			b.co3d_mouse_exited.connect(co3d_mouse_exited)
			b.co3d_mouse_pressed.connect(co3d_mouse_pressed)
			$CO3DContainer.add_child(b)
			co3d_grid[-1].append(b)
	#print(co3d_grid)

var dir_list = [Vector2i(0,-1), Vector2i(-1,0), Vector2i(0, 1), Vector2i(1,0) ]
var selected_co3d_list :Array[CollisionObject3D]
func co3d_mouse_entered(b :CollisionObject3D) -> void:
	$"왼쪽패널/현재위치".text = "%s" % b
	#print(selected_co3d_list)
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()
	selected_co3d_list = find_sameballs(b)
	for n in selected_co3d_list:
		n.start_animation()
	#$"왼쪽패널/선택목록".text = array_to_multiline_text(selected_co3d_list)

func find_sameballs(b :CollisionObject3D) -> Array[CollisionObject3D]:
	var found_balls :Array[CollisionObject3D] = []
	var visited_pos :Dictionary # vector2i 
	var to_visit_pos :Array # vector2i
	to_visit_pos.append(b.get_pos2d())
	while not to_visit_pos.is_empty():
		var current_pos = to_visit_pos.pop_front()
		if visited_pos.has(current_pos):
			continue
		visited_pos[current_pos] = true
		var current_ball = co3d_grid[current_pos.x][current_pos.y]
		if current_ball == null:
			continue
		if current_ball.type_num == b.type_num:
			found_balls.append(current_ball)
			for dir in dir_list:
				var to_pos = current_pos + dir
				if to_pos.x < 0 or to_pos.x >= Config.WorldSize.x or to_pos.y < 0 or to_pos.y >= Config.WorldSize.y:
					continue
				if co3d_grid[current_pos.x][current_pos.y] == null:
					continue
				if visited_pos.has(to_pos) :
					continue
				to_visit_pos.append(to_pos)
	return found_balls

func co3d_mouse_exited(b :CollisionObject3D) -> void:
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()

func co3d_mouse_pressed(b :CollisionObject3D) -> void:
	var co3d_list = find_sameballs(b)
	for n in co3d_list:
		var p2d = n.get_pos2d()
		co3d_grid[p2d.x][p2d.y] = null
		n.queue_free()
	co3d_down()
	co3d_left()
	fix_gridco3d_pos_all()

func co3d_down() -> void:
	var xlen = co3d_grid.size()
	var ylen = co3d_grid[0].size()
	for x in xlen:
		for y in ylen-1:
			if co3d_grid[x][y] == null:
				# find not null
				var yfound = ylen
				for ynot in range(y,ylen):
					if co3d_grid[x][ynot] != null:
						yfound = ynot
						break
				if yfound < ylen:
					co3d_grid[x][y] = co3d_grid[x][yfound]
					co3d_grid[x][yfound] = null

func co3d_left() -> void:
	var xlen = co3d_grid.size()
	var ylen = co3d_grid[0].size()
	for x in xlen-1:
		if is_ballgrid_y_empty(x):
			var xfound = xlen
			for xnot in range(x,xlen):
				if not is_ballgrid_y_empty(xnot):
					xfound = xnot
					break
			if xfound < xlen:
				co3d_grid[x] = co3d_grid[xfound]
				co3d_grid[xfound] = new_empty_ballgrid_y(ylen)

func is_ballgrid_y_empty(x :int) -> bool:
	var y_empty := true
	for b in co3d_grid[x]:
		if b != null:
			y_empty = false
			break
	return y_empty	

func new_empty_ballgrid_y(n :int) -> Array:
	var rtn := []
	for i in n:
		rtn.append(null)
	return rtn

func fix_gridco3d_pos_all() -> void:
	var xlen = co3d_grid.size()
	var ylen = co3d_grid[0].size()
	for x in xlen:
		for y in ylen:
			if co3d_grid[x][y] != null:
				co3d_grid[x][y].position = Vector3(x, y, 0.5)

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
	$Camera3D.position = Vector3(Config.WorldSize.x/2, Config.WorldSize.y/2, Config.WorldSize.x/2 )
	$Camera3D.look_at(Config.WorldSize/2)
	$Camera3D.far = Config.WorldSize.length()
