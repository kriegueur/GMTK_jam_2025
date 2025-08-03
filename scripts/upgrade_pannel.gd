extends Control
class_name UpgradePanel

@onready var open_button: TextureButton = $TextureButton
@onready var color_rect: ColorRect = $ColorRect

@onready var production: Button = $Factory/HBoxContainer2/Production
@onready var production_label: Label = $Factory/HBoxContainer2/Label
@onready var capacity: Button = $Factory/HBoxContainer3/Capacity
@onready var capacity_label: Label = $Factory/HBoxContainer3/Label
@onready var t_speed: Button = $Factory/HBoxContainer4/TSpeed
@onready var t_speed_label: Label = $Factory/HBoxContainer4/Label
@onready var t_capacity: Button = $Factory/HBoxContainer5/TCapacity
@onready var t_capacity_label: Label = $Factory/HBoxContainer5/Label

@onready var client_button: Button = $Client/HBoxContainer/Button
@onready var client_label: Label = $Client/HBoxContainer/Label

@export var train : Train
@export var factory : Factory
@export var client : Client

enum STATES {
	EMPTY,
	CLIENT_UPGRADE,
	FACTORY_UPGRADE
}

var state := STATES.EMPTY

# PRICES
var production_price := 15
var capacity_price := 10
var tspeed_price := 10
var tcapacity_price := 12

const PRICE_INCREASE := 1.1

@onready var offset = color_rect.size.x
@onready var init_pos = position.x
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position.x = init_pos + offset
	open_button.flip_h = true
	open_button.connect("pressed", func():
		if open_button.flip_h == true:
			open_panel()
		else:
			close_panel()
	)
	setup_buttons()

func setup_buttons():
	production.connect("pressed", func():
		if MoneyState.can_pay(production_price):
			MoneyState.pay(production_price)
			production_price *= PRICE_INCREASE
			production_label.text = str(production_price) + '$'
			factory.upgrade_production()
	)
	production_label.text = str(production_price) + '$'
	capacity.connect("pressed", func():
		if MoneyState.can_pay(capacity_price):
			MoneyState.pay(capacity_price)
			capacity_price *= PRICE_INCREASE
			capacity_label.text = str(capacity_price) + '$'
			factory.upgrade_capacity()
	)
	capacity_label.text = str(capacity_price) + '$'
	t_speed.connect("pressed", func():
		if MoneyState.can_pay(tspeed_price):
			MoneyState.pay(tspeed_price)
			tspeed_price *= PRICE_INCREASE
			t_speed_label.text = str(tspeed_price) + '$'
			train.upgrade_speed()
	)
	t_speed_label.text = str(tspeed_price) + '$'
	t_capacity.connect("pressed", func():
		if MoneyState.can_pay(tcapacity_price):
			MoneyState.pay(tcapacity_price)
			tcapacity_price *= PRICE_INCREASE
			t_capacity_label.text = str(tcapacity_price) + '$'
			train.upgrade_capacity()
	)
	t_capacity_label.text = str(tcapacity_price) + '$'
	client_button.connect("pressed", func():
		var price := client.upgrade_price
		if MoneyState.can_pay(price):
			MoneyState.pay(price)
			client_label.text = str(client.upgrade()) + '$'
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func open_panel() -> void:
	open_button.flip_h = false
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(init_pos,0), 1.0)

func close_panel() -> void:
	open_button.flip_h = true
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", Vector2(init_pos + offset,0), 1.0)

func upgrade_factory() -> void:
	if state == STATES.EMPTY:
		$Empty.hide()
	elif state == STATES.CLIENT_UPGRADE:
		$Client.hide()
	state = STATES.FACTORY_UPGRADE
	$Factory.show()
	open_panel()

func upgrade_client(target : Client) -> void:
	client = target
	if state == STATES.EMPTY:
		$Empty.hide()
	elif state == STATES.FACTORY_UPGRADE:
		$Factory.hide()
	state = STATES.CLIENT_UPGRADE
	client_label.text = str(client.upgrade_price) + '$'
	$Client.show()
	open_panel()
