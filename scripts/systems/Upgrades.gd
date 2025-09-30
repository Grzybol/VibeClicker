extends Node
class_name Upgrades

signal upgrade_purchased(key: String)

var balance: Dictionary = {}
var levels: Dictionary = {}

func setup(balance_data: Dictionary) -> void:
    balance = balance_data
    levels.clear()

func get_cost(key: String) -> float:
    var data: Dictionary = balance["upgrades"].get(key, {})
    var base_cost: float = data.get("base_cost", 10.0)
    var growth: float = data.get("growth", 1.2)
    var level: int = levels.get(key, 0)
    return base_cost * pow(growth, level)

func buy(key: String, economy: Economy) -> bool:
    var cost: float = get_cost(key)
    if not economy.spend(cost):
        return false
    levels[key] = levels.get(key, 0) + 1
    emit_signal("upgrade_purchased", key)
    return true

func get_bonus(key: String) -> float:
    var data: Dictionary = balance["upgrades"].get(key, {})
    var level: int = levels.get(key, 0)
    return data.get("bonus", 0.0) * level
