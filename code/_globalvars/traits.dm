/*
 FUN ZONE OF ADMIN LISTINGS
 Try to keep this in sync with __DEFINES/traits.dm
 quirks have it's own panel so we don't need them here.
*/
GLOBAL_LIST_INIT(traits_by_type, list(
	/mob = list(
		TRAIT_LEPROSY,
		TRAIT_GUARDSMAN,
		TRAIT_WOODSMAN,
		TRAIT_KNIGHTSMAN,
		TRAIT_INQUISITION,
		TRAIT_CHOSEN,
		TRAIT_WEBWALK,
		TRAIT_NOSTINK,
		TRAIT_ZJUMP,
		TRAIT_JESTERPHOBIA,
		TRAIT_XENOPHOBIC,
		TRAIT_TOLERANT,
		TRAIT_NIGHT_OWL,
		TRAIT_BEAUTIFUL,
		TRAIT_BAD_MOOD,
		TRAIT_LEAPER,
		TRAIT_NOSEGRAB,
		TRAIT_NUTCRACKER,
		TRAIT_SEEPRICES,
		TRAIT_SEEPRICES_SHITTY,
		TRAIT_STRONGBITE,
		TRAIT_NOBLE,
		TRAIT_EMPATH,
		TRAIT_BREADY,
		TRAIT_MEDIUMARMOR,
		TRAIT_HEAVYARMOR,
		TRAIT_DODGEEXPERT,
		TRAIT_MAGEARMOR,
		TRAIT_DECEIVING_MEEKNESS,
		TRAIT_CRITICAL_RESISTANCE,
		TRAIT_CRITICAL_WEAKNESS,
		TRAIT_MANIAC_AWOKEN,
		TRAIT_NOROGSTAM,
		TRAIT_NUDIST,
		TRAIT_CYCLOPS_LEFT,
		TRAIT_CYCLOPS_RIGHT,
		TRAIT_LEECHIMMUNE,
		TRAIT_INHUMEN_ANATOMY,
		TRAIT_NASTY_EATER,
		TRAIT_WILD_EATER,
		TRAIT_NOFALLDAMAGE1,
		TRAIT_NOFALLDAMAGE2,
		TRAIT_DISFIGURED,
		TRAIT_MISSING_NOSE,
		TRAIT_SPELLCOCKBLOCK,
		TRAIT_ANTIMAGIC,
		TRAIT_ANTISCRYING,
		TRAIT_SHOCKIMMUNE,
		TRAIT_NOSLEEP,
		TRAIT_ROT_EATER,
		TRAIT_ORGAN_EATER,
		TRAIT_KNEESTINGER_IMMUNITY,
		TRAIT_SOUL_EXAMINE,
		TRAIT_CRACKHEAD,
		TRAIT_COMMIE,
		TRAIT_NORUN,
		TRAIT_GOODLOVER,
		TRAIT_SEEDKNOW,
		TRAIT_PERFECT_TRACKER,
		TRAIT_NOCSIGHT,
		TRAIT_CIVILIZEDBARBARIAN,
		TRAIT_COMICSANS,
		TRAIT_SQUIRE_REPAIR,
		TRAIT_WATERBREATHING,
		TRAIT_NUDE_SLEEPER,
		TRAIT_ABYSSOR_SWIM,
		TRAIT_LONGSTRIDER,
		TRAIT_TRAINED_SMITH,
		TRAIT_DEATHSIGHT,
		TRAIT_FORGEBLESSED,
		TRAIT_XYLIX,
		TRAIT_CABAL,
		TRAIT_HORDE,
		TRAIT_FORTITUDE,
		TRAIT_GUIDANCE,
		TRAIT_DEPRAVED,
		TRAIT_SILVER_BLESSED,
		TRAIT_GOODTRAINER,
		TRAIT_SEA_DRINKER,
		TRAIT_BIGGUY,
		TRAIT_OUTDOORSMAN,
		TRAIT_STUDENT,
		TRAIT_LEGENDARY_ALCHEMIST,
		TRAIT_INTELLECTUAL,
		TRAIT_COUNTERCOUNTERSPELL,
		TRAIT_BASHDOORS,
		TRAIT_HARDDISMEMBER,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_IGNORESLOWDOWN,
		TRAIT_PIERCEIMMUNE,
		TRAIT_STEELHEARTED,
		TRAIT_TOXIMMUNE,
		TRAIT_RITUALIST,
		TRAIT_LIMPDICK,
		TRAIT_SCHIZO_AMBIENCE,
		TRAIT_KEENEARS,
		TRAIT_SENTINELOFWITS,
		TRAIT_DUALWIELDER,
		TRAIT_HERETIC_SEER,
		TRAIT_UNSEEMLY,
	),
	/obj/item/bodypart = list(
		"TRAIT_PARALYSIS" = TRAIT_PARALYSIS
		),
	/obj/item = list(
		"TRAIT_NODROP" = TRAIT_NODROP,
		"TRAIT_T_RAY_VISIBLE" = TRAIT_T_RAY_VISIBLE,
		"TRAIT_NO_TELEPORT" = TRAIT_NO_TELEPORT
		)
	))

/// value -> trait name, generated on use from trait_by_type global
GLOBAL_LIST(trait_name_map)

/proc/generate_trait_name_map()
	. = list()
	for(var/key in GLOB.traits_by_type)
		.[key] = key
