/// Rotate the texture around its own center, then place that center on the source tile.
/// The native get_matrix rotates its translation when rebuilding after a radius change.
/atom/movable/lighting_mask/flashlight_60/get_matrix(radius = 1)
	var/matrix/result = matrix()
	result.Scale(radius / 4)
	result.Turn(current_angle)
	result.Translate((world.icon_size - 256) / 2, (world.icon_size - 256) / 2)
	return result

/// Rebuild absolutely: repeated rotations and range changes must never move the origin.
/atom/movable/lighting_mask/flashlight_60/proc/set_beam_transform(angle)
	current_angle = angle
	var/matrix/new_transform = get_matrix(radius)
	overlays.Cut()
	for(var/mutable_appearance/shadow as anything in shadows)
		shadow.transform *= transform
		shadow.transform /= new_transform
	transform = new_transform
	overlays += shadows
