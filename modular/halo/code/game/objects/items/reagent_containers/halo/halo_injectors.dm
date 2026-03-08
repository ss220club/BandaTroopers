// ----------------------------- Normal Injectors -----------------------------

// ----------------------------- Primeable Injectors -----------------------------

/obj/item/reagent_container/hypospray/autoinjector/primeable
	icon = 'icons/halo/obj/items/medical.dmi'
	icon_state = "othercan"
	var/primed = FALSE
	var/prime_sound
	var/prime_text
	var/description_primed
	var/description_unprimed
	var/instructions
	var/causes_pain

/obj/item/reagent_container/hypospray/autoinjector/primeable/get_examine_text(mob/user)
	. = ..()
	if(primed == FALSE)
		. += SPAN_NOTICE("[description_unprimed]")
	else
		. += SPAN_NOTICE("[description_primed]")
	if(instructions)
		. += SPAN_BLUE("[instructions]")

/obj/item/reagent_container/hypospray/autoinjector/primeable/attack(mob/living/carbon/target, mob/living/user)
	if(primed == TRUE)
		if(uses_left == 0)
			to_chat(user, SPAN_NOTICE("The [src] is empty."))
			return
		. = ..()
		if(causes_pain)
			target.emote("pain")
		if(!uses_left)
			icon_state = "[initial(icon_state)]_spent"
		else
			icon_state = "[initial(icon_state)]_primed"
	else
		to_chat(user, SPAN_NOTICE(prime_text))
		primed = TRUE
		icon_state = "[initial(icon_state)]_primed"
		playsound(loc, prime_sound, 25, 1)

/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam
	name = "biofoam canister"
	chemname = "biofoam"
	desc = "An olive-drab canister full of a stabilizing biomedical polymer foam, otherwise known as biofoam. Fold open the injection rod to prime it, then stick it into your target's wounds."
	icon_state = "biofoam"
	amount_per_transfer_from_this = MED_REAGENTS_OVERDOSE
	volume = MED_REAGENTS_OVERDOSE
	uses_left = 1
	injectSFX = 'sound/items/biofoam.ogg'
	drop_sound = 'sound/handling/tape_drop.ogg'
	prime_sound = 'sound/items/unfold.ogg'
	causes_pain = TRUE

	prime_text = "You fold open the injection rod."
	description_unprimed = "The injection rod is folded down."
	description_primed = "The injection rod is folded up."
	instructions = "OD at 20u. Best used on critically wounded patients during mass casualty events. Prevents oxyloss, damage from injured organs, bleeding, and is as good as Oxycodone at painkilling."

/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/attack(mob/living/carbon/target, mob/living/user)
	if(primed == TRUE)
		if(uses_left == 0)
			to_chat(user, SPAN_NOTICE("The [src] is empty."))
			return
		. = ..()
		target.emote("pain")
		if(!uses_left)
			icon_state = "[initial(icon_state)]_spent"
		else
			icon_state = "[initial(icon_state)]_primed"
		target.pain.apply_pain(100)
		addtimer(CALLBACK(src, PROC_REF(reset_pain), target), 3 SECONDS)
	else
		to_chat(user, SPAN_NOTICE(prime_text))
		primed = TRUE
		icon_state = "[initial(icon_state)]_primed"
		playsound(loc, prime_sound, 25, 1)

/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/proc/reset_pain(mob/living/carbon/target)
	target.pain.recalculate_pain()

/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/small
	name = "biofoam pen"
	chemname = "biofoam_ext"
	desc = "A small silver pen containing a easy to apply biofoam spray. This is intended to be sprayed on the outside of wounds rather than put directly into the wound."
	icon_state = "syrette"
	amount_per_transfer_from_this = MED_REAGENTS_OVERDOSE/2
	volume = MED_REAGENTS_OVERDOSE
	uses_left = 2
	injectSFX = 'sound/items/biofoam_syrette.ogg'
	prime_sound = "rip"
	causes_pain = TRUE

	prime_text = "You tear the protective wrapper off of the biofoam pen."
	description_unprimed = "The biofoam pen is still sealed inside its packaging."
	description_primed = "The biofoam pen is ready to be used."
	instructions = "OD at 20u. Best used on critically wounded patients before bringing them to medically trained personnel, comparable to tricordrazine but with additional stabilizing properties and painkilling."

