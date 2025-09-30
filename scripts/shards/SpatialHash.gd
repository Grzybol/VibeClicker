extends Resource
class_name SpatialHash

var cell_size: float = 64.0
var _cells: Dictionary = {}

func clear() -> void:
    _cells.clear()

func _key_from_vec(pos: Vector2) -> int:
    return int(floor(pos.x / cell_size)) << 32 | (int(floor(pos.y / cell_size)) & 0xffffffff)

func insert(index: int, pos: Vector2) -> void:
    var key: int = _key_from_vec(pos)
    var cell := _cells.get(key)
    if cell == null:
        cell = []
        _cells[key] = cell
    cell.append(index)

func query(pos: Vector2, radius: float, out_indices: Array[int]) -> void:
    out_indices.clear()
    var min_cell_x: int = int(floor((pos.x - radius) / cell_size))
    var max_cell_x: int = int(floor((pos.x + radius) / cell_size))
    var min_cell_y: int = int(floor((pos.y - radius) / cell_size))
    var max_cell_y: int = int(floor((pos.y + radius) / cell_size))
    for cx in range(min_cell_x, max_cell_x + 1):
        for cy in range(min_cell_y, max_cell_y + 1):
            var key: int = cx << 32 | (cy & 0xffffffff)
            var cell := _cells.get(key)
            if cell != null:
                for i in cell:
                    out_indices.append(i)

func remove_all(index: int) -> void:
    for key in _cells.keys():
        var cell: Array = _cells[key]
        var idx: int = cell.find(index)
        if idx != -1:
            cell.remove_at(idx)
            if cell.is_empty():
                _cells.erase(key)
            return
