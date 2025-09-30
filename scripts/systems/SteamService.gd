extends Node
class_name SteamService

func set_achievement(id: String) -> void:
    print("[SteamService] set_achievement", id)

func set_stat(key: String, value: float) -> void:
    print("[SteamService] set_stat", key, value)

func cloud_save(bytes: PackedByteArray) -> void:
    print("[SteamService] cloud_save", bytes.size())

func cloud_load() -> PackedByteArray:
    print("[SteamService] cloud_load")
    return PackedByteArray()
