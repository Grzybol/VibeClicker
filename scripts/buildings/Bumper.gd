extends Building
class_name Bumper

@export var normal_angle: float = -PI / 2.0
@export var restitution: float = 0.8

func get_descriptor() -> Dictionary:
    return {
        "type": "bumper",
        "position": global_position,
        "normal": Vector2.from_angle(normal_angle),
        "restitution": restitution,
        "id": building_id
    }
