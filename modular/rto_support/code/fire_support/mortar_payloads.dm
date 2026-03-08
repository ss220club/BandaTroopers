/// RTO-specific mortar variants that fire a single round instead of an upstream barrage.
/datum/fire_support/mortar/rto_single
	impact_quantity = 1
	initiate_chat_message = "COORDINATES CONFIRMED. MORTAR ROUND INCOMING."
	initiate_screen_message = list("Coordinates confirmed, single HE round inbound!")

/datum/fire_support/mortar/smoke/rto_single
	impact_quantity = 1
	initiate_chat_message = "COORDINATES CONFIRMED. SMOKE ROUND INCOMING."
	initiate_screen_message = "Coordinates confirmed, single smoke round inbound!"

/datum/fire_support/mortar/incendiary/rto_single
	impact_quantity = 1
	initiate_chat_message = "COORDINATES CONFIRMED. INCENDIARY ROUND INCOMING."
	initiate_screen_message = list("Coordinates confirmed, single incendiary round inbound!")
