extends Node3D

const BallRadius := 0.5
const WorldSize := Vector3(40,22,BallRadius*2)
const MaxBallType = 4
var color_list = [
	Color.RED, 
	Color.GREEN, 
	Color.BLUE,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA,
	Color.WHITE,
	Color.BLACK,
]
var char_list = ["♥","♣","♠","♦","★","☆"]
var co3d_grid :Array # [x][y]
var 점수 :int

func _ready() -> void:
	set_walls()
	reset_camera_pos()
	add_balls()

func set_walls() -> void:
	$WallBox.mesh.size = WorldSize
	$WallBox.position = WorldSize/2 - Vector3(0.5,0.5,0)
	$OmniLight3D.position = WorldSize/2 + Vector3(0,0,WorldSize.length()/2)
	$OmniLight3D.omni_range = WorldSize.length()

func add_balls() -> void:
	co3d_grid = []
	for x in WorldSize.x:
		co3d_grid.append([])
		for y in WorldSize.y:
			var co3d_num = randi_range(0,MaxBallType-1)
			var b = preload("res://char.tscn").instantiate().set_type_num(co3d_num
				).set_height_depth(0.9,0.2
				).set_char(char_list[co3d_num]
				).set_color(color_list[co3d_num])
			b.position = Vector3(x,y,0.5)
			b.co3d_mouse_entered.connect(co3d_mouse_entered)
			b.co3d_mouse_exited.connect(co3d_mouse_exited)
			b.co3d_mouse_pressed.connect(co3d_mouse_pressed)
			$CO3DContainer.add_child(b)
			co3d_grid[-1].append(b)

var dir_list = [Vector2i(0,-1), Vector2i(-1,0), Vector2i(0, 1), Vector2i(1,0) ]
var selected_co3d_list :Array[CollisionObject3D]
func co3d_mouse_entered(b :CollisionObject3D) -> void:
	$"왼쪽패널/현재위치".text = "%s" % b
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()
	selected_co3d_list = find_sameballs(b)
	for n in selected_co3d_list:
		n.start_animation()

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
				if to_pos.x < 0 or to_pos.x >= WorldSize.x or to_pos.y < 0 or to_pos.y >= WorldSize.y:
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
	점수 += pow(co3d_list.size() ,2)
	$"왼쪽패널/점수".text = "점수 %d" % 점수
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
		$Camera3D.position = Vector3(sin(t)*WorldSize.x/2, cos(t)*WorldSize.y/2, WorldSize.length()*0.4 ) + WorldSize/2
		$Camera3D.look_at(WorldSize/2)

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
	$Camera3D.position = Vector3(WorldSize.x/2, WorldSize.y/2, WorldSize.x/2 *1.1)
	$Camera3D.look_at(WorldSize/2)
	$Camera3D.far = WorldSize.length()
