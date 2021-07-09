extends Node2D
class_name Boss
tool
signal died(node_id, name)
signal damage(pre_hit_hp, current_hp)
var area = get_parent()

export var hp : int = 3 setget _set_hp
var can_take_hit : bool = true if hp > 0 && hp != null else false

func _enter_tree() -> void:
	if !Engine.editor_hint:
		assert(area && area is BossArea)
		if !area is BossArea:
			area = null
		else:
			(area as BossArea).bosses.append(self)
	else:
		update_configuration_warning()

func _ready() -> void:
	if !Engine.editor_hint:
		if area && area is BossArea:
			connect('died', area, "_on_BossDied")

func appear() -> void: pass
func boss_start () -> void:
	if hp <= 0:
		destroy()

func destroy() -> void:
	can_take_hit = false
	var ba : BossArea = area
	emit_signal('died', get_instance_id(), name)
	ba.bosses.remove(ba.bosses.find(self))

func damage() -> void:
	var php = hp
	if hp > 0:
		hp -= 1
		emit_signal('damage', php, hp)
	else:
		destroy()

func _get_configuration_warning() -> String:
	var to_return = ""
	if !area || !area is BossArea:
		to_return += "The Boss class must contain BossArea class as a parent\n"
	if hp <= 0:
		to_return += "Hp is setted to 0, When the boss start, it will be destroyed"
	return to_return

func _set_hp(val : int) -> void:
	hp = max(val, 0)
