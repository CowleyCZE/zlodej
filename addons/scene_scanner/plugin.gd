# File: addons/scene_scanner/plugin.gd
# Godot 4.x EditorPlugin – běží pouze v editoru, nezasahuje runtime.
# Menu: Nástroje → Scan Scene → dialog s volbou složky, názvem a přepínači exportu.
# Export: 1_<název>_nodetree.txt, 2_<název>_nodeset.txt, 3_<název>_scripts.txt

@tool
extends EditorPlugin

var _dlg: AcceptDialog
var _path_line: LineEdit
var _name_line: LineEdit
var _browse_btn: Button
var _check_tree: CheckBox
var _check_props: CheckBox
var _check_scripts: CheckBox
var _file_dlg: FileDialog

func _enter_tree() -> void:
	add_tool_menu_item("Scan Scene", Callable(self, "_on_open_dialog"))
	_build_ui()

func _exit_tree() -> void:
	remove_tool_menu_item("Scan Scene")
	if is_instance_valid(_dlg):
		_dlg.queue_free()
	if is_instance_valid(_file_dlg):
		_file_dlg.queue_free()

func _build_ui() -> void:
	var root: Control = get_editor_interface().get_base_control()

	_dlg = AcceptDialog.new()
	root.add_child(_dlg)
	_dlg.title = "Scan Scene"
	_dlg.dialog_close_on_escape = true
	_dlg.min_size = Vector2(500, 280)

	var vb: VBoxContainer = VBoxContainer.new()
	vb.custom_minimum_size = Vector2(480, 240)
	_dlg.add_child(vb)

	var lbl_name: Label = Label.new()
	lbl_name.text = "Název pro soubory:"
	vb.add_child(lbl_name)

	_name_line = LineEdit.new()
	_name_line.text = "scene"
	_name_line.placeholder_text = "např. mainscene"
	_name_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_name_line)

	var sep0: HSeparator = HSeparator.new()
	vb.add_child(sep0)

	var lbl_path: Label = Label.new()
	lbl_path.text = "Výstupní složka (res:// nebo podsložka):"
	vb.add_child(lbl_path)

	_path_line = LineEdit.new()
	_path_line.text = "res://"
	_path_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vb.add_child(_path_line)

	_browse_btn = Button.new()
	_browse_btn.text = "Vybrat složku..."
	vb.add_child(_browse_btn)
	_browse_btn.pressed.connect(_on_browse_pressed)

	var sep1: HSeparator = HSeparator.new()
	vb.add_child(sep1)

	_check_tree = CheckBox.new()
	_check_tree.text = "Export Node Tree"
	_check_tree.button_pressed = true
	vb.add_child(_check_tree)

	_check_props = CheckBox.new()
	_check_props.text = "Export Properties"
	_check_props.button_pressed = true
	vb.add_child(_check_props)

	_check_scripts = CheckBox.new()
	_check_scripts.text = "Export Scripts"
	_check_scripts.button_pressed = true
	vb.add_child(_check_scripts)

	_dlg.get_ok_button().text = "Exportovat"
	_dlg.confirmed.connect(_on_run_scan)

	_file_dlg = FileDialog.new()
	_file_dlg.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	_file_dlg.access = FileDialog.ACCESS_RESOURCES
	_file_dlg.title = "Vyber výstupní složku"
	root.add_child(_file_dlg)
	_file_dlg.dir_selected.connect(_on_dir_selected)

func _on_open_dialog() -> void:
	if _dlg:
		_dlg.popup_centered()

func _on_browse_pressed() -> void:
	if _file_dlg:
		_file_dlg.current_dir = _path_line.text if _path_line.text != "" else "res://"
		_file_dlg.call_deferred("popup_centered_ratio", 0.75)

func _on_dir_selected(dir_path: String) -> void:
	_path_line.text = dir_path

