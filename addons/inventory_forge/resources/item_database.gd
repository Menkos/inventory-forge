@tool
@icon("res://addons/inventory_forge/icons/inventory_forge_icon.svg")
class_name ItemDatabase
extends Resource
## Database containing all game items.
## Manages the ItemDefinition collection and provides search methods.
##
## Inventory Forge Plugin by Menkos
## License: MIT

# === Segnali ===
signal item_added(item: ItemDefinition)
signal item_removed(item: ItemDefinition)
signal item_modified(item: ItemDefinition)
signal database_changed()


# === Dati ===
@export var items: Array[ItemDefinition] = []:
	set(value):
		items = value
		emit_changed()
		database_changed.emit()

## Migration flag - do not modify manually
@export var _migration_v2_materials_done: bool = false


# === Search Methods ===

## Gets an item by ID
func get_item_by_id(id: int) -> ItemDefinition:
	for item in items:
		if item and item.id == id:
			return item
	return null


## Gets the index of an item by ID
func get_item_index_by_id(id: int) -> int:
	for i in range(items.size()):
		if items[i] and items[i].id == id:
			return i
	return -1


## Checks if an item with the specified ID exists
func has_item(id: int) -> bool:
	return get_item_by_id(id) != null


## Gets all items of a category
func get_items_by_category(category: ItemEnums.Category) -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for item in items:
		if item and item.category == category:
			result.append(item)
	return result


## Gets all items of a rarity
func get_items_by_rarity(rarity: ItemEnums.Rarity) -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for item in items:
		if item and item.rarity == rarity:
			result.append(item)
	return result


## Search items by name (translation key)
func search_items(query: String) -> Array[ItemDefinition]:
	if query.is_empty():
		return items.duplicate()
	
	var result: Array[ItemDefinition] = []
	var query_lower := query.to_lower()
	
	for item in items:
		if item == null:
			continue
		
		# Search in name key
		if item.name_key.to_lower().contains(query_lower):
			result.append(item)
			continue
		
		# Search in translated name
		var translated_name := item.get_translated_name().to_lower()
		if translated_name.contains(query_lower):
			result.append(item)
			continue
		
		# Search in ID
		if str(item.id).contains(query):
			result.append(item)
	
	return result


## Filters items by category and search query
func filter_items(category_filter: int = -1, search_query: String = "") -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	
	for item in items:
		if item == null:
			continue
		
		# Category filter (-1 = all)
		if category_filter >= 0 and item.category != category_filter:
			continue
		
		# Search filter
		if not search_query.is_empty():
			var query_lower := search_query.to_lower()
			var name_matches := item.name_key.to_lower().contains(query_lower)
			var translated_matches := item.get_translated_name().to_lower().contains(query_lower)
			var id_matches := str(item.id).contains(search_query)
			
			if not (name_matches or translated_matches or id_matches):
				continue
		
		result.append(item)
	
	return result


## Gets all items marked as ingredients
func get_ingredients() -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for item in items:
		if item and item.is_ingredient:
			result.append(item)
	return result


# === Metodi di Gestione ===

## Gets the next available ID
func get_next_available_id() -> int:
	var max_id := -1
	for item in items:
		if item and item.id > max_id:
			max_id = item.id
	return max_id + 1


## Checks if there is a duplicate ID
func has_duplicate_id(id: int, exclude_item: ItemDefinition = null) -> bool:
	var count := 0
	for item in items:
		if item and item.id == id and item != exclude_item:
			count += 1
	return count > 0


## Aggiunge un nuovo item al database
func add_item(item: ItemDefinition) -> void:
	if item == null:
		return
	
	# Assegna ID se non valido
	if item.id < 0:
		item.id = get_next_available_id()
	
	items.append(item)
	emit_changed()
	item_added.emit(item)
	database_changed.emit()


