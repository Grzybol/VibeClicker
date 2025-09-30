extends Node2D
class_name World

signal building_selected(name: String)

@onready var rock: Rock = $Rock
@onready var stash: Stash = $Stash
@onready var buildings: Node2D = $Buildings
@onready var units: Node2D = $Units
@onready var shards_node: Node2D = $Shards

var shard_sim := ShardSim.new()
var shard_renderer := ShardRenderer.new()
var economy: Economy
var upgrades: Upgrades
var prestige: Prestige
var status_effects: StatusEffects
var host: Node
var balance: Dictionary = {}
var building_types: Array[String] = ["Fan", "Magnet", "Bumper", "Catapult"]
var selected_building_index: int = 0

var fixed_delta: float = 1.0 / 120.0
var accumulator: float = 0.0

func _ready() -> void:
    position = get_viewport_rect().size * 0.5
    shard_renderer.shard_sim = shard_sim
    shards_node.add_child(shard_renderer)

func setup(balance_data: Dictionary, economy_ref: Economy, upgrades_ref: Upgrades, prestige_ref: Prestige, status_ref: StatusEffects, host_ref: Node) -> void:
    balance = balance_data
    economy = economy_ref
    upgrades = upgrades_ref
    prestige = prestige_ref
    status_effects = status_ref
    host = host_ref
    shard_sim.configure_from_balance(balance)
    rock.setup(self, balance)
    stash.setup(self)
    shard_sim.set_stash_rect(stash.get_aabb())
    _spawn_initial_units()
    emit_signal("building_selected", get_selected_building())

func _spawn_initial_units() -> void:
    var striker := Striker.new()
    striker.position = Vector2(0, -80)
    striker.setup(self, rock, balance)
    units.add_child(striker)
    striker.add_to_group("strikers")
    var collector := Collector.new()
    collector.position = Vector2(0, 200)
    collector.setup(self, shard_sim, stash, balance)
    units.add_child(collector)
    collector.add_to_group("collectors")

func _process(delta: float) -> void:
    accumulator += delta
    while accumulator >= fixed_delta:
        _physics_step(fixed_delta)
        accumulator -= fixed_delta
    shard_renderer.update_mesh()

func _physics_step(dt: float) -> void:
    _refresh_building_fields()
    var banked: int = shard_sim.step(dt)
    if banked > 0:
        economy.shard_deposited(banked)
    if status_effects:
        status_effects.tick(dt)

func spawn_shards(origin: Vector2, count: int, speed_min: float, speed_max: float, angle_center: float, angle_spread: float) -> void:
    var bonus_speed: float = upgrades.get_bonus("striker_speed")
    shard_sim.add_burst(origin, count, speed_min * (1.0 + bonus_speed), speed_max * (1.0 + bonus_speed), angle_center, angle_spread)

func collector_deposit(count: int) -> void:
    host.call("collector_deposit", count)

func cycle_building(delta: int) -> void:
    if building_types.is_empty():
        return
    selected_building_index = wrapi(selected_building_index + delta, 0, building_types.size())
    emit_signal("building_selected", get_selected_building())

func select_building_by_number(index: int) -> void:
    if index < 0 or index >= building_types.size():
        return
    selected_building_index = index
    emit_signal("building_selected", get_selected_building())

func get_selected_building() -> String:
    if building_types.is_empty():
        return ""
    return building_types[selected_building_index]

func place_building_world(screen_position: Vector2) -> void:
    var type_name: String = get_selected_building()
    if type_name == "":
        return
    var local_point: Vector2 = to_local(screen_position)
    var arena_rect: Rect2 = shard_sim.arena
    if not arena_rect.has_point(local_point):
        return
    var cost: float = _get_building_cost(type_name)
    if not economy.spend(cost):
        return
    var node: Building = _instantiate_building(type_name)
    if node == null:
        economy.refund(cost)
        return
    node.position = local_point
    buildings.add_child(node)

func remove_building_world(screen_position: Vector2) -> void:
    var local: Vector2 = to_local(screen_position)
    var closest: Building = null
    var best_dist: float = 48.0
    for child in buildings.get_children():
        if child is Building:
            var dist: float = child.position.distance_to(local)
            if dist < best_dist:
                best_dist = dist
                closest = child
    if closest:
        var refund: float = _get_building_cost(closest.get_class()) * 0.5
        economy.refund(refund)
        closest.queue_free()

func _get_building_cost(type_name: String) -> float:
    var key: String = type_name.to_lower()
    return balance["buildings"].get(key, {}).get("cost", 100)

func _instantiate_building(type_name: String) -> Building:
    match type_name:
        "Fan":
            return Fan.new()
        "Magnet":
            return Magnet.new()
        "Bumper":
            return Bumper.new()
        "Catapult":
            return Catapult.new()
        _:
            return null

func _refresh_building_fields() -> void:
    var data: Array[Dictionary] = []
    for child in buildings.get_children():
        if child is Building and child.active:
            data.append(child.get_descriptor())
    shard_sim.set_buildings(data)

func get_shard_count() -> int:
    return shard_sim.shard_count()

func serialize_state() -> Dictionary:
    var building_data: Array = []
    for child in buildings.get_children():
        if child is Building:
            building_data.append({
                "type": child.get_class(),
                "position": child.position
            })
    return {
        "buildings": building_data
    }

func deserialize_state(state: Dictionary) -> void:
    for child in buildings.get_children():
        child.queue_free()
    var building_data: Array = state.get("buildings", [])
    for entry in building_data:
        var type_name: String = entry.get("type", "")
        var node: Building = null
        match type_name:
            "Fan":
                node = Fan.new()
            "Magnet":
                node = Magnet.new()
            "Bumper":
                node = Bumper.new()
            "Catapult":
                node = Catapult.new()
            _:
                continue
        node.position = entry.get("position", Vector2.ZERO)
        buildings.add_child(node)

func get_stash_rect() -> Rect2:
    return shard_sim.stash_rect
