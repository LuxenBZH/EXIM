--- @type character EsvCharacter
local function RemoveCharacterSkills(char)
	local skills = char.GetSkills(char)
	for i,skill in pairs(skills) do
		CharacterRemoveSkill(char.MyGuid, skill)
	end
end

local function LoadCustomStats(character, stats)
	if stats == nil then return end
	for name,value in pairs(stats) do
		local stat = Ext.GetCustomStatByName(name)
		if stat ~= nil then
			NRD_CharacterSetCustomStat(character.MyGuid, stat.Id, value)
		end
	end
end

function LoadCharacter(character)
	local char = Ext.GetCharacter(character)
	local handle, name = CharacterGetDisplayName(character)
	name = ClearSpecialCharacters(name)
	local fileName = name..".charsave"
	local data = NRD_LoadFile(fileName)
	data = Ext.JsonParse(data)
	-- Load character sheet
	--CharacterLevelUpTo(character, data["data"]["misc"]["level"])
	--NRD_CharacterSetStatInt(character, "Experience", data["data"]["attributes"]["Experience"])
	local deltaExp = data["data"]["attributes"]["Experience"] - NRD_CharacterGetStatInt(character, "Experience")
	--if deltaExp > 0 then CharacterAddExplorationExperience(character, 1, 1, deltaExp/20) end
	CharacterAddExplorationExperience(character, 1, 1, deltaExp/20)
	ClearTalents(character)
	ClearAbilities(character)
	ClearCivil(character)
	-- NRD_CharacterSetStatInt(character, "Level", data["data"]["misc"]["level"])
	local attributePoints = CharacterGetAttributePoints(character) * -1
	local abilityPoints = CharacterGetAbilityPoints(character) * -1
	local civilPoints = CharacterGetCivilAbilityPoints(character) * -1
	local talentPoints = CharacterGetTalentPoints(character) * -1
	SetVarInteger(character, "LX_Over_Attribute", attributePoints)
	SetVarInteger(character, "LX_Over_Ability", abilityPoints)
	SetVarInteger(character, "LX_Over_Civil", civilPoints)
	SetVarInteger(character, "LX_Over_Talent", talentPoints)
	TimerLaunch("LX_Cleaning_Character_Load", 50)
	
	CharacterAddAttributePoint(character, data["data"]["misc"]["attributePoints"])
	CharacterAddAbilityPoint(character, data["data"]["misc"]["abilityPoints"])
	CharacterAddCivilAbilityPoint(character, data["data"]["misc"]["civilPoints"])
	CharacterAddTalentPoint(character, data["data"]["misc"]["talentPoints"])
	
	-- NRD_PlayerSetBaseAttribute(character, "Strength", data["data"]["attributes"]["Strength"])
	-- NRD_PlayerSetBaseAttribute(character, "Finesse", data["data"]["attributes"]["Finesse"])
	-- NRD_PlayerSetBaseAttribute(character, "Intelligence", data["data"]["attributes"]["Intelligence"])
	-- NRD_PlayerSetBaseAttribute(character, "Constitution", data["data"]["attributes"]["Constitution"])
	-- NRD_PlayerSetBaseAttribute(character, "Memory", data["data"]["attributes"]["Memory"])
	-- NRD_PlayerSetBaseAttribute(character, "Wits", data["data"]["attributes"]["Wits"])
	
	if CharacterIsPlayer(character) == 1 then
		for attribute,value in pairs(data["data"]["attributes"]) do
			if attribute ~= "Experience" and attribute ~= "MaxMP" then
				NRD_PlayerSetBaseAttribute(character, attribute, value)
			end
		end
	end
	if data["data"]["attributes"]["MaxMP"] ~= nil then 
		CharacterOverrideMaxSourcePoints(character, data["data"]["attributes"]["MaxMP"]) 
	end
	
	CharacterAddCivilAbilityPoint(character, 0) --Synchronization
	
	for ability,value in pairs(data["data"]["abilities"]) do
		NRD_PlayerSetBaseAbility(character, ability, value)
	end
	for civil,value in pairs(data["data"]["civil"]) do
		NRD_PlayerSetBaseAbility(character, civil, value)
	end
	for talent,value in pairs(data["data"]["talents"]) do
		NRD_PlayerSetBaseTalent(character, talent, 1)
	end
	CharacterAddCivilAbilityPoint(character, 0) --Synchronization
	
	-- Load extension data if there's any
	if data["ext"] ~= nil then
		SetVarString(character, "LX_EXIM_Extension_Data", Ext.JsonStringify(data["ext"]))
		SetStoryEvent(character, "LX_EXIM_LoadExtData")
	end
	
	-- Load skills
	-- SetVarString(character, "LX_Skills_Data", Ext.JsonStringify(data["skills"]))
	-- SetVarString(character, "LX_Skills_Save", "")
	-- SetStoryEvent(character, "LX_Start_Load_Skills") 
	RemoveCharacterSkills(char)
	for i,skill in pairs(data["skills"]) do
		CharacterAddSkill(character, skill, 1)
	end

	-- Load custom stats
	LoadCustomStats(char, data["customStats"])
	
	-- Load inventory
	LoadInventory(character, data["inventory"], data["inventory"])
	
	-- SetVarString(character, "LX_Hotbar", Ext.JsonStringify(data["hotbar"]))
	-- Load hotbar
	LoadHotbar(character, data["hotbar"])
	-- SetStoryEvent(character, "LX_Restore_Hotbar")
	-- for i, slot in pairs(data["hotbar"]) do
	-- 	if slot[1] == "Item" then
	-- 		NRD_SkillBarSetItem(character, tonumber(i), slot[2])
	-- 	else
	-- 		Ext.Print(i)
	-- 		NRD_SkillBarSetSkill(character, tonumber(i), slot[2])
	-- 	end
	-- end
