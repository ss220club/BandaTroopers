/mob/living/carbon/xenomorph/pony/proc/get_pony_seed_base()
	return "[type]-[caste_type]-[pony_sprite_seed]-[nicknumber]"

/mob/living/carbon/xenomorph/pony/proc/get_pony_hash_value(salt)
	var/hash = md5("[get_pony_seed_base()]-[salt]")
	var/value = 0
	for(var/index = 1, index <= length(hash), index += 3)
		value += text2ascii(hash, index)
	return value

/mob/living/carbon/xenomorph/pony/proc/pony_pick_from_list(list/options, salt, default_value = null)
	if(!length(options))
		return default_value
	return options[(get_pony_hash_value(salt) % length(options)) + 1]

/mob/living/carbon/xenomorph/pony/proc/pony_pick_color(list/palette_keys, salt, fallback_color = "#FFFFFF")
	if(!length(palette_keys))
		return fallback_color

	var/palette_key = pony_pick_from_list(palette_keys, "[salt]-palette", palette_keys[1])
	var/list/palette_bank = GLOB.pony_xeno_palette_banks[palette_key]
	if(!length(palette_bank))
		return fallback_color
	return pony_pick_from_list(palette_bank, "[salt]-color", fallback_color)

/mob/living/carbon/xenomorph/pony/proc/pony_pick_distinct_color(list/palette_keys, salt, primary_color, fallback_color = "#000000")
	var/color_choice = pony_pick_color(palette_keys, salt, fallback_color)
	if(color_choice == primary_color)
		color_choice = pony_pick_color(palette_keys, "[salt]-secondary", fallback_color)
	return color_choice == primary_color ? fallback_color : color_choice

/mob/living/carbon/xenomorph/pony/proc/get_pony_variant_pool_for_caste()
	return list(
		PONY_XENO_LAYER_BODY = pony_body_variant_pool,
		PONY_XENO_LAYER_MANE_FRONT = pony_mane_front_variant_pool,
		PONY_XENO_LAYER_MANE_BACK = pony_mane_back_variant_pool,
		PONY_XENO_LAYER_TAIL = pony_tail_variant_pool,
		PONY_XENO_LAYER_EYES = pony_eye_variant_pool,
		PONY_XENO_LAYER_HORN = pony_horn_variant_pool,
		PONY_XENO_LAYER_WINGS = pony_wing_variant_pool,
		PONY_XENO_LAYER_CUTIE_MARK = pony_cutie_mark_variant_pool,
		PONY_XENO_LAYER_ARMOR = pony_armor_variant_pool
	)

/mob/living/carbon/xenomorph/pony/proc/get_pony_palette_for_caste()
	return list(
		PONY_XENO_LAYER_BODY = pony_body_palette_keys,
		PONY_XENO_LAYER_MANE_FRONT = pony_mane_palette_keys,
		PONY_XENO_LAYER_MANE_BACK = pony_mane_palette_keys,
		PONY_XENO_LAYER_TAIL = pony_tail_palette_keys,
		PONY_XENO_LAYER_EYES = pony_eye_palette_keys,
		PONY_XENO_LAYER_ARMOR = pony_armor_palette_keys
	)

