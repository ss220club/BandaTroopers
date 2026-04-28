/datum/human_ai_squad_preset/covenant
	faction = FACTION_COVENANT

/datum/human_ai_squad_preset/covenant/unggoy_pair
	name = "Пара унггоев"
	desc = "Минимальная разведывательная пара Ковенанта из двух унггоев с плазменным оружием."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_needle_pair
	name = "Пара унггоев с игольниками"
	desc = "Легкая скирмиш-пара с игольниками и запасными кристаллами."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_fireteam
	name = "Огневая группа унггоев"
	desc = "Линейная огневая группа под командованием одного мажора и трех миноров с плазменным оружием."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
	)

/datum/human_ai_squad_preset/covenant/unggoy_assault_team
	name = "Штурмовая группа унггоев"
	desc = "Штурмовая группа с мажором-игольником, поддержкой с плазменной винтовкой и линейными бойцами с плазмой."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_heavy_team
	name = "Тяжелая группа унггоев"
	desc = "Ветеранская группа тяжелой поддержки под командованием ультры, с тяжеловесами с плазменной винтовкой и игольником."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_support_team
	name = "Группа поддержки унггоев"
	desc = "Отряд поддержки унггоев с дьяконом-надзирателем и медицинским бойцом поддержки."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/deacon_command = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_at_team
	name = "Прорывная группа унггоев"
	desc = "Ветеранская группа прорыва, собранная вокруг лидера-ультры, тяжелой поддержки и медицинского помощника."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_specops_cell
	name = "Ячейка SpecOps унггоев"
	desc = "Скрытная ячейка с одной ультрой SpecOps, координирующей специалистов по плазме и игольникам."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/specops_ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_swarm
	name = "Рой унггоев"
	desc = "Плотная стая унггоев с двумя мажорами, несколькими минорами с плазмой и парой носителей игольников."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 4,
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_lance
	name = "Копье Ковенанта"
	desc = "Смешанное копье Ковенанта под командованием сангхейли-минора при поддержке ветеранов-унггоев."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_heavy_lance
	name = "Тяжелое копье Ковенанта"
	desc = "Тяжелое смешанное копье под командованием сангхейли, с карабинным прикрытием и несколькими тяжелыми унггоями."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_at_lance
	name = "Прорывное копье Ковенанта"
	desc = "Смешанное копье прорыва с командиром-зилотом, ветеранской поддержкой ультры и тяжелыми плазменными заслонами."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/zealot_command = 1,
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_suicide_pack
	name = "Стая унггоев-смертников"
	desc = "Специализированная стая унггоев-смертников, которая активирует парные плазменные гранаты и бросается на враждебные цели."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber = 3,
	)

/datum/human_ai_squad_preset/covenant/sangheili_pair
	name = "Пара сангхейли"
	desc = "Легкий патруль из двух воинов-сангхейли, вооруженных плазменными винтовками."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_fireteam
	name = "Огневая группа сангхейли"
	desc = "Дисциплинированная огневая группа сангхейли под командованием мажора с двумя минорами с плазменным оружием."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_elite_team
	name = "Элитная группа сангхейли"
	desc = "Ветеранский отряд сангхейли, собранный вокруг ультры, мажора с карабином и поддерживающих миноров."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/major/carbine = 1,
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_sword_pair
	name = "Пара сангхейли с мечами"
	desc = "Ударная пара ультр-сангхейли, вооруженных только энергетическими мечами."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword = 2,
	)

/datum/human_ai_squad_preset/covenant/sangheili_zealot_strike_cell
	name = "Ударная ячейка зилота-сангхейли"
	desc = "Ударная ячейка под командованием зилота с ультрами с мечами и плазменной поддержкой."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/zealot/cloaking = 1,
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword = 1,
		/datum/equipment_preset/covenant/sangheili/ultra/carbine = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_pair
	name = "Kig-Yar Pair"
	desc = "A light Kig-Yar skirmisher pair armed with plasma pistols and shields."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_screen_team
	name = "Kig-Yar Screen Team"
	desc = "A screen team of shielded Kig-Yar raiders built to probe and harass the front line."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/major/needler = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol = 2,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_marksman_cell
	name = "Kig-Yar Marksman Cell"
	desc = "A ranged Kig-Yar cell with a marksman and shielded escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_patrol_pair
	name = "Kig-Yar Patrol Pair"
	desc = "A light Kig-Yar patrol with a plasma rifle major and needler minor."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_marksman_overwatch
	name = "Kig-Yar Marksman Overwatch"
	desc = "A Kig-Yar marksman cell with carbine overwatch and shielded escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol = 2,
	)

/datum/human_ai_squad_preset/covenant/ruuhtian_sniper_cell
	name = "Kig-Yar Sniper Cell"
	desc = "A Kig-Yar sniper element with a carbine sniper and marksman support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/sniper/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_skirmisher_lance
	name = "Covenant Skirmisher Lance"
	desc = "A lore-aligned mixed lance with an Elite leader, Kig-Yar skirmishers, and Unggoy line troops."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/needler = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/plasma_pistol = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_marksman_lance
	name = "Covenant Marksman Lance"
	desc = "A mixed Covenant lance led by an Elite with Kig-Yar marksmen and Unggoy escorts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/major/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 2,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_raider_lance
	name = "Covenant Raider Lance"
	desc = "A harder mixed raider lance with an Elite ultra, veteran Kig-Yar, and heavy Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/needler = 1,
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/kigyar_unggoy_lance
	name = "Kig-Yar/Unggoy Lance"
	desc = "A mixed Covenant lance with Kig-Yar carbine support and Unggoy infantry."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
	)

/datum/human_ai_squad_preset/covenant/sangheili_command_lance
	name = "Sangheili Command Lance"
	desc = "A lore-led Sangheili command lance built around a zealot, veterans, and a line escort."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/zealot/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/ultra/carbine = 1,
		/datum/equipment_preset/covenant/sangheili/major/needler = 1,
		/datum/equipment_preset/covenant/sangheili/minor/plasma_rifle = 1,
	)

/datum/human_ai_squad_preset/covenant/sangheili_honor_guard_triad
	name = "Sangheili Honor Guard Triad"
	desc = "A ceremonial but lethal Sangheili honor detail with close escort and ranged support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/honor_guard = 1,
		/datum/equipment_preset/covenant/sangheili/ultra/plasma_rifle = 1,
		/datum/equipment_preset/covenant/sangheili/minor/needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_specops_strike_cell
	name = "Covenant SpecOps Strike Cell"
	desc = "A covert Covenant strike cell mixing Sangheili SpecOps command with stealth Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/specops/cloaking = 1,
		/datum/equipment_preset/covenant/sangheili/specops_ultra/carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler = 1,
	)

/datum/human_ai_squad_preset/covenant/kigyar_raider_lance
	name = "Kig-Yar Raider Lance"
	desc = "A Kig-Yar-led raider lance with skirmish screens, marksman pressure, and Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/ruuhtian/major/plasma_rifle = 1,
		/datum/equipment_preset/covenant/ruuhtian/marksman/carbine = 1,
		/datum/equipment_preset/covenant/ruuhtian/minor/needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)
