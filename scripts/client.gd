extends Area2D
class_name Client

var money_value: int = 10
var is_collected: bool = false
var demand : float = 20.0
var upgrade_price := 10

@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var button: Button = $Button

var original_modulate: Color

const DOWNTIME := 10.0
var downtime_elapsed := 0.0

signal client_reached(client: Client)
signal client_upgrading

func _ready():
	area_entered.connect(_on_area_entered)
	original_modulate = self_modulate
	update_display()
	progress_bar.max_value = DOWNTIME
	progress_bar.hide()
	button.connect("pressed", func():
		client_upgrading.emit()
	)

func _process(delta: float) -> void:
	if is_collected:
		downtime_elapsed += delta
		progress_bar.value = downtime_elapsed
		if downtime_elapsed >= DOWNTIME:
			progress_bar.hide()
			downtime_elapsed = 0.0
			is_collected = false
			update_display()

func _on_area_entered(area):
	var parent = area.get_parent()
	if parent.has_method("stop_at_client") and not is_collected:
		collect_money(parent)
		

func collect_money(train):
	if not is_collected:
		if train.stop_at_client(money_value, demand):
			is_collected = true
			progress_bar.show()
			client_reached.emit(self)
			update_display()
			if audio_player:
				audio_player.play()

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
	else:
		sprite.modulate = original_modulate

func reset_client():
	is_collected = false
	update_display()

func upgrade() -> int:
	const PRICE_INCREASE = 1.1
	const MONEY_INCREASE = 5
	const DEMAND_INCREASE = 10
	money_value += MONEY_INCREASE
	upgrade_price *= PRICE_INCREASE
	update_display()
	demand += DEMAND_INCREASE
	return upgrade_price
