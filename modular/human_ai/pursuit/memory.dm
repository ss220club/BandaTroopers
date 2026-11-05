/datum/human_ai_brain
	var/turf/pursuit_observed_turf
	var/pursuit_observed_at = -1
	var/pursuit_observed_heading = NONE
	var/pursuit_observed_identity
	var/pursuit_consumed_at = -1
	var/pursuit_next_report = 0

/// Only confirmed visual observations enter here. Reports are never rebroadcast.
/datum/human_ai_brain/proc/pursuit_record_observation(atom/movable/enemy, visibility_confirmed = FALSE)
	if(!has_valid_tied_human() || !setting("pursuit_enabled"))
		return
	var/turf/position = get_turf(enemy)
	if(!position || (!visibility_confirmed && !(enemy in view(view_distance, tied_human))))
		return
	var/identity = REF(enemy)
	if(identity != pursuit_observed_identity)
		pursuit_observed_heading = NONE
	else if(pursuit_observed_turf && position != pursuit_observed_turf && position.z == pursuit_observed_turf.z)
		pursuit_observed_heading = get_dir(pursuit_observed_turf, position)
	pursuit_observed_identity = identity
	pursuit_observed_turf = position
	pursuit_observed_at = world.time
	if(pursuit_active || pursuit_returning)
		pursuit_clear_search()
	if(!setting("pursuit_share") || world.time < pursuit_next_report || !squad_id)
		return
	pursuit_next_report = world.time + 1 SECONDS
	var/datum/human_ai_squad/squad = SShuman_ai.squad_id_dict["[squad_id]"]
	if(!squad)
		return
	var/checked = 0
	for(var/datum/human_ai_brain/receiver as anything in squad.ai_in_squad)
		if(++checked > 16)
			break
		if(receiver == src || !receiver.has_valid_tied_human() || receiver.tied_human.stat == DEAD || receiver.tied_human.client || !faction_check(receiver.tied_human))
			continue
		if(receiver.tied_human.z != tied_human.z || get_dist(tied_human, receiver.tied_human) > setting("pursuit_share_radius"))
			continue
		receiver.pursuit_receive_report(position, pursuit_observed_at, pursuit_observed_heading)

/datum/human_ai_brain/proc/pursuit_receive_report(turf/position, observed_at, heading)
	if(!setting("pursuit_enabled") || !setting("pursuit_share") || current_target || !isturf(position))
		return FALSE
	if(observed_at <= max(pursuit_observed_at, pursuit_consumed_at) || world.time >= observed_at + setting("chase_time") * 10)
		return FALSE
	if(pursuit_returning || (pursuit_active && pursuit_anchor != position))
		pursuit_clear_search()
	pursuit_observed_turf = position
	pursuit_observed_at = observed_at
	pursuit_observed_heading = heading
	pursuit_observed_identity = null
	return TRUE

/datum/human_ai_brain/proc/pursuit_forget()
	pursuit_clear_search()
	pursuit_observed_turf = null
	pursuit_observed_identity = null
	pursuit_observed_heading = NONE
	pursuit_consumed_at = pursuit_observed_at

/// Expiry works even when higher-priority actions own the legs.
/datum/human_ai_brain/proc/pursuit_update()
	if(!setting("pursuit_enabled") || setting("chase_time") <= 0 || hold_position)
		if(pursuit_active || pursuit_returning)
			pursuit_finish(FALSE)
		pursuit_consumed_at = pursuit_observed_at
		return
	if(current_target)
		return
	if(in_cover && (pursuit_active || pursuit_can_start()) && !has_live_grenade_emergency())
		end_cover()
	if(pursuit_active && current_order != pursuit_order_snapshot)
		pursuit_finish(FALSE)
		return
	if(pursuit_active && world.time >= pursuit_deadline)
		pursuit_finish()
	if(pursuit_returning && (current_order || world.time >= pursuit_return_until))
		pursuit_clear_search()
