extends Node2D
class_name Striker

@export var attack_interval: float = 1.0
@export var spawn_bias: float = 0.0
@export var spread: float = 0.6

var world: Node
var rock: Rock
var accumulator: float = 0.0

func setup(world_ref: Node, rock_ref: Rock, balance: Dictionary) -> void:
    world = world_ref
    rock = rock_ref
    attack_interval = 1.0 / balance["strikers"].get("attack_speed", 1.0)
    spread = balance["strikers"].get("spread", 0.6)
    spawn_bias = balance["strikers"].get("sector_bias", 0.1)

func _physics_process(delta: float) -> void:
    if world == null or rock == null:
        return
    accumulator += delta
    if accumulator >= attack_interval:
        accumulator -= attack_interval
        rock.trigger_hit(self)
