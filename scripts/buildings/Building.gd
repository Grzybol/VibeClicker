extends Node2D
class_name Building

@export var cost: int = 50
var active: bool = true
var building_id: int = randi()

func get_descriptor() -> Dictionary:
    return { "type": "generic", "position": global_position }

func on_tick(dt: float) -> void:
    pass
