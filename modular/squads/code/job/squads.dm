/datum/squad
	max_engineers = 3
	max_medics = 2
	max_specialists = 1
	max_tl = 2
	max_smartgun = 2
	max_leaders = 1
	/// Ограничение количества пехоты на отряд
	var/max_riflemen = 4
	/// Ограничение количества связистов
	var/max_rto = 0
	/// Количество уже имеющихся связистов
	var/num_rto = 0
	// Добавочные офицеры после каждого отряда
	var/staff_per_squad = 1

	/// После скольких READY игроков открывается этот отряд.
	var/ready_players_usable
	/// Связь с платуном по MAIN_SHIP_PLATOON, чтобы не добавляло лишние отряды в другие режимы.
	var/platoon_associated_type

// В проке идет проверка, но нет пехоты для корректного удаления из отряда.
/datum/squad/forget_marine_in_squad(mob/living/carbon/human/M)
	. = ..()
	if(GET_DEFAULT_ROLE(M.job) == JOB_SQUAD_MARINE)
		num_riflemen--

/datum/squad/proc/try_usable_squad()

/datum/squad/marine/alpha
	equipment_color = "#db1d1d"
	chat_color = "#db1d1d"
	max_riflemen = 6
	max_engineers = 0
	max_medics = 2
	max_specialists = 1
	max_tl = 2
	max_smartgun = 2
	max_leaders = 1
	max_rto = 1

/datum/squad/marine/bravo
	name = SQUAD_MARINE_2
	equipment_color = "#ffc32d"
	chat_color = "#ffe650"
	access = list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_BRAVO)
	radio_freq = BRAVO_FREQ
	use_stripe_overlay = FALSE
	minimap_color = MINIMAP_SQUAD_BRAVO
	roundstart = TRUE
	active = TRUE
	squad_type = "Section"
	usable = FALSE // Включается при ready_players_usable готовых игроков
	ready_players_usable = 10
	platoon_associated_type = /datum/squad/marine/alpha
	max_riflemen = 4
	max_engineers = 4
	max_medics = 0
	max_specialists = 0
	max_tl = 2
	max_smartgun = 2
	max_leaders = 1
	max_rto = 1
	

/datum/squad/marine/charlie
	equipment_color = "#c864c8"
	chat_color = "#ff96ff"
	access = list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_CHARLIE)
	minimap_color = MINIMAP_SQUAD_CHARLIE
	use_stripe_overlay = FALSE
	roundstart = TRUE
	active = TRUE
	squad_type = "Section"
	usable = FALSE // Включается при ready_players_usable готовых игроков
	ready_players_usable = 28 // Поменяли с дельта, т.к. дельта приоритет выше, т.к. пехотный отряд.
	platoon_associated_type = /datum/squad/marine/alpha
	max_riflemen = 4
	max_engineers = 0
	max_medics = 4
	max_specialists = 0
	max_tl = 2
	max_smartgun = 2
	max_leaders = 1
	max_rto = 1


/datum/squad/marine/delta
	equipment_color = "#4148c8"
	chat_color = "#828cff"
	access = list(ACCESS_MARINE_ALPHA, ACCESS_MARINE_DELTA)
	minimap_color = MINIMAP_SQUAD_DELTA
	use_stripe_overlay = FALSE
	roundstart = TRUE
	active = TRUE
	squad_type = "Section"
	usable = FALSE // Включается при ready_players_usable готовых игроков
	ready_players_usable = 20
	platoon_associated_type = /datum/squad/marine/alpha
	max_riflemen = 8
	max_engineers = 0
	max_medics = 2
	max_specialists = 1
	max_tl = 2
	max_smartgun = 2
	max_leaders = 1
	max_rto = 1


// Предложение как можно переименовать отряды:
// #define SQUAD_MARINE_1_RENAME "Assault A-Sct"
// #define SQUAD_MARINE_2_RENAME "Auxiliary Tech B-Sct"
// #define SQUAD_MARINE_3_RENAME "Auxiliary Care C-Sct"
// #define SQUAD_MARINE_4_RENAME "Assault D-Sct"
// #define SQUAD_MARINE_5_RENAME "Support E-Sct"
