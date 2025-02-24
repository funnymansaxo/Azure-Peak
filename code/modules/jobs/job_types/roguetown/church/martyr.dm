#define STATE_SAFE 			0
#define STATE_MARTYR		1
#define STATE_MARTYRULT		2

/datum/component/martyrweapon
	var/list/allowed_areas = list(/area/rogue/indoors/town/church, /area/rogue/indoors/town/church/chapel, /area/rogue/indoors/town/church/basement)
	var/list/allowed_patrons = list()
	var/cooldown = 30 MINUTES
	var/last_activation = 0
	var/next_activation = 0
	var/end_activation = 0
	var/ignite_chance = 10
	var/traits_applied = list(TRAIT_NOPAIN, TRAIT_NOPAINSTUN, TRAIT_CRITICAL_RESISTANCE, TRAIT_NOMOOD, TRAIT_NOHUNGER, TRAIT_EASYDISMEMBER, TRAIT_STRONGBITE)
	var/stat_bonus_martyr = 3
	var/mob/living/current_holder
	var/is_active = FALSE
	var/allow_all = FALSE
	var/is_activating
	var/current_state = STATE_SAFE
	var/martyr_duration = 6 MINUTES
	var/safe_duration = 9 MINUTES
	var/ultimate_duration = 2 MINUTES
	var/is_dying = FALSE
	var/death_time
	var/last_time

/datum/component/martyrweapon/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(item_afterattack))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	START_PROCESSING(SSdcs, src)

/datum/component/martyrweapon/process()
	if(is_active)
		if(world.time > end_activation)
			handle_end()
		else
			var/timer = timehint()
			if(timer == 30 && current_state == STATE_MARTYRULT)
				adjust_stats(STATE_MARTYRULT)
	if(is_dying && death_time)
		if(world.time > death_time)
			killhost()

/datum/component/martyrweapon/proc/handle_end()
	deactivate()
	var/mob/living/carbon/C = current_holder
	switch(current_state)
		if(STATE_SAFE)
			var/area/A = get_area(current_holder)
			var/success = FALSE
			for(var/AR in allowed_areas)
				if(istype(A, AR))
					success = TRUE
					break
			if(!success)
				for(var/turf/T in view(world.view, C))	//One last mercy check to see if it fizzles out while the church is on-screen.
					var/mercyarea = get_area(T)
					for(var/AR in allowed_areas)
						if(istype(mercyarea, AR))
							success = TRUE
				to_chat(current_holder, span_notice("The weapon fizzles out, its energies dissipating across the holy grounds."))
			else
				to_chat(current_holder, span_notice("The weapon begins to fizzle out, but the energy has nowhere to go!"))
				C.freak_out()
				if(prob(35))
					deathprocess()
				else
					to_chat(current_holder, span_notice("You manage to endure it, this time."))
		if(STATE_MARTYR)
			C.freak_out()
			deathprocess()

		if(STATE_MARTYRULT)
			C.freak_out()
			deathprocess()

/datum/component/martyrweapon/proc/deathprocess()
	if(current_holder)
		current_holder.Stun(16000, 1, 1)	//Even if you glitch out to survive you're still permastunned, you are not meant to come back from this
		current_holder.Knockdown(16000, 1, 1)
		var/count = 3
		var/list/targets = list(current_holder)
		var/mob/living/carbon/human/H = current_holder
		if(H.cmode)	//Turn off the music
			H.toggle_cmode()
		lightning_strike_heretics(H)
		addtimer(CALLBACK(src, PROC_REF(killhost)), 60 SECONDS)
		for(var/i = 1, i<=count,i++)
			if(do_after_mob(H, targets, 70, uninterruptible = 1))
				switch(i)
					if(1)
						current_holder.visible_message(span_warning("[current_holder] twitches and writhes from godly energies!"), span_warning("You can feel the weapon tap into your very being, pulling apart your body!"))
						current_holder.playsound_local(current_holder, 'sound/health/fastbeat.ogg', 100)
					if(2)
						current_holder.visible_message(span_warning("[current_holder]'s body contorts, bones splitting apart, tearing through flesh and fabric!"), span_warning("Your bones break and crack, splintering from your flesh as the power of [H.patron.name] overwhelms you."))
						H.emote_scream()
						playsound(current_holder, pick('sound/combat/fracture/headcrush (1).ogg', 'sound/combat/fracture/fracturewet (1).ogg'), 100)
					if(3)
						current_holder.visible_message(span_warning("[current_holder] ceases to move, and lets out one final gasp. It sounds content, despite the state of their body."), span_warning("Your body is nearly gone. Yet a sense of bliss and fulfillment washes over you. [H.patron.name] blessed you with this opportunity. Your Oath is fulfilled."))
						current_holder.playsound_local(current_holder, 'sound/magic/ahh1.ogg', 100)