/obj/item/reagent_container/hypospray/autoinjector/primeable/biofoam/antidote
	name = "biofoam dissolvent injector"
	chemname = "biofoam_dissolvent"
	desc = "A small silver pen containing a slightly acidic compound to dissolve any biofoam injected into someone's system. This can hurt a lot...but it's better than dying from too much foam."
	icon_state = "antidote"
	amount_per_transfer_from_this = LOWH_REAGENTS_OVERDOSE
	volume = LOWH_REAGENTS_OVERDOSE
	uses_left = 1
	injectSFX = 'sound/items/hypospray.ogg'
	prime_sound = "rip"
	causes_pain = TRUE

	prime_text = "You tear the protective wrapper off of the biofoam dissolvent injector."
	description_unprimed = "The biofoam dissolvent injector is still sealed inside its packaging."
	description_primed = "The biofoam dissolvent injector is ready to be used."
	instructions = "OD at 15u. Used on patients with extreme overdoses on biofoam, gives burn damage as a consequence however. Usually you only get one, try not to waste it."

/obj/item/reagent_container/hypospray/autoinjector/primeable/morphine
	name = "morphine syrette"
	chemname = "morphine"
	desc = "A tan syrette filled with 10 units of morphine. Not enough to knock someone out, but close. Most patients can take two doses."
	icon_state = "morphine"
	amount_per_transfer_from_this = LOW_REAGENTS_OVERDOSE_CRITICAL
	volume = LOW_REAGENTS_OVERDOSE_CRITICAL
	uses_left = 1
	prime_sound = 'sound/weapons/handling/m79_break_open.ogg'

	prime_text = "You pop the cap off of the morphine syrette."
	description_unprimed = "The morphine syrette still has the cap on it."
	description_primed = "The morphine syrette is ready to be used."
	instructions = "OD at 20u. Sitting somewhere between tramadol and oxycodone, this is a fairly good painkiller."

/obj/item/reagent_container/hypospray/autoinjector/primeable/burnguard
	name = "Optican BurnGuard package"
	chemname = "burnguard"
	desc = "An effective and simple to administer first-response burn treatment powder. Previously only seen in niche industrial settings where personnel worked with extreme heat or dangerous chemicals, now adapted for use by the UNSC as a relatively reliable first-aid treatment for the effects of plasma burns."
	desc_lore = "Application is excruciating as the powder forms a hardened antibacterial \"scab\" over the wound site, encouraging healing."
	icon_state = "burnguard"
	amount_per_transfer_from_this = 10
	volume = HIGH_REAGENTS_OVERDOSE
	uses_left = 6
	prime_sound = "rip"
	injectSFX = 'sound/items/powder_shake.ogg'

	prime_text = "You tear open the Optican BurnGuard package."
	description_unprimed = "The Optican BurnGuard package is still sealed."
	description_primed = "The Optican BurnGuard package is torn open."
	instructions = "OD at 30u. Functionally identical to kelotane along with slightly better painkilling properties than paracetamol, but with a smaller administer amount per \"injection.\""

// ----------------------------- Other -----------------------------

/obj/item/reagent_container/syringe/halo // I HATE SYRINGESTAB. FUCKING SHITCODE but i dont want to override it :>
	name = "milspec syringe"
	icon = 'icons/halo/obj/items/chemistry.dmi'
	icon_state = "0"

