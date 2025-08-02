extends PathFollow2D

class_name Train

@export var speed: float = 100.0
@onready var timer: Timer = $Timer

var is_stopped: bool = true
var money: int = 0
var capacity : float = 50.0
var storage : float = 0.0

signal money_collected(amount: int)
signal reached_factory

func _ready() -> void:
	progress = 0.0
	timer.connect("timeout", func():
		if progress != 0.0:
			resume_movement()
	)

func _process(delta: float) -> void:
	if not is_stopped:
		progress += speed * delta
		if progress_ratio >= 1.0:
			stop_at_factory()
			
func stop_at_client(client_money: int, demand : float) -> bool:
	if storage < demand:
		return false
	if not is_stopped:
		is_stopped = true
		timer.start()
		money += client_money
		storage -= demand
		money_collected.emit(client_money)
	return true

func resume_movement():
	is_stopped = false
	if (progress_ratio >= 1.0):
		progress_ratio = 0.0
		progress = 0

func leave_factory(available : float) -> float:
	if progress == 0.0:
		var empty_storage = capacity - storage
		var taken = min(available, empty_storage)
		storage += taken
		resume_movement()
		print(storage)
		return taken
	return 0.0

func stop_at_factory():
	is_stopped = true
	reached_factory.emit()
	progress_ratio = 0.0
	print("Train arrivé à la factory avec ", money, " pièces!")
