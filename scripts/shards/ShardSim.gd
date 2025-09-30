extends Resource
class_name ShardSim

const STATE_INACTIVE: int = 0
const STATE_FREE: int = 1
const STATE_CARRIED: int = 2

var gravity: float = 420.0
var linear_damp: float = 0.05
var friction: float = 0.01
var floor_restitution: float = 0.35
var wall_restitution: float = 0.5
var max_velocity: float = 720.0
var shard_radius: float = 6.0
var arena: Rect2 = Rect2(-420, -240, 840, 600)
var stash_rect: Rect2 = Rect2(-64, 220, 128, 80)

var positions: PackedVector2Array = PackedVector2Array()
var velocities: PackedVector2Array = PackedVector2Array()
var states: PackedInt32Array = PackedInt32Array()
var carried_by: PackedInt32Array = PackedInt32Array()

var _active_count: int = 0
var _free_indices: PackedInt32Array = PackedInt32Array()
var _rng := RandomNumberGenerator.new()
var _spatial_hash: SpatialHash = SpatialHash.new()
var _hash_indices: Array[int] = []

var building_fields: Array[Dictionary] = []
var _catapult_cooldowns: Dictionary = {}

func configure_from_balance(balance: Dictionary) -> void:
    gravity = balance["physics"]["gravity"]
    linear_damp = balance["physics"]["linear_damp"]
    friction = balance["physics"]["friction"]
    floor_restitution = balance["physics"]["floor_restitution"]
    wall_restitution = balance["physics"]["wall_restitution"]
    max_velocity = balance["physics"]["max_velocity"]
    shard_radius = balance["physics"]["shard_radius"]
    var bounds: Array = balance["physics"]["arena_bounds"]
    arena = Rect2(Vector2(bounds[0], bounds[1]), Vector2(bounds[2] - bounds[0], bounds[3] - bounds[1]))

func set_stash_rect(rect: Rect2) -> void:
    stash_rect = rect

func set_buildings(fields: Array[Dictionary]) -> void:
    building_fields = fields

func clear() -> void:
    positions = PackedVector2Array()
    velocities = PackedVector2Array()
    states = PackedInt32Array()
    carried_by = PackedInt32Array()
    _active_count = 0
    _free_indices = PackedInt32Array()
    _spatial_hash.clear()
    _catapult_cooldowns.clear()

func shard_count() -> int:
    return _active_count

func add_burst(origin: Vector2, count: int, speed_min: float, speed_max: float, angle_center: float, angle_spread: float) -> void:
    _rng.randomize()
    for i in count:
        var idx: int = _allocate_index()
        var speed: float = lerp(speed_min, speed_max, _rng.randf())
        var angle: float = angle_center + (angle_spread * (_rng.randf() - 0.5))
        var direction: Vector2 = Vector2(cos(angle), sin(angle))
        positions[idx] = origin
        velocities[idx] = direction * speed
        states[idx] = STATE_FREE
        carried_by[idx] = -1
        _active_count += 1

func _allocate_index() -> int:
    if _free_indices.is_empty():
        var idx: int = positions.size()
        positions.resize(idx + 1)
        velocities.resize(idx + 1)
        states.resize(idx + 1)
        carried_by.resize(idx + 1)
        return idx
    var reused: int = _free_indices.pop_back()
    return reused

