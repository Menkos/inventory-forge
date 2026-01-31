@tool
class_name IconPickerDialog
extends Window
## Dialog for selecting icons from the project's icons folder
##
## Scans res://icons/ folder and displays available icons in a grid.
## Supports filtering by filename and selecting an icon.
##
## Inventory Forge Plugin by Menkos
## License: MIT

# === Signals ===
signal icon_selected(texture: Texture2D, path: String)
signal browse_requested()

# === Constants ===
const ICON_SIZE := Vector2(64, 64)
const GRID_COLUMNS := 8
const SUPPORTED_EXTENSIONS := ["png", "jpg", "jpeg", "svg", "webp"]
const DEFAULT_SCAN_PATHS := ["res://icons/", "res://assets/icons/", "res://textures/icons/"]

# === UI References ===
var search_edit: LineEdit
var icons_container: VBoxContainer
var scroll_container: ScrollContainer
var path_label: Label
var no_icons_label: Label
var status_label: Label

# === State ===
var all_icons: Array[Dictionary] = []  # [{path: String, texture: Texture2D, folder: String}]
var filtered_icons: Array[Dictionary] = []
var icons_by_folder: Dictionary = {}  # {folder_path: Array[Dictionary]}
var scan_paths: Array[String] = []


func _init() -> void:
	title = "Select Icon"
	size = Vector2i(650, 550)
	min_size = Vector2i(400, 350)
	exclusive = true
	transient = true
	wrap_controls = true


func _ready() -> void:
	_setup_ui()
	_scan_for_icons()
	_populate_icons()


func _setup_ui() -> void:
	# Main container
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_vbox.offset_left = 10
	main_vbox.offset_top = 10
	main_vbox.offset_right = -10
	main_vbox.offset_bottom = -10
	main_vbox.add_theme_constant_override("separation", 10)
	add_child(main_vbox)
	
	# Search bar
	var search_hbox := HBoxContainer.new()
	search_hbox.add_theme_constant_override("separation", 10)
	
	var search_label := Label.new()
	search_label.text = "Search:"
	search_hbox.add_child(search_label)
	
	search_edit = LineEdit.new()
	search_edit.placeholder_text = "Filter icons by name..."
	search_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_edit.clear_button_enabled = true
	search_edit.text_changed.connect(_on_search_changed)
	search_hbox.add_child(search_edit)
	
	main_vbox.add_child(search_hbox)
	
	# Separator
	var sep := HSeparator.new()
	main_vbox.add_child(sep)
	
	# Scroll container for icons
	scroll_container = ScrollContainer.new()
	scroll_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll_container.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main_vbox.add_child(scroll_container)
	
	# VBox container for folder sections
	icons_container = VBoxContainer.new()
	icons_container.add_theme_constant_override("separation", 12)
	icons_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll_container.add_child(icons_container)
	
	# No icons label (hidden by default)
	no_icons_label = Label.new()
	no_icons_label.text = "No icons found.\n\nPlace image files in:\n- res://icons/\n- res://assets/icons/\n- res://textures/icons/"
	no_icons_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	no_icons_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	no_icons_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	no_icons_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	no_icons_label.visible = false
	main_vbox.add_child(no_icons_label)
	
	# Bottom section
	var bottom_hbox := HBoxContainer.new()
	bottom_hbox.add_theme_constant_override("separation", 10)
	
	status_label = Label.new()
	status_label.text = "0 icons"
	status_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 1))
	bottom_hbox.add_child(status_label)
	
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bottom_hbox.add_child(spacer)
	
	var rescan_btn := Button.new()
	rescan_btn.text = "Rescan"
	rescan_btn.tooltip_text = "Rescan icon folders for new images"
	rescan_btn.pressed.connect(_on_rescan_pressed)
	bottom_hbox.add_child(rescan_btn)
	
	var browse_btn := Button.new()
	browse_btn.text = "Browse..."
	browse_btn.tooltip_text = "Open file browser to select any image"
	browse_btn.pressed.connect(_on_browse_pressed)
	bottom_hbox.add_child(browse_btn)
	
	var cancel_btn := Button.new()
	cancel_btn.text = "Cancel"
	cancel_btn.pressed.connect(_on_cancel_pressed)
	bottom_hbox.add_child(cancel_btn)
	
	main_vbox.add_child(bottom_hbox)
	
	# Connect close signal
	close_requested.connect(_on_cancel_pressed)


func _scan_for_icons() -> void:
	all_icons.clear()
	icons_by_folder.clear()

	# Determina i percorsi da scansionare
	if scan_paths.is_empty():
		for path in DEFAULT_SCAN_PATHS:
			scan_paths.append(path)

	for scan_path in scan_paths:
		_scan_directory(scan_path)

	# Ordina icone per nome file in ogni cartella
	for folder in icons_by_folder:
		icons_by_folder[folder].sort_custom(func(a, b): return a.path.get_file() < b.path.get_file())

	# Ordina per nome file globalmente
	all_icons.sort_custom(func(a, b): return a.path.get_file() < b.path.get_file())

	filtered_icons = all_icons.duplicate()


