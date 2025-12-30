@tool
extends Control
## Main panel for Inventory Forge.
## Manages the item list on the left and details on the right.
##
## Inventory Forge Plugin by Menkos
## License: MIT

const Settings := preload("res://addons/inventory_forge/inventory_forge_settings.gd")

# === UI References ===
@onready var add_button: Button = %AddButton
@onready var duplicate_button: Button = %DuplicateButton
@onready var delete_button: Button = %DeleteButton
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
@onready var craftable_check: CheckBox = %CraftableCheck
@onready var ingredients_container: VBoxContainer = %IngredientsContainer

# Validation
@onready var warnings_container: VBoxContainer = %WarningsContainer

# === State ===
var database: ItemDatabase = null
var selected_item: ItemDefinition = null
var is_updating_ui: bool = false  # Prevents update loops
var filtered_items: Array[ItemDefinition] = []


func _ready() -> void:
	if not Engine.is_editor_hint():
		return
	
	_load_database()
	_setup_ui()
	_connect_signals()
	_refresh_item_list()
	_update_selection_state()


func _get_database_path() -> String:
	return Settings.get_database_path()


func _load_database() -> void:
	var db_path := _get_database_path()
	
	if ResourceLoader.exists(db_path):
		database = load(db_path) as ItemDatabase
	
	if database == null:
		database = ItemDatabase.new()
		_save_database()


func _save_database() -> void:
	if database == null:
		push_error("[InventoryForge] Cannot save: database is null!")
		return
	
	var db_path := _get_database_path()
	var error := ResourceSaver.save(database, db_path)
	if error != OK:
		push_error("[InventoryForge] Error saving database: %s" % error)
	else:
		# Notify editor that resource has changed
		if Engine.is_editor_hint():
			database.emit_changed()


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


func _connect_signals() -> void:
	# Toolbar
	add_button.pressed.connect(_on_add_pressed)
	duplicate_button.pressed.connect(_on_duplicate_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	
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
	craftable_check.toggled.connect(_on_craftable_toggled)


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
	
	# Crafting
	craftable_check.button_pressed = selected_item.craftable
	ingredients_container.visible = selected_item.craftable
	
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
		_mark_modified()
