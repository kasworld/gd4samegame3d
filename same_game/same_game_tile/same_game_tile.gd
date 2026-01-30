extends StaticBody3D
class_name SameGameTile

signal co3d_mouse_entered(me :SameGameTile)
signal co3d_mouse_exited(me :SameGameTile)
signal co3d_mouse_pressed(me :SameGameTile)

static var calc_pos_in_grid :Callable
static var tile_size :Vector3

func _to_string() -> String:
	return "SameGameTile%d-%s" % [type_num, calc_pos_in_grid.call(position)]

var type_num :int
func set_type_num(typenum :int) -> SameGameTile:
	type_num = typenum
	return self

func set_material(mat :Material) -> SameGameTile:
	$MeshInstance3D.mesh.material = mat
	return self

func set_color(co :Color) -> SameGameTile:
	$MeshInstance3D.mesh.material.albedo_color = co
	return self

func get_color() -> Color:
	return $MeshInstance3D.mesh.material.albedo_color

func set_char(s :String) -> SameGameTile:
	$MeshInstance3D.mesh.text = s
	$MeshInstance3D.mesh.depth = tile_size.z/4
	$CollisionShape3D.shape.size = tile_size
	$MeshInstance3D.mesh.pixel_size = tile_size.y/13
	return self

func _on_mouse_entered() -> void:
	start_animation()
	co3d_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	stop_animation()
	co3d_mouse_exited.emit(self)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "new_animation":
		start_animation()

func stop_animation() -> void:
	$AnimationPlayer.play("RESET")
func start_animation() -> void:
	$AnimationPlayer.play("new_animation")

func _on_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		co3d_mouse_pressed.emit(self)
