extends Node
class_name StatusEffects

signal effect_started(id: String)
signal effect_ended(id: String)

var balance: Dictionary = {}
var active: Dictionary = {}

func setup(balance_data: Dictionary) -> void:
    balance = balance_data
    active.clear()

func trigger(id: String) -> void:
    if not balance["status_effects"].has(id):
        return
    var data: Dictionary = balance["status_effects"][id]
    active[id] = data.get("duration", 10.0)
    emit_signal("effect_started", id)

func get_modifier(id: String) -> float:
    var remaining: float = active.get(id, 0.0)
    if remaining <= 0.0:
        return 1.0
    return balance["status_effects"][id].get("multiplier", 1.0)

func tick(delta: float) -> void:
    var to_remove: Array[String] = []
    for key in active.keys():
        active[key] = max(0.0, active[key] - delta)
        if active[key] == 0.0:
            emit_signal("effect_ended", key)
            to_remove.append(key)
    for key in to_remove:
        active.erase(key)
