/obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar
	name = "CANC headset"
	desc = "A special headset used by CANC military."
	icon_state = "upp_headset"
	item_state = "upp_headset"
	frequency = CANC_FREQ
	has_hud = FALSE //Until we get CANC stuff, this'll do

/obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/command
	frequency = CANC_FREQ
	initial_keys = list(/obj/item/device/encryptionkey/canc_dogwar/command)

/obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/medic
	frequency = CANC_FREQ
	initial_keys = list(/obj/item/device/encryptionkey/canc_dogwar/medic)

/obj/item/device/radio/headset/almayer/marine/solardevils/canc_dogwar/sof
	frequency = CANC_FREQ
	initial_keys = list(/obj/item/device/encryptionkey/canc_dogwar/sof)
