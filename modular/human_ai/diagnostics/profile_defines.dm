// Local numeric state only: no per-call token allocation or shared scope stack.
// These macros are undefined at the end of _human_ai.dme.
#define HAI_PROFILE_BEGIN(tag) \
	var/tag##_profile_generation = SShuman_ai.performance_profile_enabled ? SShuman_ai.performance_profile_generation : 0; \
	var/tag##_profile_tick = tag##_profile_generation ? world.time : 0; \
	var/tag##_profile_lag = tag##_profile_generation ? world.tick_lag : 0; \
	var/tag##_profile_usage = tag##_profile_generation ? world.tick_usage : 0

// Capture the end tick usage before entering the recorder. Cross-tick spans
// are rejected there, never interpreted as CPU spent waiting for an action.
#define HAI_PROFILE_END(tag, bucket) \
	if(tag##_profile_generation) { \
		SShuman_ai.record_performance_profile(bucket, tag##_profile_generation, tag##_profile_tick, tag##_profile_lag, world.tick_usage - tag##_profile_usage); \
	}