/datum/component/martyrweapon/proc/killhost()
	if(current_holder)
		var/mob/living/carbon/human/H = current_holder
		current_holder.visible_message(span_info("[current_holder] fades away."), span_info("Your life led up to this moment. In the face of the decay of the world, you endured. Now you rest. You feel your soul shed from its mortal coils, and the embrace of [H.patron.name]"))
		H.dust(drop_items = TRUE)
		is_dying = FALSE

/datum/component/martyrweapon/proc/trigger_pulse(range = 2, isfinal = FALSE)
	for(var/mob/M in oviewers(range, current_holder))
		mob_ignite(M)
		if(isfinal)
			if(ishuman(M))
				var/mob/living/carbon/human/H
				var/type = H.patron?.type
				if(istype(type, /datum/patron/inhumen))
					H.electrocution_animation(20)

/datum/component/martyrweapon/proc/timehint()
	var/result = round((end_activation - world.time) / 600)	//Minutes
	if(result != last_time && result != 0)
		to_chat(current_holder,span_notice("[result + 1] minutes left."))
		last_time = result
		return result
	if(result == 0)
		var/resultadv = (end_activation - world.time) / 10	//Seconds
		if(resultadv < 30 && resultadv > 25 && last_time != 30)
			to_chat(current_holder,span_notice("30 SECONDS!"))
			last_time = 30
			return 30
		else
			if(resultadv == 10 && last_time != 10)
				to_chat(current_holder,span_crit("10 SECONDS"))
				last_time = resultadv
	return 0

/datum/component/martyrweapon/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	if(is_active && proximity_flag)
		if(isobj(target))
			target.spark_act()
			target.fire_act()
		else if(isliving(target))
			var/mob/living/M = target
			switch(current_state)
				if(STATE_SAFE)
					return
				if(STATE_MARTYR)
					if(prob(ignite_chance))
						mob_ignite(M)
				if(STATE_MARTYRULT)
					mob_ignite(M)
		else
			return
	else
		return

/datum/component/martyrweapon/proc/mob_ignite(mob/target)
	if(isliving(target))
		var/mob/living/M = target
		M.adjust_fire_stacks(5)
		M.IgniteMob()

/datum/component/martyrweapon/proc/on_equip(datum/source, mob/user, slot)
	if(!allow_all)
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(HAS_TRAIT(user, TRAIT_ROTMAN) || HAS_TRAIT(user, TRAIT_NOBREATH))	//Can't be a Martyr if you're undead already.
				to_chat(H, span_warn("It burns and sizzles! It does not tolerate my pallid flesh!"))
				H.dropItemToGround(parent)
				return
			var/datum/job/J = SSjob.GetJob(H.mind?.assigned_role)
			if(!J.title == "Martyr" && !J.title == "Priest")		//Can't be a Martyr if you're not a Martyr. Or a Priest.
				to_chat(H, span_warn("It slips from my grasp. I can't get a hold."))
				H.dropItemToGround(parent)
				return
			else
				RegisterSignal(user, COMSIG_CLICK_ALT, PROC_REF(altclick), override = TRUE)
				current_holder = user
			if(J.title == "Martyr")
				to_chat(user, span_warning("The blade binds to you."))
			if(J.title == "Priest")
				to_chat(user, span_warning("You feel the shocking sensation as the sword attempts to bind to you. You know it will kill you. You can still drop it, and leave it for the Oathed."))
	else
		RegisterSignal(user, COMSIG_CLICK_ALT, PROC_REF(altclick), override = TRUE)
		current_holder = user

