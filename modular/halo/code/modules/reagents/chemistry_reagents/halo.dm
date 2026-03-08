/datum/reagent/medical/biofoam
	name = "Bio-Foam"
	id = "biofoam"
	description = "Biofoam is a self-sealing space-filling coagulant and anti-microbial tissue-regenerative polymer foam. It's most commonly utilized in the stabilization of patients who have undergone severe trauma."
	reagent_state = LIQUID
	color = "#265aae"
	overdose = MED_REAGENTS_OVERDOSE
	overdose_critical = MED_REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_UNCOMMON
	properties = list(PROPERTY_CARDIOSTABILIZING = 3, PROPERTY_PAINKILLING = 8, PROPERTY_NEOGENETIC = 1, PROPERTY_ANTICORROSIVE = 1, PROPERTY_ORGANSTABILIZE = 4, PROPERTY_INTRAVENOUS = 1, PROPERTY_HEMOSTATIC = 1, PROPERTY_OXYGENATING = 5)
	custom_metabolism = AMOUNT_PER_TIME(1, 40 SECONDS)

/datum/reagent/medical/biofoam/lite
	name = "External-Application Biofoam"
	id = "biofoam_ext"
	description = "Unlike standard biofoam, this one is applied externally to wounds rather than injected directly in them. It is easier to apply, but less effective."
	reagent_state = SOLID
	color = "#8e9eb7"
	overdose = MED_REAGENTS_OVERDOSE
	overdose_critical = MED_REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_UNCOMMON
	properties = list(PROPERTY_CARDIOSTABILIZING = 2, PROPERTY_PAINKILLING = 4, PROPERTY_INTRAVENOUS = 1, PROPERTY_HEMOSTATIC = 1, PROPERTY_OXYGENATING = 3, PROPERTY_NEOGENETIC = 1, PROPERTY_ANTICORROSIVE = 1)
	custom_metabolism = AMOUNT_PER_TIME(1, 15 SECONDS)

/datum/reagent/medical/biofoam/lite/nullified
	name = "Nullified External-Application Biofoam"
	id = "nullfoam"
	description = "The effects of the external application biofoam have been nullified by internal application bio-foam."
	reagent_state = LIQUID
	color = "#787f81"
	overdose = HIGH_REAGENTS_OVERDOSE_CRITICAL
	overdose_critical = VHIGH_REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_COMMON
	properties = PROPERTY_REGULATING
	custom_metabolism = AMOUNT_PER_TIME(1, 5 SECONDS)

/datum/reagent/medical/burnguard
	name = "Optican BurnGuard"
	id = "burnguard"
	description = " An effective and simple to administer first-response burn treatment."
	reagent_state = SOLID
	color = "#d8dab9"
	overdose = REAGENTS_OVERDOSE
	overdose_critical = REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_COMMON
	properties = list(PROPERTY_ANTICORROSIVE = 2, PROPERTY_PAINKILLING = 3)

/datum/reagent/medical/morphine
	name = "Morphine"
	id = "morphine"
	description = "An effective pain-killer since the dawn of time."
	reagent_state = LIQUID
	color = "#e5dddd"
	overdose = MED_REAGENTS_OVERDOSE
	overdose_critical = MED_REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_UNCOMMON
	properties = list(PROPERTY_PAINKILLING = 6)
	custom_metabolism = AMOUNT_PER_TIME(1, 20 SECONDS)

/datum/reagent/medical/chorotazine
	name = "Chorotazine"
	id = "chorotazine"
	description = "A medication used to treat head and eye related injuries."
	reagent_state = LIQUID
	color = "#e5dddd"
	overdose = LOWH_REAGENTS_OVERDOSE
	overdose_critical = MED_REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_UNCOMMON
	properties = list(PROPERTY_OCULOPEUTIC = 2, PROPERTY_NEUROPEUTIC = 2)

/datum/reagent/medical/biofoam_dissolvent
	name = "biofoam dissolvent"
	id = "biofoam_dissolvent"
	description = "A biofoam dissolvent. Burns."
	reagent_state = LIQUID
	color = "#407571"
	overdose = LOWH_REAGENTS_OVERDOSE
	overdose_critical = MED_REAGENTS_OVERDOSE_CRITICAL
	chemclass = CHEM_CLASS_UNCOMMON
	properties = list(PROPERTY_CORROSIVE = 4)

/datum/reagent/hydrogen/liquid
	name = "Liquid Hydrogen"
	id = "liquidhydrogen"
	reagent_state = LIQUID