func step(dt: float) -> int:
    var banked: int = 0
    _spatial_hash.clear()
    var rect_right: float = arena.position.x + arena.size.x
    var rect_bottom: float = arena.position.y + arena.size.y
    for i in positions.size():
        if states[i] == STATE_INACTIVE:
            continue
        if states[i] == STATE_CARRIED:
            # Collector controls the position.
            _spatial_hash.insert(i, positions[i])
            continue
        var pos: Vector2 = positions[i]
        var vel: Vector2 = velocities[i]
        vel.y += gravity * dt
        vel *= max(0.0, 1.0 - linear_damp * dt)
        vel = Math2D.clamp_length(vel, max_velocity)
        pos += vel * dt
        # Arena bounds
        if pos.x - shard_radius < arena.position.x:
            pos.x = arena.position.x + shard_radius
            vel.x = abs(vel.x) * wall_restitution
        elif pos.x + shard_radius > rect_right:
            pos.x = rect_right - shard_radius
            vel.x = -abs(vel.x) * wall_restitution
        if pos.y - shard_radius < arena.position.y:
            pos.y = arena.position.y + shard_radius
            vel.y = abs(vel.y) * wall_restitution
        elif pos.y + shard_radius > rect_bottom:
            pos.y = rect_bottom - shard_radius
            vel.y = -abs(vel.y) * floor_restitution
            vel.x *= max(0.0, 1.0 - friction)
        for field in building_fields:
            var b_type: String = field["type"]
            match b_type:
                "fan":
                    var to_shard: Vector2 = pos - field["position"]
                    var distance: float = to_shard.length()
                    if distance <= field["range"] and distance > 0.0:
                        var dir: Vector2 = field["direction"]
                        var angle: float = dir.angle_to(to_shard.normalized())
                        if abs(angle) <= field["cone"] * 0.5:
                            vel += dir * field["force"] * dt * (1.0 - distance / field["range"])
                "magnet":
                    var diff: Vector2 = field["position"] - pos
                    var dist_sq: float = diff.length_squared()
                    if dist_sq < field["radius"] * field["radius"] and dist_sq > 0.01:
                        var strength: float = field["force"] / max(32.0, dist_sq)
                        vel += diff.normalized() * strength * dt
                "bumper":
                    var normal: Vector2 = field["normal"]
                    var proj: float = (pos - field["position"]).dot(normal)
                    if proj < shard_radius:
                        pos += normal * (shard_radius - proj)
                        var vn: float = vel.dot(normal)
                        if vn < 0.0:
                            vel -= normal * (1.0 + field["restitution"]) * vn
                "catapult":
                    var diff2: Vector2 = pos - field["position"]
                    if diff2.length() <= field["radius"]:
                        var id: int = field["id"]
                        var cd: float = _catapult_cooldowns.get(id, 0.0)
                        cd -= dt
                        if cd <= 0.0:
                            vel += field["impulse"]
                            cd = field["cooldown"]
                        _catapult_cooldowns[id] = cd
        positions[i] = pos
        velocities[i] = vel
        if stash_rect.has_point(pos):
            _despawn(i)
            banked += 1
            continue
        _spatial_hash.insert(i, pos)
    return banked


func request_hash() -> SpatialHash:
    return _spatial_hash

func get_positions() -> PackedVector2Array:
    return positions

func get_states() -> PackedInt32Array:
    return states

func get_active_flags() -> PackedByteArray:
    var arr := PackedByteArray()
    arr.resize(states.size())
    for i in states.size():
        arr[i] = states[i]
    return arr

func grab_shard(index: int, collector_id: int) -> bool:
    if index < 0 or index >= states.size():
        return false
    if states[index] != STATE_FREE:
        return false
    states[index] = STATE_CARRIED
    carried_by[index] = collector_id
    velocities[index] = Vector2.ZERO
    return true

func move_carried(index: int, position: Vector2) -> void:
    if states[index] == STATE_CARRIED:
        positions[index] = position

func release_shard(index: int, velocity: Vector2) -> void:
    if states[index] == STATE_CARRIED:
        states[index] = STATE_FREE
        carried_by[index] = -1
        velocities[index] = velocity

func _despawn(index: int) -> void:
    states[index] = STATE_INACTIVE
    carried_by[index] = -1
    positions[index] = Vector2(-9999, -9999)
    velocities[index] = Vector2.ZERO
    _active_count = max(0, _active_count - 1)
    _free_indices.append(index)

func despawn_by_collector(index: int) -> void:
    _despawn(index)

func hash_query(pos: Vector2, radius: float, out_indices: Array[int]) -> void:
    _spatial_hash.query(pos, radius, out_indices)

func nearest_shard(pos: Vector2, radius: float, excluded: Array[int]) -> int:
    _hash_indices.resize(0)
    hash_query(pos, radius, _hash_indices)
    var best: int = -1
    var best_dist_sq: float = radius * radius
    for idx in _hash_indices:
        if states[idx] != STATE_FREE:
            continue
        if excluded.has(idx):
            continue
        var diff: Vector2 = positions[idx] - pos
        var dist_sq: float = diff.length_squared()
        if dist_sq < best_dist_sq:
            best = idx
            best_dist_sq = dist_sq
    return best
