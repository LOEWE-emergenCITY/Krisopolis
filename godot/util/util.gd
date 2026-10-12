class_name EMC_Util

static func print_warn(line: String) -> void:
	print_rich("[color=#ffde66][b]● WARNING:[/b] %s[/color]" % line)

static func print_success(line: String) -> void:
	print_rich("[color=#8fffdb][b]● SUCCESS:[/b] %s[/color]" % line)

static func combine_filters(f1 : Callable, f2 : Callable) -> Callable:
	return \
		func (value : Variant) -> bool:
			return f1.call(value) and f2.call(value)

class Promise:
	signal complete(name : String)
	
	const signal_or_name : String = "signal_or"
	
	func _init(signals : Array[Signal], f_name : String) -> void:
		var f : Callable = Callable(self, f_name)
		for sig : Signal in signals:
			sig.connect(f.bind(sig.get_name()))
	
	func signal_or(name : String) -> void:
		complete.emit(name)
	

class Icon_Patcher:
	
	static func cut_out(texture : Texture2D, region : Rect2) -> Texture2D:
		var result : Image = texture.get_image().get_region(region) 
		
		return ImageTexture.create_from_image(result)
	
	static func combine(textures : Array[Texture2D]) -> Texture2D:
		var width : int = 0
		var height : int = 0
		
		var images : Array[Image] = []
		
		for tex : Texture2D in textures:
			var img : Image = tex.get_image()
			if not images.is_empty() and not images[0].get_format() == img.get_format():
				printerr("EMC_Util.Icon_Patcher.combine: Texture has wrong Fromat, will be ignored")
				continue
			
			width += tex.get_width()
			height += tex.get_height()
			images.append(img)
		
		if images.is_empty():
			printerr("EMC_Util.Icon_Patcher.combine: No valid Images present: abort")
			return
		
		var result : Image = Image.create(width, height, false, images[0].get_format())
		
		var offset : Vector2i = Vector2i(0, 0)
		
		for img : Image in images:
			result.blit_rect(img, Rect2(0, 0, img.get_width(), img.get_height()), offset)
			offset += Vector2i(img.get_width(), 0)
		#result.blit_rect(img2, Rect2(0, 0, img2.get_width(), img2.get_height()), Vector2i(img1.get_width(), img1.get_height()))
		
		return ImageTexture.create_from_image(result)

static var _rng : RandomNumberGenerator = RandomNumberGenerator.new()

static func pick_weighted_random(list : Array[Variant], weights : Array[float], count : int) -> Array[Variant]:
	var result : Array[Variant] = []
	if count > list.size():
		printerr("Count cannot be greater than list size")
		return []
	if list.size() != weights.size():
		printerr("The size of list and weights must be equal")
		return []
	for i in range(count):
		var sum_of_weight : float = weights.reduce(func(a : float, b : float) -> float: return a + b)
		var random : float = _rng.randf_range(0.0, sum_of_weight)
		for index in range(list.size()):
			if random < weights[index]:
				result.append(list[index])
				list.remove_at(index)
				weights.remove_at(index)
				break
			random -= weights[index]
	return result
	
static func pick_weighted_random_const(list : Array[Variant], weights : Array[float]) -> Variant:
	if list.is_empty():
		printerr("List must not be empty")
		return []
	if list.size() != weights.size():
		printerr("The size of list and weights must be equal")
		return []
	var sum_of_weight : float = weights.reduce(func(a : float, b : float) -> float: return a + b)
	var random : float = _rng.randf_range(0.0, sum_of_weight)
	for index in range(list.size()):
		if random < weights[index]:
			return list[index]
		random -= weights[index]
	return

static func dict_to_vector(data : Dictionary, type : Variant.Type) -> Variant:
	var x : Variant = data.get("x", NAN)
	var y : Variant = data.get("y", NAN)
	var z : Variant = data.get("z", NAN)
	var w : Variant = data.get("w", NAN)
	
	match type:
		TYPE_VECTOR2:
			if (x != NAN and y != NAN 
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)):
				return Vector2(x as float, y as float)
		TYPE_VECTOR2I:
			if (x != NAN and y != NAN 
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)):
				return Vector2i(x as int, y as int)
		TYPE_VECTOR3:
			if (x != NAN and y != NAN and z != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)):
				return Vector3(x as float, y as float, z as float)
		TYPE_VECTOR3I:
			if (x != NAN and y != NAN and z != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)):
				return Vector3i(x as int, y as int, z as int)
		TYPE_VECTOR4:
			if (x != NAN and y != NAN and z != NAN and w != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)
			and (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT)):
				return Vector4(x as float, y as float, z as float, w as float)
		TYPE_VECTOR4I:
			if (x != NAN and y != NAN and z != NAN and w != NAN
			and (typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT)
			and (typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT)
			and (typeof(z) == TYPE_INT or typeof(z) == TYPE_FLOAT)
			and (typeof(w) == TYPE_INT or typeof(w) == TYPE_FLOAT)):
				return Vector4i(x as int, y as int, z as int, w as int)
		_: 
			push_error(str(type) + " is not a Type.")
	push_error("Wrong Type!")
	return null


class JSONUtil:
	
	pass
