local function TableConcat(t1, t2)
	for i=1,#t2 do
        t1[#t1+1] = t2[i]
    end
    return t1
end

function UnequipCharacter(character)
	local x, y, z = GetPosition(character)
	local slots = {
	"Helmet",
	"Amulet",
	"Breast",
	"Belt",
	"Gloves",
	"Leggings",
	"Boots",
	"Weapon",
	"Shield",
	"Ring",
	"Ring2"
	}
	local pouch = CreateItemTemplateAtPosition("ITEMGUID_LX_Saving_Pouch_Equipment_03e9201f-3dbe-4b83-9dd8-413e8483d6f0", x, y, z)
	local equipment = ""
	for i,slot in pairs(slots) do
		local item = CharacterGetEquippedItem(character, slot)
		if item ~= nil then
			--CharacterUnequipItem(character, item)
			ItemToInventory(item, pouch, 1, 0)
			if i ~= 1 then
				equipment = equipment..","..item
			else
				equipment = equipment..item
			end
		end
	end
	ItemToInventory(pouch, character, 1, 0)
end

function ReequipCharacter(character)
	local pouch = Ext.GetItem(GetItemForItemTemplateInInventory(character, "ITEMGUID_LX_Saving_Pouch_Equipment_03e9201f-3dbe-4b83-9dd8-413e8483d6f0"))
	local equipment = pouch.GetInventoryItems(pouch)
	for i,piece in pairs(equipment) do
		CharacterEquipItem(character, piece)
	end
	ItemRemove(pouch.MyGuid)
end

function InitSavingInventory(character)
	Ext.Print("#############################################################")
	Ext.Print("---------------- Saving inventory for: ",character)
	Ext.Print("#############################################################")
	-- inventory = {}
	-- inventory[character] = {}
	local charTemplate = GetTemplate(character)
	-- Inventory
	inventoryTemplates = {}
	inventoryTemplates["Character"] = {}
	inventoryTemplates["Character"]["items"] = {}
	inventoryTemplates["Character"]["containers"] = {}
	inventoryTemplates["Character"]["equipment"] = {}
	return true
end

function SaveEquippedItems(character)
	local equipment = {}
	local slots = {
	"Helmet",
	"Amulet",
	"Breast",
	"Belt",
	"Gloves",
	"Leggings",
	"Boots",
	"Weapon",
	"Shield",
	"Ring",
	"Ring2"
	}
	for i,slot in pairs(slots) do
		local item = CharacterGetEquippedItem(character, slot)
		if item ~= nil then
			equipment[item] = {}
			Ext.Print("[EXIM.SaveItem.SaveEquippedItems] ".."Found item in slot "..slot)
			local itemTemplate = GetTemplate(item)
			SaveEquipmentBonuses(item, equipment[item])
			equipment[item]["template"] = itemTemplate
			equipment[item]["slot"] = slot
		end
	end
	local charEquipment = ""
	local jsonString = Ext.JsonStringify(equipment)
	SetVarString(character, "LX_Equipment", jsonString)
end

function SaveEquipmentBonuses(item, tab)
	local itemEx = Ext.GetItem(item)
	local seed = GetVarInteger(item, "LX_Seed")
	SetStoryEvent(item, "LX_Debug")
	--local quality = GetVarFixedString(item, "LX_Item_Quality")
	local quality = itemEx.ItemTypeReal
	if quality ~= "Common" then
		tab["quality"] = quality
	end
	local isIdentified = NRD_ItemGetInt(item, "IsIdentified")
	if isIdentified == 0 then
		tab["identified"] = 0
	end
	SetVarString(item, "LX_Item_Deltamods", "")
	SetStoryEvent(item, "LX_Get_Item_Level")
	
	local itemStats = itemEx.Stats
	local eqType = itemEx.ItemType
	local boosts = ItemBoosts()
	if eqType == "Armor" then
		boosts = TableConcat(boosts, ArmorBoosts())
	elseif eqType == "Weapon" then
		boosts = TableConcat(boosts, WeaponBoosts())
	elseif eqType == "Shield" then
		boosts = TableConcat(boosts, ShieldBoosts())
	end
	local itemLevel = GetVarInteger(item, "LX_Item_Level")
	tab["level"] = itemLevel
	tab["boosts"] = {}
	tab["deltamods"] = GetDeltaMods(item)
	tab["runes"] = GetRunes(item, tab["deltamods"])
	tab["seed"] = seed
	tab["customname"] = string.gsub(itemEx.DisplayName, "|", "")
	
	local value = nil
	for i,boost in pairs(boosts) do
		if boost == "WeaponRange" or boost == "CleavePercentage" then
			value = NRD_ItemGetPermanentBoostReal(item, boost)
		elseif boost == "Skills" or boost == "ItemColor" then
			value = NRD_ItemGetPermanentBoostString(item, boost)
		else
			value = NRD_ItemGetPermanentBoostInt(item, boost)
		end
		if value ~= nil and value ~= 0 then
			--Ext.Print("[EXIM.SaveItems.SaveEquipmentBonuses] Found boost: "..boost, " = ", value)
			tab["boosts"][boost] = value
		end
	end
	local skills = NRD_ItemGetPermanentBoostString(item, "Skills")
	local talents = {}
	for i, talent in pairs(Talents()) do
		local value = NRD_ItemGetPermanentBoostTalent(item, talent)
		if value ~= 0 then talents[talent] = value end
	end
	local abilities = {}
	for i, abi in pairs(Abilities()) do
		local value = NRD_ItemGetPermanentBoostAbility(item, abi)
		if value ~= 0 then abilities[abi] = value end
	end
	if skills ~= "" or skills ~= nil then
		tab["boosts"]["Skills"] = skills
		tab["boosts"]["Talents"] = talents
		tab["boosts"]["Abilities"] = abilities
	end
	return tab
end

function GetDeltaMods(item)
	--Ext.Print("Getting Deltamods for "..item)
	local deltaTable = {}
	local runes = {}
	NRD_ItemIterateDeltaModifiers(item, "LX_Get_Equipment_Deltamods")
	local deltaMods = GetVarString(item, "LX_Item_Deltamods")
	local deltaMods = SplitString(deltaMods, ";")
	-- local runeSlots = 0
	for i,delta in ipairs(deltaMods) do
		--Ext.Print("[EXIM.SaveItem.GetDeltaMods] Deltamod: ",delta)
		local stored = deltaTable[delta]
		if stored == nil then
			deltaTable[delta] = 1
		else
			deltaTable[delta] = deltaTable[delta] + 1
		end
	end
	
	return deltaTable, runes
end


function GetRunes(item, deltaMods)
	local runes = {}
	local nbSlots = Ext.GetItem(item).Stats.RuneSlots
	if nbSlots ~= 0 then
		for slot=0,nbSlots,1 do
			local rune = ItemGetRuneItemTemplate(item, slot)
			if rune ~= nil then runes[slot] = rune end
		end
	end
	return runes
end

function StoreHolderItem(holder, item)
	
	--SetStoryEvent(item, "LX_Get_Item_Quality")
	local itemEx = Ext.GetItem(item)
	local isCharacter = ObjectIsCharacter(holder)
	local holderTemplate = "Character"
	if isCharacter == 0 then holderTemplate = GetTemplate(holder) end
	local itemTemplate = GetTemplate(item)
	--Ext.Print("[EXIM.SaveITem.StoreHolderItem]", holderTemplate, itemTemplate)
	if itemTemplate == "EXIM_SavingStone_236d9882-64f0-487f-87b9-cc7a695d66d0" or itemTemplate == "EXIM_LoadingStone_758fd0ec-4582-4be4-8f01-6b23203386d9" then
		return
	end
	local isEquipment = ItemIsEquipable(item)
	local quantity = ItemGetAmount(item)
	local isContainer = ItemIsContainer(item) -- if the holder is an item it means that it's a container
	local itemProperties = {}
	
	if quantity > 1 then
		itemProperties["quantity"] = quantity
	end
	itemProperties["template"] = itemTemplate
	local itemStats = Ext.GetItem(item)
	if itemStats.CustomDisplayName ~= "" then itemProperties["customname"] = itemStats.CustomDisplayName end
	if itemStats.CustomDescription ~= "" then itemProperties["customdesc"] = itemStats.CustomDescription end
	if itemStats.CustomBookContent ~= "" then itemProperties["customcont"] = itemStats.CustomBookContent end
	itemProperties["statsid"] = NRD_ItemGetStatsId(item)
	
	local temp = {}

	if holderTemplate == "Character" then
		holder = "Character"
	else
		holder = string.gsub(holderTemplate, "_........%-....%-....%-....%-............$", "").."_"..string.gsub(holder, ".*_", "")
	end
	if isEquipment == 1 then
		SaveEquipmentBonuses(item, itemProperties)
		table.insert(inventoryTemplates[holder]["equipment"], itemProperties)
	elseif isContainer == 1 then
		item = string.gsub(itemTemplate, "_........%-....%-....%-....%-............$", "").."_"..item
		itemProperties["containerid"] = item
		table.insert(inventoryTemplates[holder]["containers"], itemProperties)
		inventoryTemplates[item] = {}
		inventoryTemplates[item]["items"] = {}
		inventoryTemplates[item]["equipment"] = {}
		inventoryTemplates[item]["containers"] = {}
		inventoryTemplates[item]["template"] = itemTemplate
		local inventory = itemEx.GetInventoryItems(itemEx)
		for j,it in pairs(inventory) do
			StoreHolderItem(item, it)
		end
	else
		local quality = itemEx.ItemType
		if quality ~= "Common" then
			itemProperties["quality"] = quality
		end
		table.insert(inventoryTemplates[holder]["items"], itemProperties)
	end

	-- table.insert(inventory[holder], item)
end

function SavingInventoryStringManagement(character)
	local charInventory = ""
	local jsonString = Ext.JsonStringify(inventoryTemplates)
	--SetVarString(character, "LX_Inventory", jsonString)
end

function ParseInventoryForContainers(holder)
	local inventorySize = #inventory[holder]
	Ext.Print("[EXIM.SaveItem.ParseInventoryForContainers] ".."Container: ",holder)
	Ext.Print("[EXIM.SaveItem.ParseInventoryForContainers] ".."Inventory size: "..inventorySize)
	for i=1, inventorySize, 1 do
		local item = inventory[holder][i]
		print("[EXIM.SaveItem.ParseInventoryForContainers] ".."Item: "..item)
		local isContainer = ItemIsContainer(item)
		if isContainer == 1 then
			local itemTemplate = GetTemplate(item)
			local invTempSize = #inventoryTemplates
			inventoryTemplates[item] = {}
			inventoryTemplates[item]["items"] = {}
			inventoryTemplates[item]["equipment"] = {}
			inventoryTemplates[item]["containers"] = {}
			inventoryTemplates[item]["template"] = itemTemplate
			SetVarInteger(item, "LX_Is_Container", 1)
			inventory[item] = {}
			Ext.Print("[EXIM.SaveItem.ParseInventoryForContainers] "..item.." is a container.")
			-- Osi.DB_GM_Counting_Inventory(item)
			-- InventoryLaunchIterator(item, "Inventory_Count", "Inventory_Count_Done")
			--Osi.PROC_LX_Launch_Inventory_Iterator_Container(item, "Inventory_Count_"..item, "Inventory_Count_Done_"..item)
		end
	end
end


function ParsePieceEquipment(character, item)
	local charInventory = GetVarString(character, "GM_Inventory")
	local itemTemplate = GetTemplate(item)
	charInventory = charInventory.."<Equipment>"..itemTemplate.."<br>"
	local itemBase, itemType, itemLevel = NRD_ItemGetGenerationParams(item)
	charInventory = charInventory.."	Base="..itemBase.."<br>"
	charInventory = charInventory.."	Type="..itemType.."<br>"
	charInventory = charInventory.."	Level="..itemLevel.."<br>"
	charInventory = charInventory.."</Equipment><br>"
	SetVarString(character, "GM_Inventory", charInventory)
end

--- @field public char EsvCharacter
-- function SaveCharacterInventory(char)
-- 	local inventory = char.GetInventoryItems(char)
-- 	for x,item in pairs(inventory) do
-- 		if ItemIsContainer(item) == 1 then
-- 			inventoryTemplates[item] = {}
-- 			SaveContainerInventory(item)
-- 		else
			
-- 		end

-- 	end
-- end

-- function SaveContainerInventory(container, parentInventory)
-- end