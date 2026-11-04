#define PIXEL_SHIFT_MAX 32
#define PIXEL_SHIFT_PASS_CAP 8
#define PIXEL_SHIFT_TRAIT_SOURCE "pixel-shift"

/mob
	var/is_shifted = FALSE
	var/shifting = FALSE

/datum/keybinding/mob/pixel_shift
	hotkey_keys = list("J")
	name = "pixel_shift"
	full_name = "Pixel Shift"
	description = "Shift your characters offset."
	category = CATEGORY_MOVEMENT
	keybind_signal = COMSIG_KB_MOB_PIXEL_SHIFT_DOWN
	weight = WEIGHT_HIGHEST

/datum/keybinding/mob/pixel_shift/down(client/user)
	. = ..()
	if(.)
		return
	var/mob/shifted_mob = user.mob
	if(shifted_mob)
		shifted_mob.shifting = TRUE
	return TRUE

/datum/keybinding/mob/pixel_shift/up(client/user)
	. = ..()
	if(.)
		return
	var/mob/shifted_mob = user.mob
	if(shifted_mob)
		shifted_mob.shifting = FALSE
	return TRUE

/mob/proc/unpixel_shift()
	if(!is_shifted)
		return FALSE
	is_shifted = FALSE
	pixel_x = 0
	pixel_y = 0
	return TRUE

/mob/proc/pixel_shift(direction)
	if(anchored || is_mob_incapacitated())
		return FALSE

	is_shifted = TRUE
	switch(direction)
		if(NORTH)
			pixel_y++
		if(EAST)
			pixel_x++
		if(SOUTH)
			pixel_y--
		if(WEST)
			pixel_x--

	pixel_x = clamp(pixel_x, -PIXEL_SHIFT_MAX, PIXEL_SHIFT_MAX)
	pixel_y = clamp(pixel_y, -PIXEL_SHIFT_MAX, PIXEL_SHIFT_MAX)
	return TRUE

/mob/living/unpixel_shift()
	. = ..()
	if(.)
		REMOVE_TRAIT(src, TRAIT_UNDENSE, PIXEL_SHIFT_TRAIT_SOURCE)

/mob/living/pixel_shift(direction)
	. = ..()
	if(!.)
		return

	if(pixel_x > PIXEL_SHIFT_PASS_CAP || pixel_x < -PIXEL_SHIFT_PASS_CAP || pixel_y > PIXEL_SHIFT_PASS_CAP || pixel_y < -PIXEL_SHIFT_PASS_CAP)
		ADD_TRAIT(src, TRAIT_UNDENSE, PIXEL_SHIFT_TRAIT_SOURCE)
		return

	REMOVE_TRAIT(src, TRAIT_UNDENSE, PIXEL_SHIFT_TRAIT_SOURCE)

/mob/proc/handle_pixel_shift_movement(direction)
	if(shifting)
		pixel_shift(direction)
		return TRUE
	unpixel_shift()
	return FALSE

/mob/Move(atom/new_loc, direction)
	unpixel_shift()
	. = ..()

#undef PIXEL_SHIFT_MAX
#undef PIXEL_SHIFT_PASS_CAP
#undef PIXEL_SHIFT_TRAIT_SOURCE
