extends Spatial

var CRATE: PackedScene = preload("res://Objects/Crate.tscn")
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	for i in range(1000):
		_create_new_crate()
	pass

func _create_new_crate() -> void:
	var new_crate = CRATE.instance()
	var x = rng.randi_range(-49, 49)
	var y = rng.randi_range(10, 50)
	var z = rng.randi_range(-49, 49)
	var color := Color(rng.randf(),rng.randf(),rng.randf())
	new_crate.translate(Vector3(x,y,z))
	new_crate.call_deferred("change_color", color)
	add_child(new_crate)
	pass
