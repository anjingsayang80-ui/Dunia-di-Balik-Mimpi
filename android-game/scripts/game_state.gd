extends Node

var inventory: Dictionary = {}
var slime_kills := 0
var quest_completed := false
var last_notice := ""

func _ready() -> void:
    add_item("Ramuan Kecil", 2)

func add_item(item_name: String, amount: int = 1) -> void:
    if amount <= 0:
        return
    inventory[item_name] = int(inventory.get(item_name, 0)) + amount
    last_notice = "%s x%d diperoleh." % [item_name, amount]

func get_item_count(item_name: String) -> int:
    return int(inventory.get(item_name, 0))

func use_item(item_name: String) -> bool:
    if get_item_count(item_name) <= 0:
        return false
    inventory[item_name] -= 1
    if inventory[item_name] <= 0:
        inventory.erase(item_name)
    return true

func complete_slime_quest() -> void:
    if quest_completed:
        return
    slime_kills += 1
    add_item("Lendir Slime", 1)
    add_item("Koin", 10)
    quest_completed = true
    last_notice = "Misi selesai! Hadiah: Lendir Slime dan 10 Koin."

func get_quest_text() -> String:
    if quest_completed:
        return "MISI SELESAI: Kalahkan Slime  •  Hadiah sudah diterima"
    return "MISI: Kalahkan Slime  •  Progres: %d/1" % slime_kills
