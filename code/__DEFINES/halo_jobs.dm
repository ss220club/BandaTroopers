// Shared HALO squad and role string contracts consumed by code/** and modular/**.
// This file lives in code/__DEFINES so DME include-order validation stays stable.
#define SQUAD_ODST "The Ferrymen"

#define JOB_SQUAD_MARINE_ODST "ODST Rifleman"
#define JOB_SQUAD_SPECIALIST_ODST "ODST Weapons Specialist"
#define JOB_SQUAD_MEDIC_ODST "ODST Hospital Corpsman"
#define JOB_SQUAD_TEAM_LEADER_ODST "ODST Fireteam Leader"
#define JOB_SQUAD_RTO_ODST "ODST Radio Telephone Operator"
#define JOB_SQUAD_LEADER_ODST "ODST Squad Sergeant"

#define JOB_SQUAD_MARINE_UNSC "UNSC Rifleman"
#define JOB_SQUAD_SPECIALIST_UNSC "UNSC Weapons Specialist"
#define JOB_SQUAD_MEDIC_UNSC "UNSC Hospital Corpsman"
#define JOB_SQUAD_TEAM_LEADER_UNSC "UNSC Fireteam Leader"
#define JOB_SQUAD_RTO_UNSC "UNSC Radio Telephone Operator"
#define JOB_SQUAD_LEADER_UNSC "UNSC Squad Leader"

#define JOB_HALO_UNSC_MARINES_LIST list(JOB_SQUAD_LEADER_UNSC, JOB_SQUAD_TEAM_LEADER_UNSC, JOB_SQUAD_SPECIALIST_UNSC, JOB_SQUAD_MEDIC_UNSC, JOB_SQUAD_MARINE_UNSC, JOB_SQUAD_RTO_UNSC)
#define JOB_HALO_ODST_MARINES_LIST list(JOB_SQUAD_LEADER_ODST, JOB_SQUAD_TEAM_LEADER_ODST, JOB_SQUAD_SPECIALIST_ODST, JOB_SQUAD_MEDIC_ODST, JOB_SQUAD_MARINE_ODST, JOB_SQUAD_RTO_ODST)
#define JOB_HALO_MARINES_LIST (JOB_HALO_UNSC_MARINES_LIST + JOB_HALO_ODST_MARINES_LIST)
