@tool
@icon("res://addons/inventory_forge/icons/inventory_forge_icon.svg")
class_name ItemDefinition
extends Resource
## Definition of a single item in the game.
## Contains all necessary data to describe an object.
##
## Inventory Forge Plugin by Menkos
## License: MIT

# === Segnali ===
signal changed_item()


# === Base ===
@export_group("Base")
@export var id: int = -1:
	set(value):
		id = value
		emit_changed()
		changed_item.emit()

@export var name_key: String = "":
	set(value):
		name_key = value
		emit_changed()
		changed_item.emit()

@export var description_key: String = "":
	set(value):
		description_key = value
		emit_changed()
		changed_item.emit()

@export var icon: Texture2D:
	set(value):
		icon = value
		emit_changed()
		changed_item.emit()

@export var category: ItemEnums.Category = ItemEnums.Category.MISC:
	set(value):
		category = value
		emit_changed()
		changed_item.emit()


# === Stack ===
@export_group("Stack")
## Maximum items per stack (e.g., 99 potions in one stack)
@export_range(1, 999) var stack_capacity: int = 99:
	set(value):
		stack_capacity = value
		emit_changed()
		changed_item.emit()

## Total count limit across entire inventory (0 = unlimited)
## Note: Interpretation depends on your inventory system implementation
@export_range(0, 999) var stack_count_limit: int = 0:
	set(value):
		stack_count_limit = value
		emit_changed()
		changed_item.emit()


# === Economy ===
@export_group("Economy")
@export_range(0, 999999) var buy_price: int = 0:
	set(value):
		buy_price = value
		emit_changed()
		changed_item.emit()

@export_range(0, 999999) var sell_price: int = 0:
	set(value):
		sell_price = value
		emit_changed()
		changed_item.emit()

@export var tradeable: bool = true:
	set(value):
		tradeable = value
		emit_changed()
		changed_item.emit()


# === Rarity ===
@export_group("Rarity")
@export var rarity: ItemEnums.Rarity = ItemEnums.Rarity.COMMON:
	set(value):
		rarity = value
		emit_changed()
		changed_item.emit()

@export_range(0, 100) var required_level: int = 0:
	set(value):
		required_level = value
		emit_changed()
		changed_item.emit()


# === Equipment ===
@export_group("Equipment")
@export var equippable: bool = false:
	set(value):
		equippable = value
		emit_changed()
		changed_item.emit()

@export var equip_slot: ItemEnums.EquipSlot = ItemEnums.EquipSlot.NONE:
	set(value):
		equip_slot = value
		emit_changed()
		changed_item.emit()

@export_subgroup("Stats")
@export_range(-999, 999) var stat_atk: int = 0:
	set(value):
		stat_atk = value
		emit_changed()
		changed_item.emit()

@export_range(-999, 999) var stat_def: int = 0:
	set(value):
		stat_def = value
		emit_changed()
		changed_item.emit()

@export_range(-9999, 9999) var stat_hp: int = 0:
	set(value):
		stat_hp = value
		emit_changed()
		changed_item.emit()

@export_range(-9999, 9999) var stat_mp: int = 0:
	set(value):
		stat_mp = value
		emit_changed()
		changed_item.emit()

@export_range(-999, 999) var stat_spd: int = 0:
	set(value):
		stat_spd = value
		emit_changed()
		changed_item.emit()


# === Consumable ===
@export_group("Consumable")
@export var consumable: bool = false:
	set(value):
		consumable = value
		emit_changed()
		changed_item.emit()

@export var effect_type: ItemEnums.EffectType = ItemEnums.EffectType.NONE:
	set(value):
		effect_type = value
		emit_changed()
		changed_item.emit()

@export_range(0, 9999) var effect_value: int = 0:
	set(value):
		effect_value = value
		emit_changed()
		changed_item.emit()

@export_range(0, 600) var effect_duration: float = 0.0:  ## Durata in secondi (per buff)
	set(value):
		effect_duration = value
		emit_changed()
		changed_item.emit()


# === Quest ===
@export_group("Quest")
@export var is_quest_item: bool = false:
	set(value):
		is_quest_item = value
		emit_changed()
		changed_item.emit()

@export var quest_id: String = "":
	set(value):
		quest_id = value
		emit_changed()
		changed_item.emit()


