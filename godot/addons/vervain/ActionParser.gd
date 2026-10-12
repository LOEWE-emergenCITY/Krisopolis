extends RefCounted
class_name VRV_ActionParser

static var tokens : Array = []
static var pos : int = 0

static func parse(text: String) -> Variant:
	tokens = tokenize(text)
	pos = 0
	var expr = parse_expr()
	if pos < tokens.size():
		printerr("VRV_ActionParser: Unexpected token: %s" % tokens[pos])
	return expr

# -------------------------------------------------------
# Tokenizer
# -------------------------------------------------------

static func tokenize(text: String) -> Array:
	var result = []
	var i = 0

	while i < text.length():
		var c = text[i]
		if c == " " or c == "\t" or c == "\r" or c == "\n":
			i += 1
		elif c == "(" or c == ")" or c == ",":
			result.append(c)
			i += 1
			
		elif c == '"':
			var j = i + 1
			while j < text.length() and text[j] != '"':
				j += 1
			if j >= text.length():
				printerr("VRV_ActionParser: Unterminated string literal")
			result.append(text.substr(i, j - i + 1))
			i = j + 1
		elif c == '{':
			var j = i + 1
			while j < text.length() and text[j] != '}':
				j += 1
			if j >= text.length():
				printerr("VRV_ActionParser: Unterminated json")
			result.append(text.substr(i, j - i + 1))
			i = j + 1
		elif c == '[':
			var j = i + 1
			while j < text.length() and text[j] != ']':
				j += 1
			if j >= text.length():
				printerr("VRV_ActionParser: Unterminated array")
			result.append(text.substr(i, j - i + 1))
			i = j + 1
		#elif c == '@':
			#var j = i + 1
			#while j < text.length() and is_valid_prim(text[j]):
				#j += 1
			#result.append(text.substr(i, j - i))
			#i = j
		elif is_valid_prim(c):
			var j = i + 1
			while j < text.length() and is_valid_prim(text[j]):
				j += 1
			result.append(text.substr(i, j - i))
			i = j
		else:
			printerr("VRV_ActionParser: Unexpected character: '%s'" % c)
			i += 1

	return result

# -------------------------------------------------------
# Parser
# -------------------------------------------------------

static func parse_expr() -> Variant:
	var token = peek()

	# String literal
	if token.begins_with('"'):
		advance()
		return {
			"type": "string",
			"value": token.trim_prefix('"').trim_suffix('"')
		}
		
	elif token.begins_with('{'):
		advance()
		var json := JSON.new()
		var error := json.parse(token)
		if error != OK:
			printerr("VRV_ActionParser: JSON Parse Error: ", json.get_error_message(), "in ", token)
			return {}
		return {
			"type": "json",
			"value": json.data
		}
	elif token.begins_with('['):
		advance()
		var json := JSON.new()
		var error := json.parse(token)
		if error != OK:
			printerr("VRV_ActionParser: JSON Parse Error: ", json.get_error_message(), "in ", token)
			return {}
		return {
			"type": "array",
			"value": json.data
		}

	# Number
	elif token.is_valid_int():
		advance()
		return {
			"type": "int",
			"value": int(token)
		}
	
	elif token.is_valid_float():
		advance()
		return {
			"type": "float",
			"value": float(token)
		}

	# Boolean
	elif token == "true" or token == "false":
		advance()
		return {
			"type": "bool",
			"value": token == "true"
		} 

	# Identifier or function call
	elif is_identifier(token):
		return parse_identifier_or_call()

	printerr("VRV_ActionParser: Unexpected expression token: %s" % token)
	return null

static func parse_identifier_or_call() -> Variant:
	var name = peek()
	advance()

	if peek() == "(":
		return parse_call(name)
	return {
		"type": "var",
		"name": name
	}  # primitive identifier

static func parse_call(name: String) -> Dictionary:
	expect("(")

	var args: Array = []

	if peek() != ")":  # has arguments
		while true:
			args.append(parse_expr())
			if peek() == ",":
				advance()
				continue
			break

	expect(")")

	return {
		"type": "call",
		"name": name,
		"args": args
	}

# -------------------------------------------------------
# Helpers
# -------------------------------------------------------

static func peek() -> String:
	if pos < tokens.size():
		return tokens[pos]
	return ""

static func advance() -> void:
	pos += 1

static func expect(t: String) -> void:
	if peek() != t:
		printerr("VRV_ActionParser: Expected '%s' but found '%s'" % [t, peek()])
	advance()

static func is_identifier(t: String) -> bool:
	return t.length() > 0 and ((t.is_valid_ascii_identifier()) or t[0] == "@" or t[0] == "#")
	
static func is_valid_prim(ch: String) -> bool:
	return ch.length() > 0 and not (ch == " " or ch == "\t" or ch == "\n" or ch == "\r" or ch == "(" or ch == ")" or ch == ",")
