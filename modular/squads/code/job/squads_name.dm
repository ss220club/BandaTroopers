// TODO: Platoon Name
// /datum/squad/marine/bravo/New()
// 	. = ..()

// 	RegisterSignal(SSdcs, COMSIG_GLOB_PLATOON_NAME_CHANGE, PROC_REF(rename_platoon))

// /datum/squad/marine/charlie/New()
// 	. = ..()

// 	RegisterSignal(SSdcs, COMSIG_GLOB_PLATOON_NAME_CHANGE, PROC_REF(rename_platoon))
    
// /datum/squad/marine/delta/New()
// 	. = ..()

// 	RegisterSignal(SSdcs, COMSIG_GLOB_PLATOON_NAME_CHANGE, PROC_REF(rename_platoon))


// /obj/item/device/radio/headset/Initialize()
//     . = ..()
//     // !!!!! Переделать под 3 отряда + глобал дефайн
// 	if(SQUAD_MARINE_2 == default_freq && SQUAD_MARINE_2 != GLOB.main_platoon_name)
// 		rename_platoon(null, GLOB.main_platoon_name, SQUAD_MARINE_2)
