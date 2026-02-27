/atom/movable/vis_obj/xeno_wounds/arachnid
	icon = 'modular/arachnid/icons/mobs/warrior/arachnid.dmi'

/mob/living/carbon/xenomorph/arachnid/Initialize(mapload, mob/living/carbon/xenomorph/old_xeno, hivenumber)
	. = ..()
	vis_contents -= wound_icon_holder
	wound_icon_holder = new /atom/movable/vis_obj/xeno_wounds/arachnid(null, src)
	vis_contents += wound_icon_holder
