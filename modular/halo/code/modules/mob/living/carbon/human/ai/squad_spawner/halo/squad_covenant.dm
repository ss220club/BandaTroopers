/datum/human_ai_squad_preset/covenant
	faction = FACTION_COVENANT

/datum/human_ai_squad_preset/covenant/unggoy_pair
	name = "Unggoy Pair"
	desc = "A minimal Covenant scout pair made up of two plasma-armed Unggoy."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_needle_pair
	name = "Unggoy Needle Pair"
	desc = "A light skirmish pair carrying needlers and spare crystals."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_fireteam
	name = "Unggoy Fireteam"
	desc = "A line fireteam led by one major with three plasma-armed minors."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
	)

/datum/human_ai_squad_preset/covenant/unggoy_assault_team
	name = "Unggoy Assault Team"
	desc = "An assault-focused team with a needler major, plasma rifle support and plasma line troops."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_heavy_team
	name = "Unggoy Heavy Team"
	desc = "A veteran heavy-support team led by an Ultra with plasma rifle and needler heavies."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_support_team
	name = "Unggoy Support Team"
	desc = "A support-oriented Unggoy element with a deacon overseer and a medical support grunt."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/deacon_command = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_at_team
	name = "Unggoy Breach Team"
	desc = "A veteran breach team built around an Ultra leader, heavy support and a medical attendant."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 1,
	)

/datum/human_ai_squad_preset/covenant/unggoy_specops_cell
	name = "Unggoy SpecOps Cell"
	desc = "A stealth cell with one SpecOps Ultra overseeing plasma and needler specialists."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/specops_ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/specops_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_swarm
	name = "Unggoy Swarm"
	desc = "A dense pack of Unggoy with two majors, multiple plasma minors and a pair of needler carriers."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 4,
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_lance
	name = "Covenant Lance"
	desc = "A mixed Covenant lance led by a Sangheili minor with veteran Unggoy support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/major_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 3,
		/datum/equipment_preset/covenant/unggoy/ai/minor_needler = 1,
	)

/datum/human_ai_squad_preset/covenant/covenant_heavy_lance
	name = "Covenant Heavy Lance"
	desc = "A heavy mixed lance with Sangheili command, carbine overwatch and multiple Unggoy heavies."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_needler = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/covenant_at_lance
	name = "Covenant Breach Lance"
	desc = "A mixed breach lance with a zealot commander, veteran Ultra support and heavy plasma screens."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/zealot_command = 1,
		/datum/equipment_preset/covenant/unggoy/ai/ultra = 1,
		/datum/equipment_preset/covenant/unggoy/ai/heavy_plasma = 1,
		/datum/equipment_preset/covenant/unggoy/ai/support_medical = 1,
		/datum/equipment_preset/covenant/unggoy/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/unggoy_suicide_pack
	name = "Unggoy Suicide Pack"
	desc = "A dedicated pack of suicidal Unggoy bombers that prime paired plasma grenades and rush hostile contacts."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/unggoy/ai/suicide_bomber = 3,
	)

/datum/human_ai_squad_preset/covenant/sangheili_pair
	name = "Sangheili Pair"
	desc = "A light two-warrior Sangheili patrol armed with plasma rifles."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/sangheili_fireteam
	name = "Sangheili Fireteam"
	desc = "A disciplined Sangheili fireteam led by a major with two plasma-armed minors."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/sangheili_elite_team
	name = "Sangheili Elite Team"
	desc = "A veteran Sangheili element built around an Ultra, a carbine major and supporting minors."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
		/datum/equipment_preset/covenant/sangheili/ai/major_carbine = 1,
		/datum/equipment_preset/covenant/sangheili/ai/minor_plasma = 2,
	)

/datum/human_ai_squad_preset/covenant/sangheili_sword_pair
	name = "Sangheili Sword Pair"
	desc = "A shock pair of Sangheili Ultras carrying only energy swords."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword = 2,
	)

/datum/human_ai_squad_preset/covenant/sangheili_zealot_strike_cell
	name = "Sangheili Zealot Strike Cell"
	desc = "A Zealot-led strike cell with sword-bearing Ultras and plasma support."
	ai_to_spawn = list(
		/datum/equipment_preset/covenant/sangheili/ai/zealot_sword = 1,
		/datum/equipment_preset/covenant/sangheili/ai/ultra_sword = 1,
		/datum/equipment_preset/covenant/sangheili/ai/ultra_plasma = 1,
	)
