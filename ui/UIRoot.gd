extends CanvasLayer
class_name UIRoot

@export var hud: HUD
@export var shop: Shop
@export var talents: Talents
@export var prestige_panel: PrestigePanel
@export var debug_overlay: DebugOverlay
var world: World
var balance: Dictionary = {}

func setup(economy: Economy, upgrades: Upgrades, prestige: Prestige, balance_data: Dictionary) -> void:
    balance = balance_data
    if hud:
        hud.setup(economy, prestige)
    if shop:
        shop.upgrades = upgrades
        shop.economy = economy
        shop.refresh()
    if talents:
        talents.economy = economy
        talents.balance = balance
        talents._build_grid()
    if prestige_panel:
        prestige_panel.prestige = prestige
    if debug_overlay:
        debug_overlay.world = world

func toggle_debug() -> void:
    if debug_overlay:
        debug_overlay.toggle()

func toggle_prestige() -> void:
    if prestige_panel:
        prestige_panel.toggle()

func set_world(world_ref: World) -> void:
    world = world_ref
    if debug_overlay:
        debug_overlay.world = world

func _process(_delta: float) -> void:
    if debug_overlay and debug_overlay.visible:
        debug_overlay.update_overlay()

func set_selected_building(name: String) -> void:
    if shop:
        shop.set_selected_building(name)

func is_pointer_over_ui(position: Vector2) -> bool:
    var control := get_viewport().gui_pick(position)
    return control != null and control.is_visible_in_tree()
