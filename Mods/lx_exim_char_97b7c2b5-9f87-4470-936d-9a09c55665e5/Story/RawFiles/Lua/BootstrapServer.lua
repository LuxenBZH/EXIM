Ext.Require("EXIM_Save_Character.lua")
Ext.Require("EXIM_Load_Character.lua")
Ext.Require("EXIM_Save_Items.lua")
Ext.Require("EXIM_Load_Items.lua")

---- Helper functions ---
function Civil()
	local civil = {
	"Telekinesis",
	"Thievery",
	"Sneaking",
	"Persuasion",
	"Luck",
	"Barter",
	"Loremaster"}
	return civil
end

function Abilities()
	local abilities = {
	"AirSpecialist",
	"Brewmaster",
	"Charm",
	"Crafting",
	"DualWielding",
	"EarthSpecialist",
	"FireSpecialist",
	"Intimidate",
	"Leadership",
	"MagicArmorMastery",
	"Necromancy",
	"PainReflection",
	"Perseverance",
	"PhysicalArmorMastery",
	"Pickpocket",
	"Polymorph",
	"Ranged",
	"RangerLore",
	"Reason",
	"Reflexes",
	"Repair",
	"RogueLore",
	"Runecrafting",
	"Shield",
	"SingleHanded",
	"Sourcery",
	"Summoning",
	"TwoHanded",
	"VitalityMastery",
	"Wand",
	"WarriorLore",
	"WaterSpecialist"
}
	return abilities
end

function Talents()
	local talents = {
	"Throwing",
	"WandCharge",
	"Vitality",
	"FolkDancer",
	"Criticals",
	"IncreasedArmor",
	"Politician",
	"Lockpick",
	"Trade",
	"Damage",
	"MrKnowItAll",
	"AvoidDetection",
	"EarthSpells",
	"AirSpells",
	"WaterSpells",
	"FireSpells",
	"Luck",
	"Charm",
	"ExpGain",
	"ItemCreation",
	"ItemMovement",
	"ResistSilence",
	"ResistStun",
	"ResistKnockdown",
	"ResistFear",
	"ActionPoints2",
	"ActionPoints",
	"ChanceToHitMelee",
	"Repair",
	"ChanceToHitRanged",
	"Backstab",
	"RogueLoreGrenadePrecision",
	"RogueLoreHoldResistance",
	"RogueLoreMovementBonus",
	"RogueLoreDaggerBackStab",
	"RogueLoreDaggerAPBonus",
	"Kickstarter",
	"InventoryAccess",
	"Initiative",
	"Awareness",
	"Reason",
	"Intimidate",
	"ResistPoison",
	"Sight",
	"RangerLoreRangedAPBonus",
	"RangerLoreEvasionBonus",
	"WarriorLoreNaturalResistance",
	"WarriorLoreNaturalArmor",
	"SpillNoBlood",
	"GoldenMage",
	"Courageous",
	"WeatherProof",
	"LightningRod",
	"Bully",
	"Scientist",
	"LightStep",
	"StandYourGround",
	"Durability",
	"Carry",
	"ResurrectExtraHealth",
	"AnimalEmpathy",
	"ExtraSkillPoints",
	"ExtraStatPoints",
	"Escapist",
	"ElementalAffinity",
	"ResurrectToFullHealth",
	"LoneWolf",
	"Raistlin",
	"WhatARush",
	"FaroutDude",
	"Leech",
	"FiveStarRestaurant",
	"SurpriseAttack",
	"Demon",
	"IceKing",
	"WalkItOff",
	"Stench",
	"QuickStep",
	"ElementalRanger",
	"RangerLoreArrowRecover",
	"NoAttackOfOpportunity",
	"WarriorLoreGrenadeRange",
	"WarriorLoreNaturalHealth",
	"AttackOfOpportunity",
	"Zombie",
	"Unstable",
	"Ambidextrous",
	"Torturer",
	"LivingArmor",
	"Executioner",
	"DualWieldingDodging",
	"ResistDead",
	"Memory",
	"NaturalConductor",
	"Flanking",
	"Perfectionist",
	"ViolentMagic",
	"Human_Inventive",
	"Human_Civil",
	"Dwarf_Sneaking",
	"Dwarf_Sturdy",
	"Elf_CorpseEating",
	"Elf_Lore",
	"Lizard_Persuasion",
	"Lizard_Resistance",
	"Quest_SpidersKiss_Str",
	"Quest_SpidersKiss_Int",
	"Quest_SpidersKiss_Per",
	"Quest_SpidersKiss_Null",
	"Quest_TradeSecrets",
	"Quest_GhostTree",
	"Quest_Rooted",
	"PainDrinker",
	"DeathfogResistant",
	"Sourcerer",
	"Rager",
	"Elementalist",
	"Sadist",
	"Haymaker",
	"Gladiator",
	"Indomitable",
	"WildMag",
	"Jitterbug",
	"Soulcatcher",
	"MasterThief",
	"GreedyVessel",
	"MagicCycles"
	}
	return talents
