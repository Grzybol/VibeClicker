extends Resource
class_name Math2D

static func clamp_length(vec: Vector2, max_length: float) -> Vector2:
    var length_sq: float = vec.length_squared()
    if length_sq <= max_length * max_length:
        return vec
    var length: float = sqrt(length_sq)
    if length == 0.0:
        return Vector2.ZERO
    return vec * (max_length / length)

static func approach(value: float, target: float, step: float) -> float:
    if value < target:
        return min(target, value + step)
    if value > target:
        return max(target, value - step)
    return target

static func rotate_toward(current: float, target: float, step: float) -> float:
    var diff: float = wrapf(target - current, -PI, PI)
    diff = clamp(diff, -step, step)
    return wrapf(current + diff, -PI, PI)