func _on_run_scan() -> void:
	var iface: EditorInterface = get_editor_interface()
	var root: Node = iface.get_edited_scene_root()
	if root == null:
		push_warning("Scene Scanner: Není otevřena žádná scéna.")
		return

	var base_dir: String = _sanitize_base_dir(_path_line.text)
	if base_dir == "":
		push_warning("Scene Scanner: Neplatná složka, použito res://")
		base_dir = "res://"

	var file_name: String = _sanitize_filename(_name_line.text)
	if file_name == "":
		push_warning("Scene Scanner: Neplatný název, použito 'scene'")
		file_name = "scene"

	DirAccess.make_dir_recursive_absolute(base_dir)

	var do_tree: bool = _check_tree.button_pressed
	var do_props: bool = _check_props.button_pressed
	var do_scripts: bool = _check_scripts.button_pressed

	if not do_tree and not do_props and not do_scripts:
		push_warning("Scene Scanner: Není vybráno nic k exportu.")
		return

	if do_tree:
		var tree_text: String = _build_tree_text(root)
		var path_tree: String = base_dir.path_join("1_" + file_name + "_nodetree.txt")
		var f1: FileAccess = FileAccess.open(path_tree, FileAccess.WRITE)
		if f1:
			f1.store_string(tree_text)
			f1.close()
			print("Saved:", path_tree)

	if do_props:
		var props_text: String = _build_properties_text(root)
		var path_props: String = base_dir.path_join("2_" + file_name + "_nodeset.txt")
		var f2: FileAccess = FileAccess.open(path_props, FileAccess.WRITE)
		if f2:
			f2.store_string(props_text)
			f2.close()
			print("Saved:", path_props)

	if do_scripts:
		var scripts_text: String = _build_scripts_text(root)
		var path_scripts: String = base_dir.path_join("3_" + file_name + "_scripts.txt")
		var f3: FileAccess = FileAccess.open(path_scripts, FileAccess.WRITE)
		if f3:
			f3.store_string(scripts_text)
			f3.close()
			print("Saved:", path_scripts)

	print("--- Scan Scene: Done ---")

func _sanitize_base_dir(p: String) -> String:
	var s: String = p.strip_edges()
	if s == "":
		return "res://"
	if not s.begins_with("res://"):
		return "res://"
	return s

func _sanitize_filename(p: String) -> String:
	var s: String = p.strip_edges()
	if s == "":
		return ""
	var invalid := ["/", "\\", "?", "<", ">", ":", "*", "|", char(34)]
	for ch in invalid:
		s = s.replace(ch, "_")
	var result := ""
	for i in range(s.length()):
		var ch := s.substr(i, 1)
		var code := s.unicode_at(i)
		var is_alnum := (code >= 48 and code <= 57) or (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		if is_alnum or ch == " " or ch == "_" or ch == "-":
			result += ch
		else:
			result += "_"
	result = result.strip_edges()
	while result.find("__") != -1:
		result = result.replace("__", "_")
	while result.begins_with("_"):
		result = result.substr(1)
	while result.ends_with("_"):
		result = result.substr(0, result.length() - 1)
	return result

func _build_tree_text(root: Node) -> String:
	var out: String = "--- Hierarchický výpis uzlů (Generováno) ---
"
	var lines: Array[String] = []
	_collect_tree_lines(root, 0, lines)
	out += "
".join(lines) + "
"
	return out

func _collect_tree_lines(n: Node, level: int, acc: Array[String]) -> void:
	var indent: String = "    ".repeat(level)
	acc.append(indent + n.name + " (" + n.get_class() + ")")
	var children: Array = n.get_children()
	for c in children:
		var child: Node = c
		_collect_tree_lines(child, level + 1, acc)

func _build_properties_text(root: Node) -> String:
	var out: String = "--- Seznam vlastností uzlů (Generováno) ---
"
	var queue: Array[Node] = [root]
	while not queue.is_empty():
		var n: Node = queue.pop_front()
		out += "UZEL: " + n.name + " (" + n.get_class() + ")
"
		var plist: Array = n.get_property_list()
		for d in plist:
			var entry: Dictionary = d
			var key_sn: StringName = entry.get("name", &"")
			if key_sn != &"":
				var val: Variant = n.get(key_sn)
				out += "  " + str(key_sn) + ": " + str(val) + "
"
		out += "--------------------------------------------------------
"
		var children: Array = n.get_children()
		for c in children:
			var child: Node = c
			queue.append(child)
	return out

func _build_scripts_text(root: Node) -> String:
	var out: String = "--- Seznam uzlů se skripty a jejich úplný obsah (Generováno) ---

"
	var queue: Array[Node] = [root]
	while not queue.is_empty():
		var n: Node = queue.pop_front()
		var scr: Script = n.get_script() as Script
		if scr != null:
			var path: String = scr.resource_path
			if path == "":
				path = str(scr)
			out += "========================================================
"
			out += "UZEL: " + n.name + " (" + n.get_class() + ")
"
			out += "CESTA KE SKRIPTU: " + path + "
"
			out += "========================================================

"
			var script_content: String = _read_script_content(path)
			if script_content != "":
				out += script_content + "
"
			else:
				out += "[Nepodařilo se načíst obsah skriptu]
"
			out += "
--------------------------------------------------------

"
		var children: Array = n.get_children()
		for c in children:
			var child: Node = c
			queue.append(child)
	return out

func _read_script_content(script_path: String) -> String:
	if script_path == "" or not script_path.begins_with("res://"):
		return ""
	var file: FileAccess = FileAccess.open(script_path, FileAccess.READ)
	if file:
		var content: String = file.get_as_text()
		file.close()
		return content
	else:
		return ""
