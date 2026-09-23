/// Typed statistics container for round outro reports.
/// Computed from participant records, replaces string-counting in report procs.
/datum/round_cinematics_statistics
	/// Total personnel (real players: has_client && has_mind)
	var/personnel_total = 0
	/// Personnel with status "active"
	var/personnel_active = 0
	/// Personnel with status "incapacitated"
	var/personnel_incapacitated = 0
	/// Personnel with status "dead"
	var/personnel_dead = 0
	/// Personnel with status "missing"
	var/personnel_missing = 0
	/// Total destruction entries (non-player carbons)
	var/destruction_total = 0
	/// Associative list: death_reason (string) -> count (int)
	var/list/death_reason_counts = list()

/// Build statistics from a list of /datum/round_cinematics_participant_record.
/datum/round_cinematics_statistics/proc/build_from_records(list/records)
	personnel_total = 0
	personnel_active = 0
	personnel_incapacitated = 0
	personnel_dead = 0
	personnel_missing = 0
	destruction_total = 0
	death_reason_counts = list()

	if(!islist(records))
		return

	for(var/datum/round_cinematics_participant_record/record as anything in records)
		if(!istype(record))
			continue
		if(record.is_player)
			personnel_total++
			switch(record.status)
				if("active")
					personnel_active++
				if("incapacitated")
					personnel_incapacitated++
				if("dead")
					personnel_dead++
				if("missing")
					personnel_missing++
				else
					personnel_missing++
		else
			destruction_total++

		if(record.status == "dead" && length(record.death_reason))
			var/reason = record.death_reason
			death_reason_counts[reason] = (death_reason_counts[reason] || 0) + 1
