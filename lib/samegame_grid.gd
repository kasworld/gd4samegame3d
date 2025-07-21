class_name SamegameGrid

var grid_data :Array # [x][y]
var dir_list = [Vector2i(0,-1), Vector2i(-1,0), Vector2i(0, 1), Vector2i(1,0) ]
var grid_size :Vector2i

func _init(x :int, y:int) -> void:
	grid_size = Vector2i(x,y)
	grid_data = []
	for xi in grid_size.x:
		grid_data.append([])
		for yi in grid_size.y:
			grid_data[-1].append(null)

func get_data(x :int, y :int) -> CollisionObject3D:
	return grid_data[x][y]

func set_data(x :int, y :int, v :CollisionObject3D):
	#assert(grid_data[x][y] == null)
	grid_data[x][y] = v

func count_data() -> int:
	var rtn :int = 0
	for x in grid_size.x:
		for y in grid_size.y:
			if grid_data[x][y] != null:
				rtn +=1
	return rtn
	
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
		var current_ball = grid_data[current_pos.x][current_pos.y]
		if current_ball == null:
			continue
		if current_ball.type_num == b.type_num:
			found_balls.append(current_ball)
			for dir in dir_list:
				var to_pos = current_pos + dir
				if to_pos.x < 0 or to_pos.x >= grid_size.x or to_pos.y < 0 or to_pos.y >= grid_size.y:
					continue
				if grid_data[current_pos.x][current_pos.y] == null:
					continue
				if visited_pos.has(to_pos) :
					continue
				to_visit_pos.append(to_pos)
	return found_balls

func fill_down() -> void:
	for x in grid_size.x:
		for y in grid_size.y-1:
			if grid_data[x][y] == null:
				# find not null
				var yfound = grid_size.y
				for ynot in range(y,grid_size.y):
					if grid_data[x][ynot] != null:
						yfound = ynot
						break
				if yfound < grid_size.y:
					grid_data[x][y] = grid_data[x][yfound]
					grid_data[x][yfound] = null

func fill_left() -> void:
	for x in grid_size.x-1:
		if is_grid_y_empty(x):
			var xfound = grid_size.x
			for xnot in range(x,grid_size.x):
				if not is_grid_y_empty(xnot):
					xfound = xnot
					break
			if xfound < grid_size.x:
				grid_data[x] = grid_data[xfound]
				grid_data[xfound] = new_empty_grid_y()

func is_grid_y_empty(x :int) -> bool:
	var y_empty := true
	for b in grid_data[x]:
		if b != null:
			y_empty = false
			break
	return y_empty	

func new_empty_grid_y() -> Array:
	var rtn := []
	for i in grid_size.y:
		rtn.append(null)
	return rtn
