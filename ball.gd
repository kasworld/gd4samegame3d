extends StaticBody3D
class_name Ball

signal ball_mouse_entered(me :Ball)
signal ball_mouse_exited(me :Ball)

var pos2d :Vector2i
var type_num :int

func _to_string() -> String:
	return "Ball%d-%s" % [type_num, pos2d]

func set_ballinfo(typenum :int, pos :Vector2i) -> Ball:
	type_num = typenum
	pos2d = pos
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
