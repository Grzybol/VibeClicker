extends Control
class_name Talents

@export var balance: Dictionary = {}
@export var economy: Economy

var unlocked: Dictionary = {}

func _ready() -> void:
    _build_grid()

func _build_grid() -> void:
    if not balance.has("talents"):
        return
    var grid: Array = balance["talents"].get("grid", [])
    if not has_node("GridContainer"):
        return
    var grid_container: GridContainer = $GridContainer
    grid_container.columns = max(1, grid.size())
    for child in grid_container.get_children():
        child.queue_free()
    for column in grid:
        for cell in column:
            var btn := Button.new()
            btn.text = cell.get("id", "?")
            btn.tooltip_text = cell.get("desc", "")
            btn.pressed.connect(_on_talent_pressed.bind(cell))
            grid_container.add_child(btn)

func _on_talent_pressed(cell: Dictionary) -> void:
    var id: String = cell.get("id", "")
    if unlocked.has(id):
        return
    var cost: int = cell.get("cost", 1)
    if economy != null and economy.spend(cost):
        unlocked[id] = true
