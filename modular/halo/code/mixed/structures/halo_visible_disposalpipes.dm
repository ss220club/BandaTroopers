/obj/structure/disposalpipe/visible_dark
	color = "#808080"

/obj/structure/disposalpipe/visible_dark/update()
	invisibility = 0
	updateicon()

/obj/structure/disposalpipe/visible_dark/hide(intact)
	invisibility = 0
	updateicon()

/obj/structure/disposalpipe/visible_dark/segment
	icon_state = "pipe-s"

/obj/structure/disposalpipe/visible_dark/segment/Initialize(mapload, ...)
	. = ..()
	if(icon_state == "pipe-s")
		dpdir = dir | turn(dir, 180)
	else
		dpdir = dir | turn(dir, -90)
	update()

/obj/structure/disposalpipe/visible_dark/up
	icon_state = "pipe-u"

/obj/structure/disposalpipe/visible_dark/up/Initialize(mapload, ...)
	. = ..()
	dpdir = dir
	update()

/obj/structure/disposalpipe/visible_dark/up/nextdir(fromdir)
	var/nextdir
	if(fromdir == 11)
		nextdir = dir
	else
		nextdir = 12
	return nextdir

/obj/structure/disposalpipe/visible_dark/up/transfer(obj/structure/disposalholder/H)
	var/nextdir = nextdir(H.dir)
	H.setDir(nextdir)

	var/turf/T
	var/obj/structure/disposalpipe/P

	if(nextdir == 12)
		H.forceMove(loc)
		return

	T = get_step(loc, H.dir)
	P = H.findpipe(T)

	if(P)
		var/obj/structure/disposalholder/H2 = locate() in P
		if(H2 && !H2.active)
			H.merge(H2)

		H.forceMove(P)
	else
		H.forceMove(T)
		return null
	return P

/obj/structure/disposalpipe/visible_dark/junction
	icon_state = "pipe-j1"

/obj/structure/disposalpipe/visible_dark/junction/Initialize(mapload, ...)
	. = ..()
	if(icon_state == "pipe-j1")
		dpdir = dir | turn(dir, -90) | turn(dir, 180)
	else if(icon_state == "pipe-j2")
		dpdir = dir | turn(dir, 90) | turn(dir, 180)
	else
		dpdir = dir | turn(dir, 90) | turn(dir, -90)
	update()

/obj/structure/disposalpipe/visible_dark/junction/nextdir(fromdir)
	var/flipdir = turn(fromdir, 180)
	if(flipdir != dir)
		return dir

	var/mask = ..(fromdir)
	var/setbit = 0
	if(mask & NORTH)
		setbit = NORTH
	else if(mask & SOUTH)
		setbit = SOUTH
	else if(mask & EAST)
		setbit = EAST
	else
		setbit = WEST

	if(prob(50))
		return setbit
	return mask & (~setbit)
