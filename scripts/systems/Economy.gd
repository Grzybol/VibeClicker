extends Node
class_name Economy

signal shiny_changed(value: float)
signal fluxium_changed(value: int)
signal prestige_ready(threshold: float)

var shiny: float = 0.0
var fluxium: int = 0
var total_banked: float = 0.0
var bank_per_second: float = 0.0
var shard_value: float = 1.0
var balance: Dictionary = {}
var prestige_threshold: float = 100000.0

func setup(balance_data: Dictionary) -> void:
    balance = balance_data
    shiny = balance["economy"].get("starting_shiny", 0)
    prestige_threshold = balance["economy"].get("prestige_threshold_base", 50000)
    shard_value = 1.0
    emit_signal("shiny_changed", shiny)

func add_shiny(amount: float) -> void:
    shiny += amount
    total_banked += amount
    emit_signal("shiny_changed", shiny)
    if total_banked >= prestige_threshold:
        emit_signal("prestige_ready", prestige_threshold)

func spend(cost: float) -> bool:
    if shiny >= cost:
        shiny -= cost
        emit_signal("shiny_changed", shiny)
        return true
    return false

func refund(amount: float) -> void:
    shiny += amount
    emit_signal("shiny_changed", shiny)

func grant_fluxium(amount: int) -> void:
    fluxium += amount
    emit_signal("fluxium_changed", fluxium)

func reset_run() -> void:
    shiny = balance["economy"].get("starting_shiny", 0)
    total_banked = 0.0
    emit_signal("shiny_changed", shiny)

func shard_deposited(count: int) -> void:
    add_shiny(count * shard_value)