## Rimuove un item dal database
func remove_item(item: ItemDefinition) -> bool:
	var index := items.find(item)
	if index >= 0:
		items.remove_at(index)
		emit_changed()
		item_removed.emit(item)
		database_changed.emit()
		return true
	return false


## Rimuove un item per ID
func remove_item_by_id(id: int) -> bool:
	var item := get_item_by_id(id)
	if item:
		return remove_item(item)
	return false


## Duplicates an existing item
func duplicate_item(item: ItemDefinition) -> ItemDefinition:
	if item == null:
		return null
	
	var new_item := item.duplicate_item()
	new_item.id = get_next_available_id()
	
	# Modifica le chiavi per indicare che è una copia
	if not new_item.name_key.is_empty():
		new_item.name_key = new_item.name_key + "_COPY"
	if not new_item.description_key.is_empty():
		new_item.description_key = new_item.description_key + "_COPY"
	
	add_item(new_item)
	return new_item


## Crea un nuovo item vuoto
func create_new_item() -> ItemDefinition:
	var new_item := ItemDefinition.new()
	new_item.id = get_next_available_id()
	add_item(new_item)
	return new_item


## Ordina gli items per ID
func sort_by_id() -> void:
	items.sort_custom(func(a, b): return a.id < b.id)
	emit_changed()
	database_changed.emit()


## Ordina gli items per nome
func sort_by_name() -> void:
	items.sort_custom(func(a, b): return a.name_key < b.name_key)
	emit_changed()
	database_changed.emit()


## Ordina gli items per categoria
func sort_by_category() -> void:
	items.sort_custom(func(a, b): return a.category < b.category)
	emit_changed()
	database_changed.emit()


# === Validazione ===

## Gets all items with warnings
func get_items_with_warnings() -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	for item in items:
		if item and not item.get_validation_warnings().is_empty():
			result.append(item)
	return result


## Gets all duplicate IDs
func get_duplicate_ids() -> Array[int]:
	var id_count := {}
	var duplicates: Array[int] = []
	
	for item in items:
		if item == null:
			continue
		if id_count.has(item.id):
			id_count[item.id] += 1
			if not duplicates.has(item.id):
				duplicates.append(item.id)
		else:
			id_count[item.id] = 1
	
	return duplicates


## Valida tutto il database
func validate() -> Array[String]:
	var errors: Array[String] = []
	
	# Check for duplicate IDs
	var duplicate_ids := get_duplicate_ids()
	for dup_id in duplicate_ids:
		errors.append("Duplicate ID: %d" % dup_id)
	
	# Check for invalid items
	for item in items:
		if item == null:
			errors.append("Item null trovato nel database")
			continue
		
		var warnings := item.get_validation_warnings()
		for warning in warnings:
			errors.append("Item %d: %s" % [item.id, warning])
	
	return errors


# === Import/Export ===

## Esporta le chiavi di traduzione per tutti gli items
func export_translation_keys() -> Dictionary:
	var keys := {}
	
	for item in items:
		if item == null:
			continue
		
		if not item.name_key.is_empty():
			keys[item.name_key] = item.get_translated_name()
		
		if not item.description_key.is_empty():
			keys[item.description_key] = item.get_translated_description()
	
	return keys


## Gets the item count per category
func get_category_counts() -> Dictionary:
	var counts := {}
	for category in ItemEnums.Category.values():
		counts[category] = 0
	
	for item in items:
		if item:
			counts[item.category] = counts.get(item.category, 0) + 1
	
	return counts


## Gets the item count per rarity
func get_rarity_counts() -> Dictionary:
	var counts := {}
	for rarity in ItemEnums.Rarity.values():
		counts[rarity] = 0
	
	for item in items:
		if item:
			counts[item.rarity] = counts.get(item.rarity, 0) + 1
	
	return counts


## Gets count of items marked as ingredients
func get_ingredients_count() -> int:
	var count := 0
	for item in items:
		if item and item.is_ingredient:
			count += 1
	return count


