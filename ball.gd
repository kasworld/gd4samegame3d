extends MeshInstance3D
class_name Ball

func set_material(mat :Material) -> Ball:
	mesh.material = mat
	return self

func set_color(co :Color) -> Ball:
	mesh.material.albedo_color = co
	return self

func get_color() -> Color:
	return mesh.material.albedo_color

func set_radius(r :float) -> Ball:
	mesh.radius = r
	mesh.height = r*2
	return self
