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
var co3d_grid :SamegameGrid # [x][y]
var 점수 :int

var move_ani_data := [] # starttime, co3d , startpos, dstpos
func handle_move_ani() -> void:
	# del old data 
	var new_data := []
	var anidur := 0.5
	var nowtime := Time.get_unix_time_from_system()
	for mad in move_ani_data:
		if nowtime - mad.starttime < anidur:
			new_data.append(mad)
	move_ani_data = new_data
	for mad in move_ani_data:
		var rate = (nowtime - mad.starttime) / anidur
		mad.co3d.position = lerp(mad.startpos, mad.dstpos, rate)

func _ready() -> void:
	set_walls()
	reset_camera_pos()
	new_game()

func new_game() -> void:
	점수 = 0
	update_score_label()
	for n in $CO3DContainer.get_children():
		n.queue_free()
	add_co3d()

func set_walls() -> void:
	$WallBox.mesh.size = WorldSize
	$WallBox.position = WorldSize/2 - Vector3(0.5,0.5,0)
	$OmniLight3D.position = WorldSize/2 + Vector3(0,0,WorldSize.length()/2)
	$OmniLight3D.omni_range = WorldSize.length()

func add_co3d() -> void:
	co3d_grid = SamegameGrid.new(WorldSize.x, WorldSize.y)
	for x in WorldSize.x:
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
			co3d_grid.set_data(x,y,b)

var selected_co3d_list :Array[CollisionObject3D]
func co3d_mouse_entered(b :CollisionObject3D) -> void:
	$"왼쪽패널/현재위치".text = "%s" % b
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

func update_score_label() -> void:
	$"왼쪽패널/점수".text = "점수 %d" % 점수

func co3d_mouse_pressed(b :CollisionObject3D) -> void:
	var co3d_list = co3d_grid.find_sameballs(b)
	점수 += pow(co3d_list.size() ,2)
	update_score_label()
	for n in co3d_list:
		var p2d = n.get_pos2d()
		co3d_grid.set_data(p2d.x,p2d.y, null)
		n.queue_free()
	if co3d_grid.count_data() == 0:
		new_game.call_deferred()
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

func array_to_multiline_text(a :Array) -> String:
	var rtn = ""
	for n in a:
		rtn += "%s\n" %[n]
	return rtn

var camera_move = false
func _process(_delta: float) -> void:
	handle_move_ani()
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
