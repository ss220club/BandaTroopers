/datum/component/automatedfire
	///The owner of this component
	var/atom/shooter
	/// Contains the scheduled fire time, used for scheduling EOL
	var/next_fire
	/// Stores the current bucket position while this component is queued.
	var/bucket_pos = 0
	/// Contains the reference to the next component in the bucket, used by autofire subsystem
	var/datum/component/automatedfire/next
	/// Contains the reference to the previous component in the bucket, used by autofire subsystem
	var/datum/component/automatedfire/prev


/// schedule the shooter into the system, inserting it into the next fire queue
/datum/component/automatedfire/proc/schedule_shot()
	if(QDELETED(src) || QDELETED(parent))
		return

	if(bucket_pos || prev || next)
		bucket_eject()

	//We move to another bucket, so we clean the reference from the former linked list
	next = null
	prev = null
	var/list/bucket_list = SSautomatedfire.bucket_list

	// Ensure the next_fire time is properly bound to avoid missing a scheduled event
	next_fire = max(CEILING(next_fire, world.tick_lag), world.time + world.tick_lag)

	// Get bucket position and a local reference to the datum var, it's faster to access this way
	bucket_pos = AUTOFIRE_BUCKET_POS(next_fire)

	// Get the bucket head for that bucket, increment the bucket count
	var/datum/component/automatedfire/bucket_head = bucket_list[bucket_pos]
	SSautomatedfire.shooter_count++

	// If there is no existing head of this bucket, we can set this shooter to be that head
	if (!bucket_head)
		bucket_list[bucket_pos] = src
		return

	// Otherwise it's a simple insertion into the double-linked list
	if (bucket_head.next)
		next = bucket_head.next
		next.prev = src

	bucket_head.next = src
	prev = bucket_head

	//Something went wrong, probably a lag spike or something. To prevent infinite loops, we reschedule it to a another next fire
	if(prev == src)
		next_fire += 1
		schedule_shot()

/datum/component/automatedfire/proc/bucket_eject()
	if(!bucket_pos && !prev && !next)
		return

	var/list/bucket_list = SSautomatedfire.bucket_list
	var/datum/component/automatedfire/bucket_head
	if(bucket_pos > 0 && bucket_pos <= length(bucket_list))
		bucket_head = bucket_list[bucket_pos]

	if(bucket_head == src)
		bucket_list[bucket_pos] = next
		if(SSautomatedfire.shooter_count > 0)
			SSautomatedfire.shooter_count--
	else if(prev || next)
		if(SSautomatedfire.shooter_count > 0)
			SSautomatedfire.shooter_count--

	if(prev && prev.next == src)
		prev.next = next
	if(next && next.prev == src)
		next.prev = prev
	if(bucket_head == src && next)
		next.prev = null

	prev = null
	next = null
	bucket_pos = 0

///Handle the firing of the autofire component
/datum/component/automatedfire/proc/process_shot()
	return
