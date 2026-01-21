extends Node2D
class_name SameGame

signal score_changed(점수 :float)
signal game_ended(game :SameGame)

const MaxBallType := 4
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

var BallRadius :float
var cabinet_size :Vector3

var char_list := ["♥","♣","♠","♦","★","☆"]
var co3d_grid :SamegameGrid # [x][y]
var 점수 :int

func init(sz :Vector3) -> void:
	cabinet_size = sz
	BallRadius = 0.5 #cabinet_size.z/2
	점수 = 0
	$WallBox.mesh.size = cabinet_size
	$WallBox.position = cabinet_size/2 - Vector3(0.5,0.5,0)

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
	co3d_grid = SamegameGrid.new( snappedi(cabinet_size.x,1) , snappedi(cabinet_size.y,1) )
	for x :int in cabinet_size.x:
		for y :int in cabinet_size.y:
			var co3d_num = randi_range(0,MaxBallType-1)
			var b = preload("res://same_game/same_game_tile/same_game_tile.tscn").instantiate().set_type_num(co3d_num
				).set_height_depth(0.9,0.2
				).set_char(char_list[co3d_num]
				).set_color( Color(color_list[co3d_num],0.9)  )
			b.position = Vector3(x,y,0.5)
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
	selected_co3d_list = co3d_grid.find_sameballs(b)
	for n in selected_co3d_list:
		n.start_animation()

func co3d_mouse_exited(_b :CollisionObject3D) -> void:
	for n in selected_co3d_list:
		if n != null:
			n.stop_animation()

func co3d_mouse_pressed(b :CollisionObject3D) -> void:
	var co3d_list = co3d_grid.find_sameballs(b)
	점수 += pow(co3d_list.size(), 2) as int
	score_changed.emit(점수)
	for n in co3d_list:
		var p2d = n.get_pos2d()
		co3d_grid.set_data(p2d.x,p2d.y, null)
		n.queue_free()
	if co3d_grid.count_data() == 0:
		$"왼쪽패널/점수기록".text += "\n%d" % 점수
		game_ended.emit(self)
		return
	co3d_grid.fill_down()
	co3d_grid.fill_left()
	fix_gridco3d_pos_all()

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