## Gets count of craftable items
func get_craftable_count() -> int:
	var count := 0
	for item in items:
		if item and item.craftable:
			count += 1
	return count


## Gets count of items by material type
func get_material_type_counts() -> Dictionary:
	var counts := {}
	for mat_type in ItemEnums.MaterialType.values():
		counts[mat_type] = 0
	
	for item in items:
		if item and item.is_ingredient:
			counts[item.material_type] = counts.get(item.material_type, 0) + 1
	
	return counts


## Gets database statistics
func get_stats() -> Dictionary:
	return {
		"total_items": items.size(),
		"items_with_warnings": get_items_with_warnings().size(),
		"duplicate_ids": get_duplicate_ids().size(),
		"category_counts": get_category_counts(),
		"rarity_counts": get_rarity_counts(),
		"ingredients_count": get_ingredients_count(),
		"craftable_count": get_craftable_count(),
		"material_type_counts": get_material_type_counts(),
	}


# === Migration ===

## Migrates old MATERIAL category (index 4) to new is_ingredient system
func migrate_materials_to_ingredients() -> void:
	var migrated_count := 0
	
	for item in items:
		if item == null:
			continue
		
		# Se category == 4 (vecchio MATERIAL), converti
		if item.category == 4:
			item.is_ingredient = true
			item.material_type = ItemEnums.MaterialType.MISC  # Default conservativo
			item.category = ItemEnums.Category.MISC  # Nuova categoria MISC (indice 5)
			migrated_count += 1
			print("[InventoryForge Migration] Item ID %d '%s' migrated: MATERIAL → MISC + is_ingredient" % [item.id, item.name_key])
	
	if migrated_count > 0:
		print("[InventoryForge Migration] Successfully migrated %d items from MATERIAL to ingredient system" % migrated_count)
		emit_changed()
		database_changed.emit()


## Validates and runs migrations if needed
func validate_and_migrate() -> void:
	if not _migration_v2_materials_done:
		print("[InventoryForge Migration] Running migration: MATERIAL category → is_ingredient system")
		migrate_materials_to_ingredients()
		_migration_v2_materials_done = true
		print("[InventoryForge Migration] Migration completed successfully")


# === Export Methods ===

## Exports the database to JSON format
func export_to_json() -> String:
	var data := {
		"version": "1.0",
		"export_date": Time.get_datetime_string_from_system(),
		"items": []
	}
	
	for item in items:
		if item == null:
			continue
		data.items.append(_item_to_dict(item))
	
	return JSON.stringify(data, "\t")


## Exports the database to a JSON file
func export_to_json_file(path: String) -> Error:
	var json_string := export_to_json()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[InventoryForge] Failed to open file for writing: %s" % path)
		return FileAccess.get_open_error()
	
	file.store_string(json_string)
	file.close()
	return OK


