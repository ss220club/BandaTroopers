//CANC Keys
/obj/item/device/encryptionkey/canc_dogwar
	name = "\improper CANC Radio Encryption Key"
	icon_state = "upp_key"
	channels = list(RADIO_CHANNEL_CANC_GEN = TRUE)

/obj/item/device/encryptionkey/canc_dogwar/engi
	name = "\improper CANC Engineering Radio Encryption Key"
	channels = list(RADIO_CHANNEL_CANC_GEN = TRUE, RADIO_CHANNEL_CANC_ENGI = TRUE)

/obj/item/device/encryptionkey/canc_dogwar/medic
	name = "\improper CANC Medical Radio Encryption Key"
	channels = list(RADIO_CHANNEL_CANC_GEN = TRUE, RADIO_CHANNEL_CANC_MED = TRUE)

/obj/item/device/encryptionkey/canc_dogwar/command
	name = "\improper CANC Command Radio Encryption Key"
	channels = list(RADIO_CHANNEL_CANC_GEN = TRUE, RADIO_CHANNEL_CANC_MED = TRUE, RADIO_CHANNEL_CANC_ENGI = TRUE, RADIO_CHANNEL_CANC_CMD = TRUE)

/obj/item/device/encryptionkey/canc_dogwar/sof
	name = "\improper CANC Special Operations Forces Radio Encryption Key"
	channels = list(RADIO_CHANNEL_CANC_SOF = TRUE, RADIO_CHANNEL_CANC_CMD = TRUE, RADIO_CHANNEL_CANC_ENGI = TRUE, RADIO_CHANNEL_CANC_MED = TRUE)
