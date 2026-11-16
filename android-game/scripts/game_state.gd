extends Node

const SAVE_PATH := "user://savegame.cfg"
var inventory: Dictionary = {}
var slime_kills := 0
var quest_completed := false
var dream_crystals_collected := 0
var dream_crystal_quest_completed := false
var player_level := 1
var player_strength := 1.0
var boss_defeated := false
var player_hp := 100
var player_position := Vector3(0, 0.1, 4)
var has_player_save := false
var last_notice := ""

func _ready() -> void:
    if not load_game():
        inventory = {"Ramuan Kecil": 2}
        save_game()

func save_player_state(current_hp: int, current_position: Vector3) -> void:
    player_hp = clampi(current_hp, 0, 100)
    player_position = current_position
    has_player_save = true
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

func _award_progress(level_gain: int, strength_gain: float, source: String) -> void:
    player_level += level_gain
    player_strength = snappedf(player_strength + strength_gain, 0.01)
    last_notice = "%s dikalahkan! Level +%d, Kekuatan +%s." % [source, level_gain, _format_strength(strength_gain)]
    save_game()

func _format_strength(value: float) -> String:
    return ("%.2f" % value).trim_suffix("0").trim_suffix(".")

func complete_slime_quest() -> void:
    if quest_completed:
        return
    slime_kills += 1
    quest_completed = true
    inventory["Lendir Slime"] = int(inventory.get("Lendir Slime", 0)) + 1
    inventory["Koin"] = int(inventory.get("Koin", 0)) + 10
    _award_progress(1, 0.2, "Monster biasa")
    last_notice = "Slime dikalahkan! Level +1, Kekuatan +0,2. Hadiah: Lendir Slime dan 10 Koin."
    save_game()

func collect_dream_crystal() -> void:
    if not quest_completed or dream_crystal_quest_completed:
        return
    dream_crystals_collected = mini(3, dream_crystals_collected + 1)
    inventory["Kristal Mimpi"] = int(inventory.get("Kristal Mimpi", 0)) + 1
    if dream_crystals_collected >= 3:
        dream_crystal_quest_completed = true
        inventory["Koin"] = int(inventory.get("Koin", 0)) + 20
        last_notice = "Quest Kristal Mimpi selesai! Bonus 20 Koin. Bos telah muncul!"
    else:
        last_notice = "Kristal Mimpi diperoleh (%d/3)." % dream_crystals_collected
    save_game()

func defeat_boss() -> void:
    if boss_defeated:
        return
    boss_defeated = true
    inventory["Inti Bos"] = int(inventory.get("Inti Bos", 0)) + 1
    inventory["Koin"] = int(inventory.get("Koin", 0)) + 100
    _award_progress(5, 3.0, "Bos")
    last_notice = "BOS DIKALAHKAN! Level +5, Kekuatan +3. Hadiah: Inti Bos dan 100 Koin."
    save_game()

func get_quest_text() -> String:
    if not quest_completed:
        return "MISI 1: Kalahkan Slime  •  Progres: %d/1" % slime_kills
    if not dream_crystal_quest_completed:
        return "MISI 2: Kumpulkan Kristal Mimpi  •  Progres: %d/3" % dream_crystals_collected
    if not boss_defeated:
        return "MISI 3: Kalahkan Bos Mimpi"
    return "SEMUA MISI SELESAI  •  Bos telah dikalahkan"

func save_game() -> void:
    var data := ConfigFile.new()
    data.set_value("player", "inventory", inventory)
    data.set_value("player", "level", player_level)
    data.set_value("player", "strength", player_strength)
    data.set_value("player", "hp", player_hp)
    data.set_value("player", "position", player_position)
    data.set_value("player", "has_player_save", has_player_save)
    data.set_value("quest", "slime_kills", slime_kills)
    data.set_value("quest", "completed", quest_completed)
    data.set_value("quest", "dream_crystals_collected", dream_crystals_collected)
    data.set_value("quest", "dream_crystal_quest_completed", dream_crystal_quest_completed)
    data.set_value("quest", "boss_defeated", boss_defeated)
    var error := data.save(SAVE_PATH)
    if error != OK:
        push_warning("Gagal menyimpan progres: %s" % error_string(error))

func load_game() -> bool:
    var data := ConfigFile.new()
    var error := data.load(SAVE_PATH)
    if error != OK:
        return false
    inventory = data.get_value("player", "inventory", {"Ramuan Kecil": 2})
    player_level = int(data.get_value("player", "level", 1))
    player_strength = float(data.get_value("player", "strength", 1.0))
    player_hp = clampi(int(data.get_value("player", "hp", 100)), 0, 100)
    player_position = data.get_value("player", "position", Vector3(0, 0.1, 4))
    has_player_save = bool(data.get_value("player", "has_player_save", false))
    slime_kills = int(data.get_value("quest", "slime_kills", 0))
    quest_completed = bool(data.get_value("quest", "completed", false))
    dream_crystals_collected = int(data.get_value("quest", "dream_crystals_collected", 0))
    dream_crystal_quest_completed = bool(data.get_value("quest", "dream_crystal_quest_completed", false))
    boss_defeated = bool(data.get_value("quest", "boss_defeated", false))
    last_notice = "Progres permainan berhasil dimuat."
    return true