## Exports the database to CSV format
func export_to_csv() -> String:
	var lines: Array[String] = []
	
	# Header
	var headers := [
		"id", "name_key", "description_key", "icon_path",
		"category", "rarity", "stack_capacity", "stack_count_limit",
		"buy_price", "sell_price", "tradeable", "required_level",
		"equippable", "equip_slot", "stat_atk", "stat_def", "stat_hp", "stat_mp", "stat_spd",
		"consumable", "effect_type", "effect_value", "effect_duration",
		"craftable", "is_ingredient", "material_type", "ingredients"
	]
	lines.append(",".join(headers))
	
	# Data rows
	for item in items:
		if item == null:
			continue
		
		var icon_path := ""
		if item.icon:
			icon_path = item.icon.resource_path
		
		# Serialize ingredients as semicolon-separated id:amount pairs
		var ingredients_str := ""
		if item.craftable and item.ingredients.size() > 0:
			var ing_parts: Array[String] = []
			for ing in item.ingredients:
				if ing and ing.has("item_id") and ing.has("amount"):
					ing_parts.append("%d:%d" % [ing.get("item_id"), ing.get("amount")])
			ingredients_str = ";".join(ing_parts)
		
		var row := [
			str(item.id),
			_escape_csv(item.name_key),
			_escape_csv(item.description_key),
			_escape_csv(icon_path),
			ItemEnums.Category.keys()[item.category],
			ItemEnums.Rarity.keys()[item.rarity],
			str(item.stack_capacity),
			str(item.stack_count_limit),
			str(item.buy_price),
			str(item.sell_price),
			"true" if item.tradeable else "false",
			str(item.required_level),
			"true" if item.equippable else "false",
			ItemEnums.EquipSlot.keys()[item.equip_slot],
			str(item.stat_atk),
			str(item.stat_def),
			str(item.stat_hp),
			str(item.stat_mp),
			str(item.stat_spd),
			"true" if item.consumable else "false",
			ItemEnums.EffectType.keys()[item.effect_type],
			str(item.effect_value),
			str(item.effect_duration),
			"true" if item.craftable else "false",
			"true" if item.is_ingredient else "false",
			ItemEnums.MaterialType.keys()[item.material_type],
			_escape_csv(ingredients_str)
		]
		lines.append(",".join(row))
	
	return "\n".join(lines)


## Exports the database to a CSV file
func export_to_csv_file(path: String) -> Error:
	var csv_string := export_to_csv()
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("[InventoryForge] Failed to open file for writing: %s" % path)
		return FileAccess.get_open_error()
	
	file.store_string(csv_string)
	file.close()
	return OK


## Helper: Convert item to dictionary for JSON export
func _item_to_dict(item: ItemDefinition) -> Dictionary:
	var icon_path := ""
	if item.icon:
		icon_path = item.icon.resource_path
	
	var ingredients_data: Array[Dictionary] = []
	if item.craftable:
		for ing in item.ingredients:
			if ing and ing.has("item_id") and ing.has("amount"):
				ingredients_data.append({
					"item_id": ing.get("item_id"),
					"amount": ing.get("amount")
				})
	
	return {
		"id": item.id,
		"name_key": item.name_key,
		"description_key": item.description_key,
		"icon_path": icon_path,
		"category": ItemEnums.Category.keys()[item.category],
		"rarity": ItemEnums.Rarity.keys()[item.rarity],
		"stack_capacity": item.stack_capacity,
		"stack_count_limit": item.stack_count_limit,
		"buy_price": item.buy_price,
		"sell_price": item.sell_price,
		"tradeable": item.tradeable,
		"required_level": item.required_level,
		"equippable": item.equippable,
		"equip_slot": ItemEnums.EquipSlot.keys()[item.equip_slot],
		"stat_atk": item.stat_atk,
		"stat_def": item.stat_def,
		"stat_hp": item.stat_hp,
		"stat_mp": item.stat_mp,
		"stat_spd": item.stat_spd,
		"consumable": item.consumable,
		"effect_type": ItemEnums.EffectType.keys()[item.effect_type],
		"effect_value": item.effect_value,
		"effect_duration": item.effect_duration,
		"craftable": item.craftable,
		"is_ingredient": item.is_ingredient,
		"material_type": ItemEnums.MaterialType.keys()[item.material_type],
		"ingredients": ingredients_data,
		"custom_fields": item.custom_fields.duplicate(),
	}


## Helper: Escape CSV field
func _escape_csv(value: String) -> String:
	if value.contains(",") or value.contains("\"") or value.contains("\n"):
		return "\"%s\"" % value.replace("\"", "\"\"")
	return value


# === Import Methods ===

## Import mode for merging data
enum ImportMode {
	REPLACE_ALL,      # Clear database and import
	MERGE_SKIP,       # Skip items with existing IDs
	MERGE_OVERWRITE,  # Overwrite items with existing IDs
}


