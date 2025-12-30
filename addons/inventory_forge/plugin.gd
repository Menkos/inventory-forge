@tool
extends EditorPlugin
## Plugin entry point for Inventory Forge.
## Adds a main panel to the Godot editor.
##
## Inventory Forge Plugin by Menkos
## License: MIT

const MainPanelScene := preload("res://addons/inventory_forge/inventory_forge_main.tscn")
const PluginIcon := preload("res://addons/inventory_forge/icons/inventory_forge_icon.svg")
const Settings := preload("res://addons/inventory_forge/inventory_forge_settings.gd")

var main_panel_instance: Control = null


func _enter_tree() -> void:
	# Initialize plugin settings
	Settings.initialize_settings()
	
	# Ensure database directory exists
	Settings.ensure_database_directory()
	
	# Crea l'istanza del pannello principale
	main_panel_instance = MainPanelScene.instantiate()
	
	# Add to the editor's main screen
	get_editor_interface().get_editor_main_screen().add_child(main_panel_instance)
	
	# Nascondi di default
	_make_visible(false)
	
	print("[InventoryForge] Plugin loaded - Database path: ", Settings.get_database_path())


func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()
		main_panel_instance = null
	
	# Opzionale: rimuovi le impostazioni quando il plugin viene disabilitato
	# Settings.remove_settings()
	
	print("[InventoryForge] Plugin unloaded")


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name() -> String:
	return "Inventory Forge"


func _get_plugin_icon() -> Texture2D:
	return PluginIcon
