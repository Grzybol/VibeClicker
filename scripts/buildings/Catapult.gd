extends Building
class_name Catapult

@export var radius: float = 48.0
@export var impulse: Vector2 = Vector2(0, -320)
@export var cooldown: float = 1.2

func get_descriptor() -> Dictionary:
    return {
        "type": "catapult",
        "position": global_position,
        "radius": radius,
        "impulse": impulse,
        "cooldown": cooldown,
        "id": building_id
    }
