// Major Failures, fatal, voluntary by player & controllable by GM
#define MAJOR_FAILURE_CHUTE (1<<0)
#define MAJOR_FAILURE_ENTRY (1<<1)
#define MAJOR_FAILURE_BRAKES (1<<2)

// Minor Failures, nonfatal, but can hurt a bit.
#define MINOR_FAILURE_BRAKES (1<<3)
#define MINOR_FAILURE_CHUTE (1<<4)
#define MINOR_FAILURE_ENTRY (1<<5)

#define POD_READY 1
#define POD_INFLIGHT 2
#define POD_LANDED 3

#define CHUTE_READY 1
#define CHUTE_DEPLOYED 2
#define CHUTE_GONE 3
