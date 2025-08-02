extends Sprite2D

class_name Factory

@onready var button: Button = $Button
@onready var progress_bar: ProgressBar = $ProgressBar

signal start_train

var capacity : float = 100
var production : int = 10
var storage := 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.connect("pressed", func():
		start_train.emit(storage)
	)
	progress_bar.max_value = capacity


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	storage = storage + production * delta
	if storage > capacity:
		storage = capacity
		start_train.emit(storage)
	progress_bar.value = storage