func _scan_directory(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return

	dir.list_dir_begin()
	var file_name := dir.get_next()

	while file_name != "":
		var full_path := path.path_join(file_name)

		if dir.current_is_dir():
			# Scansiona ricorsivamente le sottocartelle
			if not file_name.begins_with("."):
				_scan_directory(full_path)
		else:
			# Controlla se è un'immagine supportata
			var extension := file_name.get_extension().to_lower()
			if extension in SUPPORTED_EXTENSIONS:
				var texture := _load_texture(full_path)
				if texture:
					var icon_data := {
						"path": full_path,
						"texture": texture,
						"folder": path
					}
					all_icons.append(icon_data)

					# Raggruppa per cartella
					if not icons_by_folder.has(path):
						icons_by_folder[path] = []
					icons_by_folder[path].append(icon_data)

		file_name = dir.get_next()

	dir.list_dir_end()


func _load_texture(path: String) -> Texture2D:
	if not ResourceLoader.exists(path):
		return null
	
	var resource = load(path)
	if resource is Texture2D:
		return resource
	
	return null


func _populate_icons() -> void:
	# Pulisci container
	for child in icons_container.get_children():
		child.queue_free()

	# Attendi un frame per rimuovere i nodi
	await get_tree().process_frame

	if filtered_icons.is_empty():
		no_icons_label.visible = true
		scroll_container.visible = false
		status_label.text = "0 icons"
		return

	no_icons_label.visible = false
	scroll_container.visible = true

	# Raggruppa icone filtrate per cartella
	var filtered_by_folder: Dictionary = {}
	for icon_data in filtered_icons:
		var folder: String = icon_data.folder
		if not filtered_by_folder.has(folder):
			filtered_by_folder[folder] = []
		filtered_by_folder[folder].append(icon_data)

	# Ordina le cartelle alfabeticamente
	var sorted_folders: Array = filtered_by_folder.keys()
	sorted_folders.sort()

	# Crea sezione per ogni cartella
	for folder in sorted_folders:
		var folder_icons: Array = filtered_by_folder[folder]
		if folder_icons.is_empty():
			continue

		_create_folder_section(folder, folder_icons)

	status_label.text = "%d icons" % filtered_icons.size()


func _create_folder_section(folder: String, folder_icons: Array) -> void:
	# Container per la sezione
	var section := VBoxContainer.new()
	section.add_theme_constant_override("separation", 6)

	# Header con nome cartella
	var header := Label.new()
	header.text = folder.trim_prefix("res://")
	header.add_theme_font_size_override("font_size", 12)
	header.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7, 1))
	section.add_child(header)

	# Griglia icone
	var grid := GridContainer.new()
	grid.columns = GRID_COLUMNS
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	section.add_child(grid)

	# Crea bottoni per ogni icona
	for icon_data in folder_icons:
		var btn := Button.new()
		btn.custom_minimum_size = ICON_SIZE
		btn.size = ICON_SIZE
		btn.tooltip_text = icon_data.path

		var tex_rect := TextureRect.new()
		tex_rect.texture = icon_data.texture
		tex_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
		tex_rect.offset_left = 4
		tex_rect.offset_top = 4
		tex_rect.offset_right = -4
		tex_rect.offset_bottom = -4
		tex_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

		btn.add_child(tex_rect)
		btn.pressed.connect(_on_icon_button_pressed.bind(icon_data))
		grid.add_child(btn)

	icons_container.add_child(section)


func _on_search_changed(text: String) -> void:
	var query := text.strip_edges().to_lower()
	
	if query.is_empty():
		filtered_icons = all_icons.duplicate()
	else:
		filtered_icons.clear()
		for icon_data in all_icons:
			var file_name: String = icon_data.path.get_file().to_lower()
			if file_name.contains(query):
				filtered_icons.append(icon_data)
	
	_populate_icons()


func _on_icon_button_pressed(icon_data: Dictionary) -> void:
	icon_selected.emit(icon_data.texture, icon_data.path)
	queue_free()


func _on_cancel_pressed() -> void:
	queue_free()


func _on_rescan_pressed() -> void:
	# Resetta i percorsi per forzare una nuova scansione
	scan_paths.clear()
	_scan_for_icons()
	# Riapplica il filtro di ricerca corrente
	if search_edit and not search_edit.text.is_empty():
		_on_search_changed(search_edit.text)
	else:
		_populate_icons()


func _on_browse_pressed() -> void:
	browse_requested.emit()
	queue_free()


## Configura i percorsi da scansionare (opzionale)
func set_scan_paths(paths: Array[String]) -> void:
	scan_paths = paths


## Mostra il dialog centrato rispetto al parent
func popup_centered_on(parent: Control) -> void:
	if parent:
		var parent_rect := parent.get_global_rect()
		var center := parent_rect.position + parent_rect.size / 2
		position = Vector2i(center) - size / 2
	
	show()