/datum/component/martyrweapon/proc/altclick(mob/user)
	if(user == current_holder && !is_active && !is_activating)
		if(world.time > next_activation)
			if(!allow_all)
				var/A = get_area(user)
				if(A)
					var/area/testarea = A
					var/success = FALSE
					for(var/AR in allowed_areas)
						if(istype(testarea, AR))
							success = TRUE
							break
					if(success)
						if(alert("You are within holy grounds. Do you wish to call your god to aid in its defense? (You will live if the duration ends within the Church.)", "Your Oath", "Yes", "No") == "Yes")
							is_activating = TRUE
							activate(user, STATE_SAFE)
					else
						if(alert("You are trying to activate the weapon outside of holy grounds. Do you wish to fulfill your Oath of Vengeance? (You will die.)", "Your Oath", "Yes", "No") == "Yes")
							var/choice = alert("You pray to your god. How many minutes will you ask for? (Shorter length means greater boons)","Your Oath (It is up to you if your death is canon)", "Six", "Two", "Nevermind")
							switch(choice)
								if("Six")
									is_activating = TRUE
									activate(user, STATE_MARTYR)
								if("Two")
									is_activating = TRUE
									activate(user, STATE_MARTYRULT)
								if("Nevermind")
									to_chat(user, "You reconsider. It is not the right moment.")
									return
			else
				activate(user)

/datum/component/martyrweapon/proc/on_drop(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_CLICK_ALT)
	deactivate()

/datum/component/martyrweapon/proc/on_examine(datum/source, mob/user, list/examine_list)
	if(current_holder)
		examine_list += span_notice("It looks to be bound to you. Alt + right click to activate it.")
	if(!is_active && world.time < next_activation)
		var/time = last_activation - world.time
		time = time / 10	//Deciseconds to seconds
		examine_list += span_notice("The time remaining until it is prepared: [abs(time)] seconds.")
	else if(!is_active && world.time > next_activation)
		examine_list += span_notice("It looks ready to be used again.")
	if(is_active)
		examine_list += span_warningbig("It is lit afire by godly energies!")
		if(user == current_holder)
			examine_list += span_warningbig("<i>SLAY THE HERETICS! TAKE THEM WITH YOU!</i>")

/datum/component/martyrweapon/proc/adjust_traits(remove = FALSE)
	for(var/trait in traits_applied)
		if(!remove)
			ADD_TRAIT(current_holder, trait, TRAIT_GENERIC)
		else
			REMOVE_TRAIT(current_holder, trait, TRAIT_GENERIC)

/datum/component/martyrweapon/proc/adjust_stats(state)
	if(current_holder)
		switch(state)
			if(STATE_SAFE)
				return		//no stat buffs for safe martyr
			if(STATE_MARTYR)
				current_holder.STASTR += stat_bonus_martyr
				current_holder.STASPD += stat_bonus_martyr
				current_holder.STACON += stat_bonus_martyr
				current_holder.STAEND += stat_bonus_martyr
				current_holder.STAINT += stat_bonus_martyr
				current_holder.STAPER += stat_bonus_martyr
				current_holder.STALUC += stat_bonus_martyr
			if(STATE_MARTYRULT)	//Go get 'em, Martyrissimo, it's your last 30 seconds, it's a frag or be fragged world
				current_holder.STASTR = 20
				current_holder.STASPD = 20
				current_holder.STACON = 20
				current_holder.STAEND = 20
				current_holder.STAINT = 20
				current_holder.STAPER = 20
				current_holder.STALUC = 20
				if(ishuman(current_holder))
					var/mob/living/carbon/human/H = current_holder
					if(H.mind)
						H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 6, FALSE)
						H.mind.adjust_skillrank(/datum/skill/combat/swords, 6, FALSE)
						H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 6, FALSE)
						H.mind.adjust_skillrank(/datum/skill/misc/athletics, 6, FALSE)
				ADD_TRAIT(current_holder, TRAIT_NOROGSTAM, TRAIT_GENERIC)
				current_holder.visible_message(span_warning("[current_holder] rises up, empowered once more!"), span_warningbig("I rise again! I can feel my god flow through me!"))
				flash_lightning(current_holder)
				current_holder.revive(full_heal = TRUE, admin_revive = TRUE)

