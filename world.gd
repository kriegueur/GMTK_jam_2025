extends Node2D

@onready var path_2d: Path2D = $Path2D
@onready var factory: Sprite2D = $Factory
@onready var tile_map_layer: TileMapLayer = $TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var path = find_railpath()
	path_2d.curve = _curve2d_from_path(path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_tile_center_from_pos(pos : Vector2) -> Vector2:
	var a = tile_map_layer.local_to_map(pos)
	return tile_map_layer.map_to_local(a)

func find_railpath() -> Array[Vector2i]:
	var starting_tile : Vector2i = tile_map_layer.local_to_map(factory.position)
	var current : Vector2i = starting_tile
	var prev : Array[Vector2i]
	var next : Vector2i = Vector2i()
	var tiles : Array[Vector2i] = []
	while next != starting_tile:
		next = get_adjacent_railtile(current, prev)
		if next == current:
			print("Failed to find path")
			break
		tiles.append(current)
		if current != starting_tile:
			prev.append(current)
		current = next
	tiles.append(next)
	return tiles

func get_adjacent_railtile(tile : Vector2i, previous_tiles : Array[Vector2i]) -> Vector2i:
	var current_tile_type : String = tile_map_layer.get_cell_tile_data(tile).get_custom_data("Orientation")
	match current_tile_type:
		"WE":
			return _unexplored_tile(tile, previous_tiles, Vector2i.RIGHT, Vector2i.LEFT)
		"NS":
			return _unexplored_tile(tile, previous_tiles, Vector2i.UP, Vector2i.DOWN)
		"NW":
			return _unexplored_tile(tile, previous_tiles, Vector2i.UP, Vector2i.LEFT)
		"NE":
			return _unexplored_tile(tile, previous_tiles, Vector2i.UP, Vector2i.RIGHT)
		"SW":
			return _unexplored_tile(tile, previous_tiles, Vector2i.DOWN, Vector2i.LEFT)
		"SE":
			return _unexplored_tile(tile, previous_tiles, Vector2i.DOWN, Vector2i.RIGHT)
		_:
			return tile

func _unexplored_tile(tile : Vector2i, previous_tiles: Array[Vector2i], possibility1 : Vector2i, possibility2 : Vector2i) -> Vector2i:
	var res = tile + possibility1
	if res not in previous_tiles:
		return res
	res = tile + possibility2
	if res not in previous_tiles:
		return res
	else:
		return tile

func _curve2d_from_path(path : Array[Vector2i]) -> Curve2D:
	var curve : Curve2D = Curve2D.new()
	curve.add_point(tile_map_layer.map_to_local(path[0]))
	for tile : Vector2i in path:
		match tile_map_layer.get_cell_tile_data(tile).get_custom_data("Orientation"):
			"NW":
				curve.add_point(tile_map_layer.map_to_local(tile))
			"NE":
				curve.add_point(tile_map_layer.map_to_local(tile))
			"SW":
				curve.add_point(tile_map_layer.map_to_local(tile))
			"SE":
				curve.add_point(tile_map_layer.map_to_local(tile))
	curve.add_point(tile_map_layer.map_to_local(path[-1]))
	return curve
