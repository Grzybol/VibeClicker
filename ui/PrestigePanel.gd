extends Control
class_name PrestigePanel

@export var prestige: Prestige

func _ready() -> void:
    hide()

func toggle() -> void:
    visible = not visible

func _on_prestige_button_pressed() -> void:
    if prestige:
        prestige.perform()
        hide()