/mob/living/carbon/xenomorph/pony/proc/randomize_pony_appearance(force = FALSE)
	if(pony_appearance && !force)
		return pony_appearance

	if(!pony_appearance)
		pony_appearance = new

	var/list/variant_pool = get_pony_variant_pool_for_caste()
	var/list/palette_pool = get_pony_palette_for_caste()

	pony_appearance.sprite_seed = pony_sprite_seed
	pony_appearance.body_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_BODY], "body-variant", "battle")
	pony_appearance.mane_front_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_MANE_FRONT], "mane-front", "wintershield")
	pony_appearance.mane_back_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_MANE_BACK], "mane-back", pony_appearance.mane_front_variant)
	pony_appearance.tail_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_TAIL], "tail-variant", "standard")
	pony_appearance.eye_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_EYES], "eye-variant", "standard")
	pony_appearance.horn_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_HORN], "horn-variant", PONY_XENO_NONE)
	pony_appearance.wing_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_WINGS], "wing-variant", PONY_XENO_NONE)
	pony_appearance.cutie_mark_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_CUTIE_MARK], "cutie-variant", PONY_XENO_NONE)
	pony_appearance.armor_variant = pony_pick_from_list(variant_pool[PONY_XENO_LAYER_ARMOR], "armor-variant", pony_default_armor_variant)

	pony_appearance.body_color = pony_pick_color(palette_pool[PONY_XENO_LAYER_BODY], "body-color", "#FFFFFF")
	pony_appearance.mane_primary_color = pony_pick_color(palette_pool[PONY_XENO_LAYER_MANE_FRONT], "mane-primary", "#FF8C42")
	pony_appearance.mane_secondary_color = pony_pick_distinct_color(palette_pool[PONY_XENO_LAYER_MANE_BACK], "mane-secondary", pony_appearance.mane_primary_color, "#2F1B5A")
	pony_appearance.tail_primary_color = pony_pick_color(palette_pool[PONY_XENO_LAYER_TAIL], "tail-primary", pony_appearance.mane_primary_color)
	pony_appearance.tail_secondary_color = pony_pick_distinct_color(palette_pool[PONY_XENO_LAYER_TAIL], "tail-secondary", pony_appearance.tail_primary_color, pony_appearance.mane_secondary_color)
	pony_appearance.eye_color = pony_pick_color(palette_pool[PONY_XENO_LAYER_EYES], "eye-color", "#222222")
	pony_appearance.armor_tint = BlendRGB(pony_appearance.body_color, pony_pick_color(palette_pool[PONY_XENO_LAYER_ARMOR], "armor-tint", "#4B2E83"), 0.62)
	return pony_appearance

/mob/living/carbon/xenomorph/pony/proc/get_pony_render_direction(direction)
	if((direction in GLOB.cardinals))
		return direction

	switch(direction)
		if(NORTHEAST, SOUTHEAST)
			return EAST
		if(NORTHWEST, SOUTHWEST)
			return WEST

	return SOUTH

/mob/living/carbon/xenomorph/pony/proc/build_pony_appearance_key(state_name, direction)
	randomize_pony_appearance()
	var/render_direction = get_pony_render_direction(direction)
	return "[type]|[caste_type]|[pony_appearance.body_variant]|[pony_appearance.mane_front_variant]|[pony_appearance.mane_back_variant]|[pony_appearance.tail_variant]|[pony_appearance.eye_variant]|[pony_appearance.horn_variant]|[pony_appearance.wing_variant]|[pony_appearance.cutie_mark_variant]|[pony_appearance.armor_variant]|[pony_appearance.body_color]|[pony_appearance.mane_primary_color]|[pony_appearance.mane_secondary_color]|[pony_appearance.tail_primary_color]|[pony_appearance.tail_secondary_color]|[pony_appearance.eye_color]|[pony_appearance.armor_tint]|[state_name]|[render_direction]"

/mob/living/carbon/xenomorph/pony/proc/get_pony_caste_label()
	return caste?.caste_type || caste_type

/mob/living/carbon/xenomorph/pony/proc/get_pony_external_state_name(state_name)
	switch(state_name)
		if(PONY_XENO_STATE_WALKING)
			return "Normal [get_pony_caste_label()] Walking"
		if(PONY_XENO_STATE_RUNNING)
			return "Normal [get_pony_caste_label()] Running"
		if(PONY_XENO_STATE_SLEEPING)
			return "Normal [get_pony_caste_label()] Sleeping"
		if(PONY_XENO_STATE_KNOCKED_DOWN)
			return "Normal [get_pony_caste_label()] Knocked Down"
		if(PONY_XENO_STATE_DEATH)
			return "Normal [get_pony_caste_label()] Dead"
		if(PONY_XENO_STATE_ATTACKING)
			return "Normal [get_pony_caste_label()] Attacking"
	return "Normal [get_pony_caste_label()] Running"

