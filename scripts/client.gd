extends Area2D
class_name Client

@export var money_value: int = 10
@export var is_collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
var original_modulate: Color

signal client_reached(client: Client)


func _ready():
	area_entered.connect(_on_area_entered)
	original_modulate = modulate
	update_display()

func _on_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("stop_at_client") and not is_collected:
		collect_money(parent)
		if audio_player:
			audio_player.play()

func collect_money(train):
	if not is_collected:
		is_collected = true
		train.stop_at_client(money_value)
		client_reached.emit(self)
		update_display()

func update_display():
	if label:
		if is_collected:
			label.text = "Collecté!"
			label.modulate = Color.GRAY
		else:
			label.text = str(money_value) + "€"
			label.modulate = original_modulate
	
	if sprite and is_collected:
		sprite.modulate = Color.GRAY

func reset_client():
	is_collected = false
	update_display()
