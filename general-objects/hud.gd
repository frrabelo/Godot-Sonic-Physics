extends CanvasLayer
enum Actions {
	FLASH = 0
}
onready var color_rect : ColorRect = $ColorRect
var action : int

func _ready() -> void:
	set_process(false)
	#flash_screen()

func flash_screen(time_to_fade_out : float = 0.25, alpha : float = 1.0) -> void:
	color_rect.color = Color('#ffffffff')
	color_rect.color.a = alpha
	var timer : Timer = Timer.new()
	timer.connect('timeout', self, '_flash_timeout', [timer])
	add_child(timer)
	timer.start(time_to_fade_out)

func _process(delta: float) -> void:
	match action:
		Actions.FLASH:
			color_rect.color.a -= delta * 2
			if color_rect.color.a < 0:
				color_rect.color.a = 0
				set_process(false)

func _flash_timeout(timer : Timer):
	set_process(true)
	action = Actions.FLASH
	timer.queue_free()