/mob/living/carbon/xenomorph/pony/proc/get_pony_variant_data(list/catalog, key, fallback = null)
	if(!islist(catalog))
		return list()
	if(catalog[key])
		return catalog[key]
	if(fallback && catalog[fallback])
		return catalog[fallback]
	return list()

/mob/living/carbon/xenomorph/pony/proc/pony_state_uses_open_wings(state_name)
	return state_name == PONY_XENO_STATE_RUNNING || state_name == PONY_XENO_STATE_ATTACKING || state_name == PONY_XENO_STATE_IDLE

/mob/living/carbon/xenomorph/pony/proc/get_pony_sprite_layers_for_state(state_name)
	randomize_pony_appearance()

	var/list/layers = list()
	var/list/body_data = get_pony_variant_data(GLOB.pony_xeno_body_variants, pony_appearance.body_variant, "battle")
	var/list/mane_front_data = get_pony_variant_data(GLOB.pony_xeno_mane_variants, pony_appearance.mane_front_variant, "wintershield")
	var/list/mane_back_data = get_pony_variant_data(GLOB.pony_xeno_mane_variants, pony_appearance.mane_back_variant, "wintershield")
	var/list/tail_data = get_pony_variant_data(GLOB.pony_xeno_tail_variants, pony_appearance.tail_variant, "standard")
	var/list/horn_data = get_pony_variant_data(GLOB.pony_xeno_horn_variants, pony_appearance.horn_variant, PONY_XENO_NONE)
	var/list/wing_data = get_pony_variant_data(GLOB.pony_xeno_wing_variants, pony_appearance.wing_variant, PONY_XENO_NONE)
	var/list/cutie_data = get_pony_variant_data(GLOB.pony_xeno_cutie_variants, pony_appearance.cutie_mark_variant, PONY_XENO_NONE)
	var/list/armor_data = get_pony_variant_data(GLOB.pony_xeno_armor_variants, pony_appearance.armor_variant, pony_default_armor_variant)

	var/body_scale = body_data[PONY_XENO_RENDER_SCALE] || 1.2
	var/body_pixel_y = body_data[PONY_XENO_RENDER_PIXEL_Y] || 0

	layers += list(
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_BODY, PONY_XENO_RENDER_STATE = "m_pony_ears_pony_BEHIND", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_TAIL, PONY_XENO_RENDER_STATE = tail_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.tail_primary_color, PONY_XENO_RENDER_SCALE = (tail_data[PONY_XENO_RENDER_SCALE] || 1) * body_scale, PONY_XENO_RENDER_PIXEL_X = tail_data[PONY_XENO_RENDER_PIXEL_X] || 0, PONY_XENO_RENDER_PIXEL_Y = (tail_data[PONY_XENO_RENDER_PIXEL_Y] || 0) + body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_TAIL, PONY_XENO_RENDER_STATE = tail_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.tail_secondary_color, PONY_XENO_RENDER_SCALE = ((tail_data[PONY_XENO_RENDER_SCALE] || 1) * body_scale) * 0.97, PONY_XENO_RENDER_PIXEL_X = (tail_data[PONY_XENO_RENDER_PIXEL_X] || 0) + 1, PONY_XENO_RENDER_PIXEL_Y = (tail_data[PONY_XENO_RENDER_PIXEL_Y] || 0) + body_pixel_y + 1, PONY_XENO_RENDER_ALPHA = 120),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_MANE_BACK, PONY_XENO_RENDER_STATE = mane_back_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.mane_primary_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y - 1),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_MANE_BACK, PONY_XENO_RENDER_STATE = mane_back_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.mane_secondary_color, PONY_XENO_RENDER_SCALE = body_scale * 0.95, PONY_XENO_RENDER_PIXEL_X = 1, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y, PONY_XENO_RENDER_ALPHA = 110)
	)

	if(pony_appearance.wing_variant != PONY_XENO_NONE)
		layers += list(
			list(
				PONY_XENO_RENDER_ICON = PONY_XENO_ICON_WINGS,
				PONY_XENO_RENDER_STATE = pony_state_uses_open_wings(state_name) ? "m_pony_wings_pony_FRONT" : "m_pony_wings_pony_folded_FRONT",
				PONY_XENO_RENDER_COLOR = pony_appearance.body_color,
				PONY_XENO_RENDER_SCALE = (wing_data[PONY_XENO_RENDER_SCALE] || 1) * body_scale,
				PONY_XENO_RENDER_PIXEL_X = wing_data[PONY_XENO_RENDER_PIXEL_X] || 0,
				PONY_XENO_RENDER_PIXEL_Y = (wing_data[PONY_XENO_RENDER_PIXEL_Y] || 0) + body_pixel_y
			)
		)

	layers += list(
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_BODY, PONY_XENO_RENDER_STATE = "pony_chest", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_BODY, PONY_XENO_RENDER_STATE = "pony_head", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_LEGS_FRONT, PONY_XENO_RENDER_STATE = "pony_l_arm", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_LEGS_FRONT, PONY_XENO_RENDER_STATE = "pony_r_arm", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_LEGS_BACK, PONY_XENO_RENDER_STATE = "pony_l_leg", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_LEGS_BACK, PONY_XENO_RENDER_STATE = "pony_r_leg", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y)
	)

	if(pony_appearance.cutie_mark_variant != PONY_XENO_NONE)
		layers += list(
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_CUTIE, PONY_XENO_RENDER_STATE = cutie_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.mane_secondary_color, PONY_XENO_RENDER_SCALE = cutie_data[PONY_XENO_RENDER_SCALE] || 0.45, PONY_XENO_RENDER_PIXEL_X = cutie_data[PONY_XENO_RENDER_PIXEL_X] || 0, PONY_XENO_RENDER_PIXEL_Y = (cutie_data[PONY_XENO_RENDER_PIXEL_Y] || 0) + body_pixel_y, PONY_XENO_RENDER_ALPHA = 150)
		)

	if(pony_appearance.armor_variant != PONY_XENO_NONE)
		layers += list(
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_ARMOR, PONY_XENO_RENDER_STATE = armor_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.armor_tint, PONY_XENO_RENDER_SCALE = (armor_data[PONY_XENO_RENDER_SCALE] || 1) * body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y, PONY_XENO_RENDER_ALPHA = 170)
		)

	layers += list(
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_BODY, PONY_XENO_RENDER_STATE = "m_pony_ears_pony_ADJ", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_MANE_FRONT, PONY_XENO_RENDER_STATE = mane_front_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.mane_primary_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y - 1),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_MANE_FRONT, PONY_XENO_RENDER_STATE = mane_front_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.mane_secondary_color, PONY_XENO_RENDER_SCALE = body_scale * 0.95, PONY_XENO_RENDER_PIXEL_X = 1, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y, PONY_XENO_RENDER_ALPHA = 110),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_BODY, PONY_XENO_RENDER_STATE = "m_pony_ears_pony_FRONT", PONY_XENO_RENDER_COLOR = pony_appearance.body_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_EYES, PONY_XENO_RENDER_STATE = "pony_eye_l", PONY_XENO_RENDER_COLOR = pony_appearance.eye_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y),
		list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_EYES, PONY_XENO_RENDER_STATE = "pony_eye_r", PONY_XENO_RENDER_COLOR = pony_appearance.eye_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y)
	)

	if(pony_appearance.eye_variant != "standard")
		layers += list(
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_EYES, PONY_XENO_RENDER_STATE = "pony_eyelids", PONY_XENO_RENDER_COLOR = pony_appearance.eye_color, PONY_XENO_RENDER_SCALE = body_scale, PONY_XENO_RENDER_PIXEL_Y = body_pixel_y, PONY_XENO_RENDER_ALPHA = pony_appearance.eye_variant == "arcane" ? 160 : 210)
		)

	if(pony_appearance.horn_variant != PONY_XENO_NONE)
		layers += list(
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_HORN, PONY_XENO_RENDER_STATE = horn_data[PONY_XENO_RENDER_STATE], PONY_XENO_RENDER_COLOR = pony_appearance.eye_variant == "arcane" ? pony_appearance.eye_color : pony_appearance.body_color, PONY_XENO_RENDER_SCALE = (horn_data[PONY_XENO_RENDER_SCALE] || 1) * body_scale, PONY_XENO_RENDER_PIXEL_Y = (horn_data[PONY_XENO_RENDER_PIXEL_Y] || 0) + body_pixel_y)
		)

	if(state_name == PONY_XENO_STATE_DEATH)
		layers += list(
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_BLOOD, PONY_XENO_RENDER_STATE = "csplatter3", PONY_XENO_RENDER_COLOR = get_blood_color(), PONY_XENO_RENDER_SCALE = 1.35, PONY_XENO_RENDER_PIXEL_X = 4, PONY_XENO_RENDER_PIXEL_Y = 6, PONY_XENO_RENDER_ALPHA = 150, PONY_XENO_RENDER_PRESERVE_COLOR = TRUE),
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_DEATH, PONY_XENO_RENDER_STATE = "csplatter5", PONY_XENO_RENDER_COLOR = "#5A3C3C", PONY_XENO_RENDER_SCALE = 1.40, PONY_XENO_RENDER_PIXEL_X = -2, PONY_XENO_RENDER_PIXEL_Y = 8, PONY_XENO_RENDER_ALPHA = 170, PONY_XENO_RENDER_PRESERVE_COLOR = TRUE)
		)
	else if(state_name == PONY_XENO_STATE_ATTACKING)
		layers += list(
			list(PONY_XENO_RENDER_ICON = PONY_XENO_ICON_CUTIE, PONY_XENO_RENDER_STATE = "tele_effect", PONY_XENO_RENDER_COLOR = pony_appearance.eye_color, PONY_XENO_RENDER_SCALE = 0.72, PONY_XENO_RENDER_PIXEL_X = 6, PONY_XENO_RENDER_PIXEL_Y = 6, PONY_XENO_RENDER_ALPHA = 110)
		)

	return layers

