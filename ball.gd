extends StaticBody3D
class_name Ball

signal ball_mouse_entered(me :Ball)
signal ball_mouse_exited(me :Ball)
signal ball_mouse_pressed(me :Ball)

var type_num :int

func _to_string() -> String:
	return "Ball%d-%s" % [type_num, get_pos2d()]

func get_pos2d() -> Vector2i:
	return Vector2i(position.x, position.y)

func set_type_num(typenum :int) -> Ball:
	type_num = typenum
	return self
	
func set_material(mat :Material) -> Ball:
	$MeshInstance3D.mesh.material = mat
	return self

func set_color(co :Color) -> Ball:
	$MeshInstance3D.mesh.material.albedo_color = co
	return self

func get_color() -> Color:
	return $MeshInstance3D.mesh.material.albedo_color

func set_radius(r :float) -> Ball:
	$MeshInstance3D.mesh.radius = r
	$MeshInstance3D.mesh.height = r*2
	$CollisionShape3D.shape.radius = r
	return self
	
func _on_mouse_entered() -> void:
	start_animation()
	ball_mouse_entered.emit(self)

func _on_mouse_exited() -> void:
	stop_animation()
	ball_mouse_exited.emit(self)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "new_animation":
		start_animation()

func stop_animation() -> void:
	$AnimationPlayer.play("RESET")
func start_animation() -> void:
	$AnimationPlayer.play("new_animation")

func _on_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		ball_mouse_pressed.emit(self)
