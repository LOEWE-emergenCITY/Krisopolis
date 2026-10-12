@tool
#extends EditorScript
class_name VRV_Script_Parser
## Vervain is a simple specialized dialoge language
## 
## For syntax see the docs

enum ParamType {
	MULTILINE,
	LIST,
	EMPTY
}

static var regex := RegEx.new()
static var get_file_level := RegEx.new()
static var get_node_level := RegEx.new()

# Utility function to trim and ignore empty lines
static func _clean_lines(script: String) -> Array[String]:
	var lines: PackedStringArray = script.split("\n")
	var result: Array[String] = []
	for line: String in lines:
		var trimmed: String = line.strip_edges(false)
		if trimmed != "":
			result.append(trimmed)
	return result

static func clean_multiline(p_raw_multiline_params: Array[String]) -> Array:
	if p_raw_multiline_params.is_empty():
		return [ParamType.EMPTY]
	
	if not p_raw_multiline_params[0].begins_with("-"):
		return [ParamType.MULTILINE, p_raw_multiline_params]
	
	var result: Array = []
	var i: int = 0
	var line = p_raw_multiline_params
	while i < p_raw_multiline_params.size():
		if line[i].begins_with("-"):
			line[i] = line[i].trim_prefix("-").strip_edges()
			
			var matches := get_node_level.search(line[i])
			var directive := matches.get_string(1)
			var raw_inline_param := matches.get_string(2).strip_edges()
			var raw_multiline_params: Array[String] = []
			while i+1 < p_raw_multiline_params.size() and line[i+1].begins_with("\t"):
				i += 1
				raw_multiline_params.append(line[i].trim_prefix("\t"))
			
			var multiline := [ParamType.EMPTY]
			if not raw_multiline_params.is_empty():
				multiline = clean_multiline(raw_multiline_params)
			
			result.append({directive: {"inline": raw_inline_param, "multiline": multiline}})
		i += 1
	
	return [ParamType.LIST, result]

# Parsing sequance directives
static func parse_sequence(directive: String, raw_inline_params: String, multiline_list_params: Array, line_nr: int) -> Variant:

	var list_params = multiline_list_params[1] if multiline_list_params[0] == ParamType.LIST else []
	var multiline_params = multiline_list_params[1] if multiline_list_params[0] == ParamType.MULTILINE else []

	match directive:
		"text":
			var text: Array[Dictionary] = []
			if not raw_inline_params.is_empty():
				var param: PackedStringArray = raw_inline_params.split(":", false)
				var speaker: String = param[0].strip_edges()
				var line: String = param[1].strip_edges()
				text.append({"speaker": speaker, "line": line})
			elif not multiline_params.is_empty():
				for raw_param: String in multiline_params:
					var param: PackedStringArray = raw_param.split(":", false)
					var speaker: String = param[0].strip_edges()
					var line: String = param[1].strip_edges()
					text.append({"speaker": speaker, "line": line})
			
			return text
			
		"jump":
			var inline_params := raw_inline_params.split(" ", false)
			if not inline_params.is_empty():
				return inline_params[0]
			elif not multiline_params.is_empty():
				return multiline_params[0]
				
		"random":
			if not list_params.is_empty():
				var code: Array
				for entry: Dictionary in list_params:
					var dir: String = entry.keys()[0]
					code.append({dir: parse_sequence(dir, entry[dir]["inline"], entry[dir]["multiline"], line_nr)})
						
				return code
				
		"actors": 
			var actors: Array[Dictionary] = []
			if not raw_inline_params.is_empty():
				var inline_params := raw_inline_params.split(" ", false)
				for param: String in inline_params:
					var data: Array[String]
					data.assign(param.split(".", false))
					var name: String = data[0]
					var flip: bool = false
					if data.size() > 1:
						flip = data[1] == "flipped"
					actors.append({"name": name, "flip": flip})
			elif not list_params.is_empty():
				for param: String in list_params:
					var data: PackedStringArray = param.split(" ", false)
					var name: String = data[0]
					var flip: bool = false
					if data.size() > 1:
						flip = data[1] == "flipped"
					actors.append({"name": name, "flip": flip})
				
			return actors
			
		"content":
			if not raw_inline_params.is_empty():
				return raw_inline_params.strip_edges()
			elif not multiline_params.is_empty():
				return "\n".join(PackedStringArray(multiline_params))
			#elif not list_params.is_empty():
				#return list_params
				
		"Type", "Start", "title":
			if not raw_inline_params.is_empty():
				return raw_inline_params.strip_edges()
				
		"action", "Condition":
			if not raw_inline_params.is_empty():
				var action: VRV_Action = VRV_Action.new()
				action.ast = VRV_ActionParser.parse(raw_inline_params)
				return action
		#"if":
			#return {"if": "some"}
		#"than":
			#return {"than": "some"}
		#"else":
			#return {"else": "some"}
			
		"match":
			if not raw_inline_params.is_empty() and not list_params.is_empty():
				var action: VRV_Action = VRV_Action.new()
				action.ast = VRV_ActionParser.parse(raw_inline_params)
				var options: Dictionary = {}
				for entry: Dictionary in list_params:
					var case: String = entry.keys()[0]
					var line: String = entry[case]["inline"]
					var matches := get_node_level.search(line)
					if matches == null:
						printerr("VRV_Script_Parser: parsing line:\n%s" % line)
						return null
						#continue 
					var dir := matches.get_string(1)
					var raw_inline := matches.get_string(2)
					
					var case_value: Variant
					var case_action: VRV_Action = VRV_Action.new()
					case_action.ast = VRV_ActionParser.parse(case)
					case_value = case_action.execute(null)
					
					options[case_value] = {}
					options[case_value][dir] = parse_sequence(dir, raw_inline, entry[case]["multiline"], line_nr)
				
				return [action, options]
				
		"set":
			if not raw_inline_params.is_empty():
				var inline_params := raw_inline_params.split(" ", false)
				var name: String = inline_params[0]
				var action: VRV_Action = VRV_Action.new()
				var script: String = " ".join(inline_params.slice(1))
				action.ast = VRV_ActionParser.parse(script)
				return [name, action]
				
		## Choices: [{"prompt": "Bla Bla", "id": "NODE_NAME", "icon": ""}] 
		"Choice":
			if not list_params.is_empty():
				var result: Array[Dictionary]
				for entry: Dictionary in list_params:
					var id: String = entry.keys()[0]
					var prompt: String = entry[id]["inline"]
					if id.is_empty():
						break
					result.append({"id": id, "prompt": prompt})
				
				return result
				
	EMC_Util.print_warn("VRV_Script_Parser: Missing directive or wrong parameter on line: %s directive: %s" % [line_nr+1, directive])
	return {}