/mob/living/carbon/xenomorph/pony/proc/build_pony_layer_icon(list/layer_data, direction)
	var/icon_file = layer_data[PONY_XENO_RENDER_ICON]
	var/icon_state = layer_data[PONY_XENO_RENDER_STATE]
	if(!icon_file || !icon_state)
		return null

	var/render_direction = get_pony_render_direction(direction)
	var/icon/part = new /icon(icon_file, icon_state, render_direction)
	var/scale = layer_data[PONY_XENO_RENDER_SCALE] || 1
	if(scale != 1)
		part.Scale(max(1, round(part.Width() * scale)), max(1, round(part.Height() * scale)))

	var/color_to_apply = layer_data[PONY_XENO_RENDER_COLOR]
	if(color_to_apply)
		if(!layer_data[PONY_XENO_RENDER_PRESERVE_COLOR])
			part.GrayScale()
		part.Blend(color_to_apply, ICON_MULTIPLY)

	var/alpha = layer_data[PONY_XENO_RENDER_ALPHA]
	if(!isnull(alpha) && alpha < 255)
		part.Blend(rgb(255, 255, 255, alpha), ICON_MULTIPLY)

	return part

/mob/living/carbon/xenomorph/pony/proc/get_pony_directional_offset(direction)
	var/offset_x = 0
	var/offset_y = 0

	switch(direction)
		if(NORTH)
			offset_x = pony_directional_north_x
			offset_y = pony_directional_north_y
		if(SOUTH)
			offset_x = pony_directional_south_x
			offset_y = pony_directional_south_y
		if(EAST)
			offset_x = pony_directional_east_x
			offset_y = pony_directional_east_y
		if(WEST)
			offset_x = pony_directional_west_x
			offset_y = pony_directional_west_y

	return list(offset_x, offset_y)