/datum/component/martyrweapon/proc/deactivate()
	var/obj/item/I = parent
	if(HAS_TRAIT(parent, TRAIT_NODROP))
		REMOVE_TRAIT(parent, TRAIT_NODROP, TRAIT_GENERIC)
	is_active = FALSE
	I.damtype = BRUTE
	I.slot_flags = initial(I.slot_flags)
	adjust_traits(remove = TRUE)
	adjust_icons(tonormal = TRUE)

/datum/component/martyrweapon/proc/flash_lightning(mob/user)
	for(var/mob/living/carbon/M in viewers(world.view, user))
		M.lightning_flashing = TRUE
		M.update_sight()
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon, reset_lightning)), 2)
	var/turf/T = get_step(get_step(user, NORTH), NORTH)
	T.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(user, 'sound/magic/lightning.ogg', 100, FALSE)

/datum/component/martyrweapon/proc/lightning_strike_heretics(mob/user)
	for(var/mob/living/carbon/human/M in viewers(world.view, user))
		M.lightning_flashing = TRUE
		M.update_sight()
		addtimer(CALLBACK(M, TYPE_PROC_REF(/mob/living/carbon, reset_lightning)), 2)
		if(istype(M.patron, /datum/patron/inhumen))
			var/turf/T = get_step(get_step(M, NORTH), NORTH)
			T.Beam(M, icon_state="lightning[rand(1,12)]", time = 5)
			M.visible_message(span_warning("[M] gets struck down by the Ten!"), span_warning("The Ten curse you! You stood too close to one of their devout!"))
			M.electrocution_animation(20)
			mob_ignite(M)
			playsound(M, 'sound/magic/lightning.ogg', 100, FALSE)

/datum/component/martyrweapon/proc/adjust_icons(tonormal = FALSE)
	var/obj/item/I = parent
	if(!tonormal)
		if(current_state == STATE_MARTYR || current_state == STATE_MARTYRULT)
			I.toggle_state = "[I.icon_state]_ulton"
		else
			I.toggle_state = "[I.icon_state]_on"
		I.item_state = "[I.toggle_state]"
		I.icon_state = "[I.toggle_state]"
	else
		I.icon_state = initial(I.icon_state)
		I.item_state = initial(I.item_state)
		I.toggle_state = null
	
	current_holder.regenerate_icons()

