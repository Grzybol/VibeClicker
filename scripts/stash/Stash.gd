extends Area2D
class_name Stash

@export var intake_rate: float = 1.0
var world: Node

func setup(world_ref: Node) -> void:
    world = world_ref

func get_aabb() -> Rect2:
    var rect_shape := RectangleShape2D.new()
    for shape in get_shape_owners():
        var owner_shape: Shape2D = get_shape_owner_shape(shape, 0)
        if owner_shape is RectangleShape2D:
            rect_shape = owner_shape
            break
    var size: Vector2 = rect_shape.size
    return Rect2(global_position - size * 0.5, size)
