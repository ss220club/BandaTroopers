/obj/item/device/radio/headset/almayer/marine/solardevils/unsc
	name = "гарнитура ККОН"
	desc = "Специальная гарнитура, используемая Космическим Командованием Объединённых Наций во всех родах войск."
	frequency = CRYO_FREQ
	has_hud = TRUE
	hud_type = list(MOB_HUD_FACTION_UNSC)
	inbuilt_tracking_options = list(
		"Platoon Commander" = TRACKER_PLTCO,
		"Squad Leader" = TRACKER_SL,
		"Fireteam Leader" = TRACKER_FTL,
		"Landing Zone" = TRACKER_LZ
	)
	locate_setting = TRACKER_FTL

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/rockhoppers
	frequency = UNSC_FREQ

/obj/item/device/radio/headset/almayer/marine/solardevils/unsc/ferrymen
	frequency = ODST_FREQ

/obj/item/device/radio/headset/distress/oni
	name = "гарнитура охраны ONI"
	desc = "Гарнитура, используемая силами безопасности ONI."
	frequency = ONI_FREQ
	initial_keys = list(/obj/item/device/encryptionkey/oni)
