/datum/world_edit_room_graph
	var/list/datum/world_edit_room_node/nodes = list()
	var/list/datum/world_edit_room_edge/edges = list()
	var/datum/world_edit_room_node/root_node

/datum/world_edit_room_graph/proc/add_node(id, room_type, size_class)
	var/datum/world_edit_room_node/node = new(id, room_type, size_class)
	nodes += node
	return node

/datum/world_edit_room_graph/proc/add_edge(datum/world_edit_room_node/a, datum/world_edit_room_node/b, edge_type = "door")
	var/datum/world_edit_room_edge/edge = new(a, b, edge_type)
	edges += edge
	a.connections += edge
	b.connections += edge
	return edge

/datum/world_edit_room_node
	var/id
	var/room_type
	var/size_class
	var/importance = 1
	var/list/datum/world_edit_room_edge/connections = list()
	var/shape_profile = "rectangle"
	var/list/tags = list()
	var/interior_preset
	var/purpose
	var/faction
	var/danger = 0
	var/clutter_density = 0
	// Fields assigned during BSP mapping
	var/list/turfs = list()
	var/x = 0
	var/y = 0
	var/width = 0
	var/height = 0

/datum/world_edit_room_node/New(id_val, type_val, size_class_val)
	id = id_val
	room_type = type_val
	size_class = size_class_val

/datum/world_edit_room_edge
	var/datum/world_edit_room_node/node_a
	var/datum/world_edit_room_node/node_b
	var/edge_type

/datum/world_edit_room_edge/New(datum/world_edit_room_node/a, datum/world_edit_room_node/b, type_val)
	node_a = a
	node_b = b
	edge_type = type_val

/datum/world_edit_room_edge/proc/get_other(datum/world_edit_room_node/node)
	if(node == node_a)
		return node_b
	if(node == node_b)
		return node_a
	return null
