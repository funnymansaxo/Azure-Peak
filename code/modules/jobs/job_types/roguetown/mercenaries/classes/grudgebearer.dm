//Dwarf-exclusive mercenary class with unique armor setups.
/datum/advclass/mercenary/grudgebearer
	name = "Grudgebearer Clan"
	tutorial = "Bound by eternal grudges of eons past that have not been forgotten, the Grudgebearers are left to wander the surface, as every other clan has a grudge against you, and you against them. This putrid swampland of a Duchy has also wronged you and your people, you care little for it. Coins are a means to an end -- something you can mine and forge yourself. Trinkets -- made by true smiths, now that will carry respect among your clan. However, such artifacts might not buy you food, or a roof."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = list(
		/datum/species/dwarf,
		/datum/species/dwarf/mountain
	)
	outfit = /datum/outfit/job/roguetown/mercenary/grudgebearer
	category_tags = list(CTAG_MERCENARY)
	cmode_music = 'sound/music/combat_grudgebearer.ogg'

/datum/outfit/job/roguetown/mercenary/grudgebearer/pre_equip(mob/living/carbon/human/H)
	..()
	shoes = /obj/item/clothing/shoes/roguetown/boots/armor/dwarven
	cloak = /obj/item/clothing/cloak/forrestercloak/snow
	belt = /obj/item/storage/belt/rogue/leather/black
	backl = /obj/item/storage/backpack/rogue/satchel
	shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt/black
	gloves = /obj/item/clothing/gloves/roguetown/plate/dwarven
	pants = /obj/item/clothing/under/roguetown/trou/leather
	armor = /obj/item/clothing/suit/roguetown/armor/plate/full/dwarven
	head = /obj/item/clothing/head/roguetown/helmet/heavy/dwarven
	backpack_contents = list(/obj/item/roguekey/mercenary, /obj/item/storage/belt/rogue/pouch/coins/poor, /obj/item/rogueweapon/hammer, /obj/item/book/rogue/grudge, /obj/item/natural/feather)
	if(H.mind)
		H.mind.adjust_skillrank(/datum/skill/combat/axes, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/maces, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/reading, 4, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/tracking, 3, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/blacksmithing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/craft/armorsmithing, 2, TRUE)
		H.mind.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	var/classes = list("Strong", "Hardy")
	var/classchoice = input("Choose your archetype", "Available archetypes") as anything in classes
	switch(classchoice)
		if("Strong")
			H.change_stat("strength", 4)
			H.change_stat("constitution", 1)
			H.change_stat("endurance", 1)
			H.change_stat("speed", -2)
		if("Hardy")
			H.change_stat("constitution", 5)
			H.change_stat("endurance", 4)
			H.change_stat("strength", 2)
			H.change_stat("speed", -2)
	var/weapons = list("Axe", "Mace")
	var/wepchoice = input("Choose your weapon", "Available weapons") as anything in weapons
	switch(wepchoice)
		if("Axe")
			backr = /obj/item/rogueweapon/stoneaxe/battle
		if("Mace")
			backr = /obj/item/rogueweapon/mace/goden/steel
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)


/obj/item/clothing/suit/roguetown/armor/plate/full/dwarven
	name = "grudgebearer dwarven plate"
	desc = "A standard, layered plate worn by many dwarven troops. It cannot be worked on without intrinsic dwarven knowledge."
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	icon_state = "dwarfchest"
	item_state = "dwarfchest"
	armor = list("blunt" = 100, "slash" = 100, "stab" = 100, "piercing" = 100, "fire" = 0, "acid" = 0)
	body_parts_covered = CHEST|GROIN|VITALS|ARMS|LEGS
	equip_delay_self = 5 SECONDS
	unequip_delay_self = 5 SECONDS
	equip_delay_other = 4 SECONDS
	strip_delay = 12 SECONDS
	smelt_bar_num = 4
	max_integrity = 6000	//They have their own unique integrity

/obj/item/clothing/suit/roguetown/armor/plate/full/dwarven/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/peelarmor/grudgebearer)

