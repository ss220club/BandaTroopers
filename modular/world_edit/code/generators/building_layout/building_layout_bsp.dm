/datum/world_edit_bsp_node
	var/datum/world_edit_bsp_node/left
	var/datum/world_edit_bsp_node/right
	var/x = 0
	var/y = 0
	var/width = 0
	var/height = 0
	var/min_size = 4
	var/is_leaf = TRUE
	var/datum/world_edit_room_node/assigned_room

/datum/world_edit_bsp_node/New(x_val, y_val, w_val, h_val, min_s = 4)
	x = x_val
	y = y_val
	width = w_val
	height = h_val
	min_size = min_s

/datum/world_edit_bsp_node/proc/split(datum/world_edit_building_prng/prng)
	if(!is_leaf)
		return FALSE // Already split

	var/split_h = FALSE
	if(width > height && width / height >= 1.25)
		split_h = FALSE
	else if(height > width && height / width >= 1.25)
		split_h = TRUE
	else
		// Random split
		split_h = (prng.next_value() % 2) == 0

	var/max_size = (split_h ? height : width) - min_size
	if(max_size <= min_size)
		return FALSE // Too small to split

	var/split_point = min_size + prng.next_between(0, max_size - min_size - 1)

	if(split_h)
		left = new(x, y, width, split_point, min_size)
		right = new(x, y + split_point, width, height - split_point, min_size)
	else
		left = new(x, y, split_point, height, min_size)
		right = new(x + split_point, y, width - split_point, height, min_size)

	is_leaf = FALSE
	return TRUE

/datum/world_edit_bsp_node/proc/get_leaves()
	var/list/leaves = list()
	if(is_leaf)
		leaves += src
	else
		if(left)
			leaves += left.get_leaves()
		if(right)
			leaves += right.get_leaves()
	return leaves
