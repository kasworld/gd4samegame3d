extends Node3D
class_name SameGame

signal score_changed(점수 :float)
signal game_ended(game :SameGame)

const MaxBallType := 2
var color_list := [
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA,
	Color.WHITE,
	Color.BLACK,
]

var cabinet_size :Vector3
var game_size := Vector2(16,9)
var tile_size :Vector3

func pos2d_to_pos3d( x :int, y :int) -> Vector3:
	return Vector3(
		float(x) * tile_size.x - cabinet_size.x/2 + tile_size.x/2,
		float(y) *tile_size.y -cabinet_size.y/2 + tile_size.y/2,
		0.0)
func pos3d_to_pos2d( pos :Vector3 ) -> Vector2i:
	return Vector2i(
		snappedi( (pos.x + cabinet_size.x/2 - tile_size.x/2) / tile_size.x ,1 ),
		snappedi( (pos.y + cabinet_size.y/2 - tile_size.y/2) / tile_size.y ,1 ),
	)


var char_list := ["♥","♣","♠","♦","★","☆"]
var co3d_grid :SamegameGrid # [x][y]
var 점수 :int

func init(sz :Vector3) -> SameGame:
	$WallBox.mesh.size = cabinet_size
	$WallBox.position =  - Vector3(0.5,0.5,0)
	cabinet_size = sz
	tile_size = Vector3(cabinet_size.x / game_size.x, cabinet_size.y / game_size.y, cabinet_size.y / game_size.y /4 )
	SameGameTile.calc_pos_in_grid = pos3d_to_pos2d
	new_game()
	return self

func new_game() -> void:
	점수 = 0
	score_changed.emit(점수)
	for n in $CO3DContainer.get_children():
		n.queue_free()
	add_co3d()

var move_ani_data := [] # starttime, co3d , startpos, dstpos
func handle_move_ani() -> void:
	# del old data
	var new_data := []
	var anidur := 0.5
	var nowtime := Time.get_unix_time_from_system()
	for mad in move_ani_data:
		if nowtime - mad.starttime < anidur:
			new_data.append(mad)
		else :
			mad.co3d.position = mad.dstpos
	move_ani_data = new_data
	for mad in move_ani_data:
		var rate = (nowtime - mad.starttime) / anidur
		mad.co3d.position = lerp(mad.startpos, mad.dstpos, rate)

func _process(_delta: float) -> void:
	handle_move_ani()

func add_co3d() -> void:
	co3d_grid = SamegameGrid.new( game_size.x , game_size.y )
	for x :int in game_size.x:
		for y :int in game_size.y:
			var co3d_num = randi_range(0,MaxBallType-1)
			var b = preload("res://same_game/same_game_tile/same_game_tile.tscn").instantiate().set_type_num(co3d_num
				).set_size(tile_size
				).set_char(char_list[co3d_num]
				).set_color( Color(color_list[co3d_num],0.9)  )
			b.position = pos2d_to_pos3d(x,y)
			b.co3d_mouse_entered.connect(co3d_mouse_entered)
			b.co3d_mouse_exited.connect(co3d_mouse_exited)
			b.co3d_mouse_pressed.connect(co3d_mouse_pressed)
			$CO3DContainer.add_child(b)
			co3d_grid.set_data(x, y, b)

var selected_co3d_list :Array[CollisionObject3D]
func co3d_mouse_entered(b :CollisionObject3D) -> void:
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()
	selected_co3d_list = find_sameballs(b)
	for n in selected_co3d_list:
		n.start_animation()

func co3d_mouse_exited(_b :CollisionObject3D) -> void:
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()

func co3d_mouse_pressed(b :CollisionObject3D) -> void:
	var co3d_list = find_sameballs(b)
	점수 += pow(co3d_list.size(), 2) as int
	score_changed.emit(점수)
	for n in co3d_list:
		var p2d = pos3d_to_pos2d(n.position)
		co3d_grid.set_data(p2d.x,p2d.y, null)
		n.queue_free()
	if co3d_grid.count_data() == 0:
		score_changed.emit(점수)
		game_ended.emit(self)
		return
	co3d_grid.fill_down()
	co3d_grid.fill_left()
	fix_gridco3d_pos_all()

func find_sameballs(b :CollisionObject3D) -> Array[CollisionObject3D]:
	var found_balls :Array[CollisionObject3D] = []
	var visited_pos :Dictionary # vector2i
	var to_visit_pos :Array # vector2i
	to_visit_pos.append(pos3d_to_pos2d(b.position) )
	while not to_visit_pos.is_empty():
		var current_pos = to_visit_pos.pop_front()
		if visited_pos.has(current_pos):
			continue
		visited_pos[current_pos] = true
		var current_ball = co3d_grid.grid_data[current_pos.x][current_pos.y]
		if current_ball == null:
			continue
		if current_ball.type_num == b.type_num:
			found_balls.append(current_ball)
			for dir in co3d_grid.dir_list:
				var to_pos = current_pos + dir
				if to_pos.x < 0 or to_pos.x >= co3d_grid.grid_size.x or to_pos.y < 0 or to_pos.y >= co3d_grid.grid_size.y:
					continue
				if co3d_grid.grid_data[current_pos.x][current_pos.y] == null:
					continue
				if visited_pos.has(to_pos) :
					continue
				to_visit_pos.append(to_pos)
	return found_balls


func fix_gridco3d_pos_all() -> void:
	for x in co3d_grid.grid_size.x:
		for y in co3d_grid.grid_size.y:
			var co3d = co3d_grid.get_data(x,y)
			if co3d != null:
				move_ani_data.append({
					"starttime" : Time.get_unix_time_from_system(),
					"co3d" : co3d,
					"startpos" : co3d.position,
					"dstpos" : Vector3(x, y, 0.5),
				})