/mob/living/carbon/xenomorph/pony/proc/get_pony_state_offset(state_name)
	var/offset_x = 0
	var/offset_y = 0
	switch(state_name)
		if(PONY_XENO_STATE_ATTACKING)
			offset_y = -1
		if(PONY_XENO_STATE_SLEEPING, PONY_XENO_STATE_KNOCKED_DOWN)
			offset_y = 2
		if(PONY_XENO_STATE_DEATH)
			offset_y = 3

	return list(offset_x, offset_y)

/mob/living/carbon/xenomorph/pony/proc/get_pony_layer_directional_offset(list/layer_data, direction)
	var/offset_x = 0
	var/offset_y = 0
	var/render_direction = get_pony_render_direction(direction)

	switch(render_direction)
		if(NORTH)
			offset_x = layer_data[PONY_XENO_RENDER_NORTH_PIXEL_X] || 0
			offset_y = layer_data[PONY_XENO_RENDER_NORTH_PIXEL_Y] || 0
		if(SOUTH)
			offset_x = layer_data[PONY_XENO_RENDER_SOUTH_PIXEL_X] || 0
			offset_y = layer_data[PONY_XENO_RENDER_SOUTH_PIXEL_Y] || 0
		if(EAST)
			offset_x = layer_data[PONY_XENO_RENDER_EAST_PIXEL_X] || 0
			offset_y = layer_data[PONY_XENO_RENDER_EAST_PIXEL_Y] || 0
		if(WEST)
			offset_x = layer_data[PONY_XENO_RENDER_WEST_PIXEL_X] || 0
			offset_y = layer_data[PONY_XENO_RENDER_WEST_PIXEL_Y] || 0

	return list(offset_x, offset_y)

