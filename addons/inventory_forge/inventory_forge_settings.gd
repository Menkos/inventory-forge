@tool
class_name InventoryForgeSettings
extends RefCounted
## Manages Inventory Forge plugin settings.
## Saves and loads settings from ProjectSettings.
##
## Inventory Forge Plugin by Menkos
## License: MIT

const SETTING_DATABASE_PATH := "inventory_forge/database/path"
const SETTING_AUTO_SAVE := "inventory_forge/editor/auto_save"
const SETTING_SHOW_WARNINGS := "inventory_forge/editor/show_warnings"

const DEFAULT_DATABASE_PATH := "res://addons/inventory_forge/demo/demo_database.tres"
const DEFAULT_AUTO_SAVE := true
const DEFAULT_SHOW_WARNINGS := true


## Inizializza le impostazioni del plugin (chiamato da plugin.gd)
static func initialize_settings() -> void:
	# Database path
	if not ProjectSettings.has_setting(SETTING_DATABASE_PATH):
		ProjectSettings.set_setting(SETTING_DATABASE_PATH, DEFAULT_DATABASE_PATH)
	ProjectSettings.set_initial_value(SETTING_DATABASE_PATH, DEFAULT_DATABASE_PATH)
	ProjectSettings.add_property_info({
		"name": SETTING_DATABASE_PATH,
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.tres"
	})
	
	# Auto save
	if not ProjectSettings.has_setting(SETTING_AUTO_SAVE):
		ProjectSettings.set_setting(SETTING_AUTO_SAVE, DEFAULT_AUTO_SAVE)
	ProjectSettings.set_initial_value(SETTING_AUTO_SAVE, DEFAULT_AUTO_SAVE)
	ProjectSettings.add_property_info({
		"name": SETTING_AUTO_SAVE,
		"type": TYPE_BOOL
	})
	
	# Show warnings
	if not ProjectSettings.has_setting(SETTING_SHOW_WARNINGS):
		ProjectSettings.set_setting(SETTING_SHOW_WARNINGS, DEFAULT_SHOW_WARNINGS)
	ProjectSettings.set_initial_value(SETTING_SHOW_WARNINGS, DEFAULT_SHOW_WARNINGS)
	ProjectSettings.add_property_info({
		"name": SETTING_SHOW_WARNINGS,
		"type": TYPE_BOOL
	})


## Rimuove le impostazioni del plugin (chiamato alla disattivazione)
static func remove_settings() -> void:
	if ProjectSettings.has_setting(SETTING_DATABASE_PATH):
		ProjectSettings.set_setting(SETTING_DATABASE_PATH, null)
	if ProjectSettings.has_setting(SETTING_AUTO_SAVE):
		ProjectSettings.set_setting(SETTING_AUTO_SAVE, null)
	if ProjectSettings.has_setting(SETTING_SHOW_WARNINGS):
		ProjectSettings.set_setting(SETTING_SHOW_WARNINGS, null)


## Gets the database path
static func get_database_path() -> String:
	return ProjectSettings.get_setting(SETTING_DATABASE_PATH, DEFAULT_DATABASE_PATH)


## Imposta il percorso del database
static func set_database_path(path: String) -> void:
	ProjectSettings.set_setting(SETTING_DATABASE_PATH, path)
	ProjectSettings.save()


## Verifica se l'auto-save è attivo
static func is_auto_save_enabled() -> bool:
	return ProjectSettings.get_setting(SETTING_AUTO_SAVE, DEFAULT_AUTO_SAVE)


## Verifica se i warning devono essere mostrati
static func is_show_warnings_enabled() -> bool:
	return ProjectSettings.get_setting(SETTING_SHOW_WARNINGS, DEFAULT_SHOW_WARNINGS)


## Creates the database folder if it does not exist
static func ensure_database_directory() -> void:
	var path := get_database_path()
	var dir_path := path.get_base_dir()
	
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)
