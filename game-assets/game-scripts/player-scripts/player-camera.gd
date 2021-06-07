extends Node2D

class_name PlayerCamera

export(float) var vertical_offset
export(float) var horizontal_offset

export(bool) var follow_player = true;
export(bool) var followUp = false;
export(bool) var followLeft = true;
export(bool) var followRight = true;
export(bool) var followDown = true;


export(float) var LEFT = -16
export(float) var RIGHT = .0
export(float) var GROUND_TOP = .0
export(float) var GROUND_BOTTOM = .0
export(float) var AIR_TOP = 48
export(float) var AIR_BOTTOM = -16

export(float) var SCROLL_UP = -104
export(float) var SCROLL_DOWN = 88
export(float) var SCROLL_SPEED = 120
export(float) var SCROLL_DELAY = 2

var scroll_timer : float
export(bool) var rotateWithPlayer:bool
var stuck_in_object:bool
var object_to_stuck;
var secondary_target:Node2D;

onready var camera_scroll = $CameraScroll

func camera_ready(player : PlayerPhysics) -> void:
	position = player.position

func can_scroll(delta : float):
	if scroll_timer > 0:
		scroll_timer -= delta
		return false
	
	return true

func camera_step(player : PlayerPhysics, delta : float):
	if !stuck_in_object:
		horizontal_border(player)
		vertical_border(player)
		vertical_scrolling(player, delta);
		if rotation == 0 && rotateWithPlayer == false:
			$CameraScroll/Camera2D.rotating = false;
		else:
			$CameraScroll/Camera2D.rotating = true;
		if rotateWithPlayer:
			var dir = (player.position - secondary_target.position).normalized();
			rotation_degrees = rad2deg(dir.angle()) + 90;
			position += (secondary_target.position - position) / 4
			position.y -= 20 * cos(rotation);
			position.x -= 20 * -sin(rotation)
		else:
			rotation_degrees += player.smooth_rotate(rotation_degrees, 0, 180);

func horizontal_border(player : PlayerPhysics):
	if follow_player:
		if player.position.x > position.x + RIGHT && followRight:
			position.x += min(player.position.x - (position.x + RIGHT), 16)
		elif player.position.x < position.x + LEFT && followLeft:
			position.x += max(player.position.x - (position.x + LEFT), -16)

func vertical_border(player : PlayerPhysics):
	if follow_player:
		var vel;
		var scroll_back = true
		var scroll_world = camera_scroll.global_position
		var realPos = position.y + vertical_offset;
		if player.is_grounded:
			if (realPos + 16 - position.y) != 0:
				var playerPosCam = (player.position.y + 16) - realPos;
				var playerLt360 = abs(player.speed.y) <= 360;
				vel = \
					max(playerPosCam,\
						-6 - (10 * int(!playerLt360)\
					));
				if ((realPos + vel) - realPos < 0) && !followUp:
					return
				elif ((realPos + vel) - realPos > 0) && !followDown:
					return
				position.y += vel;
			return
		
		var velAtt;
		var playerLtAt = player.position.y < realPos - AIR_TOP;
		var playerGtAb = player.position.y > realPos + AIR_BOTTOM;
		if (!playerGtAb && !playerLtAt):
			return
		
		if (playerLtAt):
			vel = max(\
				player.position.y - (realPos - AIR_TOP), -16
			)
		elif playerGtAb:
			vel = min(\
				player.position.y - (realPos + AIR_BOTTOM), 16
			)
		
		if ((realPos + vel) - realPos < 0) && !followUp:
			return
		elif ((realPos + vel) - realPos > 0) && !followDown:
			return
		
		position.y += vel;

func vertical_scrolling(player : PlayerPhysics, delta : float):
	var scroll_back = true
	var scroll_world = camera_scroll.global_position
	
	if player.is_looking_up:
		if can_scroll(delta):
			camera_scroll.position.y -= SCROLL_SPEED * delta
			camera_scroll.position.y = max(camera_scroll.position.y, SCROLL_UP)
			scroll_back = false
	elif player.is_looking_down:
		if can_scroll(delta):
			camera_scroll.position.y += SCROLL_SPEED * delta
			camera_scroll.position.y = min(camera_scroll.position.y, SCROLL_DOWN)
			scroll_back = false
	else:
		scroll_timer = SCROLL_DELAY
	
	if scroll_back:
		if camera_scroll.position.y > 0:
			camera_scroll.position.y -= SCROLL_SPEED * delta
			camera_scroll.position.y = max(camera_scroll.position.y, 0)
		elif camera_scroll.position.y < 0:
			camera_scroll.position.y += SCROLL_SPEED * delta
			camera_scroll.position.y = min(camera_scroll.position.y, 0)

func delay(secs:float = -1):
	follow_player = false
	var timer = Timer.new();
	self.add_child(timer);
	timer.start(secs);
	timer.connect("timeout", self, "followAgain", [timer]);
	

func followAgain(timerNode:Timer):
	remove_child(timerNode);
	follow_player = true