/mob/living/carbon/xenomorph/pony/proc/get_pony_layer_blend_position(icon/canvas, icon/part, list/layer_data, state_name, direction)
	var/list/directional_offset = get_pony_directional_offset(direction)
	var/list/state_offset = get_pony_state_offset(state_name)
	var/list/layer_directional_offset = get_pony_layer_directional_offset(layer_data, direction)
	var/base_x = round((canvas.Width() - part.Width()) / 2)
	var/base_y = round((canvas.Height() - part.Height()) / 2)
	var/directional_x = (islist(directional_offset) && length(directional_offset) >= 1) ? (directional_offset[1] || 0) : 0
	var/directional_y = (islist(directional_offset) && length(directional_offset) >= 2) ? (directional_offset[2] || 0) : 0
	var/state_x = (islist(state_offset) && length(state_offset) >= 1) ? (state_offset[1] || 0) : 0
	var/state_y = (islist(state_offset) && length(state_offset) >= 2) ? (state_offset[2] || 0) : 0
	var/layer_directional_x = (islist(layer_directional_offset) && length(layer_directional_offset) >= 1) ? (layer_directional_offset[1] || 0) : 0
	var/layer_directional_y = (islist(layer_directional_offset) && length(layer_directional_offset) >= 2) ? (layer_directional_offset[2] || 0) : 0

	return list(
		base_x + pony_render_offset_x + directional_x + state_x + layer_directional_x + (layer_data[PONY_XENO_RENDER_PIXEL_X] || 0),
		base_y + pony_render_offset_y + directional_y + state_y + layer_directional_y + (layer_data[PONY_XENO_RENDER_PIXEL_Y] || 0)
	)

/mob/living/carbon/xenomorph/pony/proc/get_pony_runtime_state_name()
	if(stat == DEAD)
		return PONY_XENO_STATE_DEATH

	if(body_position == LYING_DOWN)
		if(!HAS_TRAIT(src, TRAIT_INCAPACITATED) && !HAS_TRAIT(src, TRAIT_FLOORED))
			return PONY_XENO_STATE_SLEEPING
		return PONY_XENO_STATE_KNOCKED_DOWN

	if(m_intent != MOVE_INTENT_RUN)
		return PONY_XENO_STATE_WALKING

	return PONY_XENO_STATE_RUNNING