## Imports items from JSON string
func import_from_json(json_string: String, mode: ImportMode = ImportMode.MERGE_SKIP) -> Dictionary:
	var result := {"success": false, "imported": 0, "skipped": 0, "errors": []}
	
	var json := JSON.new()
	var parse_result := json.parse(json_string)
	
	if parse_result != OK:
		result.errors.append("Failed to parse JSON: %s at line %d" % [json.get_error_message(), json.get_error_line()])
		return result
	
	var data: Dictionary = json.data
	if not data.has("items") or not data.items is Array:
		result.errors.append("Invalid JSON structure: missing 'items' array")
		return result
	
	if mode == ImportMode.REPLACE_ALL:
		items.clear()
	
	for item_data in data.items:
		var import_result := _import_item_from_dict(item_data, mode)
		if import_result.success:
			result.imported += 1
		elif import_result.skipped:
			result.skipped += 1
		else:
			result.errors.append(import_result.error)
	
	if result.imported > 0:
		emit_changed()
		database_changed.emit()
	
	result.success = result.errors.is_empty()
	return result


## Imports items from a JSON file
func import_from_json_file(path: String, mode: ImportMode = ImportMode.MERGE_SKIP) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"success": false, "imported": 0, "skipped": 0, "errors": ["Failed to open file: %s" % path]}
	
	var json_string := file.get_as_text()
	file.close()
	
	return import_from_json(json_string, mode)


## Imports items from CSV string
func import_from_csv(csv_string: String, mode: ImportMode = ImportMode.MERGE_SKIP) -> Dictionary:
	var result := {"success": false, "imported": 0, "skipped": 0, "errors": []}
	
	var lines := csv_string.split("\n")
	if lines.size() < 2:
		result.errors.append("CSV file is empty or has no data rows")
		return result
	
	# Parse header
	var headers := _parse_csv_line(lines[0])
	
	if mode == ImportMode.REPLACE_ALL:
		items.clear()
	
	# Parse data rows
	for i in range(1, lines.size()):
		var line := lines[i].strip_edges()
		if line.is_empty():
			continue
		
		var values := _parse_csv_line(line)
		if values.size() != headers.size():
			result.errors.append("Line %d: column count mismatch (expected %d, got %d)" % [i + 1, headers.size(), values.size()])
			continue
		
		var item_data := {}
		for j in range(headers.size()):
			item_data[headers[j]] = values[j]
		
		var import_result := _import_item_from_csv_row(item_data, mode)
		if import_result.success:
			result.imported += 1
		elif import_result.skipped:
			result.skipped += 1
		else:
			result.errors.append("Line %d: %s" % [i + 1, import_result.error])
	
	if result.imported > 0:
		emit_changed()
		database_changed.emit()
	
	result.success = result.errors.is_empty()
	return result


## Imports items from a CSV file
func import_from_csv_file(path: String, mode: ImportMode = ImportMode.MERGE_SKIP) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {"success": false, "imported": 0, "skipped": 0, "errors": ["Failed to open file: %s" % path]}
	
	var csv_string := file.get_as_text()
	file.close()
	
	return import_from_csv(csv_string, mode)


