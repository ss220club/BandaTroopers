
/proc/agibs(atom/location, list/viruses)
	new /obj/effect/spawner/gibspawner/arachnid(get_turf(location),viruses)

/obj/effect/spawner/gibspawner/arachnid
	gibtypes = list(
		/obj/effect/decal/cleanable/blood/gibs/arachnid,
		/obj/effect/decal/cleanable/blood/gibs/arachnid/limb,
		/obj/effect/decal/cleanable/blood/gibs/arachnid/body,
		/obj/effect/decal/cleanable/blood/gibs/arachnid/splat,
	)
	gibamounts = list(1,1,1,2)

/obj/effect/spawner/gibspawner/arachnid/Initialize(mapload, list/viruses, mob/living/ml, fleshcolor, bloodcolor)
	gibdirections = list(GLOB.alldirs, GLOB.alldirs, list(), GLOB.alldirs)
	. = ..()
