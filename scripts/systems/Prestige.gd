extends Node
class_name Prestige

signal prestige_performed(fluxium: int)

var balance: Dictionary = {}
var economy: Economy

func setup(balance_data: Dictionary, economy_ref: Economy) -> void:
    balance = balance_data
    economy = economy_ref

func can_prestige() -> bool:
    return economy.total_banked >= economy.prestige_threshold

func perform() -> void:
    if not can_prestige():
        return
    var base_flux: int = balance["economy"].get("fluxium_per_prestige", 5)
    var growth: float = balance["economy"].get("fluxium_growth", 0.25)
    var bonus: int = int(float(base_flux) + growth * float(economy.total_banked / economy.prestige_threshold))
    economy.grant_fluxium(bonus)
    emit_signal("prestige_performed", bonus)
    economy.reset_run()
