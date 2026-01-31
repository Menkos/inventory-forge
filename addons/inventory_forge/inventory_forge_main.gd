@tool
extends Control
## Main panel for Inventory Forge.
## Manages the item list on the left and details on the right.
##
## Inventory Forge Plugin by Menkos
## License: MIT

const Settings := preload("res://addons/inventory_forge/inventory_forge_settings.gd")
const IconPickerDialog := preload("res://addons/inventory_forge/ui/icon_picker_dialog.gd")

# === Constants ===
const MAX_INGREDIENTS := 10  # Limite massimo ingredienti per ricetta

# === UI References ===
@onready var add_button: Button = %AddButton
@onready var duplicate_button: Button = %DuplicateButton
@onready var delete_button: Button = %DeleteButton
@onready var import_button: Button = %ImportButton
@onready var export_button: Button = %ExportButton
@onready var search_edit: LineEdit = %SearchEdit
@onready var category_filter: OptionButton = %CategoryFilter
@onready var item_list: ItemList = %ItemList
@onready var details_container: ScrollContainer = %DetailsContainer
@onready var no_selection_label: Label = %NoSelectionLabel
@onready var item_count_label: Label = %ItemCountLabel

# Base Details
@onready var icon_preview: TextureRect = %IconPreview
@onready var item_name_label: Label = %ItemNameLabel
@onready var item_id_label: Label = %ItemIdLabel
@onready var id_spinbox: SpinBox = %IdSpinBox
@onready var name_key_edit: LineEdit = %NameKeyEdit
@onready var generate_name_key_button: Button = %GenerateNameKeyButton
@onready var desc_key_edit: LineEdit = %DescKeyEdit
@onready var generate_desc_key_button: Button = %GenerateDescKeyButton
@onready var icon_picker: Button = %IconPicker
@onready var clear_icon_button: Button = %ClearIconButton
@onready var category_option: OptionButton = %CategoryOption

# Stack
@onready var stack_capacity_spinbox: SpinBox = %StackCapacitySpinBox
@onready var stack_limit_spinbox: SpinBox = %StackLimitSpinBox

# Economy
@onready var buy_price_spinbox: SpinBox = %BuyPriceSpinBox
@onready var sell_price_spinbox: SpinBox = %SellPriceSpinBox
@onready var tradeable_check: CheckBox = %TradeableCheck

# Rarity
@onready var rarity_option: OptionButton = %RarityOption
@onready var required_level_spinbox: SpinBox = %RequiredLevelSpinBox

# Equipment
@onready var equippable_check: CheckBox = %EquippableCheck
@onready var equip_slot_option: OptionButton = %EquipSlotOption
@onready var stats_container: VBoxContainer = %StatsContainer
@onready var stat_atk_spinbox: SpinBox = %StatAtkSpinBox
@onready var stat_def_spinbox: SpinBox = %StatDefSpinBox
@onready var stat_hp_spinbox: SpinBox = %StatHpSpinBox
@onready var stat_mp_spinbox: SpinBox = %StatMpSpinBox
@onready var stat_spd_spinbox: SpinBox = %StatSpdSpinBox

# Consumable
@onready var consumable_check: CheckBox = %ConsumableCheck
@onready var consumable_container: VBoxContainer = %ConsumableContainer
@onready var effect_type_option: OptionButton = %EffectTypeOption
@onready var effect_value_spinbox: SpinBox = %EffectValueSpinBox
@onready var effect_duration_spinbox: SpinBox = %EffectDurationSpinBox

# Quest
@onready var quest_item_check: CheckBox = %QuestItemCheck
@onready var quest_id_edit: LineEdit = %QuestIdEdit

# Crafting
@onready var is_ingredient_check: CheckBox = get_node_or_null("%IsIngredientCheck")
@onready var material_type_option: OptionButton = get_node_or_null("%MaterialTypeOption")
@onready var material_type_row: HBoxContainer = get_node_or_null("%MaterialTypeRow")
@onready var craftable_check: CheckBox = %CraftableCheck
@onready var ingredients_container: VBoxContainer = %IngredientsContainer
@onready var add_ingredient_button: Button = get_node_or_null("%AddIngredientButton")
@onready var ingredients_list_vbox: VBoxContainer = get_node_or_null("%IngredientsListVBox")

# Custom Fields
@onready var add_custom_field_button: Button = get_node_or_null("%AddCustomFieldButton")
@onready var custom_fields_container: VBoxContainer = get_node_or_null("%CustomFieldsContainer")

# Passives
@onready var passives_section: VBoxContainer = get_node_or_null("%PassivesSection")
@onready var add_passive_button: Button = get_node_or_null("%AddPassiveButton")
@onready var passives_list_vbox: VBoxContainer = get_node_or_null("%PassivesListVBox")

# Validation
@onready var warnings_container: VBoxContainer = %WarningsContainer

# === State ===
var database: ItemDatabase = null
var selected_item: ItemDefinition = null
var is_updating_ui: bool = false  # Prevents update loops
var filtered_items: Array[ItemDefinition] = []

# Statistics Dashboard
@onready var main_tab_container: TabContainer = get_node_or_null("%MainTabContainer")
@onready var stats_scroll_container: ScrollContainer = get_node_or_null("%StatsScrollContainer")
@onready var stats_vbox: VBoxContainer = get_node_or_null("%StatsVBox")

# Loot Tables Tab
@onready var add_loot_table_button: Button = get_node_or_null("%AddLootTableButton")
@onready var duplicate_loot_table_button: Button = get_node_or_null("%DuplicateLootTableButton")
@onready var delete_loot_table_button: Button = get_node_or_null("%DeleteLootTableButton")
@onready var import_loot_button: Button = get_node_or_null("%ImportLootButton")
@onready var export_loot_button: Button = get_node_or_null("%ExportLootButton")
@onready var loot_table_count_label: Label = get_node_or_null("%LootTableCountLabel")
@onready var loot_search_edit: LineEdit = get_node_or_null("%LootSearchEdit")
@onready var loot_table_list: ItemList = get_node_or_null("%LootTableList")
@onready var loot_no_selection_label: Label = get_node_or_null("%LootNoSelectionLabel")
@onready var loot_details_scroll: ScrollContainer = get_node_or_null("%LootDetailsScroll")
@onready var loot_table_name_label: Label = get_node_or_null("%LootTableNameLabel")
@onready var loot_id_edit: LineEdit = get_node_or_null("%LootIdEdit")
@onready var loot_name_edit: LineEdit = get_node_or_null("%LootNameEdit")
@onready var loot_desc_edit: TextEdit = get_node_or_null("%LootDescEdit")
@onready var min_drops_spinbox: SpinBox = get_node_or_null("%MinDropsSpinBox")
@onready var max_drops_spinbox: SpinBox = get_node_or_null("%MaxDropsSpinBox")
@onready var empty_chance_spinbox: SpinBox = get_node_or_null("%EmptyChanceSpinBox")
@onready var allow_duplicates_check: CheckBox = get_node_or_null("%AllowDuplicatesCheck")
@onready var add_entry_button: Button = get_node_or_null("%AddEntryButton")
@onready var loot_entries_container: VBoxContainer = get_node_or_null("%LootEntriesContainer")
@onready var test_roll_button: Button = get_node_or_null("%TestRollButton")
@onready var test_result_label: RichTextLabel = get_node_or_null("%TestResultLabel")

# Rarity Preset
@onready var rarity_tier_option: OptionButton = get_node_or_null("%RarityTierOption")
@onready var rarity_desc_label: Label = get_node_or_null("%RarityDescLabel")

# Sub-Tables
@onready var add_sub_table_button: Button = get_node_or_null("%AddSubTableButton")
@onready var sub_tables_container: VBoxContainer = get_node_or_null("%SubTablesContainer")

# Loot Tables State
var loot_database: LootTableDatabase = null
var selected_loot_table: LootTable = null
var filtered_loot_tables: Array[LootTable] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	
	_load_database()
	_load_loot_database()
	_setup_ui()
	_setup_statistics_tab()
	_setup_loot_tables_tab()
	_connect_signals()
	_refresh_item_list()
	_refresh_loot_table_list()
	_update_selection_state()
	_update_loot_selection_state()


func _get_database_path() -> String:
	return Settings.get_database_path()


func _load_database() -> void:
	var db_path := _get_database_path()
	
	if ResourceLoader.exists(db_path):
		database = load(db_path) as ItemDatabase
	
	if database == null:
		database = ItemDatabase.new()
		_save_database()
	else:
		# Esegui migrazione se necessario
		database.validate_and_migrate()


func _save_database() -> void:
	if database == null:
		push_error("[InventoryForge] Cannot save: database is null!")
		return
	
	var db_path := _get_database_path()
	
	# Ensure directory exists
	var dir_path := db_path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		var err := DirAccess.make_dir_recursive_absolute(dir_path)
		if err != OK:
			push_error("[InventoryForge] Cannot create directory: %s (error: %s)" % [dir_path, err])
			return
	
	# Check if path is writable
	if db_path.begins_with("res://addons/inventory_forge/demo/"):
		push_warning("[InventoryForge] Saving to demo database. Consider using a custom path in Project Settings.")
	
	var error := ResourceSaver.save(database, db_path)
	if error != OK:
		var error_msg := ""
		match error:
			ERR_CANT_OPEN:
				error_msg = "Cannot open file for writing. File may be read-only or locked."
			ERR_CANT_CREATE:
				error_msg = "Cannot create file. Check directory permissions."
			ERR_FILE_CANT_WRITE:
				error_msg = "Cannot write to file. File may be in use."
			_:
				error_msg = "Unknown error code: %s" % error
		
		push_error("[InventoryForge] Error saving database to '%s': %s" % [db_path, error_msg])
		push_error("[InventoryForge] Try changing the database path in Project Settings → Inventory Forge → Database → Path")
	else:
		# Notify editor that resource has changed
		if Engine.is_editor_hint():
			database.emit_changed()
		print("[InventoryForge] Database saved successfully to: %s" % db_path)


