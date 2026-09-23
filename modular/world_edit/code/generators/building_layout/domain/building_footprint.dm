/datum/world_edit_building_footprint_cell
	var/x = 0
	var/y = 0
	var/z_level = 0
	var/turf/source_turf

/datum/world_edit_building_footprint_cell/New(_x = 0, _y = 0, _z_level = 0, turf/_source_turf = null)
	. = ..()
	x = round(text2num("[_x]") || 0)
	y = round(text2num("[_y]") || 0)
	z_level = round(text2num("[_z_level]") || 0)
	source_turf = _source_turf

/datum/world_edit_building_footprint_cell/proc/cell_key()
	return "[x],[y],[z_level]"

/datum/world_edit_building_footprint
	var/family_id = WORLD_EDIT_BUILDING_FOOTPRINT_FAMILY_RECT
	var/shape_id = WORLD_EDIT_SHAPE_POINT
	var/list/cells = list()
	var/list/lookup = list()
	var/list/boundary = list()
	var/list/interior = list()
	var/list/connected_components = list()
	var/list/entry_edge_candidates = list()
	var/width = 0
	var/depth = 0
	var/z_level = 0
	var/hash = ""

/datum/world_edit_building_footprint/proc/add_cell(datum/world_edit_building_footprint_cell/cell)
	if(!istype(cell))
		return FALSE
	var/cell_lookup_key = cell.cell_key()
	if(lookup[cell_lookup_key])
		return FALSE
	cells += cell
	lookup[cell_lookup_key] = cell
	if(cell.x > width)
		width = cell.x
	if(cell.y > depth)
		depth = cell.y
	if(!z_level && cell.z_level)
		z_level = cell.z_level
	return TRUE

/datum/world_edit_building_footprint/proc/rebuild_lookup()
	lookup = list()
	for(var/datum/world_edit_building_footprint_cell/cell as anything in cells)
		if(!istype(cell))
			continue
		lookup[cell.cell_key()] = cell
	return lookup

/datum/world_edit_building_footprint/proc/copy_cells()
	return islist(cells) ? cells.Copy() : list()

/datum/world_edit_building_footprint/proc/as_payload()
	return list(
		"family_id" = family_id,
		"shape_id" = shape_id,
		"cell_count" = length(cells),
		"boundary_count" = length(boundary),
		"interior_count" = length(interior),
		"component_count" = length(connected_components),
		"entry_edge_candidate_count" = length(entry_edge_candidates),
		"width" = width,
		"depth" = depth,
		"z_level" = z_level,
		"hash" = hash,
	)
