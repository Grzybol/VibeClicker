extends Node

@onready var world_scene: PackedScene = preload("res://scenes/World.tscn")
@onready var ui_scene: PackedScene = preload("res://scenes/UI.tscn")

var world: Node
var ui: CanvasLayer
var balance: Dictionary = {}

var economy := Economy.new()
var upgrades := Upgrades.new()
var prestige := Prestige.new()
var status_effects := StatusEffects.new()
var save_load := SaveLoad.new()
var steam := SteamService.new()
var timer_bus := TimerBus.new()

func _ready() -> void:
    add_child(economy)
    add_child(upgrades)
    add_child(prestige)
    add_child(status_effects)
    add_child(save_load)
    add_child(steam)
    add_child(timer_bus)
    balance = _load_balance()
    economy.setup(balance)
    upgrades.setup(balance)
    prestige.setup(balance, economy)
    status_effects.setup(balance)
    timer_bus.ensure_timer("autosave", 10.0)
    timer_bus.timer_fired.connect(_on_timer_fired)
    _spawn_world()
    _spawn_ui()
    _load_save()

func _load_balance() -> Dictionary:
    var file := FileAccess.open("res://content/balance.json", FileAccess.READ)
    if file == null:
        push_error("Failed to load balance.json")
        return {}
    var text := file.get_as_text()
    file.close()
    var data := JSON.parse_string(text)
    if typeof(data) == TYPE_DICTIONARY:
        return data
    return {}

func _spawn_world() -> void:
    world = world_scene.instantiate()
    add_child(world)
    world.call("setup", balance, economy, upgrades, prestige, status_effects, self)

func _spawn_ui() -> void:
    ui = ui_scene.instantiate()
    add_child(ui)
    ui.call("setup", economy, upgrades, prestige, balance)
    ui.call("set_world", world)
    world.connect("building_selected", Callable(ui, "set_selected_building"))
    ui.call("set_selected_building", world.call("get_selected_building"))

func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        get_tree().quit()
    if Input.is_action_just_pressed("toggle_debug") and ui:
        ui.call("toggle_debug")
    if Input.is_action_just_pressed("toggle_prestige") and ui:
        ui.call("toggle_prestige")
    if Input.is_action_just_pressed("toggle_pause"):
        get_tree().paused = not get_tree().paused

func _unhandled_input(event: InputEvent) -> void:
    if world == null:
        return
    if event is InputEventMouseButton and event.pressed and not event.is_echo():
        var mb := event as InputEventMouseButton
        if ui and bool(ui.call("is_pointer_over_ui", mb.position)):
            return
        match mb.button_index:
            MOUSE_BUTTON_LEFT:
                world.call("place_building_world", mb.position)
            MOUSE_BUTTON_RIGHT:
                world.call("remove_building_world", mb.position)
            MOUSE_BUTTON_WHEEL_UP:
                world.call("cycle_building", -1)
            MOUSE_BUTTON_WHEEL_DOWN:
                world.call("cycle_building", 1)
    elif event is InputEventKey and event.pressed and not event.is_echo():
        var key_event := event as InputEventKey
        match key_event.keycode:
            KEY_1:
                world.call("select_building_by_number", 0)
            KEY_2:
                world.call("select_building_by_number", 1)
            KEY_3:
                world.call("select_building_by_number", 2)
            KEY_4:
                world.call("select_building_by_number", 3)

func _on_timer_fired(name: StringName) -> void:
    if name == "autosave":
        _save_state()

func _save_state() -> void:
    var state := world.call("serialize_state")
    state["economy"] = {
        "shiny": economy.shiny,
        "fluxium": economy.fluxium,
        "total_banked": economy.total_banked
    }
    state["upgrades"] = upgrades.levels
    save_load.save_state(state)

func _load_save() -> void:
    var state := save_load.load_state()
    if state.is_empty():
        return
    economy.shiny = state.get("economy", {}).get("shiny", economy.shiny)
    economy.fluxium = state.get("economy", {}).get("fluxium", economy.fluxium)
    economy.total_banked = state.get("economy", {}).get("total_banked", economy.total_banked)
    upgrades.levels = state.get("upgrades", {})
    world.call("deserialize_state", state)
    economy.emit_signal("shiny_changed", economy.shiny)
    economy.emit_signal("fluxium_changed", economy.fluxium)

func collector_deposit(count: int) -> void:
    economy.shard_deposited(count)

func get_shard_count() -> int:
    return world.call("get_shard_count")
