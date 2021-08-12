extends TileSet
tool

var oneway

func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	#print_debug("drawn: ", drawn_id, ", neighbor: ", neighbor_id)
	if neighbor_id >= 0:
		return true
	return false

func _gen_collision (tile_id) -> void:
	var region_size : Vector2 = tile_get_region(tile_id).size 
	var subtile_size : Vector2 = autotile_get_size(tile_id)
	var dimensions = region_size / subtile_size
	var subtile_amount = ceil(dimensions.x) * ceil(dimensions.y)
	for x in dimensions.x:
		for y in dimensions.y:
			var shape = ConvexPolygonShape2D.new()
			shape.points = [Vector2.ZERO, Vector2(subtile_size.x, 0), Vector2(0, subtile_size.y), Vector2(subtile_size.x, subtile_size.y)]
			tile_add_shape(tile_id, shape, Transform2D(0, Vector2.ZERO), false, Vector2(x, y))
