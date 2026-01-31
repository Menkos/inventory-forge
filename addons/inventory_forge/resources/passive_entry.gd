@tool
@icon("res://addons/inventory_forge/icons/inventory_forge_icon.svg")
class_name PassiveEntry
extends Resource
## Definition of a single passive effect for equipment.
## Used by ItemDefinition to define passive abilities on items.
##
## Inventory Forge Plugin by Menkos
## License: MIT

# === Segnali ===
signal changed_passive()


# === Properties ===

@export var passive_type: ItemEnums.PassiveType = ItemEnums.PassiveType.NONE:
	set(value):
		passive_type = value
		emit_changed()
		changed_passive.emit()

## The value/strength of the passive effect (percentage or flat value depending on type)
@export_range(-999, 999) var value: int = 0:
	set(v):
		value = v
		emit_changed()
		changed_passive.emit()

## Optional: Chance for the passive to trigger (0-100%). Default 100 = always active.
@export_range(0, 100) var trigger_chance: float = 100.0:
	set(v):
		trigger_chance = v
		emit_changed()
		changed_passive.emit()


# === Helper Methods ===

## Gets the display name for this passive
func get_display_name() -> String:
	return ItemEnums.get_passive_display_name(passive_type)


## Gets the translation key for this passive
func get_translation_key() -> String:
	return ItemEnums.get_passive_type_name(passive_type)


## Checks if this passive is valid (has a type set)
func is_valid() -> bool:
	return passive_type != ItemEnums.PassiveType.NONE


## Converts to dictionary for serialization
func to_dict() -> Dictionary:
	return {
		"passive_type": passive_type,
		"value": value,
		"trigger_chance": trigger_chance,
	}


## Loads from dictionary
func from_dict(data: Dictionary) -> void:
	passive_type = data.get("passive_type", ItemEnums.PassiveType.NONE)
	value = data.get("value", 0)
	trigger_chance = data.get("trigger_chance", 100.0)


## Creates a duplicate of this passive entry
func duplicate_passive() -> PassiveEntry:
	var new_passive := PassiveEntry.new()
	new_passive.passive_type = passive_type
	new_passive.value = value
	new_passive.trigger_chance = trigger_chance
	return new_passive