static func parse_script(script: String) -> VRV_Script:
	get_file_level.compile("\\[\\[(?<file_directive>\\w+)\\]\\] (?<file_inline_param>\\w+)")
	get_node_level.compile("\\[(?<directive>\\w+)\\](?:(?<directive_inline>(?: .+)*))")
	
	var result: VRV_Script = VRV_Script.new()
	var current_node_name: String
	
	var lines: Array[String] = _clean_lines(script)
	var i: int = 0
	while i < lines.size():
		var line: String = lines[i]
		if line.begins_with("[["):
			var matches := get_file_level.search(line)
			if matches == null:
				printerr("VRV_Script_Parser: parsing line:\n%s" % line)
				return null
			var directive := matches.get_string(1)
			var name := matches.get_string(2) 
			current_node_name = name
			result.nodes[current_node_name] = {"type": directive}
			
		elif line.begins_with("["):
			var matches := get_node_level.search(line)
			if matches == null:
				printerr("VRV_Script_Parser: parsing line:\n%s" % line)
				return null
			var directive := matches.get_string(1)
			var raw_inline_param := matches.get_string(2)
			var raw_multiline_params: Array[String] = []
			
			var tmp_lines = lines.slice(i+1)
			for l: String in tmp_lines:
				if l.begins_with("["):
					break
				i += 1
				raw_multiline_params.append(l)
			
			var multiline_params := clean_multiline(raw_multiline_params)
			
			if directive == "Comment":
				i += 1
				continue
				
			var parsed_sequence := parse_sequence(directive, raw_inline_param, multiline_params, i)
			if parsed_sequence == null:
				return null
				
			if directive.to_lower() == directive:
				if not result.nodes[current_node_name].has("sequence"):
					result.nodes[current_node_name]["sequence"] = []
				result.nodes[current_node_name]["sequence"].append({directive: parsed_sequence})
			else:
				result.nodes[current_node_name][directive] = parsed_sequence
			
		else:
			printerr("VRV_Script_Parser: What the hell did you do?")
			return null
		
		i += 1
		
	return result

func _run() -> void:
	#var action_script: String = 'add(1, @set)'
	#var action: VRV_Action = VRV_Action.new()
	#action.ast = VRV_ActionParser.parse(action_script)
	#print(">> %s\n%s" % [action_script, action.execute(VRV_GSI.new(), {"@set": 2})])
	#
	#return
	
	#print(clean_multiline(["- [1] [jump] on", "- [2] [jump] on", "- [3] [text]", "\tGerhard: Hallo"]))
	#
	#return 
	
	
	var input: String = """
[[Meta]] Quest
[Start] friedel_weg
[Type] quest
[set] @addition add(1, 1)
[match] @addition
- [1] [text]
	Gerhard: This cant be happening
- [2] [jump] end

[[Quest]] friedel_weg
[random]
- [jump] ARGUMENT
- [jump] one
- [text]
	Gerhard: Hello.
	Avatar: hi
[jump] pop_gerhard

[[PopUp]] pop_gerhard
[content] 
Gerhard klopf an der Tür.
Vielleicht braucht er hilfe.
[Choice]
- [open] Tür öffnen
- [end] Klopfen ingonrieren

[[Node]] end
[action] end_quest("friedel_weg")

[[Test]] hello

[[Dialoge]] open
[action] move_npc("gerhard", "home")
[actors] gerhard avatar.flipped
[text]
Gerhard: Friedel ist weg kannst du mir helfen ihn zu suchen?
Avatar: Hallo!
[text] Gerhard: Hali Halo
[jump] open_city

[[Quest]] open_city
"""
	
	parse_script(input)
