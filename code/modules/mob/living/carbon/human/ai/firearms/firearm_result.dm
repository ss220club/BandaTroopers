// Isolated Human AI firearm result proposal. Not included in colonialmarines.dme yet.

/datum/human_ai_firearm_result
	/// TRUE when the handler consumed this weapon event and the caller should not run default weapon follow-up.
	var/handled = FALSE
	/// TRUE when the caller should end its current firing loop.
	var/stop_fire = FALSE
	/// TRUE when the caller should break/clear burst state.
	var/interrupt_burst = FALSE
	/// Cooldown the caller may apply to ranged firing.
	var/cooldown = 0
	/// Optional delayed weapon continuation, usually start_fire or unique_action.
	var/datum/callback/callback
	var/callback_delay = 0

/datum/human_ai_firearm_result/proc/consume()
	handled = TRUE
	return src

/datum/human_ai_firearm_result/proc/stop_fire_for(delay = 0)
	handled = TRUE
	stop_fire = TRUE
	interrupt_burst = TRUE
	cooldown = delay
	return src

/datum/human_ai_firearm_result/proc/queue_callback(datum/callback/new_callback, delay = 0, new_cooldown = 0)
	handled = TRUE
	stop_fire = TRUE
	interrupt_burst = TRUE
	callback = new_callback
	callback_delay = delay
	cooldown = max(delay, new_cooldown)
	return src
