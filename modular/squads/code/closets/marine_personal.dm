// Шкафчики под отряды и их привязка
/obj/structure/closet/secure_closet/marine_personal
	var/squad_type

/obj/structure/closet/secure_closet/marine_personal/proc/is_correct_squad(mob/living/carbon/human/H)
	if(!squad_type)
		return TRUE
	if(!H.assigned_squad)
		return FALSE
	if(H.assigned_squad.name == squad_type)
		return TRUE

	// Отдельная проверка для первого сквада
	if(squad_type == SQUAD_MARINE_1)
		// Так как связаны с ренеймом платунов
		if(H.assigned_squad.name == GLOB.main_platoon_name)
			return TRUE
	return FALSE


// Пехотинец
/obj/structure/closet/secure_closet/marine_personal/rifleman
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rm"
	icon_closed = "secure-rm"
	icon_locked = "secure1-rm"
	icon_opened = "secureopen-rm"
	icon_broken = "securebroken-rm"
	icon_off = "secureoff-rm"


// Смартганнер
/obj/structure/closet/secure_closet/marine_personal/smartgunner
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-sg"
	icon_closed = "secure-sg"
	icon_locked = "secure1-sg"
	icon_opened = "secureopen-sg"
	icon_broken = "securebroken-sg"
	icon_off = "secureoff-sg"


// Инженер
/obj/structure/closet/secure_closet/marine_personal/engineer
	job = JOB_SQUAD_ENGI
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-eng"
	icon_closed = "secure-eng"
	icon_locked = "secure1-eng"
	icon_opened = "secureopen-eng"
	icon_broken = "securebroken-eng"
	icon_off = "secureoff-eng"


// Медик
/obj/structure/closet/secure_closet/marine_personal/corpsman
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-med"
	icon_closed = "secure-med"
	icon_locked = "secure1-med"
	icon_opened = "secureopen-med"
	icon_broken = "securebroken-med"
	icon_off = "secureoff-med"


// Спек
/obj/structure/closet/secure_closet/marine_personal/specialist
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-spec"
	icon_closed = "secure-spec"
	icon_locked = "secure1-spec"
	icon_opened = "secureopen-spec"
	icon_broken = "securebroken-spec"
	icon_off = "secureoff-spec"


// Радио оператор
/obj/structure/closet/secure_closet/marine_personal/rto
	job = JOB_SQUAD_RTO
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-rto"
	icon_closed = "secure-rto"
	icon_locked = "secure1-rto"
	icon_opened = "secureopen-rto"
	icon_broken = "securebroken-rto"
	icon_off = "secureoff-rto"

/obj/structure/closet/secure_closet/marine_personal/rto/spawn_gear()
	. = ..()
	new /obj/item/device/binoculars/fire_support/uscm(src)
	new /obj/item/storage/box/flare/signal(src)
	new /obj/item/storage/box/flare/signal(src)


// ФТЛ
/obj/structure/closet/secure_closet/marine_personal/squad_leader
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-ftl"
	icon_closed = "secure-ftl"
	icon_locked = "secure1-ftl"
	icon_opened = "secureopen-ftl"
	icon_broken = "securebroken-ftl"
	icon_off = "secureoff-ftl"


// СЛ
/obj/structure/closet/secure_closet/marine_personal/platoon_leader
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-sl"
	icon_closed = "secure-sl"
	icon_locked = "secure1-sl"
	icon_opened = "secureopen-sl"
	icon_broken = "securebroken-sl"
	icon_off = "secureoff-sl"


// SO
/obj/structure/closet/secure_closet/marine_personal/platoon_commander
	icon = 'modular/squads/icons/closet.dmi'
	icon_state = "secure1-so"
	icon_closed = "secure-so"
	icon_locked = "secure1-so"
	icon_opened = "secureopen-so"
	icon_broken = "securebroken-so"
	icon_off = "secureoff-so"
