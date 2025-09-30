extends CharacterBody2D
class_name Collector

@export var move_speed: float = 180.0
@export var carry_capacity: int = 4
@export var pickup_radius: float = 32.0
@export var deposit_time: float = 0.2
@export var retarget_interval: float = 0.35

var world: Node
var shard_sim: ShardSim
var stash: Stash
var carried: Array[int] = []
var target_shard: int = -1
var retarget_timer: float = 0.0
var deposit_timer: float = 0.0
var collector_id: int = randi()
var _excluded: Array[int] = []

func setup(world_ref: Node, shard_sim_ref: ShardSim, stash_ref: Stash, balance: Dictionary) -> void:
    world = world_ref
    shard_sim = shard_sim_ref
    stash = stash_ref
    move_speed = balance["collectors"].get("base_speed", move_speed)
    carry_capacity = balance["collectors"].get("carry_capacity", carry_capacity)
    pickup_radius = balance["collectors"].get("pickup_radius", pickup_radius)
    retarget_interval = balance["collectors"].get("retarget_interval", retarget_interval)
    deposit_time = balance["collectors"].get("deposit_time", deposit_time)

func _physics_process(delta: float) -> void:
    if shard_sim == null or stash == null:
        return
    if carried.size() >= carry_capacity:
        target_shard = -1
    var positions := shard_sim.get_positions()
    var states := shard_sim.get_states()
    if target_shard != -1 and (target_shard >= positions.size() or states[target_shard] != ShardSim.STATE_FREE):
        target_shard = -1
    retarget_timer -= delta
    if target_shard == -1 and carried.size() < carry_capacity and retarget_timer <= 0.0:
        retarget_timer = retarget_interval
        target_shard = shard_sim.nearest_shard(global_position, pickup_radius * 3.0, _excluded)
    var target_pos: Vector2 = global_position
    var returning: bool = carried.size() > 0 and (target_shard == -1)
    if returning:
        target_pos = stash.global_position
        if global_position.distance_to(target_pos) <= pickup_radius * 0.5:
            deposit_timer += delta
            if deposit_timer >= deposit_time:
                deposit_timer = 0.0
                if carried.size() > 0:
                    world.call("collector_deposit", carried.size())
                    for idx in carried:
                        shard_sim.despawn_by_collector(idx)
                    carried.clear()
                    _excluded.clear()
    elif target_shard != -1:
        target_pos = positions[target_shard]
        if global_position.distance_to(target_pos) <= pickup_radius:
            if shard_sim.grab_shard(target_shard, collector_id):
                carried.append(target_shard)
                _excluded.append(target_shard)
                target_shard = -1
    var dir: Vector2 = (target_pos - global_position)
    if dir.length_squared() > 1.0:
        dir = dir.normalized()
    velocity = dir * move_speed
    move_and_slide()
    for idx in carried:
        shard_sim.move_carried(idx, global_position)
