extends Control
class_name HUD

@export var economy: Economy
@export var prestige: Prestige

func _ready() -> void:
    _connect_signals()

func setup(economy_ref: Economy, prestige_ref: Prestige) -> void:
    economy = economy_ref
    prestige = prestige_ref
    _connect_signals()

func _connect_signals() -> void:
    if economy and not economy.shiny_changed.is_connected(_on_shiny_changed):
        economy.shiny_changed.connect(_on_shiny_changed)
        economy.prestige_ready.connect(_on_prestige_ready)
    if prestige and not prestige.prestige_performed.is_connected(_on_prestige_performed):
        prestige.prestige_performed.connect(_on_prestige_performed)

func _on_shiny_changed(value: float) -> void:
    if has_node("MarginContainer/VBoxContainer/ShinyLabel"):
        $MarginContainer/VBoxContainer/ShinyLabel.text = "Shiny: %0.1f" % value

func _on_prestige_ready(threshold: float) -> void:
    if has_node("MarginContainer/VBoxContainer/PrestigeLabel"):
        $MarginContainer/VBoxContainer/PrestigeLabel.text = "Prestige Ready at %d" % int(threshold)

func _on_prestige_performed(amount: int) -> void:
    if has_node("MarginContainer/VBoxContainer/PrestigeLabel"):
        $MarginContainer/VBoxContainer/PrestigeLabel.text = "Prestiged for %d Fluxium" % amount