end

function ClearCivil(character)
	if CharacterIsPlayer(character) == 0 then return end
	local civil = Civil()
	for i,civ in pairs(civil) do
		NRD_PlayerSetBaseAbility(character, civ, 0)
	end
end

function ClearAbilities(character)
	if CharacterIsPlayer(character) == 0 then return end
	local abilities = Abilities()
	for i,abi in pairs(abilities) do
		NRD_PlayerSetBaseAbility(character, abi, 0)
	end
end

function ClearTalents(character)
	if CharacterIsPlayer(character) == 0 then return end
	local talents = Talents()
	for i,talent in pairs(talents) do
		NRD_PlayerSetBaseTalent(character, talent, 0)
	end
end

function LoadHotbar(character, hotbar)
	if CharacterIsPlayer(character) == 0 then return end
	ClearHotbar(character)
	-- local hotbar = Ext.JsonParse(GetVarString(character, "LX_Hotbar"))
	for i, slot in pairs(hotbar) do
		if slot[1] == "Item" then
			local isInInventory = ItemTemplateIsInCharacterInventory(character, slot[2])
			if isInInventory > 0 then
				local item = GetItemForItemTemplateInInventory(character, slot[2])
				NRD_SkillBarSetItem(character, tonumber(i), item)
			end
		else
			NRD_SkillBarSetSkill(character, tonumber(i), slot[2])
		end
	end
	SetVarString(character, "LX_Hotbar", "")
end

function ClearHotbar(character)
	local i = 0
	while i < 144 do
		NRD_SkillBarClear(character, i)
		i = i+1
	end
end

function LoadSkills(character)
	UnequipCharacter(character)
	local skills = ParseSkills(character)
	for i,skill in pairs(skills) do
		--Ext.Print(skill)
		CharacterRemoveSkill(character, skill)
	end
	
	skills = Ext.JsonParse(GetVarString(character, "LX_Skills_Data"))
	for i,skill in pairs(skills) do
		CharacterAddSkill(character, skill, 0)
	end
	ReequipCharacter(character)
	SetVarString(character, "LX_Skills_Data", "")
end

function GetCharacterSkills(character)
	local x, y, z = GetPosition(character)
	local tempChar = TemporaryCharacterCreateAtPosition(x, y, z, "25611432-e5e4-482a-8f5d-196c9e90001e", 0)
	Osi.DB_EXIM_Saving_Char(character, tempChar)
	CharacterCloneSkillsTo(character, tempChar, 0)
	CharacterTransformFromCharacter(tempChar, character, 1, 1, 1, 1, 1, 1, 0)
	return tempChar
end

function CleanCharacterPoints(character)
	CharacterAddAttributePoint(character, GetVarInteger(character, "LX_Over_Attribute"))
	CharacterAddAbilityPoint(character, GetVarInteger(character, "LX_Over_Ability"))
	CharacterAddCivilAbilityPoint(character, GetVarInteger(character, "LX_Over_Civil"))
	CharacterAddTalentPoint(character, GetVarInteger(character, "LX_Over_Talent"))
end