class_name Utils

enum Vec2AngleDirection {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

static func sign_2_bool(minus:bool, plus:bool) -> int:
	return - int(minus) + int(plus)

static func sign_bool(dir:bool) -> int:
	return - int(!dir) + int(dir)

static func get_node_by_type(from:Node, i:String):
	for c in from.get_children():
		if c.is_class(i):
			return c
	return null

static func get_nodes_by_type(from:Node, i:String):
	var to_return = []
	for c in from.get_children():
		if c.is_class(i):
			to_return.append(c)
			#print(c)
	if to_return.size() <= 0:
		to_return = null
	return to_return

static func int2bin(n : int, bits: int) -> String:
	var to_return := ""
	var num = n
	for i in range(bits, -1, -1):
		var k = num >> i
		to_return += String(int(k & 1))
	
	return to_return

static func bin2int(b : String) -> int:
	var to_return : int = 0
	var bin = b
	var base = 1
	
	for i in range(b.length() - 1, -1, -1):
		if (bin[i] == "1"):
			to_return += base
		base = base * 2
	
	return to_return

static func count_how_much_has(digit:bool, b:String) -> int:
	var to_return = 0
	var bin = b
	for i in b:
		to_return += int(digit)
	
	return to_return

static func angle2Vec2(angle : float, to : int = 0) -> Vector2:
	var to_return : Vector2
	to_return = Vector2(cos(angle), -sin(angle))
	
	return to_return

static func between(val: float, minor:float, major:float) -> bool:
	return val > minor && val < major

static func is_action(action:String) -> bool:
	var to_return = false
	
	to_return = Input.is_action_pressed(action) or Input.is_action_just_released(action)
	
	return to_return

static func round_between(n:float, minor : float , major: float):
	return minor if (n - minor) < (major - n) else major
	pass