## Helper: Import single item from dictionary (JSON)
func _import_item_from_dict(data: Dictionary, mode: ImportMode) -> Dictionary:
	var result := {"success": false, "skipped": false, "error": ""}
	
	if not data.has("id"):
		result.error = "Missing 'id' field"
		return result
	
	var id: int = int(data.get("id", -1))
	var existing := get_item_by_id(id)
	
	if existing and mode == ImportMode.MERGE_SKIP:
		result.skipped = true
		return result
	
	var item: ItemDefinition
	if existing and mode == ImportMode.MERGE_OVERWRITE:
		item = existing
	else:
		item = ItemDefinition.new()
		item.id = id
	
	# Set basic properties
	item.name_key = str(data.get("name_key", ""))
	item.description_key = str(data.get("description_key", ""))
	
	# Load icon if path provided
	var icon_path: String = str(data.get("icon_path", ""))
	if not icon_path.is_empty() and ResourceLoader.exists(icon_path):
		item.icon = load(icon_path)
	
	# Enums
	item.category = _parse_enum(data.get("category", "CONSUMABLE"), ItemEnums.Category)
	item.rarity = _parse_enum(data.get("rarity", "COMMON"), ItemEnums.Rarity)
	item.equip_slot = _parse_enum(data.get("equip_slot", "NONE"), ItemEnums.EquipSlot)
	item.effect_type = _parse_enum(data.get("effect_type", "NONE"), ItemEnums.EffectType)
	item.material_type = _parse_enum(data.get("material_type", "NONE"), ItemEnums.MaterialType)
	
	# Numeric values
	item.stack_capacity = int(data.get("stack_capacity", 99))
	item.stack_count_limit = int(data.get("stack_count_limit", 0))
	item.buy_price = int(data.get("buy_price", 0))
	item.sell_price = int(data.get("sell_price", 0))
	item.required_level = int(data.get("required_level", 0))
	item.stat_atk = int(data.get("stat_atk", 0))
	item.stat_def = int(data.get("stat_def", 0))
	item.stat_hp = int(data.get("stat_hp", 0))
	item.stat_mp = int(data.get("stat_mp", 0))
	item.stat_spd = int(data.get("stat_spd", 0))
	item.effect_value = int(data.get("effect_value", 0))
	item.effect_duration = float(data.get("effect_duration", 0.0))
	
	# Booleans
	item.tradeable = _parse_bool(data.get("tradeable", true))
	item.equippable = _parse_bool(data.get("equippable", false))
	item.consumable = _parse_bool(data.get("consumable", false))
	item.craftable = _parse_bool(data.get("craftable", false))
	item.is_ingredient = _parse_bool(data.get("is_ingredient", false))
	
	# Note: ingredients are not imported here to avoid circular dependencies
	# They should be resolved in a second pass if needed
	
	# Custom fields
	var custom_fields_data = data.get("custom_fields", {})
	if custom_fields_data is Dictionary:
		item.custom_fields = custom_fields_data.duplicate()
	
	if not existing:
		items.append(item)
	
	result.success = true
	return result


## Helper: Import single item from CSV row
func _import_item_from_csv_row(data: Dictionary, mode: ImportMode) -> Dictionary:
	# Convert CSV row to same format as JSON dict
	var converted := {}
	
	for key in data.keys():
		var value: String = data[key]
		
		# Convert boolean strings
		if value == "true":
			converted[key] = true
		elif value == "false":
			converted[key] = false
		# Keep as string for enum parsing
		else:
			converted[key] = value
	
	return _import_item_from_dict(converted, mode)


## Helper: Parse CSV line respecting quoted fields
func _parse_csv_line(line: String) -> Array[String]:
	var result: Array[String] = []
	var current := ""
	var in_quotes := false
	var i := 0
	
	while i < line.length():
		var c := line[i]
		
		if c == "\"":
			if in_quotes and i + 1 < line.length() and line[i + 1] == "\"":
				# Escaped quote
				current += "\""
				i += 1
			else:
				in_quotes = not in_quotes
		elif c == "," and not in_quotes:
			result.append(current)
			current = ""
		else:
			current += c
		
		i += 1
	
	result.append(current)
	return result


## Helper: Parse enum from string name
func _parse_enum(value, enum_type) -> int:
	var value_str := str(value).to_upper()
	var keys: Array = enum_type.keys()
	var index := keys.find(value_str)
	if index >= 0:
		return index
	return 0


## Helper: Parse boolean from various formats
func _parse_bool(value) -> bool:
	if value is bool:
		return value
	var str_value := str(value).to_lower()
	return str_value == "true" or str_value == "1" or str_value == "yes"
