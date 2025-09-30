extends Node
class_name SaveLoad

const SAVE_PATH := "user://save.json"

func save_state(state: Dictionary) -> void:
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return
    file.store_string(JSON.stringify(state))
    file.close()

func load_state() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return {}
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return {}
    var text := file.get_as_text()
    file.close()
    var data := JSON.parse_string(text)
    if typeof(data) == TYPE_DICTIONARY:
        return data
    return {}
