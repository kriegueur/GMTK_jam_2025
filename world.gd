extends Node2D

@onready var path_2d: Path2D = $Path2D
@onready var factory: Sprite2D = $Factory
@onready var tile_map_layer: TileMapLayer = $TileMapLayer
@onready var placement_indicator: Sprite2D = $PlacementIndicator

enum ORIENTATION {
	WE,
	NS,
	NW,
	NE,
	SW,
	SE,
}

enum ADJACENTPOS {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var path = find_railpath()
	path_2d.curve = _curve2d_from_path(path)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_position := get_global_mouse_position()
	var cursor_tile := tile_map_layer.local_to_map(to_local(mouse_position))
	var cursor_tile_center := tile_map_layer.map_to_local(cursor_tile)
	placement_indicator.global_position = cursor_tile_center
	if Input.is_action_pressed("click"):
		if tile_empty(cursor_tile):
			place_rail(cursor_tile)

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

func tile_empty(tile : Vector2i) -> bool:
	return tile_map_layer.get_cell_source_id(tile) == -1

func place_rail(tile : Vector2i):
	var orientation := find_rail_orientation(tile)
	var atlas_coords := orientation_to_atlas(orientation)
	tile_map_layer.set_cell(tile, 0, atlas_coords)
	update_tile(tile + Vector2i.UP)
	update_tile(tile + Vector2i.DOWN)
	update_tile(tile + Vector2i.LEFT)
	update_tile(tile + Vector2i.RIGHT)

func orientation_to_atlas(orientation : ORIENTATION) -> Vector2i:
	match orientation:
		ORIENTATION.WE:
			return Vector2i(1,0)
		ORIENTATION.NS:
			return Vector2i(0,0)
		ORIENTATION.NW:
			return Vector2i(2,1)
		ORIENTATION.NE:
			return Vector2i(1,1)
		ORIENTATION.SW:
			return Vector2i(2,0)
		ORIENTATION.SE:
			return Vector2i(0,1)
		_:
			return Vector2i(0,0)

func find_adjacents(tile : Vector2i) -> Array[ADJACENTPOS]:
	var adjacents : Array[ADJACENTPOS] = []
	if !tile_empty(tile + Vector2i.DOWN):
		adjacents.append(ADJACENTPOS.DOWN)
	if !tile_empty(tile + Vector2i.UP):
		adjacents.append(ADJACENTPOS.UP)
	if !tile_empty(tile + Vector2i.LEFT):
		adjacents.append(ADJACENTPOS.LEFT)
	if !tile_empty(tile + Vector2i.RIGHT):
		adjacents.append(ADJACENTPOS.RIGHT)
	
	return adjacents

func find_rail_orientation(tile : Vector2i) -> ORIENTATION:
	var adjacents : Array[ADJACENTPOS] = find_adjacents(tile)
	if len(adjacents) == 0:
		return ORIENTATION.NS
	if len(adjacents) == 1:
		match adjacents[0]:
			ADJACENTPOS.UP:
				return ORIENTATION.NS
			ADJACENTPOS.DOWN:
				return ORIENTATION.NS
			ADJACENTPOS.LEFT:
				return ORIENTATION.WE
			ADJACENTPOS.RIGHT:
				return ORIENTATION.WE
	if len(adjacents) > 2:
		if ADJACENTPOS.UP not in adjacents:
			return ORIENTATION.WE
		if ADJACENTPOS.DOWN not in adjacents:
			return ORIENTATION.WE
		if ADJACENTPOS.LEFT not in adjacents:
			return ORIENTATION.NS
		if ADJACENTPOS.RIGHT not in adjacents:
			return ORIENTATION.NS
		return get_tile_orientation(tile)
	match adjacents[0]:
		ADJACENTPOS.UP:
			if adjacents[1] == ADJACENTPOS.DOWN:
				return ORIENTATION.NS
			if adjacents[1] == ADJACENTPOS.RIGHT:
				return ORIENTATION.NE
			return ORIENTATION.NW
		ADJACENTPOS.DOWN:
			if adjacents[1] == ADJACENTPOS.UP:
				return ORIENTATION.NS
			if adjacents[1] == ADJACENTPOS.RIGHT:
				return ORIENTATION.SE
			return ORIENTATION.SW
		ADJACENTPOS.LEFT:
			if adjacents[1] == ADJACENTPOS.RIGHT:
				return ORIENTATION.WE
			if adjacents[1] == ADJACENTPOS.UP:
				return ORIENTATION.NW
			return ORIENTATION.SW
		ADJACENTPOS.RIGHT:
			if adjacents[1] == ADJACENTPOS.LEFT:
				return ORIENTATION.WE
			if adjacents[1] == ADJACENTPOS.UP:
				return ORIENTATION.NE
			return ORIENTATION.SE
		_:
			return ORIENTATION.NS

func update_tile(tile : Vector2i):
	if tile_empty(tile):
		return
	var orientation := find_rail_orientation(tile)
	var atlas_coords := orientation_to_atlas(orientation)
	tile_map_layer.set_cell(tile, 0, atlas_coords)

func get_tile_orientation(tile : Vector2i) -> ORIENTATION:
	if tile_empty(tile):
		return ORIENTATION.NS
	var tile_type : String = tile_map_layer.get_cell_tile_data(tile).get_custom_data("Orientation")
	match tile_type:
		"WE":
			return ORIENTATION.WE
		"NS":
			return ORIENTATION.NS
		"NW":
			return ORIENTATION.NW
		"NE":
			return ORIENTATION.NE
		"SW":
			return ORIENTATION.SW
		"SE":
			return ORIENTATION.SE
		_:
			return ORIENTATION.NS
