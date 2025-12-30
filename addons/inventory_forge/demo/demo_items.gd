@tool
extends Node
## Script demo che mostra come usare ItemDatabase e ItemDefinition nel gioco.
## Questo file serve come esempio di integrazione di Inventory Forge.
##
## Inventory Forge Plugin by Menkos
## License: MIT

## Path al database (configurato nelle impostazioni del progetto)
## Puoi cambiarlo in: Project Settings -> Inventory Forge -> Database -> Path
const DEFAULT_DATABASE_PATH := "res://addons/inventory_forge/demo/demo_database.tres"

var database: ItemDatabase = null


func _ready() -> void:
	# Carica il database
	_load_database()
	
	# Stampa tutti gli items
	if database:
		print("=== DEMO: Items nel database ===")
		for item in database.items:
			if item:
				print("  [%d] %s - %s" % [item.id, item.name_key, tr(item.name_key)])
		print("================================")


func _load_database() -> void:
	var db_path := DEFAULT_DATABASE_PATH
	
	# Prova a caricare dalle impostazioni se disponibili
	if ProjectSettings.has_setting("inventory_forge/database/path"):
		db_path = ProjectSettings.get_setting("inventory_forge/database/path")
	
	if ResourceLoader.exists(db_path):
		database = ResourceLoader.load(db_path) as ItemDatabase
		print("[Demo] Database caricato: %d items" % database.items.size())
	else:
		push_warning("[Demo] Database non trovato a: %s" % db_path)


## Example: Gets an item by ID
func get_item(item_id: int) -> ItemDefinition:
	if database == null:
		return null
	return database.get_item_by_id(item_id)


## Example: Gets the translated name of an item
func get_item_name(item_id: int) -> String:
	var item := get_item(item_id)
	if item:
		return item.get_translated_name()
	return "???"


## Example: Gets all items of a category
func get_consumables() -> Array[ItemDefinition]:
	if database == null:
		return []
	return database.get_items_by_category(ItemEnums.Category.CONSUMABLE)


## Example: Gets all equippable items
func get_equippable_items() -> Array[ItemDefinition]:
	var result: Array[ItemDefinition] = []
	if database:
		for item in database.items:
			if item and item.equippable:
				result.append(item)
	return result


## Esempio: Usa un consumabile (logica base)
func use_consumable(item_id: int) -> Dictionary:
	var item := get_item(item_id)
	if item == null:
		return {"success": false, "message": "Item non trovato"}
	
	if not item.consumable:
		return {"success": false, "message": "Item non consumabile"}
	
	# Applica effetto
	match item.effect_type:
		ItemEnums.EffectType.HEAL_HP:
			return {
				"success": true, 
				"message": "Curato %d HP" % item.effect_value,
				"heal_hp": item.effect_value
			}
		ItemEnums.EffectType.HEAL_MP:
			return {
				"success": true, 
				"message": "Curato %d MP" % item.effect_value,
				"heal_mp": item.effect_value
			}
		ItemEnums.EffectType.BUFF_ATK:
			return {
				"success": true, 
				"message": "ATK +%d per %ds" % [item.effect_value, item.effect_duration],
				"buff_atk": item.effect_value,
				"duration": item.effect_duration
			}
		_:
			return {"success": true, "message": "Effetto applicato"}
