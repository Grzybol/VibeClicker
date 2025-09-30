extends Control
class_name Shop

@export var upgrades: Upgrades
@export var economy: Economy

var _current_building: String = "Fan"

func _ready() -> void:
    _refresh_buttons()

func refresh() -> void:
    _refresh_buttons()

func _refresh_buttons() -> void:
    if upgrades == null or economy == null:
        return
    if has_node("VBoxContainer/StrikerButton"):
        var cost := upgrades.get_cost("striker_speed")
        $VBoxContainer/StrikerButton.text = "Boost Strikers (%d)" % int(cost)
    if has_node("VBoxContainer/CollectorButton"):
        var cost2 := upgrades.get_cost("collector_speed")
        $VBoxContainer/CollectorButton.text = "Boost Collectors (%d)" % int(cost2)
    if has_node("VBoxContainer/ShardButton"):
        var cost3 := upgrades.get_cost("shard_value")
        $VBoxContainer/ShardButton.text = "Polish Shards (%d)" % int(cost3)
    if has_node("VBoxContainer/SelectedLabel"):
        $VBoxContainer/SelectedLabel.text = "Selected: %s" % _current_building

func _on_striker_button_pressed() -> void:
    if upgrades.buy("striker_speed", economy):
        _refresh_buttons()

func _on_collector_button_pressed() -> void:
    if upgrades.buy("collector_speed", economy):
        _refresh_buttons()

func _on_shard_button_pressed() -> void:
    if upgrades.buy("shard_value", economy):
        _refresh_buttons()

func _on_visibility_changed() -> void:
    _refresh_buttons()

func set_selected_building(name: String) -> void:
    _current_building = name
    if has_node("VBoxContainer/SelectedLabel"):
        $VBoxContainer/SelectedLabel.text = "Selected: %s" % name
    _refresh_buttons()
