extends TileSet
tool

func _is_tile_bound(drawn_id: int, neighbor_id: int) -> bool:
	#print_debug("drawn: ", drawn_id, ", neighbor: ", neighbor_id)
	if neighbor_id > 0:
		return true
	return false
