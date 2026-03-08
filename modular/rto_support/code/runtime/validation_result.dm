/// Result object returned by RTO validation rules.
/datum/rto_support_validation_result
	var/success = FALSE
	var/message = ""

/datum/rto_support_validation_result/proc/set_success(new_message = "")
	success = TRUE
	message = new_message
	return src

/datum/rto_support_validation_result/proc/set_failure(new_message)
	success = FALSE
	message = new_message
	return src
