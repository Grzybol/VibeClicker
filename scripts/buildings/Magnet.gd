extends Building
class_name Magnet

@export var radius: float = 200.0
@export var force: float = 420.0

func get_descriptor() -> Dictionary:
    return {
        "type": "magnet",
        "position": global_position,
        "radius": radius,
        "force": force,
        "id": building_id
    }
