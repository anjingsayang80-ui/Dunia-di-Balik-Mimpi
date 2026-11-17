extends Node

const SAVE_PATH := "user://savegame.cfg"
const ITEM_HEAL_VALUES := {"Ramuan Kecil": 30, "Ramuan Besar": 60}
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

func get_item_heal_value(item_name: String) -> int:
    return int(ITEM_HEAL_VALUES.get(item_name, 0))

func use_item(item_name: String) -> bool:
    if get_item_heal_value(item_name) <= 0 or get_item_count(item_name) <= 0:
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
        inventory["Ramuan Besar"] = int(inventory.get("Ramuan Besar", 0)) + 1
        last_notice = "Quest Kristal Mimpi selesai! Bonus 20 Koin dan 1 Ramuan Besar (+60 HP). Bos telah muncul!"
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
    data.set_value("meta", "save_version", 1)
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

    # Sanitasi data agar save lama/rusak tidak membuat UI atau quest crash.
    var saved_inventory: Variant = data.get_value("player", "inventory", {"Ramuan Kecil": 2})
    inventory.clear()
    if saved_inventory is Dictionary:
        for item_name in saved_inventory.keys():
            var raw_count: Variant = saved_inventory[item_name]
            if item_name is String and (raw_count is int or raw_count is float):
                var safe_count := maxi(0, int(raw_count))
                if safe_count > 0:
                    inventory[item_name] = safe_count

    player_level = maxi(1, int(data.get_value("player", "level", 1)))
    player_strength = maxf(0.2, float(data.get_value("player", "strength", 1.0)))
    player_hp = clampi(int(data.get_value("player", "hp", 100)), 0, 100)
    var saved_position: Variant = data.get_value("player", "position", Vector3(0, 0.1, 4))
    player_position = saved_position if saved_position is Vector3 else Vector3(0, 0.1, 4)
    has_player_save = bool(data.get_value("player", "has_player_save", false))

    slime_kills = clampi(int(data.get_value("quest", "slime_kills", 0)), 0, 1)
    quest_completed = bool(data.get_value("quest", "completed", false))
    dream_crystals_collected = clampi(int(data.get_value("quest", "dream_crystals_collected", 0)), 0, 3)
    dream_crystal_quest_completed = bool(data.get_value("quest", "dream_crystal_quest_completed", false))
    boss_defeated = bool(data.get_value("quest", "boss_defeated", false))

    # Pertahankan urutan quest: bos tidak mungkin selesai sebelum dua misi sebelumnya.
    if quest_completed:
        slime_kills = maxi(1, slime_kills)
    if dream_crystal_quest_completed:
        quest_completed = true
        slime_kills = maxi(1, slime_kills)
        dream_crystals_collected = 3
    if boss_defeated:
        quest_completed = true
        slime_kills = maxi(1, slime_kills)
        dream_crystal_quest_completed = true
        dream_crystals_collected = 3

    last_notice = "Progres permainan berhasil dimuat."
    return true
