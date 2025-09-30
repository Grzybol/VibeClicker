extends Node
class_name TimerBus

signal timer_fired(name: StringName)

var _timers: Dictionary = {}

func ensure_timer(name: StringName, interval: float, repeat: bool = true) -> void:
    if _timers.has(name):
        var timer: Timer = _timers[name]
        timer.wait_time = interval
        timer.one_shot = not repeat
        return
    var timer := Timer.new()
    timer.wait_time = interval
    timer.one_shot = not repeat
    timer.autostart = true
    add_child(timer)
    timer.timeout.connect(_on_timer_timeout.bind(name))
    _timers[name] = timer

func _on_timer_timeout(name: StringName) -> void:
    emit_signal("timer_fired", name)
