extends Node2D
class_name Rock

signal burst_spawned(count: int)

@export var world: Node
@export var spawn_point: Vector2 = Vector2.ZERO
var balance: Dictionary = {}

func setup(world_ref: Node, balance_data: Dictionary) -> void:
    world = world_ref
    balance = balance_data

func trigger_hit(striker: Node = null) -> void:
    if world == null:
        return
    var spawns: Dictionary = balance["spawns"]
    var count: int = int(spawns.get("shards_per_hit", 10))
    var speed_min: float = spawns.get("spawn_speed_min", 120.0)
    var speed_max: float = spawns.get("spawn_speed_max", 220.0)
    var angle_center: float = spawns.get("spawn_angle_center", -PI / 2.0)
    var angle_spread: float = spawns.get("spawn_angle_spread", PI / 3.0)
    var origin: Vector2 = global_position + spawn_point
    world.call("spawn_shards", origin, count, speed_min, speed_max, angle_center, angle_spread)
    emit_signal("burst_spawned", count)
