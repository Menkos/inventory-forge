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


## Gets database statistics
func get_stats() -> Dictionary:
	return {
		"total_items": items.size(),
		"items_with_warnings": get_items_with_warnings().size(),
		"duplicate_ids": get_duplicate_ids().size(),
		"category_counts": get_category_counts(),
	}