end

function ItemBoosts()
	local boosts = {
	"Durability",
	"DurabilityDegradeSpeed",
	"StrengthBoost",
	"FinesseBoost",
	"IntelligenceBoost",
	"ConstitutionBoost",
	"MemoryBoost",
	"WitsBoost",
	"SightBoost",
	"HearingBoost",
	"VitalityBoost",
	"SourcePointsBoost",
	"MaxAP",
	"StartAP",
	"APRecovery",
	"AccuracyBoost",
	"LifeSteal",
	"CriticalChance",
	"ChanceToHitBoost",
	"MovementSpeedBoost",
	"RuneSlots",
	"RuneSlots_V1",
	"FireResistance",
	"AirResistance",
	"WaterResistance",
	"EarthResistance",
	"PoisonResistance",
	"ShadowResistance",
	"PiercingResistance",
	"CorrosiveResistance",
	"PhysicalResistance",
	"MagicResistance",
	"CustomResistance",
	"Movement",
	"Initiative",
	"Willpower",
	"Bodybuilding",
	"MaxSummons",
	"Value",
	"Weight",
	"Skills",
	"ItemColor"
	}
	return boosts
end

function WeaponBoosts()
	return {
		"DamageType",
		"MinDamage",
		"MaxDamage",
		"DamageBoost",
		"DamageFromBase",
		"CriticalDamage",
		"WeaponRange",
		"CleaveAngle",
		"CleavePercentage",
		"AttackAPCost",
	}
end

function ShieldBoosts()
	return {
		"Blocking"
	}
end

function ArmorBoosts()
	return {
		"ArmorValue",
		"ArmorBoost",
		"MagicArmorValue",
		"MagicArmorBoost"
	}
end

function SplitString(str, sep)
	local t={}
	if str ~= nil then
		for s in string.gmatch(str, "([^"..sep.."]+)") do
			table.insert(t, s)
		end
	end
	return t
end


Ext.NewQuery(InitSavingInventory, "LX_EXT_InitSavingInventory", "(CHARACTERGUID)_Character");
Ext.NewCall(ParseInventoryForContainers, "LX_EXT_CheckInventory", "(GUIDSTRING)_Holder");
--Ext.NewQuery(UnequipCharacter, "LX_EXT_UnequipCharacter", "(CHARACTERGUID)_Character");
Ext.NewCall(StoreHolderItem, "LX_EXT_StoreHolderItem", "(GUIDSTRING)_Holder, (ITEMGUID)_Item");
Ext.NewCall(SavingInventoryStringManagement, "LX_EXT_SaveInventory", "(CHARACTERGUID)_Character");
Ext.NewCall(SaveCharacterData, "LX_EXT_SaveCharacterData", "(CHARACTERGUID)_Character");
Ext.NewCall(ParsePieceEquipment, "LX_EXT_ParsePieceEquipment", "(CHARACTERGUID)_Character, (ITEMGUID)_Item");
Ext.NewCall(LoadHotbar, "LX_EXT_LoadHotbar", "(CHARACTERGUID)_Character");
Ext.NewQuery(GetHotbar, "LX_EXT_SaveHotbar", "(CHARACTERGUID)_Character");

Ext.NewCall(LoadCharacter, "LX_EXT_LoadCharacter", "(CHARACTERGUID)_Character");
Ext.NewCall(LoadInventory, "LX_EXT_LoadInventory", "(CHARACTERGUID)_Character, (STRING)_Data1, (STRING)_Data2");
Ext.NewCall(LoadSkills, "LX_EXT_LoadSkills", "(CHARACTERGUID)_Character");
Ext.NewCall(CleanCharacterPoints, "LX_EXT_CleanCharacterPoints", "(CHARACTERGUID)_Character");