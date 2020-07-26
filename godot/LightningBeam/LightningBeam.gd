extends RayCast2D

export (int, 1, 10) var flashes := 3
export (float, 0.0, 3.0) var flash_time := 0.1
export (int, 0, 10) var bounces_max := 3
export var lightning_jolt: PackedScene = preload("res://LightningBeam/LightningJolt.tscn")

var target_point := Vector2.ZERO

onready var collider := $Collider
onready var jump_area := $JumpArea


func _physics_process(delta):
	cast_to = Vector2(650, 0)

	target_point = to_global(cast_to)

	if is_colliding():
		target_point = get_collision_point()

	collider.global_position = target_point
	jump_area.global_position = target_point


func shoot() -> void:
	var _target_point = target_point

	var _primary_body = collider.get_overlapping_bodies()
	var _secondary_bodies = jump_area.get_overlapping_bodies()

	if _primary_body.size() > 0:
		_target_point = _primary_body.front().global_position
		_secondary_bodies.erase(collider.get_overlapping_bodies()[0])

	for flash in range(flashes):
		var _start = global_position

		var _new_jolt = lightning_jolt.instance()
		add_child(_new_jolt)
		_new_jolt.create(_start, target_point)

		_start = _target_point
		for _i in range(min(bounces_max, _secondary_bodies.size())):
			var _body = _secondary_bodies[_i]

			_new_jolt = lightning_jolt.instance()
			add_child(_new_jolt)
			_new_jolt.create(_start, _body.global_position)

			_start = _body.global_position

		yield(get_tree().create_timer(flash_time), "timeout")