/obj/item/clothing/head/roguetown/helmet/heavy/dwarven
	name = "grudgebearer dwarven helm"
	desc = "A hardy, layered helmet. It lets one's dwarvenly beard to poke out."
	body_parts_covered = (HEAD | MOUTH | NOSE | EYES | EARS | NECK)
	armor = list("blunt" = 100, "slash" = 100, "stab" = 100, "piercing" = 80, "fire" = 0, "acid" = 0)
	prevent_crits = list(BCLASS_BLUNT, BCLASS_SMASH, BCLASS_TWIST, BCLASS_PICK)
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	icon_state = "dwarfhead"
	item_state = "dwarfhead"
	block2add = FOV_BEHIND
	bloody_icon = 'icons/effects/blood64.dmi'
	smeltresult = /obj/item/ingot/steel
	max_integrity = 3000

/obj/item/clothing/head/roguetown/helmet/heavy/dwarven/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/peelarmor/grudgebearer/helmet)

/obj/item/clothing/gloves/roguetown/plate/dwarven
	name = "grudgebearer dwarven gauntlets"
	desc = "Forged to fit the stubbiest of fingers. It is covered in protective layers."
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	icon_state = "dwarfhand"
	item_state = "dwarfhand"
	armor = list("blunt" = 100, "slash" = 100, "stab" = 100, "piercing" = 90, "fire" = 0, "acid" = 0)
	max_integrity = 3000

/obj/item/clothing/gloves/roguetown/plate/dwarven/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/peelarmor/grudgebearer/limbs)

/obj/item/clothing/shoes/roguetown/boots/armor/dwarven
	name = "grudgebearer dwarven boots"
	desc = "Clatters mightily. It is covered in protective layers."
	icon = 'icons/roguetown/clothing/special/race_armor.dmi'
	mob_overlay_icon = 'icons/roguetown/clothing/special/onmob/race_armor.dmi'
	allowed_race = list(/datum/species/dwarf, /datum/species/dwarf/mountain)
	icon_state = "dwarfshoe"
	item_state = "dwarfshoe"
	armor = list("blunt" = 100, "slash" = 100, "stab" = 100, "piercing" = 90, "fire" = 0, "acid" = 0)
	max_integrity = 3000

/obj/item/clothing/shoes/roguetown/boots/armor/dwarven/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/peelarmor/grudgebearer/limbs)

/datum/component/peelarmor/grudgebearer
	repair_items = list(
		/obj/item/ingot/silver,
		/obj/item/ingot/gold,
		/obj/item/ingot/blacksteel,
		/obj/item/ingot/steel,
	)

	repair_skills = list(
		/datum/skill/craft/armorsmithing = 5,
		/datum/skill/craft/blacksmithing = 5,
		/datum/skill/craft/smelting = 5,
	)

	race_repair = list(
		/datum/species/dwarf,
		/datum/species/dwarf/mountain,
	)

	applied_trait = TRAIT_HARDSHELL
	trait_message_apply = span_warn("The armor weighs my limbs down. I won't be able to parry well like this.")
	trait_message_remove = span_warn("As the weighted thing slips off, my limbs are freed. I can parry effectively again.")

/datum/component/peelarmor/grudgebearer/helmet
	repair_skills = list(
		/datum/skill/craft/armorsmithing = 5,
		/datum/skill/craft/blacksmithing = 4,
		/datum/skill/craft/smelting = 4,
	)

	applied_trait = null

/datum/component/peelarmor/grudgebearer/limbs
	layer_max = list(
		"blunt" = 100,
		"slash" = 100,
		"stab" = 100,
		"piercing" = 90,
	)

	hits_per_layer = list(
		"100" 	= 5,
		"90" 	= 10,
		"80" 	= 10,
		"70" 	= 15,
		"60" 	= 15,
		"50"	= 20,
		"40"	= 20,
		"30"	= 30,
		"20"	= 30,
		"10"	= 40,
	)

	peel_amt = 20	//Limbs lose 2 grades per layer peel, but also repair 4.

	repair_items = list(
		/obj/item/ingot/silver,
		/obj/item/ingot/gold,
		/obj/item/ingot/steel,
	)

	repair_skills = list(
		/datum/skill/craft/armorsmithing = 4,
		/datum/skill/craft/blacksmithing = 4,
		/datum/skill/craft/smelting = 4,
	)
	applied_trait = null
