extends Node

const SAVE_PATH := "user://savegame.cfg"
var inventory: Dictionary = {}
var slime_kills := 0
var quest_completed := false
var last_notice := ""

func _ready() -> void:
    if not load_game():
        inventory = {"Ramuan Kecil": 2}
        save_game()

func add_item(item_name: String, amount: int = 1) -> void:
    if amount <= 0:
        return
    inventory[item_name] = int(inventory.get(item_name, 0)) + amount
    last_notice = "%s x%d diperoleh." % [item_name, amount]
    save_game()

func get_item_count(item_name: String) -> int:
    return int(inventory.get(item_name, 0))

func use_item(item_name: String) -> bool:
    if get_item_count(item_name) <= 0:
        return false
    inventory[item_name] -= 1
    if inventory[item_name] <= 0:
        inventory.erase(item_name)
    save_game()
    return true

func complete_slime_quest() -> void:
    if quest_completed:
        return
    slime_kills += 1
    quest_completed = true
    inventory["Lendir Slime"] = int(inventory.get("Lendir Slime", 0)) + 1
    inventory["Koin"] = int(inventory.get("Koin", 0)) + 10
    last_notice = "Misi selesai! Hadiah: Lendir Slime dan 10 Koin."
    save_game()

func get_quest_text() -> String:
    if quest_completed:
        return "MISI SELESAI: Kalahkan Slime  •  Hadiah sudah diterima"
    return "MISI: Kalahkan Slime  •  Progres: %d/1" % slime_kills

func save_game() -> void:
    var data := ConfigFile.new()
    data.set_value("player", "inventory", inventory)
    data.set_value("quest", "slime_kills", slime_kills)
    data.set_value("quest", "completed", quest_completed)
    var error := data.save(SAVE_PATH)
    if error != OK:
        push_warning("Gagal menyimpan progres: %s" % error_string(error))

func load_game() -> bool:
    var data := ConfigFile.new()
    var error := data.load(SAVE_PATH)
    if error != OK:
        return false
    inventory = data.get_value("player", "inventory", {"Ramuan Kecil": 2})
    slime_kills = int(data.get_value("quest", "slime_kills", 0))
    quest_completed = bool(data.get_value("quest", "completed", false))
    last_notice = "Progres permainan berhasil dimuat."
    return true
