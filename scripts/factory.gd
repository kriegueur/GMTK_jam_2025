extends Sprite2D

class_name Factory

@onready var button: Button = $Button
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var select: Button = $Select

signal start_train
signal select_factory

var capacity : float = 50
var production : int = 5
var storage := 0.0
var stopped = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.connect("pressed", func():
		start_train.emit(storage)
	)
	progress_bar.max_value = capacity
	select.connect("pressed", func():
		select_factory.emit()
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if stopped:
		return
	storage = storage + production * delta
	if storage > capacity:
		storage = capacity
		start_train.emit(storage)
	progress_bar.value = storage

func upgrade_capacity():
	capacity += 10.0
	progress_bar.max_value = capacity

func upgrade_production():
	production += 3
