@tool
extends EditorPlugin

const DOCK_SCENE = "res://addons/godot_scribe_plugin/scribe_dock.tscn"
const PORT = 9090

var tcp_server = null
var peers = []
var dock_instance

func _enter_tree():
    # Přidání docku do editoru
    dock_instance = preload(DOCK_SCENE).instantiate()
    add_control_to_dock(DOCK_SLOT_RIGHT_UL, dock_instance)
    dock_instance.set_server(self)

    # Spuštění TCP serveru pro WebSocket
    tcp_server = TCPServer.new()
    var error = tcp_server.listen(PORT)
    if error != OK:
        push_error("Godot Scribe: Nepodařilo se spustit TCP server.")
        return
    
    log_message("WebSocket server naslouchá na portu %d" % PORT)

func _exit_tree():
    # Odebrání docku
    if is_instance_valid(dock_instance):
        remove_control_from_docks(dock_instance)
        dock_instance.free()

    # Zastavení serveru
    for peer in peers:
        peer.close()
    
    if tcp_server:
        tcp_server.stop()
    log_message("WebSocket server zastaven.")

func _process(_delta):
    if not tcp_server:
        return

    if tcp_server.is_listening():
        if tcp_server.is_connection_available():
            var conn = tcp_server.take_connection()
            if conn:
                var peer = WebSocketPeer.new()
                peer.accept_stream(conn)
                peers.append(peer)
                log_message("Nový klient čeká na handshake.")

    # Projdeme peery v opačném pořadí, abychom je mohli bezpečně odebírat
    for i in range(peers.size() - 1, -1, -1):
        var peer : WebSocketPeer = peers[i]
        peer.poll()
        
        var state = peer.get_ready_state()
        if state == WebSocketPeer.STATE_OPEN:
            while peer.get_available_packet_count() > 0:
                var packet = peer.get_packet()
                var data = packet.get_string_from_utf8()
                
                var json = JSON.parse_string(data)
                if json == null:
                    send_error(peer, -32700, "Chyba parsování JSON.")
                    continue

                log_message("Data přijata: " + data)
                handle_request(peer, json)
        elif state == WebSocketPeer.STATE_CLOSING:
            # Klient se odpojuje
            pass
        elif state == WebSocketPeer.STATE_CLOSED:
            # Spojení bylo uzavřeno
            log_message("Klient odpojen.")
            peers.remove_at(i)


func handle_request(peer, request):
    if not "method" in request:
        send_error(peer, -32600, "Neplatný požadavek (chybí 'method').")
        return

    var method = request["method"]
    var params = request.get("params", {})
    var request_id = request.get("id", null)

    var result = null
    var error = null

    match method:
        "get_project_state":
            result = get_project_state()
        "update_script":
            if "path" in params and "content" in params:
                result = update_script(params["path"], params["content"])
            else:
                error = {"code": -32602, "message": "Neplatné parametry pro 'update_script'."}
        _:
            error = {"code": -32601, "message": "Metoda nenalezena: " + method}
    
    if request_id != null:
        if error != null:
            send_response(peer, request_id, null, error)
        else:
            send_response(peer, request_id, result, null)


func get_project_state():
    return {
        "scene_tree": get_scene_tree_data(get_editor_interface().get_edited_scene_root()),
        "input_map": get_input_map_data()
    }

func get_scene_tree_data(node):
    if not is_instance_valid(node):
        return null
    
    var data = {
        "name": node.name,
        "type": node.get_class(),
        "script": null,
        "exported_variables": [],
        "children": []
    }

    var script = node.get_script()
    if is_instance_valid(script):
        data["script"] = script.resource_path
        data["exported_variables"] = get_exported_variables(script)

    for child in node.get_children():
        data["children"].append(get_scene_tree_data(child))
        
    return data

func get_exported_variables(script):
    var variables = []
    if not is_instance_valid(script):
        return variables
        
    for prop in script.get_script_property_list():
        if prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE:
            var type_name = ""
            if prop.type == TYPE_OBJECT and prop.class_name != "":
                type_name = prop.class_name
            else:
                # Using str(prop.type) as a fallback to avoid Variant scope issues in @tool
                type_name = str(prop.type)

            variables.append({
                "name": prop.name,
                "type": type_name
            })
    return variables

func get_input_map_data():
    var actions = {}
    for action_name in InputMap.get_actions():
        var action_events = []
        for event in InputMap.action_get_events(action_name):
            action_events.append(event.as_text())
        actions[action_name] = action_events
    return actions

func update_script(file_path, content):
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if not is_instance_valid(file):
        var error_code = FileAccess.get_open_error()
        var error_msg = "Nepodařilo se otevřít soubor pro zápis: %s (Chyba: %s)" % [file_path, error_string(error_code)]
        push_error(error_msg)
        return {"success": false, "error": error_msg}
    
    file.store_string(content)
    file.close()
    
    # Reload script in editor
    get_editor_interface().get_resource_filesystem().update_file(file_path)
    
    log_message("Skript aktualizován: " + file_path)
    return {"success": true}

# --- Komunikace ---

func send_response(peer, request_id, result, error):
    var response = {
        "jsonrpc": "2.0",
        "id": request_id
    }
    if error != null:
        response["error"] = error
    else:
        response["result"] = result
        
    var json_string = JSON.stringify(response)
    peer.put_packet(json_string.to_utf8_buffer())

func send_error(peer, code, message):
    var response = {
        "jsonrpc": "2.0",
        "id": null,
        "error": {
            "code": code,
            "message": message
        }
    }
    var json_string = JSON.stringify(response)
    peer.put_packet(json_string.to_utf8_buffer())

func log_message(message):
    print("Godot Scribe: " + message)
    if is_instance_valid(dock_instance):
        dock_instance.add_log(message)