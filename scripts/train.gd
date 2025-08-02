extends PathFollow2D

class_name Train

@export var speed: float = 100.0
@export var stop_duration: float = 1.0

var is_stopped: bool = false
var stop_timer: float = 0.0
var money: int = 0

signal money_collected(amount: int)
signal reached_factory

func _ready() -> void:
	progress = 0.0

func _process(delta: float) -> void:
	if not is_stopped:
		progress += speed * delta
		if progress_ratio >= 1.0:
			stop_at_factory()
	else:
		stop_timer -= delta
		if stop_timer <= 0.0 && progress_ratio < 1.0 or Input.is_action_just_pressed("start_train") and is_stopped:
			resume_movement()
			
func stop_at_client(client_money: int):
	if not is_stopped:
		is_stopped = true
		stop_timer = stop_duration
		money += client_money
		money_collected.emit(client_money)

func resume_movement():
	is_stopped = false
	if (progress_ratio >= 1.0):
		progress_ratio = 0.0
		progress = 0

func stop_at_factory():
	is_stopped = true
	reached_factory.emit()
	progress_ratio = 1.0
	print("Train arrivé à la factory avec ", money, " pièces!")
