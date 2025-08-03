extends Node

signal money_changed

var money = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pay(value : int):
	money -= value
	money_changed.emit()

func can_pay(value : int) -> bool:
	return money >= value

func gain(value : int):
	money += value
	money_changed.emit()