/datum/component/martyrweapon/proc/activate(mob/user, status_flag)
	current_holder.visible_message("[span_notice("[current_holder] begins invoking their Oath!")]", span_notice("You begin to invoke your oath."))
	switch(status_flag)
		if(STATE_MARTYR)
			user.playsound_local(user, 'sound/misc/martyrcharge.ogg', 100, FALSE)
		if(STATE_MARTYRULT)
			user.playsound_local(user, 'sound/misc/martyrultcharge.ogg', 100, FALSE)
	if(do_after(user, 50))
		flash_lightning(user)
		var/obj/item/I = parent
		I.damtype = BURN
		I.slot_flags = null	//Can't sheathe a burning sword

		ADD_TRAIT(parent, TRAIT_NODROP, TRAIT_GENERIC)

		last_activation = world.time
		next_activation = last_activation + cooldown

		if(status_flag)
			current_state = status_flag
		adjust_icons()
		switch(current_state)
			if(STATE_SAFE)
				end_activation = world.time + safe_duration
			if(STATE_MARTYR)
				end_activation = world.time + martyr_duration
				I.max_integrity = 2000
				I.obj_integrity = I.max_integrity
				adjust_stats(current_state)
			if(STATE_MARTYRULT)
				end_activation = world.time + ultimate_duration
				I.max_integrity = 9999
				I.obj_integrity = I.max_integrity
				current_holder.STASTR += stat_bonus_martyr
				current_holder.STASPD += stat_bonus_martyr
				current_holder.STACON += stat_bonus_martyr
				current_holder.STAEND += stat_bonus_martyr
				current_holder.STAINT += stat_bonus_martyr
				current_holder.STAPER += stat_bonus_martyr
				current_holder.STALUC += stat_bonus_martyr
			else
				end_activation = world.time + safe_duration

		if(ishuman(current_holder))
			var/mob/living/carbon/human/H = current_holder
			switch(status_flag)
				if(STATE_MARTYR)
					SEND_SOUND(H, sound(null))
					H.cmode_music = 'sound/music/combat_martyr.ogg'
					to_chat(H, span_warning("I can feel my muscles nearly burst from power! I can jump great heights!"))
					ADD_TRAIT(H, TRAIT_ZJUMP, TRAIT_GENERIC)
					ADD_TRAIT(H, TRAIT_NOFALLDAMAGE2, TRAIT_GENERIC)
				if(STATE_MARTYRULT)
					SEND_SOUND(H, sound(null))
					H.cmode_music = 'sound/music/combat_martyrult.ogg'
					to_chat(H, span_warning("I can jump great heights!"))
					ADD_TRAIT(H, TRAIT_ZJUMP, TRAIT_GENERIC)
					ADD_TRAIT(H, TRAIT_NOFALLDAMAGE2, TRAIT_GENERIC)
			adjust_traits(remove = FALSE)
			if(!H.cmode)
				H.toggle_cmode()
			else
				H.toggle_cmode()
				H.toggle_cmode()

		is_activating = FALSE
		is_active = TRUE
	else
		is_activating = FALSE
		SEND_SOUND(current_holder, sound(null))

/datum/job/roguetown/martyr
	title = "Martyr"
	department_flag = CHURCHMEN
	faction = "Station"
	tutorial = "Martyrs are hand-picked among the most devout of the Holy See. They are given one of the See's cherished relics to protect the Church, and to inspire hope and lead by example of grace, kindness and vicious intolerance to any who do not share the belief of the Ten. They have sworn an Oath in the sight of the gods, and will fulfill it to the bitter end."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	allowed_patrons = ALL_DIVINE_PATRONS
	outfit = /datum/outfit/job/roguetown/martyr
	min_pq = 10 //Cus it's a Martyr of the Ten. Get it.
	max_pq = null
	round_contrib_points = 3
	total_positions = 1
	spawn_positions = 1
	advclass_cat_rolls = list(CTAG_TEMPLAR = 20)
	display_order = JDO_TEMPLAR
	undead_not_allowed = TRUE
	
	give_bank_account = TRUE

	cmode_music = 'sound/music/combat_martyrsafe.ogg'


/datum/outfit/job/roguetown/martyr/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor
	belt = /obj/item/storage/belt/rogue/leather/plaquegold
	beltr = /obj/item/storage/keyring/priest
	backr = /obj/item/storage/backpack/rogue/satchel
	gloves = /obj/item/clothing/gloves/roguetown/chain
	wrists = /obj/item/clothing/wrists/roguetown/bracers
	neck = /obj/item/clothing/neck/roguetown/bevor
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/holysee
	shirt = /obj/item/clothing/suit/roguetown/armor/chainmail
	pants = /obj/item/clothing/under/roguetown/platelegs/holysee
	cloak = /obj/item/clothing/cloak/holysee
	head = /obj/item/clothing/head/roguetown/helmet/heavy/holysee

	//No, they don't get any miracles. Their miracle is being able to use their weapon at all.
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 5, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/swords, 4, TRUE)	//Maybe activating the sword could give them Expert / Master and they stay at Jman by default?
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/knives, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/cooking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
		ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_NOBLE, TRAIT_GENERIC)
		ADD_TRAIT(H, TRAIT_DUALWIELDER, TRAIT_GENERIC)	//You can't dual wield the unique weapon, this is more to cover for the NODROP weapon that might end up in an off-hand.
		H.change_stat("strength", 2)
		H.change_stat("constitution", 3)
		H.change_stat("endurance", 3)
		H.change_stat("intelligence", 1)
		H.change_stat("perception", 1)
		H.dna.species.soundpack_m = new /datum/voicepack/male/knight()