/mob/living/carbon/xenomorph/pony/proc/get_generated_pony_icon(state_name, direction)
	var/cache_key = build_pony_appearance_key(state_name, direction)
	if(GLOB.pony_xeno_generated_icons[cache_key])
		return GLOB.pony_xeno_generated_icons[cache_key]

	var/canvas_size = icon_size || PONY_XENO_ICON_CANVAS_SIZE
	var/icon/canvas = new /icon(PONY_XENO_ICON_STATES_BASE, PONY_XENO_ICON_STATE_EMPTY, SOUTH)
	canvas.Scale(canvas_size, canvas_size)

	var/list/layers = get_pony_sprite_layers_for_state(state_name)
	for(var/list/layer_data as anything in layers)
		var/icon/part = build_pony_layer_icon(layer_data, direction)
		if(!part)
			continue

		var/list/blend_position = get_pony_layer_blend_position(canvas, part, layer_data, state_name, direction)
		if(!islist(blend_position) || length(blend_position) < 2)
			continue

		canvas.Blend(part, ICON_OVERLAY, blend_position[1], blend_position[2])

	if(state_name == PONY_XENO_STATE_SLEEPING || state_name == PONY_XENO_STATE_KNOCKED_DOWN || state_name == PONY_XENO_STATE_DEATH)
		canvas.GrayScale()
		if(state_name == PONY_XENO_STATE_DEATH)
			canvas.Blend("#8C6B6B", ICON_MULTIPLY)

	GLOB.pony_xeno_generated_icons[cache_key] = canvas
	return canvas

/mob/living/carbon/xenomorph/pony/proc/get_pony_runtime_directions()
	return list(SOUTH, NORTH, EAST, WEST, SOUTHEAST, SOUTHWEST, NORTHEAST, NORTHWEST)

/mob/living/carbon/xenomorph/pony/proc/generate_pony_icon_pack()
	if(!caste && !caste_type)
		return null

	randomize_pony_appearance()
	var/pack_key = build_pony_appearance_key("pack", "all_dirs")
	if(GLOB.pony_xeno_generated_icon_packs[pack_key])
		return GLOB.pony_xeno_generated_icon_packs[pack_key]

	var/list/runtime_states = list(PONY_XENO_STATE_WALKING, PONY_XENO_STATE_RUNNING, PONY_XENO_STATE_SLEEPING, PONY_XENO_STATE_KNOCKED_DOWN, PONY_XENO_STATE_DEATH, PONY_XENO_STATE_ATTACKING)
	var/list/runtime_directions = get_pony_runtime_directions()
	for(var/state_name in runtime_states)
		for(var/direction in runtime_directions)
			get_generated_pony_icon(state_name, direction)

	GLOB.pony_xeno_generated_icon_packs[pack_key] = TRUE
	return TRUE

/mob/living/carbon/xenomorph/pony/proc/apply_generated_pony_appearance(state_name = null, direction = null)
	if(!caste && !caste_type)
		return null

	if(!state_name)
		state_name = get_pony_runtime_state_name()

	if(!direction)
		direction = dir

	var/icon/generated_icon = get_generated_pony_icon(state_name, direction)
	if(!generated_icon)
		return null

	icon_xeno = generated_icon
	icon_xenonid = generated_icon
	icon = generated_icon
	icon_state = PONY_XENO_ICON_STATE_EMPTY
	has_walking_icon_state = FALSE
	return generated_icon

/mob/living/carbon/xenomorph/pony/get_custom_remains_icon()
	var/cache_key = build_pony_appearance_key(PONY_XENO_STATE_REMAINS, SOUTH)
	if(GLOB.pony_xeno_generated_remains[cache_key])
		return GLOB.pony_xeno_generated_remains[cache_key]

	var/icon/generated = get_generated_pony_icon(PONY_XENO_STATE_DEATH, SOUTH)
	if(!generated)
		generated = new /icon(PONY_XENO_ICON_STATES_BASE, PONY_XENO_ICON_STATE_EMPTY, SOUTH)

	GLOB.pony_xeno_generated_remains[cache_key] = generated
	return generated

/mob/living/carbon/xenomorph/pony/get_custom_remains_icon_state()
	return PONY_XENO_ICON_STATE_EMPTY