func _setup_ui() -> void:
	# Setup category filter
	category_filter.clear()
	category_filter.add_item("All Categories", -1)
	for i in range(ItemEnums.Category.size()):
		var cat_name: String = str(ItemEnums.Category.keys()[i]).capitalize()
		category_filter.add_item(cat_name, i)
	category_filter.selected = 0
	
	# Setup opzioni categoria item
	category_option.clear()
	for i in range(ItemEnums.Category.size()):
		var cat_name: String = str(ItemEnums.Category.keys()[i]).capitalize()
		category_option.add_item(cat_name, i)
	
	# Setup opzioni rarità
	rarity_option.clear()
	for i in range(ItemEnums.Rarity.size()):
		var rarity_name: String = str(ItemEnums.Rarity.keys()[i]).capitalize()
		rarity_option.add_item(rarity_name, i)
	
	# Setup opzioni slot equip
	equip_slot_option.clear()
	for i in range(ItemEnums.EquipSlot.size()):
		var slot_name: String = str(ItemEnums.EquipSlot.keys()[i]).capitalize()
		equip_slot_option.add_item(slot_name, i)
	
	# Setup opzioni tipo effetto
	effect_type_option.clear()
	for i in range(ItemEnums.EffectType.size()):
		var effect_name: String = str(ItemEnums.EffectType.keys()[i]).capitalize().replace("_", " ")
		effect_type_option.add_item(effect_name, i)
	
	# Setup opzioni material type
	if material_type_option:
		material_type_option.clear()
		for i in range(ItemEnums.MaterialType.size()):
			var mat_name: String = str(ItemEnums.MaterialType.keys()[i]).capitalize()
			material_type_option.add_item(mat_name, i)


