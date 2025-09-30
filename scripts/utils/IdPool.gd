extends Resource
class_name IdPool

var _free: PackedInt32Array = PackedInt32Array()
var _next_id: int = 0

func reset() -> void:
    _free.clear()
    _next_id = 0

func acquire() -> int:
    if _free.is_empty():
        var id: int = _next_id
        _next_id += 1
        return id
    return _free.pop_back()

func release(id: int) -> void:
    _free.append(id)
