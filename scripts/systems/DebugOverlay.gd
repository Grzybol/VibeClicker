extends Control
class_name DebugOverlay

@export var world: Node
var visible_overlay: bool = false

func _ready() -> void:
    hide()

func toggle() -> void:
    visible_overlay = not visible_overlay
    visible = visible_overlay

func update_overlay() -> void:
    if world == null:
        return
    var shard_count: int = world.call("get_shard_count")
    var text := "Shards: %d\n" % shard_count
    text += "FPS: %0.1f\n" % Engine.get_frames_per_second()
    if has_node("Label"):
        $Label.text = text
