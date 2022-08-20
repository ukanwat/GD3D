extends RigidBody

onready var MESH: MeshInstance = $MeshInstance

func change_color(color: Color):
	var newMaterial = SpatialMaterial.new()
	newMaterial.albedo_color = color
	MESH.material_override = newMaterial
	pass
