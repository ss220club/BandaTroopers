/// Typed participant record for round outro reports.
/// Replaces string-based participant_entries / personnel_entries / destruction_entries.
/datum/round_cinematics_participant_record
	/// Display name (real_name)
	var/name
	/// Paygrade prefix (e.g. "PFC")
	var/rank
	/// Job assignment
	var/role
	/// Squad name
	var/squad
	/// Faction string
	var/faction
	/// "active", "incapacitated", "dead", "missing"
	var/status
	/// Categorized death reason (e.g. "EXPLOSION", "GUNFIRE", "XENO AGGRESSION")
	var/death_reason
	/// TRUE if the mob had a client at the time of recording
	var/has_client
	/// TRUE if the mob had a mind at the time of recording
	var/has_mind
	/// TRUE for real players (has_client && has_mind) — personnel; FALSE for destruction
	var/is_player
