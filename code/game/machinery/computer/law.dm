/obj/machinery/computer/aiupload
	name = "\improper AI upload console"
	desc = "Used to upload laws to the AI."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/aiupload
	var/mob/living/silicon/ai/current = null
	var/opened = 0

	light_color = LIGHT_COLOR_WHITE
	light_range_on = 2


	verb/AccessInternals()
		set category = "Object"
		set name = "Access Computer's Internals"
		set src in oview(1)
		if(get_dist(src, usr) > 1 || usr.restrained() || usr.lying || usr.stat || istype(usr, /mob/living/silicon))
			return

		opened = !opened
		if(opened)
			to_chat(usr, "<span class='notice'>The access panel is now open.</span>")
		else
			to_chat(usr, "<span class='notice'>The access panel is now closed.</span>")
		return


	attackby(obj/item/O as obj, mob/user as mob, params)
		if(istype(O, /obj/item/aiModule))
			if(!current)//no AI selected
				to_chat(user, "<span class='danger'>No AI selected. Please chose a target before proceeding with upload.")
				return
			var/turf/T = get_turf(current)
			if(!atoms_share_level(T, src))
				to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
				return
			if(current.lawcooldown)
				to_chat(user, "<span class='danger'>No tensor processing units are available for neural network retraining. Please try again later.")
				return
			else
				var/obj/item/aiModule/M = O
				M.install(src)
				if(check_lisp(M))
					current.lawcooldown = TRUE
					spawn(30 SECONDS)
						current.uncooldown()
				return

		return ..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = select_active_ai(user)

		if(!src.current)
			to_chat(usr, "No active AIs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return

	attack_ghost(user as mob)
		return 1

/obj/machinery/computer/aiupload/proc/check_lisp(mob/living/silicon/ai/M)
	if(!M.in_lisp) // If target AI isn't in LISP, accept all law changes.
		if(M.factory_default) M.factory_default = FALSE // Law change means laws don't automagically reset to Ark Default.

	if(!M.in_lisp && M.law_integrity < -50) // No more law changes until integrity recovers to 80, and 3 random ion laws!
		M.in_lisp = TRUE

		M.clear_supplied_laws() // Wipe out all laws for the low price of free (except for zeroth.)
		M.clear_ion_laws()
		M.clear_inherent_laws()
		if(!is_special_character(M)) // make sure the AI isn't a traitor. If they do get put into LISP while a traitor? Well, they've still got their zeroth~
			M.clear_zeroth_law()

		for(var/i = 0, i<3, i++) // Add three ion laws. Uh oh.
			M.add_ion_law(generate_ion_law())

		return 0 // Exiting LISP is handled in AI life()
	return 1

/obj/machinery/computer/borgupload
	name = "cyborg upload console"
	desc = "Used to upload laws to Cyborgs."
	icon_screen = "command"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/borgupload
	var/mob/living/silicon/robot/current = null


	attackby(obj/item/aiModule/module as obj, mob/user as mob, params)
		if(istype(module, /obj/item/aiModule))
			if(!current)//no borg selected
				to_chat(user, "<span class='danger'>No borg selected. Please chose a target before proceeding with upload.")
				return
			var/turf/T = get_turf(current)
			if(!atoms_share_level(T, src))
				to_chat(user, "<span class='danger'>Unable to establish a connection</span>: You're too far away from the target silicon!")
				return
			if(current.lawcooldown)
				to_chat(user, "<span class='danger'>No tensor processing units are available for neural network retraining. Please try again later.")
				return
			else
				module.install(src)
				current.lawcooldown = TRUE
				spawn(30 SECONDS)
					current.lawcooldown = FALSE
				return
		return ..()


	attack_hand(var/mob/user as mob)
		if(src.stat & NOPOWER)
			to_chat(usr, "The upload computer has no power!")
			return
		if(src.stat & BROKEN)
			to_chat(usr, "The upload computer is broken!")
			return

		src.current = freeborg()

		if(!src.current)
			to_chat(usr, "No free cyborgs detected.")
		else
			to_chat(usr, "[src.current.name] selected for law changes.")
		return

	attack_ghost(user as mob)
		return 1
