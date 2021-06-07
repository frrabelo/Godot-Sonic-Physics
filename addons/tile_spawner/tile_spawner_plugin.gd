tool
extends EditorPlugin

const TileSpawnerControls = preload("res://addons/tile_spawner/tile_spawner_controls.tscn")
const ACTIONS = preload('res://addons/tile_spawner/tile_spawner_action.gd')

func _enter_tree():
	# Listen to selection changes so we can show custom buttons
	var selection = get_editor_interface().get_selection().connect("selection_changed", self, "selection_changed")

	# Register TileSpawner node
	add_custom_type("TileSpawner", "Node2D", load("res://addons/tile_spawner/tile_spawner.gd"), load("res://addons/tile_spawner/tile_spawner_icon.png"))

	# Register TileSpawnerMapping resource
	# add_custom_type("TileSpawnerMapping", "Resource", preload("res://addons/tile_spawner/tile_spawner_mapping.gd"), preload("res://addons/tile_spawner/tile_spawner_mapping_icon.png"))

func _exit_tree():
	# Clean up any UI changes
	remove_tile_spawner_controls()

	# Unregister TileSpawnerMapping resource
	#remove_custom_type("TileSpawnerMapping")

	# Unregister TileSpawner
	remove_custom_type("TileSpawner")

	# Stop listening for selection changes
	get_editor_interface().get_selection().disconnect("selection_changed", self, "selection_changed")

func selection_changed():
	# When the current selection changes, check to see what's now selected
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()

	# Only show the controls when one node is selected.
	# Note: Perhaps this check isn't necessary
	if selected_nodes == null or selected_nodes.size() != 1:
		remove_tile_spawner_controls()
		return

	var related_tile_spawners = filter_related_tile_spawners(selected_nodes)
	if related_tile_spawners.size() > 0:
		add_tile_spawner_controls()
	else:
		remove_tile_spawner_controls()

# Given a tile_map, find the tile_spawners that are targeting it.
func get_source_tile_spawners(tile_map):
	var tile_spawners = []
	for tile_spawner in get_tree().get_nodes_in_group(ACTIONS.UUID_TILE_SPAWNER):
		if tile_spawner.get_source_tilemap() == tile_map:
			tile_spawners.push_back(tile_spawner)
	return tile_spawners

# Given a list of nodes, return all related tile_spawners, either directly or
# indirectly from the list
func filter_related_tile_spawners(nodes):
	var tile_spawners = []
	for node in nodes:

		# Add a node if it is a tile spawner
		if node.is_in_group(ACTIONS.UUID_TILE_SPAWNER):
			tile_spawners.push_back(node)
			continue

		# Add any tile_spawners targeting this node.
		var source_tile_spawners = get_source_tile_spawners(node)
		tile_spawners = array_extend(tile_spawners, source_tile_spawners)

	return tile_spawners

static func array_extend(array1, array2):
	for item in array2:
		array1.push_back(item)
	return array1

func undo_spawn(tile_spawner, old_children):
	ACTIONS.free_children(tile_spawner)
	var scene_root = get_tree().get_edited_scene_root()
	for child in old_children:
		tile_spawner.add_child(child)
		child.set_owner(scene_root)


func bake_button_pressed():
	# Get all nodes selected
	var selected_nodes = get_editor_interface().get_selection().get_selected_nodes()

	# Only bake when one node is selected.
	# Note: Perhaps this check isn't necessary
	if selected_nodes == null or selected_nodes.size() != 1:
		print("Error: Trying to bake with multiple nodes selected")
		return

	var related_tile_spawners = filter_related_tile_spawners(selected_nodes)
	if related_tile_spawners.size() <= 0:
		print("Error: Trying to bake without a TileSpawner or TileMap selected")
		return

	var undo_redo = get_undo_redo()
	undo_redo.create_action("Bake Tile Spawner")

	# Do the tilemap spawning
	for tile_spawner in related_tile_spawners:
		undo_redo.add_undo_method(self, "undo_spawn", tile_spawner, tile_spawner.get_children())
		undo_redo.add_do_method(self, "spawn_from_tilemap", get_tree(), tile_spawner)
		ACTIONS.spawn_from_tilemap(get_tree(), tile_spawner)
	
	undo_redo.commit_action()

func add_tile_spawner_controls():
	# If the tile spawner controls are already present, don't add them again
	if len(get_tree().get_nodes_in_group(ACTIONS.UUID_TILE_SPAWNER_CONTROLS)) > 0:
		return

	# Add the controls to the editor
	var tile_spawner_controls = TileSpawnerControls.instance()
	tile_spawner_controls.add_to_group(ACTIONS.UUID_TILE_SPAWNER_CONTROLS)
	add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU, tile_spawner_controls)

	# Listen for events from the controls so we can react to them
	tile_spawner_controls.get_node("bake_button").connect("pressed", self, "bake_button_pressed")

func remove_tile_spawner_controls():
	for tile_spawner_controls in get_tree().get_nodes_in_group(ACTIONS.UUID_TILE_SPAWNER_CONTROLS):
		# Remove the controls from the editor
		remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU, tile_spawner_controls)

		# Free the controls
		tile_spawner_controls.queue_free()
