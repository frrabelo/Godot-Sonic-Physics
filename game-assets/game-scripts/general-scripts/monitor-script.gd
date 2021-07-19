extends Node2D
class_name ItemBox
tool
signal exploded
var yspeed = 0.0
onready var spawn_pos = global_position
var explode : PackedScene = preload('res://general-objects/item-boxes/item-box-explosion-object.tscn')

enum ITEM_TO_PICK{
	RING,
	SHIELD_NORMAL,
	LIFE_UP,
	HYPER_RING,
	SHIELD_BUBBLE,
	INVINCIBILITY,
	SHIELD_FIRE,
	SUPER,
	SPEED,
	SHIELD_LIGHTNING,
	DAMAGE,
	SWITCH,
	RANDOM
}

const ITEM_VALUES : Dictionary = {
	ITEM_TO_PICK.RING: 0,
	ITEM_TO_PICK.SHIELD_NORMAL: 1,
	ITEM_TO_PICK.LIFE_UP: [2, 3, 6, 7, 10],
	ITEM_TO_PICK.HYPER_RING: 4,
	ITEM_TO_PICK.SHIELD_BUBBLE: 5,
	ITEM_TO_PICK.INVINCIBILITY: 8,
	ITEM_TO_PICK.SHIELD_FIRE: 9,
	ITEM_TO_PICK.SUPER: 11,
	ITEM_TO_PICK.SPEED: 12,
	ITEM_TO_PICK.SHIELD_LIGHTNING: 13,
	ITEM_TO_PICK.DAMAGE: 14,
	ITEM_TO_PICK.SWITCH: 15,
	ITEM_TO_PICK.RANDOM: 16,
}

export(ITEM_TO_PICK) var object_to_pick : int = ITEM_TO_PICK.RING setget _set_obj_to_pick
onready var base_sprite = $base
onready var object_sprite = $Display/ObjectIndicator
onready var explode_area = $ExplodeArea
onready var hit_box = $HitBox

func _ready() -> void:
	set_process(false)
	if !Engine.editor_hint:
		for i in get_children():
			if i is Area2D:
				i.connect('body_entered', self, '_on_ExplodeArea_body_entered')
		if !get_tree().get_current_scene().has_node('Players'):
			return
		var player = get_tree().current_scene.get_node('Players').get_node('Player').CHARACTER_SELECTED
		if object_to_pick == ITEM_TO_PICK.LIFE_UP:
			object_sprite.frame = ITEM_VALUES[object_to_pick][player]
		else:
			object_sprite.frame = ITEM_VALUES[object_to_pick]

func _set_obj_to_pick(val : int) -> void:
	if !has_node('Display') || !$Display.has_node('ObjectIndicator'):
		return
	object_to_pick = val
	if object_to_pick == ITEM_TO_PICK.LIFE_UP:
		$Display/ObjectIndicator.frame = 2
	else:
		$Display/ObjectIndicator.frame = ITEM_VALUES[object_to_pick]


func _action(player : PlayerPhysics) -> void:
	pass

func _push_player(player : PlayerPhysics) -> void:
	if !player.is_grounded:
		pass
	var direction = global_position.direction_to(player.global_position).sign()
	var angle = rotation
	player.speed.y -= (player.speed.y * 1.85) * cos(angle)
	player.speed.x -= (player.speed.x * 1.85) * sin(angle)

func _on_ExplodeArea_body_entered(body: Node) -> void:
	if body is PlayerPhysics:
		emit_signal('exploded')
		if body.global_position.y < $JumpPosition.global_position.y:
			$AnimationPlayer.play('JumpExplode')
			var explosion_obj : AnimatedSprite = explode.instance()
			explosion_obj.position = base_sprite.position + Vector2(0, -8)
			add_child(explosion_obj)
			hit_box.queue_free()
			explode_area.queue_free()
			for i in base_sprite.get_children():
				i.queue_free()
			base_sprite.frame = int(rand_range(1, 3))
			get_tree().get_current_scene().get_node('GlobalSFX/Destroy').play()
			_push_player(body)
			var timer = Timer.new()
			timer.connect('timeout', self, '_timeout_action', [timer, body])
			add_child(timer)
			timer.start(0.5)
			return
		if body.speed.y < 0:
			yspeed = body.speed.y if body.speed.y > -200 else -200
			set_process(true)
			body.speed.y = 10

func _process(delta: float) -> void:
	yspeed += 600 * delta
	position.y += yspeed * delta
	#print(yspeed)
	if global_position.y > spawn_pos.y:
		yspeed = 0
		global_position.y = spawn_pos.y
		set_process(false)

func _timeout_action(timer : Timer, body : Node) -> void:
	_action(body)
	timer.queue_free()
