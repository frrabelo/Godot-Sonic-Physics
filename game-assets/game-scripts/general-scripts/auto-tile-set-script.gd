extends TileSet
tool

export(PoolIntArray) var id_neighbors = []
export(PoolIntArray) var id_drawn = []

func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	print_debug("drawn: ", drawn_id, ", neighbor: ", neighbor_id)
	for i in id_neighbors:
		if i == neighbor_id:
			return true
	return false
