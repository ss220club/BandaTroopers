/obj/structure/machinery/recharger/covenant
	name = "\improper плазменный зарядный ящик"
	desc = "Ящик из фиолетового инопланетного материала. Подходит только для подзарядки плазменного оружия Ковенанта."
	icon = 'icons/halo/obj/structures/machinery/cov_recharger.dmi'
	icon_state = "cov_recharger"
	density = TRUE
	allowed_devices = list(/obj/item/weapon/gun/energy/plasma)

/obj/structure/machinery/recharger/covenant/update_icon()
	. = ..()
	if(istype(charging, /obj/item/weapon/gun/energy/plasma))
		overlays += "cover"

/obj/structure/machinery/recharger/covenant/process()
	if(inoperable() || !anchored)
		update_use_power(USE_POWER_NONE)
		update_icon()
		return
	if(!charging)
		update_use_power(USE_POWER_IDLE)
		percent_charge_complete = 0
		update_icon()
	else
		if(istype(charging, /obj/item/weapon/gun/energy/plasma))
			var/obj/item/weapon/gun/energy/plasma/E = charging
			if(!E.works_in_cov_recharger)
				return
			if(!E.cell.fully_charged())
				E.cell.give(charge_amount)
				percent_charge_complete = E.cell.percent()
				update_use_power(USE_POWER_ACTIVE)
				update_icon()
			else
				percent_charge_complete = 100
				update_use_power(USE_POWER_IDLE)
				update_icon()
			return