func _connect_signals() -> void:
	# Toolbar
	add_button.pressed.connect(_on_add_pressed)
	duplicate_button.pressed.connect(_on_duplicate_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	import_button.pressed.connect(_on_import_pressed)
	export_button.pressed.connect(_on_export_pressed)
	
	# Filtri
	search_edit.text_changed.connect(_on_search_changed)
	category_filter.item_selected.connect(_on_category_filter_changed)
	
	# Lista
	item_list.item_selected.connect(_on_item_selected)
	
	# Base Details
	id_spinbox.value_changed.connect(_on_id_changed)
	name_key_edit.text_changed.connect(_on_name_key_changed)
	generate_name_key_button.pressed.connect(_on_generate_name_key_pressed)
	desc_key_edit.text_changed.connect(_on_desc_key_changed)
	generate_desc_key_button.pressed.connect(_on_generate_desc_key_pressed)
	icon_picker.pressed.connect(_on_icon_picker_pressed)
	clear_icon_button.pressed.connect(_on_clear_icon_pressed)
	category_option.item_selected.connect(_on_category_changed)
	
	# Stack
	stack_capacity_spinbox.value_changed.connect(_on_stack_capacity_changed)
	stack_limit_spinbox.value_changed.connect(_on_stack_limit_changed)
	
	# Economy
	buy_price_spinbox.value_changed.connect(_on_buy_price_changed)
	sell_price_spinbox.value_changed.connect(_on_sell_price_changed)
	tradeable_check.toggled.connect(_on_tradeable_toggled)
	
	# Rarity
	rarity_option.item_selected.connect(_on_rarity_changed)
	required_level_spinbox.value_changed.connect(_on_required_level_changed)
	
	# Equipment
	equippable_check.toggled.connect(_on_equippable_toggled)
	equip_slot_option.item_selected.connect(_on_equip_slot_changed)
	stat_atk_spinbox.value_changed.connect(_on_stat_atk_changed)
	stat_def_spinbox.value_changed.connect(_on_stat_def_changed)
	stat_hp_spinbox.value_changed.connect(_on_stat_hp_changed)
	stat_mp_spinbox.value_changed.connect(_on_stat_mp_changed)
	stat_spd_spinbox.value_changed.connect(_on_stat_spd_changed)
	
	# Consumable
	consumable_check.toggled.connect(_on_consumable_toggled)
	effect_type_option.item_selected.connect(_on_effect_type_changed)
	effect_value_spinbox.value_changed.connect(_on_effect_value_changed)
	effect_duration_spinbox.value_changed.connect(_on_effect_duration_changed)
	
	# Quest
	quest_item_check.toggled.connect(_on_quest_item_toggled)
	quest_id_edit.text_changed.connect(_on_quest_id_changed)
	
	# Crafting
	if is_ingredient_check:
		is_ingredient_check.toggled.connect(_on_is_ingredient_toggled)
	if material_type_option:
		material_type_option.item_selected.connect(_on_material_type_changed)
	craftable_check.toggled.connect(_on_craftable_toggled)
	if add_ingredient_button:
		add_ingredient_button.pressed.connect(_on_add_ingredient_pressed)

	# Passives
	if add_passive_button:
		add_passive_button.pressed.connect(_on_add_passive_pressed)

	# Custom Fields
	if add_custom_field_button:
		add_custom_field_button.pressed.connect(_on_add_custom_field_pressed)


# === Refresh UI ===

func _refresh_item_list() -> void:
	item_list.clear()
	
	if database == null:
		return
	
	# Apply filters
	# If selected index is 0 ("All Categories"), use -1 to not filter
	var selected_index := category_filter.selected
	var category_id := -1 if selected_index == 0 else category_filter.get_item_id(selected_index)
	var search_query := search_edit.text
	
	filtered_items = database.filter_items(category_id, search_query)
	
	# Popola lista
	for item in filtered_items:
		if item == null:
			continue
		
		var display_name := item.get_translated_name()
		if display_name.is_empty() or display_name == "???":
			display_name = item.name_key if not item.name_key.is_empty() else "(No name)"
		
		var label := "[%d] %s" % [item.id, display_name]
		var idx := item_list.add_item(label, item.icon)
		
		# Colore per rarità
		item_list.set_item_custom_fg_color(idx, item.get_rarity_color())
		
		# Warning icon se ci sono problemi
		if not item.get_validation_warnings().is_empty():
			item_list.set_item_tooltip(idx, "\n".join(item.get_validation_warnings()))
	
	# Aggiorna contatore
	item_count_label.text = "%d items" % filtered_items.size()
	
	# Riseleziona item corrente se ancora visibile
	if selected_item:
		var new_idx := filtered_items.find(selected_item)
		if new_idx >= 0:
			item_list.select(new_idx)


func _update_selection_state() -> void:
	var has_selection := selected_item != null
	
	details_container.visible = has_selection
	no_selection_label.visible = not has_selection
	
	duplicate_button.disabled = not has_selection
	delete_button.disabled = not has_selection
	
	if has_selection:
		_update_details_panel()


func _update_details_panel() -> void:
	if selected_item == null:
		return
	
	is_updating_ui = true
	
	# Header
	icon_preview.texture = selected_item.icon
	item_name_label.text = selected_item.get_translated_name()
	item_id_label.text = "ID: %d" % selected_item.id
	
	# Base
	id_spinbox.value = selected_item.id
	name_key_edit.text = selected_item.name_key
	desc_key_edit.text = selected_item.description_key
	category_option.selected = selected_item.category
	
	# Stack
	stack_capacity_spinbox.value = selected_item.stack_capacity
	stack_limit_spinbox.value = selected_item.stack_count_limit
	
	# Economy
	buy_price_spinbox.value = selected_item.buy_price
	sell_price_spinbox.value = selected_item.sell_price
	tradeable_check.button_pressed = selected_item.tradeable
	
	# Rarity
	rarity_option.selected = selected_item.rarity
	required_level_spinbox.value = selected_item.required_level
	
	# Equipment
	equippable_check.button_pressed = selected_item.equippable
	equip_slot_option.selected = selected_item.equip_slot
	stats_container.visible = selected_item.equippable
	stat_atk_spinbox.value = selected_item.stat_atk
	stat_def_spinbox.value = selected_item.stat_def
	stat_hp_spinbox.value = selected_item.stat_hp
	stat_mp_spinbox.value = selected_item.stat_mp
	stat_spd_spinbox.value = selected_item.stat_spd
	
	# Consumable
	consumable_check.button_pressed = selected_item.consumable
	consumable_container.visible = selected_item.consumable
	effect_type_option.selected = selected_item.effect_type
	effect_value_spinbox.value = selected_item.effect_value
	effect_duration_spinbox.value = selected_item.effect_duration
	
	# Quest
	quest_item_check.button_pressed = selected_item.is_quest_item
	quest_id_edit.text = selected_item.quest_id
	quest_id_edit.visible = selected_item.is_quest_item
	
	# Crafting - Ingredient
	if is_ingredient_check:
		is_ingredient_check.button_pressed = selected_item.is_ingredient
	if material_type_row:
		material_type_row.visible = selected_item.is_ingredient
	if material_type_option:
		material_type_option.selected = selected_item.material_type
	
	# Crafting - Craftable
	craftable_check.button_pressed = selected_item.craftable
	ingredients_container.visible = selected_item.craftable
	if selected_item.craftable:
		_populate_ingredients_ui()

	# Passives (solo per item equipaggiabili)
	if passives_section:
		passives_section.visible = selected_item.equippable
	if selected_item.equippable:
		_populate_passives_ui()

	# Custom Fields
	_populate_custom_fields_ui()
	
	# Warnings
	_update_warnings()
	
	is_updating_ui = false


func _update_warnings() -> void:
	# Clear existing warnings
	for child in warnings_container.get_children():
		child.queue_free()
	
	if selected_item == null:
		return
	
	var warnings := selected_item.get_validation_warnings()
	
	# Add duplicate ID warning
	if database.has_duplicate_id(selected_item.id, selected_item):
		warnings.insert(0, "Duplicate ID: an item with ID %d already exists" % selected_item.id)
	
	# Add advanced ingredient validation
	if selected_item.craftable:
		warnings.append_array(selected_item.validate_ingredients_with_db(database))
	
	for warning in warnings:
		var label := Label.new()
		label.text = "⚠️ " + warning
		label.add_theme_color_override("font_color", Color.ORANGE)
		warnings_container.add_child(label)


# === Handlers Toolbar ===

func _on_add_pressed() -> void:
	var new_item := database.create_new_item()
	_save_database()
	_refresh_item_list()
	
	# Seleziona il nuovo item
	var idx := filtered_items.find(new_item)
	if idx >= 0:
		item_list.select(idx)
		_on_item_selected(idx)


func _on_duplicate_pressed() -> void:
	if selected_item == null:
		return
	
	var new_item := database.duplicate_item(selected_item)
	_save_database()
	_refresh_item_list()
	
	# Select the duplicated item
	var idx := filtered_items.find(new_item)
	if idx >= 0:
		item_list.select(idx)
		_on_item_selected(idx)


func _on_delete_pressed() -> void:
	if selected_item == null:
		return
	
	# Conferma eliminazione
	database.remove_item(selected_item)
	selected_item = null
	_save_database()
	_refresh_item_list()
	_update_selection_state()


# === Import/Export Handlers ===

func _on_import_pressed() -> void:
	# Crea popup menu per scegliere formato e modalità
	var popup := PopupMenu.new()
	popup.add_item("Import JSON (Skip existing)", 0)
	popup.add_item("Import JSON (Overwrite existing)", 1)
	popup.add_item("Import JSON (Replace all)", 2)
	popup.add_separator()
	popup.add_item("Import CSV (Skip existing)", 3)
	popup.add_item("Import CSV (Overwrite existing)", 4)
	popup.add_item("Import CSV (Replace all)", 5)
	
	popup.id_pressed.connect(_on_import_option_selected)
	add_child(popup)
	popup.popup(Rect2i(import_button.global_position + Vector2(0, import_button.size.y), Vector2i(220, 0)))


func _on_import_option_selected(id: int) -> void:
	var is_json := id < 3
	var mode: ItemDatabase.ImportMode
	
	match id % 3:
		0: mode = ItemDatabase.ImportMode.MERGE_SKIP
		1: mode = ItemDatabase.ImportMode.MERGE_OVERWRITE
		2: mode = ItemDatabase.ImportMode.REPLACE_ALL
	
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	
	if is_json:
		dialog.filters = PackedStringArray(["*.json ; JSON Files"])
		dialog.file_selected.connect(_on_import_json_file_selected.bind(mode))
	else:
		dialog.filters = PackedStringArray(["*.csv ; CSV Files"])
		dialog.file_selected.connect(_on_import_csv_file_selected.bind(mode))
	
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_import_json_file_selected(path: String, mode: ItemDatabase.ImportMode) -> void:
	var result := database.import_from_json_file(path, mode)
	_show_import_result(result)
	
	if result.imported > 0:
		_save_database()
		_refresh_item_list()


func _on_import_csv_file_selected(path: String, mode: ItemDatabase.ImportMode) -> void:
	var result := database.import_from_csv_file(path, mode)
	_show_import_result(result)
	
	if result.imported > 0:
		_save_database()
		_refresh_item_list()


func _show_import_result(result: Dictionary) -> void:
	var message := "Import completed:\n"
	message += "- Imported: %d items\n" % result.imported
	message += "- Skipped: %d items\n" % result.skipped
	
	if not result.errors.is_empty():
		message += "\nErrors:\n"
		for error in result.errors.slice(0, 5):  # Max 5 errori mostrati
			message += "- %s\n" % error
		if result.errors.size() > 5:
			message += "... and %d more errors\n" % (result.errors.size() - 5)
	
	var dialog := AcceptDialog.new()
	dialog.title = "Import Result"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()


func _on_export_pressed() -> void:
	# Crea popup menu per scegliere formato
	var popup := PopupMenu.new()
	popup.add_item("Export to JSON", 0)
	popup.add_item("Export to CSV", 1)
	
	popup.id_pressed.connect(_on_export_option_selected)
	add_child(popup)
	popup.popup(Rect2i(export_button.global_position + Vector2(0, export_button.size.y), Vector2i(150, 0)))


func _on_export_option_selected(id: int) -> void:
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	
	if id == 0:
		dialog.filters = PackedStringArray(["*.json ; JSON Files"])
		dialog.current_file = "items_export.json"
		dialog.file_selected.connect(_on_export_json_file_selected)
	else:
		dialog.filters = PackedStringArray(["*.csv ; CSV Files"])
		dialog.current_file = "items_export.csv"
		dialog.file_selected.connect(_on_export_csv_file_selected)
	
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_export_json_file_selected(path: String) -> void:
	var error := database.export_to_json_file(path)
	if error == OK:
		var dialog := AcceptDialog.new()
		dialog.title = "Export Successful"
		dialog.dialog_text = "Database exported to:\n%s\n\n%d items exported." % [path, database.items.size()]
		add_child(dialog)
		dialog.popup_centered()
	else:
		push_error("[InventoryForge] Export failed: %s" % error_string(error))


func _on_export_csv_file_selected(path: String) -> void:
	var error := database.export_to_csv_file(path)
	if error == OK:
		var dialog := AcceptDialog.new()
		dialog.title = "Export Successful"
		dialog.dialog_text = "Database exported to:\n%s\n\n%d items exported." % [path, database.items.size()]
		add_child(dialog)
		dialog.popup_centered()
	else:
		push_error("[InventoryForge] Export failed: %s" % error_string(error))


# === Handlers Filtri ===

func _on_search_changed(_text: String) -> void:
	_refresh_item_list()


func _on_category_filter_changed(_index: int) -> void:
	_refresh_item_list()


# === Handlers Lista ===

func _on_item_selected(index: int) -> void:
	if index < 0 or index >= filtered_items.size():
		selected_item = null
	else:
		selected_item = filtered_items[index]
	
	_update_selection_state()


# === Handlers Dettagli ===

func _mark_modified(refresh_list: bool = true) -> void:
	if is_updating_ui:
		return
	
	_save_database()
	if refresh_list:
		_refresh_item_list()
	_update_warnings()


func _on_id_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.id = int(value)
		item_id_label.text = "ID: %d" % selected_item.id
		_mark_modified()


func _on_name_key_changed(text: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.name_key = text
		item_name_label.text = selected_item.get_translated_name()
		_mark_modified(false)  # Non refresh lista per ogni carattere


func _on_generate_name_key_pressed() -> void:
	if selected_item:
		var base_name := name_key_edit.text
		if base_name.is_empty():
			base_name = "item_%d" % selected_item.id
		selected_item.generate_translation_keys(base_name)
		_update_details_panel()
		_mark_modified()


func _on_desc_key_changed(text: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.description_key = text
		_mark_modified(false)  # Non refresh lista per ogni carattere


func _on_generate_desc_key_pressed() -> void:
	_on_generate_name_key_pressed()  # Genera entrambe le chiavi


func _on_icon_picker_pressed() -> void:
	# Usa IconPickerDialog per selezionare icone dalle cartelle standard
	var icon_dialog := IconPickerDialog.new()
	icon_dialog.icon_selected.connect(_on_icon_selected_from_picker)
	icon_dialog.browse_requested.connect(_open_file_dialog_for_icon)
	
	add_child(icon_dialog)
	icon_dialog.popup_centered()


func _on_icon_selected_from_picker(texture: Texture2D, path: String) -> void:
	if selected_item:
		selected_item.icon = texture
		icon_preview.texture = texture
		_mark_modified()


func _open_file_dialog_for_icon() -> void:
	# Fallback al file dialog standard
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.filters = PackedStringArray(["*.png, *.jpg, *.svg ; Images"])
	dialog.file_selected.connect(_on_icon_selected)
	
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_icon_selected(path: String) -> void:
	if selected_item:
		selected_item.icon = load(path)
		icon_preview.texture = selected_item.icon
		_mark_modified()


func _on_clear_icon_pressed() -> void:
	if selected_item:
		selected_item.icon = null
		icon_preview.texture = null
		_mark_modified()


func _on_category_changed(index: int) -> void:
	if selected_item and not is_updating_ui:
		selected_item.category = index as ItemEnums.Category
		_mark_modified()


func _on_stack_capacity_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stack_capacity = int(value)
		_mark_modified()


func _on_stack_limit_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stack_count_limit = int(value)
		_mark_modified()


func _on_buy_price_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.buy_price = int(value)
		_mark_modified()


func _on_sell_price_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.sell_price = int(value)
		_mark_modified()


func _on_tradeable_toggled(pressed: bool) -> void:
	if selected_item and not is_updating_ui:
		selected_item.tradeable = pressed
		_mark_modified()


func _on_rarity_changed(index: int) -> void:
	if selected_item and not is_updating_ui:
		selected_item.rarity = index as ItemEnums.Rarity
		_mark_modified()


func _on_required_level_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.required_level = int(value)
		_mark_modified()


func _on_equippable_toggled(pressed: bool) -> void:
	if selected_item and not is_updating_ui:
		selected_item.equippable = pressed
		stats_container.visible = pressed
		_mark_modified()


func _on_equip_slot_changed(index: int) -> void:
	if selected_item and not is_updating_ui:
		selected_item.equip_slot = index as ItemEnums.EquipSlot
		_mark_modified()


func _on_stat_atk_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stat_atk = int(value)
		_mark_modified()


func _on_stat_def_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stat_def = int(value)
		_mark_modified()


func _on_stat_hp_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stat_hp = int(value)
		_mark_modified()


func _on_stat_mp_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stat_mp = int(value)
		_mark_modified()


func _on_stat_spd_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.stat_spd = int(value)
		_mark_modified()


func _on_consumable_toggled(pressed: bool) -> void:
	if selected_item and not is_updating_ui:
		selected_item.consumable = pressed
		consumable_container.visible = pressed
		_mark_modified()


func _on_effect_type_changed(index: int) -> void:
	if selected_item and not is_updating_ui:
		selected_item.effect_type = index as ItemEnums.EffectType
		_mark_modified()


func _on_effect_value_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.effect_value = int(value)
		_mark_modified()


func _on_effect_duration_changed(value: float) -> void:
	if selected_item and not is_updating_ui:
		selected_item.effect_duration = value
		_mark_modified()


func _on_quest_item_toggled(pressed: bool) -> void:
	if selected_item and not is_updating_ui:
		selected_item.is_quest_item = pressed
		quest_id_edit.visible = pressed
		_mark_modified()


func _on_quest_id_changed(text: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.quest_id = text
		_mark_modified()


func _on_craftable_toggled(pressed: bool) -> void:
	if selected_item and not is_updating_ui:
		selected_item.craftable = pressed
		ingredients_container.visible = pressed
		if pressed:
			_populate_ingredients_ui()
		_mark_modified()


# === Crafting Ingredients Management ===

func _populate_ingredients_ui() -> void:
	if selected_item == null or ingredients_list_vbox == null:
		return
	
	# Pulisci la lista corrente
	for child in ingredients_list_vbox.get_children():
		child.queue_free()
	
	# Se non ci sono ingredienti, mostra messaggio vuoto
	if selected_item.ingredients.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No ingredients yet. Click + Add to start"
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		ingredients_list_vbox.add_child(empty_label)
		return
	
	# Crea una riga per ogni ingrediente
	for i in range(selected_item.ingredients.size()):
		var ingredient_data: Dictionary = selected_item.ingredients[i]
		var row := _create_ingredient_row(ingredient_data, i)
		ingredients_list_vbox.add_child(row)


func _create_ingredient_row(ingredient_data: Dictionary, row_index: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)
	
	# === Item Selection (OptionButton) ===
	var item_option := OptionButton.new()
	item_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_option.custom_minimum_size = Vector2(200, 0)
	
	# Popola con solo item che hanno is_ingredient = true
	var available_ingredients := database.get_ingredients() if database else []
	
	if available_ingredients.is_empty():
		item_option.add_item("(No ingredients available)", -1)
		item_option.disabled = true
	else:
		item_option.add_item("(Select ingredient...)", -1)
		
		var selected_idx := 0
		for i in range(available_ingredients.size()):
			var item := available_ingredients[i]
			if item == null:
				continue
			
			var display_name := item.get_translated_name()
			if display_name.is_empty() or display_name == "???":
				display_name = item.name_key if not item.name_key.is_empty() else "(No name)"
			
			# Formato: [ID] Nome (MATERIAL_TYPE) [📝 Craftable]
			var mat_type: String = ItemEnums.MaterialType.keys()[item.material_type]
			var label := "[%d] %s (%s)" % [item.id, display_name, mat_type]
			
			# Visual cue se l'ingrediente è anche craftabile (crafting ricorsivo)
			if item.craftable:
				label += " [📝 Craftable]"
			
			item_option.add_item(label, item.id)
			
			# Se questo è l'item selezionato, ricorda l'indice
			if item.id == ingredient_data.get("item_id", -1):
				selected_idx = item_option.item_count - 1
		
		item_option.selected = selected_idx
	
	item_option.item_selected.connect(_on_ingredient_item_changed.bind(row_index))
	row.add_child(item_option)
	
	# === Amount Label ===
	var amount_label := Label.new()
	amount_label.text = "×"
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(amount_label)
	
	# === Amount SpinBox ===
	var amount_spinbox := SpinBox.new()
	amount_spinbox.min_value = 1
	amount_spinbox.max_value = 999
	amount_spinbox.value = ingredient_data.get("amount", 1)
	amount_spinbox.custom_minimum_size = Vector2(80, 0)
	amount_spinbox.value_changed.connect(_on_ingredient_amount_changed.bind(row_index))
	row.add_child(amount_spinbox)
	
	# === Up Button ===
	var up_button := Button.new()
	up_button.text = "↑"
	up_button.custom_minimum_size = Vector2(32, 0)
	up_button.tooltip_text = "Move up"
	up_button.disabled = (row_index == 0)  # Disabilita se è il primo
	up_button.pressed.connect(_move_ingredient_up.bind(row_index))
	row.add_child(up_button)
	
	# === Down Button ===
	var down_button := Button.new()
	down_button.text = "↓"
	down_button.custom_minimum_size = Vector2(32, 0)
	down_button.tooltip_text = "Move down"
	down_button.disabled = (row_index == selected_item.ingredients.size() - 1)  # Disabilita se è l'ultimo
	down_button.pressed.connect(_move_ingredient_down.bind(row_index))
	row.add_child(down_button)
	
	# === Remove Button ===
	var remove_button := Button.new()
	remove_button.text = "X"
	remove_button.custom_minimum_size = Vector2(32, 0)
	remove_button.tooltip_text = "Remove ingredient"
	remove_button.pressed.connect(_on_remove_ingredient_pressed.bind(row_index))
	row.add_child(remove_button)
	
	return row


func _on_add_ingredient_pressed() -> void:
	if selected_item == null:
		return
	
	# Controlla il limite massimo
	if selected_item.ingredients.size() >= MAX_INGREDIENTS:
		push_warning("[InventoryForge] Maximum %d ingredients per recipe" % MAX_INGREDIENTS)
		return
	
	# Aggiungi nuovo ingrediente con valori default
	selected_item.ingredients.append({"item_id": -1, "amount": 1})
	_populate_ingredients_ui()
	_mark_modified()


func _on_remove_ingredient_pressed(row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.ingredients.size():
		return
	
	selected_item.ingredients.remove_at(row_index)
	_populate_ingredients_ui()
	_mark_modified()


func _on_ingredient_item_changed(item_index: int, row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.ingredients.size():
		return
	
	if is_updating_ui:
		return
	
	# Ottieni l'ID dell'item selezionato dall'OptionButton
	# item_index è l'indice selezionato, dobbiamo recuperare l'ID associato
	# Per farlo, dobbiamo accedere al nodo... ma qui abbiamo solo l'indice
	# Soluzione: prendiamo l'ID dalla lista filtrata del database
	
	# Trova il nodo OptionButton dalla lista
	if row_index >= ingredients_list_vbox.get_child_count():
		return
	
	var row := ingredients_list_vbox.get_child(row_index) as HBoxContainer
	if row == null or row.get_child_count() == 0:
		return
	
	var option_button := row.get_child(0) as OptionButton
	if option_button == null:
		return
	
	var selected_id := option_button.get_item_id(option_button.selected)
	selected_item.ingredients[row_index]["item_id"] = selected_id
	_mark_modified()


func _on_ingredient_amount_changed(value: float, row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.ingredients.size():
		return
	
	if is_updating_ui:
		return
	
	selected_item.ingredients[row_index]["amount"] = int(value)
	_mark_modified()


func _move_ingredient_up(row_index: int) -> void:
	if selected_item == null or row_index <= 0 or row_index >= selected_item.ingredients.size():
		return
	
	# Scambia con l'elemento precedente
	var temp = selected_item.ingredients[row_index]
	selected_item.ingredients[row_index] = selected_item.ingredients[row_index - 1]
	selected_item.ingredients[row_index - 1] = temp
	
	_populate_ingredients_ui()
	_mark_modified()


func _move_ingredient_down(row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.ingredients.size() - 1:
		return
	
	# Scambia con l'elemento successivo
	var temp = selected_item.ingredients[row_index]
	selected_item.ingredients[row_index] = selected_item.ingredients[row_index + 1]
	selected_item.ingredients[row_index + 1] = temp
	
	_populate_ingredients_ui()
	_mark_modified()


func _on_is_ingredient_toggled(pressed: bool) -> void:
	if selected_item and not is_updating_ui:
		selected_item.is_ingredient = pressed
		if material_type_row:
			material_type_row.visible = pressed
		if not pressed:
			selected_item.material_type = ItemEnums.MaterialType.NONE
		_mark_modified()


func _on_material_type_changed(index: int) -> void:
	if selected_item and not is_updating_ui:
		selected_item.material_type = index as ItemEnums.MaterialType
		_mark_modified()


# === Passives Management ===

const MAX_PASSIVES := 5  # Limite massimo passives per item

func _populate_passives_ui() -> void:
	if selected_item == null or passives_list_vbox == null:
		return

	# Pulisci la lista corrente
	for child in passives_list_vbox.get_children():
		child.queue_free()

	# Se non ci sono passives, mostra messaggio vuoto
	if selected_item.passives.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No passives. Click + Add Passive to add one."
		empty_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
		empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		passives_list_vbox.add_child(empty_label)
		return

	# Crea una riga per ogni passive
	for i in range(selected_item.passives.size()):
		var passive: PassiveEntry = selected_item.passives[i]
		if passive == null:
			continue
		var row := _create_passive_row(passive, i)
		passives_list_vbox.add_child(row)


func _create_passive_row(passive: PassiveEntry, row_index: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 4)

	# === Passive Type (OptionButton) ===
	var type_option := OptionButton.new()
	type_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_option.custom_minimum_size = Vector2(180, 0)

	# Popola con tutti i tipi di passive
	for pt in ItemEnums.PassiveType.values():
		var display_name := ItemEnums.get_passive_display_name(pt)
		type_option.add_item(display_name, pt)
		if pt == passive.passive_type:
			type_option.selected = type_option.item_count - 1

	type_option.item_selected.connect(_on_passive_type_changed.bind(row_index))
	row.add_child(type_option)

	# === Value Label ===
	var value_label := Label.new()
	value_label.text = "Value:"
	value_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(value_label)

	# === Value SpinBox ===
	var value_spinbox := SpinBox.new()
	value_spinbox.min_value = -999
	value_spinbox.max_value = 999
	value_spinbox.value = passive.value
	value_spinbox.custom_minimum_size = Vector2(80, 0)
	value_spinbox.value_changed.connect(_on_passive_value_changed.bind(row_index))
	row.add_child(value_spinbox)

	# === Chance Label ===
	var chance_label := Label.new()
	chance_label.text = "%"
	chance_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	row.add_child(chance_label)

	# === Chance SpinBox ===
	var chance_spinbox := SpinBox.new()
	chance_spinbox.min_value = 0
	chance_spinbox.max_value = 100
	chance_spinbox.value = passive.trigger_chance
	chance_spinbox.custom_minimum_size = Vector2(70, 0)
	chance_spinbox.suffix = "%"
	chance_spinbox.value_changed.connect(_on_passive_chance_changed.bind(row_index))
	row.add_child(chance_spinbox)

	# === Remove Button ===
	var remove_button := Button.new()
	remove_button.text = "X"
	remove_button.custom_minimum_size = Vector2(32, 0)
	remove_button.tooltip_text = "Remove passive"
	remove_button.pressed.connect(_on_remove_passive_pressed.bind(row_index))
	row.add_child(remove_button)

	return row


func _on_add_passive_pressed() -> void:
	if selected_item == null:
		return

	# Controlla il limite massimo
	if selected_item.passives.size() >= MAX_PASSIVES:
		push_warning("[InventoryForge] Maximum %d passives per item" % MAX_PASSIVES)
		return

	# Aggiungi nuova passive con valori default
	var new_passive := PassiveEntry.new()
	new_passive.passive_type = ItemEnums.PassiveType.NONE
	new_passive.value = 0
	new_passive.trigger_chance = 100.0
	selected_item.passives.append(new_passive)
	_populate_passives_ui()
	_mark_modified()


func _on_remove_passive_pressed(row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.passives.size():
		return

	selected_item.passives.remove_at(row_index)
	_populate_passives_ui()
	_mark_modified()


func _on_passive_type_changed(item_index: int, row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.passives.size():
		return

	if is_updating_ui:
		return

	var passive: PassiveEntry = selected_item.passives[row_index]
	if passive:
		passive.passive_type = item_index as ItemEnums.PassiveType
		_mark_modified()


func _on_passive_value_changed(value: float, row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.passives.size():
		return

	if is_updating_ui:
		return

	var passive: PassiveEntry = selected_item.passives[row_index]
	if passive:
		passive.value = int(value)
		_mark_modified()


func _on_passive_chance_changed(value: float, row_index: int) -> void:
	if selected_item == null or row_index < 0 or row_index >= selected_item.passives.size():
		return

	if is_updating_ui:
		return

	var passive: PassiveEntry = selected_item.passives[row_index]
	if passive:
		passive.trigger_chance = value
		_mark_modified()


# === Custom Fields ===

func _populate_custom_fields_ui() -> void:
	if custom_fields_container == null or selected_item == null:
		return
	
	# Pulisci container
	for child in custom_fields_container.get_children():
		child.queue_free()
	
	# Crea UI per ogni custom field
	var keys := selected_item.get_custom_keys()
	for key in keys:
		var value = selected_item.get_custom(key)
		var field_ui := _create_custom_field_ui(key, value)
		custom_fields_container.add_child(field_ui)


func _create_custom_field_ui(key: String, value: Variant) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	
	# Key edit
	var key_edit := LineEdit.new()
	key_edit.text = key
	key_edit.placeholder_text = "field_name"
	key_edit.custom_minimum_size = Vector2(120, 0)
	key_edit.text_changed.connect(_on_custom_field_key_changed.bind(key))
	row.add_child(key_edit)
	
	# Type selector
	var type_option := OptionButton.new()
	type_option.add_item("String", 0)
	type_option.add_item("Int", 1)
	type_option.add_item("Float", 2)
	type_option.add_item("Bool", 3)
	type_option.custom_minimum_size = Vector2(70, 0)
	
	# Determina tipo corrente
	var current_type := 0
	if value is int:
		current_type = 1
	elif value is float:
		current_type = 2
	elif value is bool:
		current_type = 3
	type_option.selected = current_type
	type_option.item_selected.connect(_on_custom_field_type_changed.bind(key))
	row.add_child(type_option)
	
	# Value editor (diverso per tipo)
	var value_control: Control
	
	match current_type:
		1:  # Int
			var spin := SpinBox.new()
			spin.min_value = -999999
			spin.max_value = 999999
			spin.value = value if value is int else 0
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.value_changed.connect(_on_custom_field_int_changed.bind(key))
			value_control = spin
		2:  # Float
			var spin := SpinBox.new()
			spin.min_value = -999999.0
			spin.max_value = 999999.0
			spin.step = 0.01
			spin.value = value if value is float else 0.0
			spin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			spin.value_changed.connect(_on_custom_field_float_changed.bind(key))
			value_control = spin
		3:  # Bool
			var check := CheckBox.new()
			check.button_pressed = value if value is bool else false
			check.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			check.toggled.connect(_on_custom_field_bool_changed.bind(key))
			value_control = check
		_:  # String (default)
			var edit := LineEdit.new()
			edit.text = str(value) if value != null else ""
			edit.placeholder_text = "value"
			edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			edit.text_changed.connect(_on_custom_field_string_changed.bind(key))
			value_control = edit
	
	row.add_child(value_control)
	
	# Delete button
	var delete_btn := Button.new()
	delete_btn.text = "X"
	delete_btn.tooltip_text = "Remove field"
	delete_btn.custom_minimum_size = Vector2(28, 0)
	delete_btn.pressed.connect(_on_remove_custom_field_pressed.bind(key))
	row.add_child(delete_btn)
	
	return row


func _on_add_custom_field_pressed() -> void:
	if selected_item == null:
		return
	
	# Genera nome unico
	var base_name := "custom_field"
	var counter := 1
	var new_key := base_name
	
	while selected_item.has_custom(new_key):
		new_key = "%s_%d" % [base_name, counter]
		counter += 1
	
	selected_item.set_custom(new_key, "")
	_save_database()
	_populate_custom_fields_ui()


func _on_remove_custom_field_pressed(key: String) -> void:
	if selected_item == null:
		return
	
	selected_item.remove_custom(key)
	_save_database()
	_populate_custom_fields_ui()


func _on_custom_field_key_changed(new_key: String, old_key: String) -> void:
	if selected_item == null or is_updating_ui:
		return
	
	if new_key.is_empty() or new_key == old_key:
		return
	
	# Verifica che la nuova chiave non esista già
	if selected_item.has_custom(new_key):
		return
	
	# Rinomina la chiave
	var value = selected_item.get_custom(old_key)
	selected_item.remove_custom(old_key)
	selected_item.set_custom(new_key, value)
	_save_database()
	_populate_custom_fields_ui()


func _on_custom_field_type_changed(type_index: int, key: String) -> void:
	if selected_item == null or is_updating_ui:
		return
	
	var old_value = selected_item.get_custom(key)
	var new_value: Variant
	
	match type_index:
		0:  # String
			new_value = str(old_value) if old_value != null else ""
		1:  # Int
			if old_value is int:
				new_value = old_value
			elif old_value is float:
				new_value = int(old_value)
			elif old_value is String and old_value.is_valid_int():
				new_value = int(old_value)
			elif old_value is bool:
				new_value = 1 if old_value else 0
			else:
				new_value = 0
		2:  # Float
			if old_value is float:
				new_value = old_value
			elif old_value is int:
				new_value = float(old_value)
			elif old_value is String and old_value.is_valid_float():
				new_value = float(old_value)
			elif old_value is bool:
				new_value = 1.0 if old_value else 0.0
			else:
				new_value = 0.0
		3:  # Bool
			if old_value is bool:
				new_value = old_value
			elif old_value is int:
				new_value = old_value != 0
			elif old_value is float:
				new_value = old_value != 0.0
			elif old_value is String:
				new_value = old_value.to_lower() in ["true", "1", "yes", "on"]
			else:
				new_value = false
	
	selected_item.set_custom(key, new_value)
	_save_database()
	_populate_custom_fields_ui()


func _on_custom_field_string_changed(value: String, key: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.set_custom(key, value)
		_save_database()


func _on_custom_field_int_changed(value: float, key: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.set_custom(key, int(value))
		_save_database()


func _on_custom_field_float_changed(value: float, key: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.set_custom(key, value)
		_save_database()


func _on_custom_field_bool_changed(pressed: bool, key: String) -> void:
	if selected_item and not is_updating_ui:
		selected_item.set_custom(key, pressed)
		_save_database()


# === Statistics Dashboard ===

func _setup_statistics_tab() -> void:
	if stats_vbox == null:
		return
	
	# Connetti segnale cambio tab per aggiornare statistiche
	if main_tab_container:
		main_tab_container.tab_changed.connect(_on_tab_changed)


func _on_tab_changed(tab_index: int) -> void:
	# Se siamo sulla tab Statistics (index 2), aggiorna
	if tab_index == 2:
		_update_statistics()


func _update_statistics() -> void:
	if stats_vbox == null or database == null:
		return
	
	# Pulisci contenuto esistente
	for child in stats_vbox.get_children():
		child.queue_free()
	
	# Attendi un frame per assicurarsi che i nodi siano stati rimossi
	await get_tree().process_frame
	
	var stats := database.get_stats()
	
	# === Header con Refresh ===
	var header := HBoxContainer.new()
	var title := Label.new()
	title.text = "DATABASE STATISTICS"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.6, 0.8, 1, 1))
	header.add_child(title)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(spacer)
	
	var refresh_btn := Button.new()
	refresh_btn.text = "Refresh"
	refresh_btn.pressed.connect(_update_statistics)
	header.add_child(refresh_btn)
	
	stats_vbox.add_child(header)
	
	# === Separator ===
	var sep := HSeparator.new()
	stats_vbox.add_child(sep)
	
	# === Overview Cards ===
	var overview_container := HBoxContainer.new()
	overview_container.add_theme_constant_override("separation", 20)
	
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("Total Items", str(stats.total_items), Color.WHITE))
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("Ingredients", str(stats.ingredients_count), Color.CORNFLOWER_BLUE))
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("Craftable", str(stats.craftable_count), Color.MEDIUM_SEA_GREEN))
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("With Warnings", str(stats.items_with_warnings), Color.ORANGE if stats.items_with_warnings > 0 else Color.GRAY))
	
	stats_vbox.add_child(overview_container)
	
	# === Two Columns Layout ===
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 40)
	
	# Left Column
	var left_col := VBoxContainer.new()
	left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_col.add_theme_constant_override("separation", 20)
	
	# === Category Distribution ===
	left_col.add_child(StatisticsUIBuilder.create_section_title("BY CATEGORY"))
	left_col.add_child(StatisticsUIBuilder.create_category_chart(stats.category_counts, stats.total_items))
	
	columns.add_child(left_col)
	
	# Right Column
	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 20)
	
	# === Rarity Distribution ===
	right_col.add_child(StatisticsUIBuilder.create_section_title("BY RARITY"))
	right_col.add_child(StatisticsUIBuilder.create_rarity_chart(stats.rarity_counts, stats.total_items))
	
	columns.add_child(right_col)
	
	stats_vbox.add_child(columns)
	
	# === Material Types (if any ingredients) ===
	if stats.ingredients_count > 0:
		stats_vbox.add_child(StatisticsUIBuilder.create_section_title("MATERIAL TYPES"))
		stats_vbox.add_child(StatisticsUIBuilder.create_material_type_chart(stats.material_type_counts, stats.ingredients_count))
	
	# === Issues Section ===
	if stats.items_with_warnings > 0 or stats.duplicate_ids > 0:
		stats_vbox.add_child(StatisticsUIBuilder.create_section_title("ITEM ISSUES"))
		var issues_container := VBoxContainer.new()
		
		if stats.duplicate_ids > 0:
			var dup_label := Label.new()
			dup_label.text = "  Duplicate IDs: %d" % stats.duplicate_ids
			dup_label.add_theme_color_override("font_color", Color.INDIAN_RED)
			issues_container.add_child(dup_label)
		
		if stats.items_with_warnings > 0:
			var warn_label := Label.new()
			warn_label.text = "  Items with warnings: %d" % stats.items_with_warnings
			warn_label.add_theme_color_override("font_color", Color.ORANGE)
			issues_container.add_child(warn_label)
		
		stats_vbox.add_child(issues_container)
	
	# === LOOT TABLES SECTION ===
	_add_loot_table_statistics(stats_vbox)


func _add_loot_table_statistics(container: VBoxContainer) -> void:
	if loot_database == null:
		return
	
	var loot_stats := loot_database.get_stats()
	
	# === Separator ===
	var sep := HSeparator.new()
	sep.add_theme_constant_override("separation", 20)
	container.add_child(sep)
	
	# === Loot Tables Header ===
	var loot_header := Label.new()
	loot_header.text = "LOOT TABLES STATISTICS"
	loot_header.add_theme_font_size_override("font_size", 24)
	loot_header.add_theme_color_override("font_color", Color(0.6, 0.8, 1, 1))
	container.add_child(loot_header)
	
	# === Separator ===
	var sep2 := HSeparator.new()
	container.add_child(sep2)
	
	# === Overview Cards ===
	var overview_container := HBoxContainer.new()
	overview_container.add_theme_constant_override("separation", 20)
	
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("Total Tables", str(loot_stats.total_tables), Color.WHITE))
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("Total Entries", str(loot_stats.total_entries), Color.CORNFLOWER_BLUE))
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("Avg Entries", "%.1f" % loot_stats.avg_entries_per_table, Color.MEDIUM_SEA_GREEN))
	overview_container.add_child(StatisticsUIBuilder.create_stat_card("With Sub-Tables", str(loot_stats.tables_with_sub_tables), Color.MEDIUM_PURPLE))
	
	container.add_child(overview_container)
	
	# === Two Columns Layout ===
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 40)
	
	# Left Column - Rarity Tier Distribution
	var left_col := VBoxContainer.new()
	left_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_col.add_theme_constant_override("separation", 20)
	
	left_col.add_child(StatisticsUIBuilder.create_section_title("BY RARITY TIER"))
	left_col.add_child(StatisticsUIBuilder.create_rarity_tier_chart(loot_stats.rarity_tier_counts, loot_stats.total_tables))
	
	columns.add_child(left_col)
	
	# Right Column - Issues
	var right_col := VBoxContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.add_theme_constant_override("separation", 20)
	
	# Loot Table Issues
	if loot_stats.tables_with_warnings > 0 or loot_stats.duplicate_ids > 0 or loot_stats.empty_tables > 0:
		right_col.add_child(StatisticsUIBuilder.create_section_title("LOOT TABLE ISSUES"))
		var issues_container := VBoxContainer.new()
		issues_container.add_theme_constant_override("separation", 4)
		
		if loot_stats.duplicate_ids > 0:
			var dup_label := Label.new()
			dup_label.text = "  Duplicate IDs: %d" % loot_stats.duplicate_ids
			dup_label.add_theme_color_override("font_color", Color.INDIAN_RED)
			issues_container.add_child(dup_label)
		
		if loot_stats.empty_tables > 0:
			var empty_label := Label.new()
			empty_label.text = "  Empty tables (no entries): %d" % loot_stats.empty_tables
			empty_label.add_theme_color_override("font_color", Color.ORANGE)
			issues_container.add_child(empty_label)
		
		if loot_stats.tables_with_warnings > 0:
			var warn_label := Label.new()
			warn_label.text = "  Tables with warnings: %d" % loot_stats.tables_with_warnings
			warn_label.add_theme_color_override("font_color", Color.ORANGE)
			issues_container.add_child(warn_label)
		
		right_col.add_child(issues_container)
	else:
		right_col.add_child(StatisticsUIBuilder.create_section_title("STATUS"))
		var ok_label := Label.new()
		ok_label.text = "  All loot tables are valid"
		ok_label.add_theme_color_override("font_color", Color.MEDIUM_SEA_GREEN)
		right_col.add_child(ok_label)
	
	columns.add_child(right_col)
	container.add_child(columns)


# === Loot Tables Tab ===

func _get_loot_database_path() -> String:
	return Settings.get_loot_database_path()


func _load_loot_database() -> void:
	var db_path := _get_loot_database_path()
	
	if ResourceLoader.exists(db_path):
		loot_database = load(db_path) as LootTableDatabase
	
	if loot_database == null:
		loot_database = LootTableDatabase.new()
		_save_loot_database()


func _save_loot_database() -> void:
	if loot_database == null:
		push_error("[InventoryForge] Cannot save: loot database is null!")
		return
	
	var db_path := _get_loot_database_path()
	var error := ResourceSaver.save(loot_database, db_path)
	if error != OK:
		push_error("[InventoryForge] Failed to save loot database: %s" % error_string(error))


func _setup_loot_tables_tab() -> void:
	if add_loot_table_button == null:
		return
	
	# Connetti segnali dei controlli loot tables
	add_loot_table_button.pressed.connect(_on_add_loot_table_pressed)
	duplicate_loot_table_button.pressed.connect(_on_duplicate_loot_table_pressed)
	delete_loot_table_button.pressed.connect(_on_delete_loot_table_pressed)
	loot_search_edit.text_changed.connect(_on_loot_search_changed)
	loot_table_list.item_selected.connect(_on_loot_table_selected)
	
	# Details
	loot_id_edit.text_changed.connect(_on_loot_id_changed)
	loot_name_edit.text_changed.connect(_on_loot_name_changed)
	loot_desc_edit.text_changed.connect(_on_loot_desc_changed)
	min_drops_spinbox.value_changed.connect(_on_min_drops_changed)
	max_drops_spinbox.value_changed.connect(_on_max_drops_changed)
	empty_chance_spinbox.value_changed.connect(_on_empty_chance_changed)
	allow_duplicates_check.toggled.connect(_on_allow_duplicates_toggled)
	add_entry_button.pressed.connect(_on_add_entry_pressed)
	test_roll_button.pressed.connect(_on_test_roll_pressed)
	
	# Rarity Preset
	if rarity_tier_option:
		rarity_tier_option.item_selected.connect(_on_rarity_tier_changed)
	
	# Sub-Tables
	if add_sub_table_button:
		add_sub_table_button.pressed.connect(_on_add_sub_table_pressed)
	
	# Import/Export
	if import_loot_button:
		import_loot_button.pressed.connect(_on_import_loot_pressed)
	if export_loot_button:
		export_loot_button.pressed.connect(_on_export_loot_pressed)


func _refresh_loot_table_list() -> void:
	if loot_table_list == null or loot_database == null:
		return
	
	loot_table_list.clear()
	
	var search_query := loot_search_edit.text.strip_edges() if loot_search_edit else ""
	filtered_loot_tables = loot_database.search_tables(search_query)
	
	for table in filtered_loot_tables:
		if table == null:
			continue
		
		var display_text := "[%s] %s" % [table.id, table.name if not table.name.is_empty() else "(unnamed)"]
		loot_table_list.add_item(display_text)
	
	# Aggiorna contatore
	if loot_table_count_label:
		loot_table_count_label.text = "%d tables" % loot_database.tables.size()
	
	# Riseleziona se possibile
	if selected_loot_table:
		var idx := filtered_loot_tables.find(selected_loot_table)
		if idx >= 0:
			loot_table_list.select(idx)


func _update_loot_selection_state() -> void:
	if loot_no_selection_label == null:
		return
	
	var has_selection := selected_loot_table != null
	
	loot_no_selection_label.visible = not has_selection
	if loot_details_scroll:
		loot_details_scroll.visible = has_selection
	
	if duplicate_loot_table_button:
		duplicate_loot_table_button.disabled = not has_selection
	if delete_loot_table_button:
		delete_loot_table_button.disabled = not has_selection
	
	if has_selection:
		_update_loot_details_panel()


func _update_loot_details_panel() -> void:
	if selected_loot_table == null:
		return
	
	is_updating_ui = true
	
	# Header
	if loot_table_name_label:
		var display_name := selected_loot_table.name if not selected_loot_table.name.is_empty() else selected_loot_table.id
		loot_table_name_label.text = display_name
	
	# Basic info
	if loot_id_edit:
		loot_id_edit.text = selected_loot_table.id
	if loot_name_edit:
		loot_name_edit.text = selected_loot_table.name
	if loot_desc_edit:
		loot_desc_edit.text = selected_loot_table.description
	
	# Rarity Preset
	if rarity_tier_option:
		rarity_tier_option.selected = selected_loot_table.rarity_tier
		_update_rarity_desc_label()
	
	# Settings
	if min_drops_spinbox:
		min_drops_spinbox.value = selected_loot_table.min_drops
	if max_drops_spinbox:
		max_drops_spinbox.value = selected_loot_table.max_drops
	if empty_chance_spinbox:
		empty_chance_spinbox.value = selected_loot_table.empty_chance * 100.0
	if allow_duplicates_check:
		allow_duplicates_check.button_pressed = selected_loot_table.allow_duplicates
	
	# Entries
	_populate_loot_entries_ui()
	
	# Sub-Tables
	_populate_sub_tables_ui()
	
	# Reset test result
	if test_result_label:
		test_result_label.text = "[i]Click 'Roll!' to test the loot table[/i]"
	
	is_updating_ui = false


func _populate_loot_entries_ui() -> void:
	if loot_entries_container == null or selected_loot_table == null:
		return
	
	# Pulisci container
	for child in loot_entries_container.get_children():
		child.queue_free()
	
	# Crea UI per ogni entry
	for i in range(selected_loot_table.entries.size()):
		var entry := selected_loot_table.entries[i]
		if entry == null:
			continue
		
		var entry_ui := _create_loot_entry_ui(entry, i)
		loot_entries_container.add_child(entry_ui)


func _create_loot_entry_ui(entry: LootEntry, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	
	# Row 1: Item selector + Delete
	var row1 := HBoxContainer.new()
	row1.add_theme_constant_override("separation", 8)
	
	var item_option := OptionButton.new()
	item_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_option.add_item("-- Select Item --", -1)
	
	# Popola con items dal database
	if database:
		for item in database.items:
			if item:
				var item_name := item.get_translated_name()
				item_option.add_item("[%d] %s" % [item.id, item_name], item.id)
	
	# Seleziona l'item corrente
	if entry.item:
		for j in range(item_option.item_count):
			if item_option.get_item_id(j) == entry.item.id:
				item_option.select(j)
				break
	
	item_option.item_selected.connect(_on_entry_item_changed.bind(index, item_option))
	row1.add_child(item_option)
	
	var delete_btn := Button.new()
	delete_btn.text = "X"
	delete_btn.tooltip_text = "Remove entry"
	delete_btn.custom_minimum_size = Vector2(30, 0)
	delete_btn.pressed.connect(_on_remove_entry_pressed.bind(index))
	row1.add_child(delete_btn)
	
	vbox.add_child(row1)
	
	# Row 2: Weight + Quantity range
	var row2 := HBoxContainer.new()
	row2.add_theme_constant_override("separation", 8)
	
	var weight_label := Label.new()
	weight_label.text = "Weight:"
	row2.add_child(weight_label)
	
	var weight_spin := SpinBox.new()
	weight_spin.min_value = 0.1
	weight_spin.max_value = 1000.0
	weight_spin.step = 0.1
	weight_spin.value = entry.weight
	weight_spin.custom_minimum_size = Vector2(70, 0)
	weight_spin.value_changed.connect(_on_entry_weight_changed.bind(index))
	row2.add_child(weight_spin)
	
	var qty_label := Label.new()
	qty_label.text = "  Qty:"
	row2.add_child(qty_label)
	
	var min_qty_spin := SpinBox.new()
	min_qty_spin.min_value = 1
	min_qty_spin.max_value = 999
	min_qty_spin.value = entry.min_quantity
	min_qty_spin.custom_minimum_size = Vector2(60, 0)
	min_qty_spin.value_changed.connect(_on_entry_min_qty_changed.bind(index))
	row2.add_child(min_qty_spin)
	
	var to_label := Label.new()
	to_label.text = "-"
	row2.add_child(to_label)
	
	var max_qty_spin := SpinBox.new()
	max_qty_spin.min_value = 1
	max_qty_spin.max_value = 999
	max_qty_spin.value = entry.max_quantity
	max_qty_spin.custom_minimum_size = Vector2(60, 0)
	max_qty_spin.value_changed.connect(_on_entry_max_qty_changed.bind(index))
	row2.add_child(max_qty_spin)
	
	# Probability display
	var prob_label := Label.new()
	var prob := selected_loot_table.get_entry_probability(entry)
	prob_label.text = "  (%.1f%%)" % prob
	prob_label.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6, 1))
	row2.add_child(prob_label)
	
	vbox.add_child(row2)
	
	margin.add_child(vbox)
	panel.add_child(margin)
	
	return panel


func _mark_loot_modified() -> void:
	if is_updating_ui:
		return
	
	_save_loot_database()
	_refresh_loot_table_list()
	_update_loot_details_panel()


# === Loot Table Handlers ===

func _on_add_loot_table_pressed() -> void:
	var new_table := loot_database.create_new_table()
	selected_loot_table = new_table
	_save_loot_database()
	_refresh_loot_table_list()
	_update_loot_selection_state()


func _on_duplicate_loot_table_pressed() -> void:
	if selected_loot_table == null:
		return
	
	var new_table := loot_database.duplicate_table(selected_loot_table)
	selected_loot_table = new_table
	_save_loot_database()
	_refresh_loot_table_list()
	_update_loot_selection_state()


func _on_delete_loot_table_pressed() -> void:
	if selected_loot_table == null:
		return
	
	loot_database.remove_table(selected_loot_table)
	selected_loot_table = null
	_save_loot_database()
	_refresh_loot_table_list()
	_update_loot_selection_state()


func _on_loot_search_changed(_text: String) -> void:
	_refresh_loot_table_list()


func _on_loot_table_selected(index: int) -> void:
	if index < 0 or index >= filtered_loot_tables.size():
		selected_loot_table = null
	else:
		selected_loot_table = filtered_loot_tables[index]
	
	_update_loot_selection_state()


func _on_loot_id_changed(text: String) -> void:
	if selected_loot_table and not is_updating_ui:
		selected_loot_table.id = text
		_mark_loot_modified()


func _on_loot_name_changed(text: String) -> void:
	if selected_loot_table and not is_updating_ui:
		selected_loot_table.name = text
		_mark_loot_modified()


func _on_loot_desc_changed() -> void:
	if selected_loot_table and not is_updating_ui and loot_desc_edit:
		selected_loot_table.description = loot_desc_edit.text
		_save_loot_database()


func _on_min_drops_changed(value: float) -> void:
	if selected_loot_table and not is_updating_ui:
		selected_loot_table.min_drops = int(value)
		_save_loot_database()


func _on_max_drops_changed(value: float) -> void:
	if selected_loot_table and not is_updating_ui:
		selected_loot_table.max_drops = int(value)
		_save_loot_database()


func _on_empty_chance_changed(value: float) -> void:
	if selected_loot_table and not is_updating_ui:
		selected_loot_table.empty_chance = value / 100.0
		_save_loot_database()


func _on_allow_duplicates_toggled(pressed: bool) -> void:
	if selected_loot_table and not is_updating_ui:
		selected_loot_table.allow_duplicates = pressed
		_save_loot_database()


func _on_add_entry_pressed() -> void:
	if selected_loot_table == null:
		return
	
	var new_entry := LootEntry.new()
	selected_loot_table.add_entry(new_entry)
	_mark_loot_modified()


func _on_remove_entry_pressed(index: int) -> void:
	if selected_loot_table == null:
		return
	
	selected_loot_table.remove_entry_at(index)
	_mark_loot_modified()


func _on_entry_item_changed(option_index: int, entry_index: int, item_option: OptionButton) -> void:
	if selected_loot_table == null or is_updating_ui:
		return
	
	var entry := selected_loot_table.get_entry(entry_index)
	if entry == null:
		return
	
	if item_option == null:
		return
	
	var item_id := item_option.get_item_id(option_index)
	if item_id < 0:
		entry.item = null
	else:
		entry.item = database.get_item_by_id(item_id)
	
	_mark_loot_modified()


func _on_entry_weight_changed(value: float, entry_index: int) -> void:
	if selected_loot_table == null or is_updating_ui:
		return
	
	var entry := selected_loot_table.get_entry(entry_index)
	if entry:
		entry.weight = value
		_mark_loot_modified()


func _on_entry_min_qty_changed(value: float, entry_index: int) -> void:
	if selected_loot_table == null or is_updating_ui:
		return
	
	var entry := selected_loot_table.get_entry(entry_index)
	if entry:
		entry.min_quantity = int(value)
		_save_loot_database()


func _on_entry_max_qty_changed(value: float, entry_index: int) -> void:
	if selected_loot_table == null or is_updating_ui:
		return
	
	var entry := selected_loot_table.get_entry(entry_index)
	if entry:
		entry.max_quantity = int(value)
		_save_loot_database()


func _on_test_roll_pressed() -> void:
	if selected_loot_table == null or test_result_label == null:
		return
	
	# Usa roll_with_sub_tables per includere le sub-tables
	var result := selected_loot_table.roll_with_sub_tables(loot_database)
	
	if result.is_empty():
		test_result_label.text = "[color=gray][i]Nothing dropped![/i][/color]"
	else:
		var text := "[color=lime]Drops:[/color]\n"
		for item_data in result.items:
			var item: ItemDefinition = item_data.item
			var qty: int = item_data.quantity
			var item_name := item.get_translated_name() if item else "???"
			text += "  - %s x%d\n" % [item_name, qty]
		
		# Mostra info sulle sub-tables se presenti
		if selected_loot_table.has_sub_tables():
			text += "\n[color=cyan][i](Includes sub-tables)[/i][/color]"
		
		test_result_label.text = text


# === Rarity Preset Handlers ===

func _on_rarity_tier_changed(index: int) -> void:
	if selected_loot_table == null or is_updating_ui:
		return
	
	selected_loot_table.rarity_tier = index as LootTable.RarityTier
	_update_rarity_desc_label()
	
	# Aggiorna anche i valori visualizzati negli spinbox
	is_updating_ui = true
	if min_drops_spinbox:
		min_drops_spinbox.value = selected_loot_table.min_drops
	if max_drops_spinbox:
		max_drops_spinbox.value = selected_loot_table.max_drops
	if empty_chance_spinbox:
		empty_chance_spinbox.value = selected_loot_table.empty_chance * 100.0
	is_updating_ui = false
	
	_save_loot_database()


func _update_rarity_desc_label() -> void:
	if rarity_desc_label == null or selected_loot_table == null:
		return
	
	var tier := selected_loot_table.rarity_tier
	if tier == LootTable.RarityTier.CUSTOM:
		rarity_desc_label.text = "Manual configuration - adjust drop settings below"
	else:
		var desc := LootTable.get_rarity_description(tier)
		rarity_desc_label.text = "Preset applied: %s" % desc


# === Sub-Tables Handlers ===

func _populate_sub_tables_ui() -> void:
	if sub_tables_container == null or selected_loot_table == null:
		return
	
	# Pulisci container
	for child in sub_tables_container.get_children():
		child.queue_free()
	
	# Se non ci sono sub-tables, mostra messaggio
	if selected_loot_table.sub_table_ids.is_empty():
		var empty_label := Label.new()
		empty_label.text = "No sub-tables configured"
		empty_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
		sub_tables_container.add_child(empty_label)
		return
	
	# Crea una riga per ogni sub-table
	for i in range(selected_loot_table.sub_table_ids.size()):
		var sub_id: String = selected_loot_table.sub_table_ids[i]
		var row := _create_sub_table_row(sub_id, i)
		sub_tables_container.add_child(row)


func _create_sub_table_row(sub_id: String, index: int) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	
	# Dropdown per selezionare la tabella
	var table_option := OptionButton.new()
	table_option.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	table_option.add_item("-- Select Table --", -1)
	
	# Popola con tutte le tabelle disponibili (esclusa quella corrente)
	var selected_idx := 0
	if loot_database:
		for table in loot_database.tables:
			if table and table.id != selected_loot_table.id:  # Escludi self-reference
				var display := "[%s] %s" % [table.id, table.name if not table.name.is_empty() else "(unnamed)"]
				table_option.add_item(display)
				# Salva l'ID come metadata
				table_option.set_item_metadata(table_option.item_count - 1, table.id)
				
				# Se corrisponde all'ID corrente, selezionalo
				if table.id == sub_id:
					selected_idx = table_option.item_count - 1
	
	table_option.selected = selected_idx
	table_option.item_selected.connect(_on_sub_table_changed.bind(index, table_option))
	row.add_child(table_option)
	
	# Indicatore di stato della sub-table
	var status_label := Label.new()
	var sub_table := loot_database.get_table_by_id(sub_id) if loot_database and not sub_id.is_empty() else null
	if sub_table:
		var tier_name := LootTable.get_rarity_name(sub_table.rarity_tier)
		status_label.text = "[%s]" % tier_name
		status_label.add_theme_color_override("font_color", Color(0.5, 0.8, 0.5, 1))
	else:
		status_label.text = "[Not found]"
		status_label.add_theme_color_override("font_color", Color(1, 0.5, 0.5, 1))
	status_label.custom_minimum_size = Vector2(80, 0)
	row.add_child(status_label)
	
	# Bottone rimuovi
	var remove_btn := Button.new()
	remove_btn.text = "X"
	remove_btn.tooltip_text = "Remove sub-table"
	remove_btn.custom_minimum_size = Vector2(30, 0)
	remove_btn.pressed.connect(_on_remove_sub_table_pressed.bind(index))
	row.add_child(remove_btn)
	
	return row


func _on_add_sub_table_pressed() -> void:
	if selected_loot_table == null:
		return
	
	# Aggiungi un nuovo slot vuoto
	selected_loot_table.sub_table_ids.append("")
	_populate_sub_tables_ui()
	_save_loot_database()


func _on_remove_sub_table_pressed(index: int) -> void:
	if selected_loot_table == null or index < 0 or index >= selected_loot_table.sub_table_ids.size():
		return
	
	selected_loot_table.sub_table_ids.remove_at(index)
	_populate_sub_tables_ui()
	_save_loot_database()


func _on_sub_table_changed(option_index: int, row_index: int, table_option: OptionButton) -> void:
	if selected_loot_table == null or is_updating_ui:
		return
	
	if row_index < 0 or row_index >= selected_loot_table.sub_table_ids.size():
		return
	
	# Ottieni l'ID dalla metadata
	var new_id := ""
	if option_index > 0:  # 0 è "-- Select Table --"
		new_id = table_option.get_item_metadata(option_index)
	
	selected_loot_table.sub_table_ids[row_index] = new_id
	_populate_sub_tables_ui()
	_save_loot_database()


# === Loot Tables Import/Export Handlers ===

func _on_import_loot_pressed() -> void:
	# Crea popup menu per scegliere formato e modalità
	var popup := PopupMenu.new()
	popup.add_item("Import JSON (Skip existing)", 0)
	popup.add_item("Import JSON (Overwrite existing)", 1)
	popup.add_item("Import JSON (Replace all)", 2)
	popup.add_separator()
	popup.add_item("Import CSV (Skip existing)", 3)
	popup.add_item("Import CSV (Overwrite existing)", 4)
	popup.add_item("Import CSV (Replace all)", 5)
	
	popup.id_pressed.connect(_on_import_loot_option_selected)
	add_child(popup)
	popup.popup(Rect2i(import_loot_button.global_position + Vector2(0, import_loot_button.size.y), Vector2i(220, 0)))


func _on_import_loot_option_selected(id: int) -> void:
	var is_json := id < 3
	var mode: LootTableDatabase.ImportMode
	
	match id % 3:
		0: mode = LootTableDatabase.ImportMode.MERGE_SKIP
		1: mode = LootTableDatabase.ImportMode.MERGE_OVERWRITE
		2: mode = LootTableDatabase.ImportMode.REPLACE_ALL
	
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	
	if is_json:
		dialog.filters = PackedStringArray(["*.json ; JSON Files"])
		dialog.file_selected.connect(_on_import_loot_json_file_selected.bind(mode))
	else:
		dialog.filters = PackedStringArray(["*.csv ; CSV Files"])
		dialog.file_selected.connect(_on_import_loot_csv_file_selected.bind(mode))
	
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_import_loot_json_file_selected(path: String, mode: LootTableDatabase.ImportMode) -> void:
	var result := loot_database.import_from_json_file(path, mode, database)
	_show_import_loot_result(result)
	
	if result.imported > 0:
		_save_loot_database()
		_refresh_loot_table_list()


func _on_import_loot_csv_file_selected(path: String, mode: LootTableDatabase.ImportMode) -> void:
	var result := loot_database.import_from_csv_file(path, mode, database)
	_show_import_loot_result(result)
	
	if result.imported > 0:
		_save_loot_database()
		_refresh_loot_table_list()


func _show_import_loot_result(result: Dictionary) -> void:
	var message := "Import completed:\n"
	message += "- Imported: %d tables\n" % result.imported
	message += "- Skipped: %d tables\n" % result.skipped
	
	if not result.errors.is_empty():
		message += "\nErrors:\n"
		for error in result.errors.slice(0, 5):  # Max 5 errori mostrati
			message += "- %s\n" % error
		if result.errors.size() > 5:
			message += "... and %d more errors\n" % (result.errors.size() - 5)
	
	var dialog := AcceptDialog.new()
	dialog.title = "Import Result"
	dialog.dialog_text = message
	add_child(dialog)
	dialog.popup_centered()


func _on_export_loot_pressed() -> void:
	# Crea popup menu per scegliere formato
	var popup := PopupMenu.new()
	popup.add_item("Export to JSON", 0)
	popup.add_item("Export to CSV", 1)
	
	popup.id_pressed.connect(_on_export_loot_option_selected)
	add_child(popup)
	popup.popup(Rect2i(export_loot_button.global_position + Vector2(0, export_loot_button.size.y), Vector2i(150, 0)))


func _on_export_loot_option_selected(id: int) -> void:
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.access = EditorFileDialog.ACCESS_FILESYSTEM
	
	if id == 0:
		dialog.filters = PackedStringArray(["*.json ; JSON Files"])
		dialog.current_file = "loot_tables_export.json"
		dialog.file_selected.connect(_on_export_loot_json_file_selected)
	else:
		dialog.filters = PackedStringArray(["*.csv ; CSV Files"])
		dialog.current_file = "loot_tables_export.csv"
		dialog.file_selected.connect(_on_export_loot_csv_file_selected)
	
	add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_export_loot_json_file_selected(path: String) -> void:
	var error := loot_database.export_to_json_file(path)
	if error == OK:
		var dialog := AcceptDialog.new()
		dialog.title = "Export Successful"
		dialog.dialog_text = "Loot tables exported to:\n%s\n\n%d tables exported." % [path, loot_database.tables.size()]
		add_child(dialog)
		dialog.popup_centered()
	else:
		push_error("[InventoryForge] Export failed: %s" % error_string(error))


func _on_export_loot_csv_file_selected(path: String) -> void:
	var error := loot_database.export_to_csv_file(path)
	if error == OK:
		var dialog := AcceptDialog.new()
		dialog.title = "Export Successful"
		dialog.dialog_text = "Loot tables exported to:\n%s\n\n%d tables exported." % [path, loot_database.tables.size()]
		add_child(dialog)
		dialog.popup_centered()
	else:
		push_error("[InventoryForge] Export failed: %s" % error_string(error))
