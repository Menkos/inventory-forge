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

## Questo item può essere usato come ingrediente per crafting
@export var is_ingredient: bool = false:
	set(value):
		is_ingredient = value
		emit_changed()
		changed_item.emit()

## Tipo di materiale (se is_ingredient = true)
@export var material_type: ItemEnums.MaterialType = ItemEnums.MaterialType.NONE:
	set(value):
		material_type = value
		emit_changed()
		changed_item.emit()

@export_subgroup("Crafting Recipe")

## Questo item può essere creato tramite crafting
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


# === Passives ===
@export_group("Passives")

## Passive effects on this item (only for equippable items)
@export var passives: Array[PassiveEntry] = []:
	set(value):
		passives = value
		emit_changed()
		changed_item.emit()


# === Custom Fields ===
@export_group("Custom Fields")

## User-defined custom properties for game-specific data.
## Supports String, int, float, bool values.
## Example: {"damage_type": "fire", "cooldown": 2.5, "is_legendary": true}
@export var custom_fields: Dictionary = {}:
	set(value):
		custom_fields = value
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


## Validates ingredients with database context
func validate_ingredients_with_db(db: ItemDatabase) -> Array[String]:
	var warnings: Array[String] = []
	
	if not craftable or db == null:
		return warnings
	
	if ingredients.is_empty():
		return warnings  # Già gestito da get_validation_warnings()
	
	var seen_ids: Array[int] = []
	
	for i in range(ingredients.size()):
		var ing = ingredients[i]
		
		# Verifica struttura dictionary
		if not ing.has("item_id") or not ing.has("amount"):
			continue  # Già segnalato dalla validazione base
		
		var item_id: int = ing.get("item_id", -1)
		var amount: int = ing.get("amount", 0)
		
		# Verifica item_id valido
		if item_id < 0:
			warnings.append("Ingredient %d: Item not selected" % (i + 1))
			continue
		
		# Verifica self-reference
		if item_id == id:
			warnings.append("Ingredient %d: Item cannot use itself" % (i + 1))
		
		# Verifica duplicati
		if item_id in seen_ids:
			warnings.append("Ingredient %d: Duplicate item ID %d" % [i + 1, item_id])
		else:
			seen_ids.append(item_id)
		
		# Verifica esistenza nel database
		var found_item := db.get_item_by_id(item_id)
		if found_item == null:
			warnings.append("Ingredient %d: Item ID %d not found in database" % [i + 1, item_id])
	
	return warnings


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
	
	# Validazione base ingredienti (senza database)
	for i in range(ingredients.size()):
		var ing = ingredients[i]
		
		if not ing.has("item_id") or not ing.has("amount"):
			warnings.append("Ingredient %d: Invalid structure" % i)
			continue
		
		var amount: int = ing.get("amount", 0)
		if amount <= 0:
			warnings.append("Ingredient %d: Amount must be > 0" % i)
	
	# Validazione is_ingredient e material_type
	if is_ingredient and material_type == ItemEnums.MaterialType.NONE:
		warnings.append("Item marked as ingredient but material type not set")
	
	if not is_ingredient and material_type != ItemEnums.MaterialType.NONE:
		warnings.append("Material type set but item not marked as ingredient")
	
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
	new_item.is_ingredient = is_ingredient
	new_item.material_type = material_type
	new_item.craftable = craftable
	new_item.ingredients = ingredients.duplicate(true)
	# Duplica passives
	new_item.passives = []
	for p in passives:
		if p:
			new_item.passives.append(p.duplicate_passive())
	new_item.custom_fields = custom_fields.duplicate(true)

	return new_item


## Converte l'item in un Dictionary (per serializzazione/debug)
func to_dictionary() -> Dictionary:
	var passives_data = []
	for p in passives:
		if p:
			passives_data.append(p.to_dict())

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
		"is_ingredient": is_ingredient,
		"material_type": material_type,
		"craftable": craftable,
		"passives": passives_data,
		"custom_fields": custom_fields.duplicate(),
	}


# === Custom Fields Methods ===

## Gets a custom field value with optional default
func get_custom(key: String, default: Variant = null) -> Variant:
	return custom_fields.get(key, default)


## Sets a custom field value
func set_custom(key: String, value: Variant) -> void:
	custom_fields[key] = value
	emit_changed()
	changed_item.emit()


## Checks if a custom field exists
func has_custom(key: String) -> bool:
	return custom_fields.has(key)


## Removes a custom field
func remove_custom(key: String) -> bool:
	if custom_fields.has(key):
		custom_fields.erase(key)
		emit_changed()
		changed_item.emit()
		return true
	return false


## Gets all custom field keys
func get_custom_keys() -> Array:
	return custom_fields.keys()


## Gets a custom field as String (with type conversion)
func get_custom_string(key: String, default: String = "") -> String:
	var value = custom_fields.get(key)
	if value == null:
		return default
	return str(value)


## Gets a custom field as int (with type conversion)
func get_custom_int(key: String, default: int = 0) -> int:
	var value = custom_fields.get(key)
	if value == null:
		return default
	if value is int:
		return value
	if value is float:
		return int(value)
	if value is String and value.is_valid_int():
		return int(value)
	return default


## Gets a custom field as float (with type conversion)
func get_custom_float(key: String, default: float = 0.0) -> float:
	var value = custom_fields.get(key)
	if value == null:
		return default
	if value is float:
		return value
	if value is int:
		return float(value)
	if value is String and value.is_valid_float():
		return float(value)
	return default


## Gets a custom field as bool (with type conversion)
func get_custom_bool(key: String, default: bool = false) -> bool:
	var value = custom_fields.get(key)
	if value == null:
		return default
	if value is bool:
		return value
	if value is int:
		return value != 0
	if value is String:
		return value.to_lower() in ["true", "1", "yes", "on"]
	return default


## Clears all custom fields
func clear_custom_fields() -> void:
	custom_fields.clear()
	emit_changed()
	changed_item.emit()


## Merges custom fields from another dictionary
func merge_custom_fields(fields: Dictionary, overwrite: bool = true) -> void:
	if overwrite:
		custom_fields.merge(fields, true)
	else:
		for key in fields:
			if not custom_fields.has(key):
				custom_fields[key] = fields[key]
	emit_changed()
	changed_item.emit()
