extends Building
class_name Fan

@export var direction_angle: float = -PI / 2.0
@export var cone_angle: float = 1.0
@export var range: float = 200.0
@export var force: float = 320.0

func get_descriptor() -> Dictionary:
    return {
        "type": "fan",
        "position": global_position,
        "direction": Vector2.from_angle(direction_angle),
        "cone": cone_angle,
        "range": range,
        "force": force,
        "id": building_id
    }