# === Crafting ===
@export_group("Crafting")
@export var craftable: bool = false:
	set(value):
		craftable = value
		emit_changed()
		changed_item.emit()

## Array di Dictionary con struttura: {"item_id": int, "amount": int}
@export var ingredients: Array[Dictionary] = []:
	set(value):
		ingredients = value
		emit_changed()
		changed_item.emit()


# === Metodi Helper ===

## Gets the translated name of the item
func get_translated_name() -> String:
	if name_key.is_empty():
		return "???"
	return tr(name_key)


## Gets the translated description of the item
func get_translated_description() -> String:
	if description_key.is_empty():
		return ""
	return tr(description_key)


## Gets the rarity color
func get_rarity_color() -> Color:
	return ItemEnums.get_rarity_color(rarity)


## Automatically generates translation keys from name
func generate_translation_keys(base_name: String) -> void:
	# Normalizza il nome: rimuovi spazi, converti in uppercase, sostituisci spazi con underscore
	var normalized := base_name.strip_edges().to_upper().replace(" ", "_")
	# Rimuovi caratteri speciali
	var clean_name := ""
	for c in normalized:
		if c.is_valid_identifier() or c == "_":
			clean_name += c
	
	if clean_name.is_empty():
		clean_name = "ITEM_%d" % id
	
	name_key = "ITEM_%s_NAME" % clean_name
	description_key = "ITEM_%s_DESC" % clean_name


## Verifica se l'item è valido
func is_valid() -> bool:
	return id >= 0 and not name_key.is_empty()


## Gets a list of validation warnings
func get_validation_warnings() -> Array[String]:
	var warnings: Array[String] = []
	
	if id < 0:
		warnings.append("Invalid ID (must be >= 0)")
	
	if name_key.is_empty():
		warnings.append("Missing name key")
	
	if description_key.is_empty():
		warnings.append("Missing description key")
	
	if icon == null:
		warnings.append("Missing icon")
	
	if sell_price > buy_price and buy_price > 0:
		warnings.append("Sell price higher than buy price")
	
	if equippable and equip_slot == ItemEnums.EquipSlot.NONE:
		warnings.append("Equippable item but slot not specified")
	
	if consumable and effect_type == ItemEnums.EffectType.NONE:
		warnings.append("Consumable item but effect not specified")
	
	if is_quest_item and tradeable:
		warnings.append("Quest items should not be tradeable")
	
	if craftable and ingredients.is_empty():
		warnings.append("Craftable item but no ingredients specified")
	
	return warnings


## Crea una copia profonda dell'item
func duplicate_item() -> ItemDefinition:
	var new_item := ItemDefinition.new()
	
	# Copia tutti i campi
	new_item.id = -1  # Nuovo ID sarà assegnato dal database
	new_item.name_key = name_key
	new_item.description_key = description_key
	new_item.icon = icon
	new_item.category = category
	new_item.stack_capacity = stack_capacity
	new_item.stack_count_limit = stack_count_limit
	new_item.buy_price = buy_price
	new_item.sell_price = sell_price
	new_item.tradeable = tradeable
	new_item.rarity = rarity
	new_item.required_level = required_level
	new_item.equippable = equippable
	new_item.equip_slot = equip_slot
	new_item.stat_atk = stat_atk
	new_item.stat_def = stat_def
	new_item.stat_hp = stat_hp
	new_item.stat_mp = stat_mp
	new_item.stat_spd = stat_spd
	new_item.consumable = consumable
	new_item.effect_type = effect_type
	new_item.effect_value = effect_value
	new_item.effect_duration = effect_duration
	new_item.is_quest_item = is_quest_item
	new_item.quest_id = quest_id
	new_item.craftable = craftable
	new_item.ingredients = ingredients.duplicate(true)
	
	return new_item


## Converte l'item in un Dictionary (per serializzazione/debug)
func to_dictionary() -> Dictionary:
	return {
		"id": id,
		"name_key": name_key,
		"description_key": description_key,
		"category": category,
		"rarity": rarity,
		"stack_capacity": stack_capacity,
		"buy_price": buy_price,
		"sell_price": sell_price,
		"tradeable": tradeable,
		"equippable": equippable,
		"equip_slot": equip_slot,
		"consumable": consumable,
		"effect_type": effect_type,
		"effect_value": effect_value,
		"is_quest_item": is_quest_item,
		"craftable": craftable,
	}