/obj/item/rogueweapon/sword/long/martyr
	force = 30
	force_wielded = 36
	possible_item_intents = list(/datum/intent/sword/cut, /datum/intent/sword/thrust, /datum/intent/sword/strike)
	gripped_intents = list(/datum/intent/sword/cut, /datum/intent/sword/thrust, /datum/intent/sword/strike, /datum/intent/sword/chop)
	icon_state = "martyrsword"
	icon = 'icons/roguetown/weapons/64.dmi'
	item_state = "martyrsword"
	lefthand_file = 'icons/mob/inhands/weapons/roguemartyr_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/roguemartyr_righthand.dmi'
	name = "martyr sword"
	desc = "A relic from the Holy See's own vaults. It simmers with godly energies, and will only yield to the hands of those who have taken the Oath."
	max_blade_int = 200
	max_integrity = 300
	parrysound = "bladedmedium"
	swingsound = BLADEWOOSH_LARGE
	pickup_sound = 'sound/foley/equip/swordlarge2.ogg'
	bigboy = 1
	wlength = WLENGTH_LONG
	gripsprite = TRUE
	pixel_y = -16
	pixel_x = -16
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	associated_skill = /datum/skill/combat/swords
	throwforce = 15
	thrown_bclass = BCLASS_CUT
	dropshrink = 1
	smeltresult = /obj/item/ingot/silver
	is_silver = TRUE
	toggle_state = null

/obj/item/rogueweapon/sword/long/martyr/Initialize()
	AddComponent(/datum/component/martyrweapon)
	..()

/obj/item/rogueweapon/sword/long/martyr/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen") return list("shrink" = 0.6,"sx" = -14,"sy" = -8,"nx" = 15,"ny" = -7,"wx" = -10,"wy" = -5,"ex" = 7,"ey" = -6,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = -13,"sturn" = 110,"wturn" = -60,"eturn" = -30,"nflip" = 1,"sflip" = 1,"wflip" = 8,"eflip" = 1)
			if("onback") return list("shrink" = 0.6,"sx" = -1,"sy" = 2,"nx" = 0,"ny" = 2,"wx" = 2,"wy" = 1,"ex" = 0,"ey" = 1,"nturn" = 0,"sturn" = 0,"wturn" = 70,"eturn" = 15,"nflip" = 1,"sflip" = 1,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 0,"eastabove" = 0,"westabove" = 0)
			if("wielded") return list("shrink" = 0.7,"sx" = 6,"sy" = -2,"nx" = -4,"ny" = 2,"wx" = -8,"wy" = -1,"ex" = 7,"ey" = 0,"northabove" = 0,"southabove" = 1,"eastabove" = 1,"westabove" = 0,"nturn" = 15,"sturn" = -200,"wturn" = -160,"eturn" = -25,"nflip" = 8,"sflip" = 8,"wflip" = 0,"eflip" = 0)
			if("onbelt") return list("shrink" = 0.6,"sx" = -2,"sy" = -5,"nx" = 0,"ny" = -5,"wx" = 0,"wy" = -5,"ex" = -3,"ey" = -5,"nturn" = 180,"sturn" = 180,"wturn" = 0,"eturn" = 90,"nflip" = 0,"sflip" = 0,"wflip" = 1,"eflip" = 1,"northabove" = 1,"southabove" = 1,"eastabove" = 1,"westabove" = 0)

