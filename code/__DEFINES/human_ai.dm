#define HUMAN_AI_HEALTHITEMS "health"
#define HUMAN_AI_AMMUNITION "ammo"
#define HUMAN_AI_GRENADES "grenades"
#define HUMAN_AI_TOOLS "tools"

#define HUMAN_AI_STORAGE_BELT "belt"
#define HUMAN_AI_STORAGE_BACKPACK "backpack"
#define HUMAN_AI_STORAGE_LEFT_POCKET "left_pocket"
#define HUMAN_AI_STORAGE_RIGHT_POCKET "right_pocket"
#define HUMAN_AI_STORAGE_ARMOR "armor"
#define HUMAN_AI_STORAGE_UNIFORM "uniform"

#define ACTION_USING_HANDS (1<<0)
#define ACTION_USING_LEGS (1<<1)
#define ACTION_USING_MOUTH (1<<2)

/// Action is completed, delete this and move onto the next ongoing action
#define ONGOING_ACTION_COMPLETED "completed"
/// Action isn't finished, move onto the next ongoing action
#define ONGOING_ACTION_UNFINISHED "unfinished"
/// Action isn't finished, block any further actions from the AI this tick
#define ONGOING_ACTION_UNFINISHED_BLOCK "unfinished_block"

#define HUMAN_AI_LIFECYCLE_INVALID "invalid"
#define HUMAN_AI_LIFECYCLE_DEAD "dead"
#define HUMAN_AI_LIFECYCLE_PLAYER_CONTROLLED "player_controlled"
#define HUMAN_AI_LIFECYCLE_HARDCRIT "hardcrit"
#define HUMAN_AI_LIFECYCLE_INCAPACITATED "incapacitated"
#define HUMAN_AI_LIFECYCLE_ACTIVE "active"

#define HUMAN_AI_EVENT_TARGET_CHANGED "target_changed"
#define HUMAN_AI_EVENT_PROJECTILE_THREAT "projectile_threat"
#define HUMAN_AI_EVENT_COMBAT_ENTERED "combat_entered"
#define HUMAN_AI_EVENT_COMBAT_EXIT_STARTED "combat_exit_started"
#define HUMAN_AI_EVENT_COMBAT_EXIT_FINISHED "combat_exit_finished"
#define HUMAN_AI_EVENT_COMBAT_EXIT_FORCE_CLEARED "combat_exit_force_cleared"
#define HUMAN_AI_EVENT_RESET_BEFORE_WAKE_CLEAR "reset_before_wake_clear"
#define HUMAN_AI_EVENT_RESET_AFTER_WAKE_CLEAR "reset_after_wake_clear"
#define HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_BEFORE_WAKE_CLEAR "lifecycle_suspended_before_wake_clear"
#define HUMAN_AI_EVENT_LIFECYCLE_SUSPENDED_AFTER_WAKE_CLEAR "lifecycle_suspended_after_wake_clear"
#define HUMAN_AI_EVENT_LIFECYCLE_RESUMED "lifecycle_resumed"
#define HUMAN_AI_EVENT_BODY_POSITION_CHANGED "body_position_changed"
#define HUMAN_AI_EVENT_MOVED "moved"
#define HUMAN_AI_EVENT_HANDCUFFED "handcuffed"
#define HUMAN_AI_EVENT_SPECIES_CHANGED "species_changed"
#define HUMAN_AI_EVENT_INITIALIZED "initialized"

#define HUMAN_AI_MAX_PATHFINDING_RANGE 45

#define HUMAN_AI_FIRE_LINE_CLEAR 0
#define HUMAN_AI_FIRE_LINE_CAUTION 1
#define HUMAN_AI_FIRE_LINE_BLOCKED 2

GLOBAL_LIST_EMPTY(ai_humans)