/obj/item/reagent_container/syringe/halo/afterattack(obj/target, mob/user, proximity) // i am a monument to all your sins
	if(!proximity) return
	if(!target.reagents) return

	if(mode == SYRINGE_BROKEN)
		to_chat(user, SPAN_DANGER("This syringe is broken!"))
		return

	var/injection_time = 5 SECONDS
	if(user.skills)
		if(!skillcheck(user, SKILL_MEDICAL, SKILL_MEDICAL_TRAINED))
			to_chat(user, SPAN_WARNING("You aren't trained to use syringes... better go slow."))
		else
			injection_time = ((injection_time/5)*user.get_skill_duration_multiplier(SKILL_MEDICAL))


	switch(mode)
		if(SYRINGE_DRAW)

			if(reagents.total_volume >= reagents.maximum_volume)
				to_chat(user, SPAN_DANGER("The syringe is full."))
				return

			if(ismob(target))//Blood!
				if(iscarbon(target))//maybe just add a blood reagent to all mobs. Then you can suck them dry...With hundreds of syringes. Jolly good idea.
					var/amount = src.reagents.maximum_volume - src.reagents.total_volume
					var/mob/living/carbon/T = target
					if(T.get_blood_id() && reagents.has_reagent(T.get_blood_id()))
						to_chat(user, SPAN_DANGER("There is already a blood sample in this syringe"))
						return

					if(ishuman(T))
						var/mob/living/carbon/human/H = T
						if(H.species.flags & NO_BLOOD)
							to_chat(user, SPAN_DANGER("You are unable to locate any blood."))
							return
						else
							T.take_blood(src,amount)
					else
						T.take_blood(src,amount)

					on_reagent_change()
					reagents.handle_reactions()
					user.visible_message(SPAN_WARNING("[user] takes a blood sample from [target]."),
						SPAN_NOTICE("You take a blood sample from [target]."), null, 4)

			else //if not mob
				if(!target.reagents.total_volume)
					to_chat(user, SPAN_DANGER("[target] is empty."))
					return

				if(!target.is_open_container() && !target.can_be_syringed())
					to_chat(user, SPAN_DANGER("You cannot directly remove reagents from this object."))
					return

				var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this) // transfer from, transfer to - who cares?

				if(!trans)
					to_chat(user, SPAN_DANGER("You fail to remove reagents from [target]."))
					return

				to_chat(user, SPAN_NOTICE(" You fill the syringe with [trans] units of the solution."))
			if (reagents.total_volume >= reagents.maximum_volume)
				mode=!mode
				update_icon()

		if(SYRINGE_INJECT)
			if(!reagents.total_volume)
				to_chat(user, SPAN_DANGER("The syringe is empty."))
				return
			if(istype(target, /obj/item/implantcase/chem))
				return

			if(!target.is_open_container() && !ismob(target) && !target.can_be_syringed())
				to_chat(user, SPAN_DANGER("You cannot directly fill this object."))
				return
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				to_chat(user, SPAN_DANGER("[target] is full."))
				return

			if(ismob(target))
				var/mob/living/M = target
				if(!istype(M))
					return
				if(!M.can_inject(user, TRUE))
					return
				if(target != user)

					if(ishuman(target))
						var/mob/living/carbon/human/H = target
						if(istype(H.wear_suit, /obj/item/clothing/suit/space))
							injection_time = 60

					if(injection_time != 60)
						user.visible_message(SPAN_DANGER("<B>[user] is trying to inject [target]!</B>"))
					else
						user.visible_message(SPAN_DANGER("<B>[user] begins hunting for an injection port on [target]'s suit!</B>"))

					if(!do_after(user, injection_time, INTERRUPT_ALL, BUSY_ICON_FRIENDLY, target, INTERRUPT_MOVED, BUSY_ICON_MEDICAL)) return

					user.visible_message(SPAN_DANGER("[user] injects [target] with the syringe!"))

					var/list/injected = list()
					for(var/datum/reagent/R in src.reagents.reagent_list)
						injected += R.name
						R.last_source_mob = WEAKREF(user)
					var/contained = english_list(injected)
					M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been injected with [src.name] by [key_name(user)]. Reagents: [contained]</font>")
					user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to inject [key_name(M)]. Reagents: [contained]</font>")
					msg_admin_attack("[key_name(user)] injected [key_name(M)] with [src.name] (REAGENTS: [contained]) (INTENT: [uppertext(intent_text(user.a_intent))]) in [get_area(user)] ([user.loc.x],[user.loc.y],[user.loc.z]).", user.loc.x, user.loc.y, user.loc.z)

				reagents.reaction(target, INGEST)


			var/trans = amount_per_transfer_from_this
			if(iscarbon(target) && locate(/datum/reagent/blood) in reagents.reagent_list)
				var/mob/living/carbon/C = target
				C.inject_blood(src, amount_per_transfer_from_this)
			else

				var/list/reagents_in_syringe = list()
				for(var/datum/reagent/R in reagents.reagent_list)
					reagents_in_syringe += R.name
				var/contained = english_list(reagents_in_syringe)
				user.attack_log += text("\[[time_stamp()]\] <font color='red'>[key_name(user)] injected [target] with a syringe (REAGENTS: [contained]) (INTENT: [uppertext(intent_text(user.a_intent))])</font>")
				msg_admin_niche("[key_name(user)] injected [target] with a syringe (REAGENTS: [contained]) (INTENT: [uppertext(intent_text(user.a_intent))]) in [get_area(user)] ([user.loc.x],[user.loc.y],[user.loc.z]).", user.loc.x, user.loc.y, user.loc.z)

				trans = reagents.trans_to(target, amount_per_transfer_from_this)

			to_chat(user, SPAN_NOTICE(" You inject [trans] units of the solution. The syringe now contains [src.reagents.total_volume] units."))
			if (reagents.total_volume <= 0 && mode==SYRINGE_INJECT)
				mode = SYRINGE_DRAW
				update_icon()

