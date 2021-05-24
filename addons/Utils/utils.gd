class_name Utils
static func sign_2_bool(minus:bool, plus:bool) -> int:
	return - int(minus) + int(plus)

static func sign_bool(dir:bool) -> int:
	return - int(!dir) + int(dir)
