function LoadInventory(container, inventory, first)
	local isCharacter = ObjectIsCharacter(container)
	local contTemplate = "Character"
	if isCharacter == 0 then contTemplate = GetTemplate(container) end
	local contInventory = ""
	if ObjectIsCharacter(container) == 1 then 
		contInventory = inventory[contTemplate]
	else
		contInventory = inventory
	end
	
	local x, y, z = GetPosition(container)
	-- Load items
	for j,item in pairs(contInventory["items"]) do
		Ext.Print("[EXIM.LoadItem.LoadInventory] Load item "..item["template"])
		local isIdentified = item["identified"]
		local it = CreateItemTemplateAtPosition(item["template"], x, y, z)
		if item == nil then goto ignoreItem end
		-- if isIdentified ~= 0 then
			-- NRD_ItemSetIdentified(it, 1)
		-- end
		local amount = 1
		local quality = "Common"
		local statsID = item["statsid"]
		if item["quantity"] ~= nil then amount = item["quantity"] end
		if item["quality"] ~= nil then quality = item["quality"] end
		local customStrings = LoadItemCustomStrings(eq, item["customname"], item["customdesc"], item["customcont"])
		it = ItemClone(it, amount, quality, statsID, customStrings)
		ItemToInventory(it, container, amount, 1)
		::ignoreItem::
	end
	-- Load equipments
	for i,equipment in pairs(contInventory["equipment"]) do
		local isIdentified = equipment["identified"]
		local eq = CreateItemTemplateAtPosition(equipment["template"], x, y, z)
		if eq == nil then goto ignoreEq end
		ItemLevelUpTo(eq, equipment["level"])
		if isIdentified ~= 0 then
			NRD_ItemSetIdentified(eq, 1)
		end
		local quality = "Common"
		if equipment["quality"] ~= nil then quality = equipment["quality"] end
		if equipment["boosts"] ~= nil then ItemSetBoosts(eq, equipment["boosts"]) end
		
		local customStrings = LoadItemCustomStrings(eq, equipment["customname"], equipment["customdesc"], nil)
		
		local finishedEq = EquipmentClone(eq, 1, quality, equipment["level"], equipment["deltamods"], equipment["seed"], equipment["statsid"], customStrings, false)

		if HasRunes(equipment["runes"]) == true then
			for slot, rune in pairs(equipment["runes"]) do
				ItemInsertRune(container, finishedEq, rune, tonumber(slot))
			end
		end
	
		ItemToInventory(finishedEq, container, 1)
		
		if contTemplate == "LX_Saving_Pouch_Equipment_03e9201f-3dbe-4b83-9dd8-413e8483d6f0" then
			CharacterEquipItem(GetVarString(container, "LX_Container_Owner"), finishedEq)
		end
		::ignoreEq::
	end
	
	-- Load containers
	for j, cont in pairs(contInventory["containers"]) do
		Ext.Print("[EXIM.LoadItem.LoadInventory] ".."Loading container ",cont["template"])
		local it = CreateItemTemplateAtPosition(cont["template"], x, y, z)
		local containerId = cont["containerid"]
		if cont["template"] == "LX_Saving_Pouch_Equipment_03e9201f-3dbe-4b83-9dd8-413e8483d6f0" then 
			SetVarString(it, "LX_Container_Owner", container)
		end
		LoadInventory(it, first[containerId], first)
		ItemToInventory(it, container, 1, 1)
	end
	if contTemplate == "LX_Saving_Pouch_Equipment_03e9201f-3dbe-4b83-9dd8-413e8483d6f0" then
		ItemRemove(container)
	end
end

function HasRunes(runeList)
	local i = 0
	for j, rune in pairs(runeList) do
		return true
	end
	return false
end

function LoadItemCustomStrings(item, name, desc, cont)
	local customStrings = {}
	if name ~= nil then customStrings["CustomDisplayName"] = name end
	if desc ~= nil then customStrings["CustomDescription"] = desc end
	if cont ~= nil then customStrings["CustomBookContent"] = cont end
	return customStrings
end

function ItemClone(item, amount, quality, statsID, customStrings)
	NRD_ItemCloneBegin(item)
	for field,str in pairs(customStrings) do
		Ext.Print("CUSTOM : ",field,str)
		NRD_ItemCloneSetString(field, str)
	end
	NRD_ItemCloneSetInt("Amount", amount)
	NRD_ItemCloneSetString("ItemType", quality)
	NRD_ItemCloneSetString("GenerationStatsId", statsID)
	NRD_ItemCloneSetString("StatsEntryName", statsID)
	local newItem = NRD_ItemClone()
	ItemRemove(item)
	return newItem
end

function EquipmentClone(item, amount, quality, level, deltamods, seed, statsID, customStrings, recursion)
	NRD_ItemCloneBegin(item)
	for field,str in pairs(customStrings) do
		NRD_ItemCloneSetString(field, str)
	end
	if seed ~= nil then NRD_ItemCloneSetInt("GenerationRandom", seed) end
	NRD_ItemCloneSetString("GenerationStatsId", statsID)
	if quality == "Unique" and recursion == false then
		NRD_ItemCloneSetString("GenerationItemType", "Divine")
		NRD_ItemCloneSetString("ItemType", "Divine")
	else
		NRD_ItemCloneSetString("GenerationItemType", quality)
		NRD_ItemCloneSetString("ItemType", quality)
	end
	NRD_ItemCloneSetInt("StatsLevel", level)
	NRD_ItemCloneSetInt("GenerationLevel", level)
	NRD_ItemCloneSetInt("HasGeneratedStats", 1)
	NRD_ItemCloneSetInt("Amount", amount)
	NRD_ItemCloneSetInt("GMFolding", 0)
	--NRD_ItemCloneResetProgression()
	if deltamods ~= nil then
		for dm,nb in pairs(deltamods) do
			local i = 0
			while i < nb do
				NRD_ItemCloneAddBoost("Generation", dm)
				i = i + 1
			end
		end
	end
	
	local newItem = NRD_ItemClone()
	if quality == "Unique" and recursion == false then
		newItem = EquipmentClone(newItem, amount, quality, level, nil, seed, statsID, customStrings, true)
	end
	ItemRemove(item)
	return newItem
end

function ItemClearBoosts(item)
	local boosts = ItemBoosts()
	for i,boost in pairs(boosts) do
		if boost == "Skills" then
			NRD_ItemSetPermanentBoostString(item, boost, "")
		elseif boost == "WeaponRange" or boost == "CleavePercentage" then
			NRD_ItemSetPermanentBoostReal(item, boost, 0.0)
		else
			print("[EXIM.LoadItem.ItemClearBoosts] Clear Boost "..boost)
			NRD_ItemSetPermanentBoostInt(item, boost, 0)
		end
	end
end

function ItemSetBoosts(item, boosts)
	for boost, value in pairs(boosts) do
		if boost == "Skills" then
			NRD_ItemSetPermanentBoostString(item, boost, value)
		elseif boost == "Talents" then
			for talent, v in pairs(value) do NRD_ItemSetPermanentBoostTalent(item, talent, 1) end
		elseif boost == "Abilities" then
			for abi, v in pairs(value) do NRD_ItemSetPermanentBoostAbility(item, abi, v) end	
		elseif boost == "WeaponRange" or boost == "CleavePercentage" then
			NRD_ItemSetPermanentBoostReal(item, boost, value)
		elseif boost == "Skills" or boost == "ItemColor" then
			NRD_ItemSetPermanentBoostString(item, boost, value)
		else
			NRD_ItemSetPermanentBoostInt(item, boost, value)
		end
	end
end