/obj/item/clothing/cloak/martyr
	name = "martyr cloak"
	desc = "An elegant cloak in the colors of Astrata. Looks like it can only fit Humen-sized people."
	color = null
	icon_state = "martyrcloak"
	item_state = "martyrcloak"
	mob_overlay_icon = 'icons/roguetown/clothing/onmob/cloaks.dmi'
	body_parts_covered = CHEST|GROIN
	boobed = FALSE
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	flags_inv = HIDECROTCH|HIDEBOOB

/obj/item/clothing/suit/roguetown/armor/plate/full/holysee
	name = "Holy See's silver plate"
	desc = "It spent a long trek to get here from the seat of the Holy See, and now it glistens in full defiance of the rot, and its putrid supporters."
	icon = 'icons/roguetown/clothing/special/martyr.dmi'
	icon_state = "silverarmor"
	item_state = "silverarmor"
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/martyr.dmi'
	armor = list("blunt" = 80, "slash" = 100, "stab" = 80, "piercing" = 20, "fire" = 0, "acid" = 0)
	sellprice = 1000
	smeltresult = /obj/item/ingot/silver
	smelt_bar_num = 4

/obj/item/clothing/under/roguetown/platelegs/holysee
	name = "Holy See's silver platelegs"
	desc = "Its silver hues glisten majestically under any light. It provides ample, sturdy protection from heretics and vagabonds alike."
	icon = 'icons/roguetown/clothing/special/martyr.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/martyr.dmi'
	icon_state = "silverlegs"
	item_state = "silverlegs"
	sellprice = 1000
	smeltresult = /obj/item/ingot/silver
	smelt_bar_num = 3

/obj/item/clothing/head/roguetown/helmet/heavy/holysee
	name = "Holy See's silver bascinet"
	desc = "Branded by the Holy See, it denotes the holiest, most hopeful lot of its kind. Even with the visor closed, this helm will spread hope among the followers of the Ten."
	icon = 'icons/roguetown/clothing/special/martyr.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/martyrbascinet.dmi'
	adjustable = CAN_CADJUST
	emote_environment = 3
	flags_inv = HIDEEARS|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	worn_x_dimension = 64
	worn_y_dimension = 64
	icon_state = "silverbascinet"
	item_state = "silverbascinet"
	sellprice = 1000
	smeltresult = /obj/item/ingot/silver
	smelt_bar_num = 3

/obj/item/clothing/head/roguetown/helmet/heavy/holysee/AdjustClothes(mob/user)
	if(loc == user)
		playsound(user, "sound/items/visor.ogg", 100, TRUE, -1)
		if(adjustable == CAN_CADJUST)
			adjustable = CADJUSTED
			icon_state = "silverbascinet_raised"
			body_parts_covered = HEAD|EARS|HAIR
			flags_inv = HIDEEARS
			flags_cover = null
			if(ishuman(user))
				var/mob/living/carbon/H = user
				H.update_inv_head()
			block2add = null
		else if(adjustable == CADJUSTED)
			ResetAdjust(user)
			if(user)
				if(ishuman(user))
					var/mob/living/carbon/H = user
					H.update_inv_head()
		user.update_fov_angles()

/obj/item/clothing/cloak/holysee
	name = "holy see tabard"
	desc = "A tabard worn by Holy See's most devout. It has silver embroidery woven through the fabric."
	icon = 'icons/roguetown/clothing/special/martyr.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/martyr.dmi'
	icon_state = "silvertabard"
	item_state = "silvertabard"
	alternate_worn_layer = TABARD_LAYER
	body_parts_covered = CHEST|GROIN
	boobed = TRUE
	slot_flags = ITEM_SLOT_ARMOR|ITEM_SLOT_CLOAK
	flags_inv = HIDECROTCH|HIDEBOOB
	var/overarmor = TRUE
	sellprice = 100

/obj/item/clothing/cloak/holysee/MiddleClick(mob/user)
	overarmor = !overarmor
	to_chat(user, span_info("I [overarmor ? "wear the tabard over my armor" : "wear the tabard under my armor"]."))
	if(overarmor)
		alternate_worn_layer = TABARD_LAYER
	else
		alternate_worn_layer = UNDER_ARMOR_LAYER
	user.update_inv_cloak()
	user.update_inv_armor()