/obj/item/reagent_container/syringe/halo/update_icon()
	if(mode == SYRINGE_BROKEN)
		icon_state = "broken"
		overlays.Cut()
		return
	var/rounded_vol = round(reagents.total_volume,5)
	overlays.Cut()
	if(ismob(loc))
		var/injoverlay
		switch(mode)
			if (SYRINGE_DRAW)
				injoverlay = "draw"
			if (SYRINGE_INJECT)
				injoverlay = "inject"
		overlays += injoverlay
	icon_state = "[rounded_vol]"
	item_state = "syringe_[rounded_vol]"

	if(reagents.total_volume)
		var/image/filling = image('icons/halo/obj/items/chemistry.dmi', src, "syringe10")

		filling.icon_state = "syringe[rounded_vol]"

		filling.color = mix_color_from_reagents(reagents.reagent_list)
		overlays += filling

// ----------------------------- Autoinjectors -----------------------------

/obj/item/reagent_container/hypospray/autoinjector/tricord/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/adrenaline/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/adrenaline_concentrated/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/dexalinp/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/chloralhydrate/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/tramadol/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/oxycodone/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/kelotane/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/bicaridine/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/inaprovaline/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'

/obj/item/reagent_container/hypospray/autoinjector/dylovene/halo
	icon = 'icons/halo/obj/items/chemistry.dmi'
	amount_per_transfer_from_this = REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD
	volume = (REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD) * INJECTOR_USES

/obj/item/reagent_container/hypospray/autoinjector/halo_peridaxon
	name = "\improper peridaxon autoinjector"
	icon = 'icons/halo/obj/items/chemistry.dmi'
	chemname = "peridaxon"
	desc = "An autoinjector loaded with 3 uses of Peridaxon, the novel blend of drugs that TEMPORARILY halts the symptoms of organ damage."
	amount_per_transfer_from_this = LOWH_REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD
	volume = (LOWH_REAGENTS_OVERDOSE * INJECTOR_PERCENTAGE_OF_OD) * INJECTOR_USES
	uses_left = 3
	display_maptext = TRUE
	maptext_label = "Pr"
