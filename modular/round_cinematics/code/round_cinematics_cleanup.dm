/proc/round_cinematics_cleanup_session(datum/round_cinematics_session/session, reason = "cleanup")
	if(!session)
		return
	session.finish_session(reason)

/// Session-owned cleanup: only removes objects tracked by this session.
/// Does NOT call clear_screen() to avoid wiping unrelated screen objects.
/proc/round_cinematics_cleanup_client(client/target_client)
	if(!istype(target_client))
		return
	// No-op: cleanup is handled per-session via finish_session().
	// clear_screen() is too aggressive and would wipe non-cinematics screen objects.
	return
