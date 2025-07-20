extends StaticBody3D
class_name Char

signal co3d_mouse_entered(me :Char)
signal co3d_mouse_exited(me :Char)
signal co3d_mouse_pressed(me :Char)

var type_num :int

func _to_string() -> String:
	return "Char%d-%s" % [type_num, get_pos2d()]

func get_pos2d() -> Vector2i:
	return Vector2i(position.x, position.y)

func set_type_num(typenum :int) -> Char:
	type_num = typenum
	return self

func set_material(mat :Material) -> Char:
	$MeshInstance3D.mesh.material = mat
	return self

func set_color(co :Color) -> Char:
	$MeshInstance3D.mesh.material.albedo_color = co
	return self

func get_color() -> Color:
	return $MeshInstance3D.mesh.material.albedo_color

func set_height_depth(h :float, d :float) -> Char:
	$MeshInstance3D.mesh.depth = d
	$CollisionShape3D.shape.size.y = d
	$CollisionShape3D.shape.size.z = h
	$MeshInstance3D.mesh.pixel_size = h/10
	$CollisionShape3D.shape.size.x = $CollisionShape3D.shape.size.y * 0.9 * $MeshInstance3D.mesh.text.length() 
	return self

func set_char(s :String) -> Char:
	$MeshInstance3D.mesh.text = s
	$CollisionShape3D.shape.size.x = $CollisionShape3D.shape.size.y * 0.9 * $MeshInstance3D.mesh.text.length() 
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

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		co3d_mouse_pressed.emit(self)
