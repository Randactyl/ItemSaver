local libFilters = LibStub("libFilters")

local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack
local DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
local ENCHANTING = ZO_EnchantingTopLevelInventoryBackpack
local LIST_DIALOG = ZO_ListDialog1List

local ISSettings = nil
local markedItems = nil

local SIGNED_INT_MAX = 2^32 / 2 - 1
local INT_MAX = 2^32

--converts unsigned itemId to signed
local function SignItemId(itemId)
	if(itemId and itemId > SIGNED_INT_MAX) then
		itemId = itemId - INT_MAX
	end
	return itemId
end

local function GetInfoFromRowControl(rowControl)
	--gotta do this in case deconstruction...
	local dataEntry = rowControl.dataEntry
	local bagId, slotIndex 

	--case to handle equiped items
	if(not dataEntry) then
		bagId = rowControl.bagId
		slotIndex = rowControl.slotIndex
	else
		bagId = dataEntry.data.bagId
		slotIndex = dataEntry.data.slotIndex
	end

	--case to handle list dialog, list dialog uses index instead of slotIndex and bag instead of badId...?
	if(dataEntry and not bagId and not slotIndex) then 
		bagId = rowControl.dataEntry.data.bag
		slotIndex = rowControl.dataEntry.data.index
	end

	return bagId, slotIndex
end

local function GetItemSaverControl(parent)
	return parent:GetNamedChild("ItemSaver")
end

local function CreateMarkerControl(parent)
	local control = parent:GetNamedChild("ItemSaver")
	local bagId, slotIndex = GetInfoFromRowControl(parent)
	local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

	if(not control) then
		control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ItemSaver", parent, CT_TEXTURE)
		control:SetDimensions(32, 32)
	end

	control:SetTexture(ISSettings:GetTexturePath())
	control:SetColor(ISSettings:GetTextureColor())

	if(markedItems[signedItemInstanceId]) then
		control:SetHidden(false)
	else
		control:SetHidden(true)
	end

	if(parent:GetWidth() - parent:GetHeight() < 5) then
		if(parent:GetNamedChild("SellPrice")) then
			parent:GetNamedChild("SellPrice"):SetHidden(true)
		end
		control:SetDrawTier(DT_HIGH)
		control:ClearAnchors()
		control:SetAnchor(ISSettings:GetMarkerAnchor(), parent, ISSettings:GetMarkerAnchor())
	else
		control:ClearAnchors()
		control:SetAnchor(LEFT, parent, LEFT)
	end

	return control
end

local function CreateMarkerControlForEquipment(parent)
	local control = CreateMarkerControl(parent)
	control:ClearAnchors()
	control:SetAnchor(ISSettings:GetMarkerAnchor(), parent, ISSettings:GetMarkerAnchor())
	control:SetDimensions(20, 20)
	control:SetDrawTier(1)
end

local function RefreshEquipmentControls()
	for i=1, ZO_Character:GetNumChildren() do
		local child = ZO_Character:GetChild(i)
		if(child and child:GetName():find("ZO_CharacterEquipmentSlots")) then
			CreateMarkerControlForEquipment(ZO_Character:GetChild(i))
		end
	end
end

local function RefreshAll()
	ZO_ScrollList_RefreshVisible(BACKPACK)
	ZO_ScrollList_RefreshVisible(BANK)
	ZO_ScrollList_RefreshVisible(GUILD_BANK)
	ZO_ScrollList_RefreshVisible(DECONSTRUCTION)
	ZO_ScrollList_RefreshVisible(ENCHANTING)
	ZO_ScrollList_RefreshVisible(LIST_DIALOG)
	RefreshEquipmentControls()
end

local function UnsaveItem(bagId, slotIndex)
	local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

	if(markedItems[signedItemInstanceId]) then
		markedItems[signedItemInstanceId] = nil
	end
	RefreshAll()
end

local function SaveItem(bagId, slotIndex)
	local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

	markedItems[signedItemInstanceId] = true
	RefreshAll()
end

local function ToggleSave(bagId, slotIndex)
	local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

	if(not markedItems[signedItemInstanceId]) then 
		SaveItem(bagId, slotIndex)
		return true
	end
	UnsaveItem(bagId, slotIndex)
	return false
end

local function AddContextMenuOption(rowControl)
	local bagId, slotIndex = GetInfoFromRowControl(rowControl)
	local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

	if(not markedItems[signedItemInstanceId]) then 
		AddMenuItem("Save item", function() 
				SaveItem(bagId, slotIndex) 

				if(GetItemSaverControl(rowControl)) then
					GetItemSaverControl(rowControl):SetHidden(false)
				end
			end, MENU_ADD_OPTION_LABEL)
	else
		AddMenuItem("Unsave item", function()
				UnsaveItem(bagId, slotIndex)

				if(GetItemSaverControl(rowControl)) then
					GetItemSaverControl(rowControl):SetHidden(true)
				end
			end, MENU_ADD_OPTION_LABEL)
	end
	ShowMenu(self)
end

local function AddContextMenuOptionSoon(rowControl)
	if(rowControl:GetOwningWindow() == ZO_TradingHouse) then return end
	if(BACKPACK:IsHidden() and BANK:IsHidden() and GUILD_BANK:IsHidden() and DECONSTRUCTION:IsHidden() and ENCHANTING:IsHidden()) then return end

	if(rowControl:GetParent() ~= ZO_Character) then
		zo_callLater(function() AddContextMenuOption(rowControl:GetParent()) end, 50)
	else
		zo_callLater(function() AddContextMenuOption(rowControl) end, 50)
	end
end

local function FilterSavedItems(bagId, slotIndex, ...)
	if(markedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]) then
		return false
	end
	return true
end

local function FilterSavedItemsForShop(slot)
	local bagId, slotIndex = GetInfoFromRowControl(slot)
	local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

	if(markedItems[signedItemInstanceId]) then
		return false
	end
	return true
end

function ItemSaver_ToggleDeconstructionFilter( toggle )
	if(toggle) then
		if(ISSettings:IsFilterDeconstruction() and not libFilters:IsFilterRegistered("ItemSaver_DeconstructionFilter")) then
			libFilters:RegisterFilter("ItemSaver_DeconstructionFilter", LAF_DECONSTRUCTION, FilterSavedItems)
		end
	else
		libFilters:UnregisterFilter("ItemSaver_DeconstructionFilter")
	end
end

function ItemSaver_ToggleEnchantingFilter( toggle )
	if(toggle) then
		if(ISSettings:IsFilterDeconstruction() and not libFilters:IsFilterRegistered("ItemSaver_EnchantingFilter")) then
			libFilters:RegisterFilter("ItemSaver_EnchantingFilter", LAF_ENCHANTING_EXTRACTION, FilterSavedItems)
		end
	else
		libFilters:UnregisterFilter("ItemSaver_EnchantingFilter")
	end
end

function ItemSaver_ToggleShopFilter( toggle )
	if(toggle) then
		if(ISSettings:IsFilterShop() and not libFilters:IsFilterRegistered("ItemSaver_ShopFilter")) then
			libFilters:RegisterFilter("ItemSaver_ShopFilter", LAF_STORE, FilterSavedItemsForShop)
		end
	else
		libFilters:UnregisterFilter("ItemSaver_ShopFilter")
	end
end

function ItemSaver_ToggleFilters( toggle, quiet )
	if(not quiet) then
		if(not toggle) then
			d("ItemSaver filters turned OFF")
		else
			d("ItemSaver filters turned ON")
		end
	end
	ItemSaver_ToggleShopFilter(toggle)
	ItemSaver_ToggleDeconstructionFilter(toggle)
	ItemSaver_ToggleEnchantingFilter(toggle)
	--ZO_ScrollList_RefreshVisible(LIST_DIALOG)
	RefreshAll()
end

--[[GLOBAL FUNCTIONS]]------------------------------------------------------------------
--returns true if the shop should be filterd, returns false otherwise
function ItemSaver_IsShopFiltered()
	return ISSettings:IsFilterOn() and ISSettings:IsFilterShop()
end

--returns true if the deconstruction panel should be filterd, returns false otherwise
function ItemSaver_IsDeconstructionFiltered()
	return ISSettings:IsFilterOn() and ISSettings:IsFilterDeconstruction()
end

--returns true if the research panel should be filterd, returns false otherwise
function ItemSaver_IsResearchFiltered()
	return ISSettings:IsFilterOn() and ISSettings:IsFilterResearch()
end

--returns true if the item is saved, returns nil if the item is not saved
function ItemSaver_IsItemSaved(bagIdOrItemId, slotIndex)
	if slotIndex == nil then --ItemId
		return markedItems[SignItemId(bagIdOrItemId)]
	else -- bagId and slotId
		return markedItems[SignItemId(GetItemInstanceId(bagIdOrItemId, slotIndex))]
	end
end

function ItemSaver_ToggleItemSave(bagId, slotIndex)
	local returnVal
	--if bagId is nil, then keybind was pressed.
	if bagId == nil then
		local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
		--if is a backpack row or child of one
		if(mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*")) then
			--check if the control IS the row
			if(mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*$")) then
				local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

				returnVal = ToggleSave(bagId, slotIndex)
			else
				mouseOverControl = mouseOverControl:GetParent()
				--this SHOULD be the row control - if it isn't then idk how to handle it without going iterating through parents
				--that shouldn't happen unless someone is doing something weird
				if(mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*$")) then
					local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

					returnVal = ToggleSave(bagId, slotIndex)
				end
			end
		elseif(mouseOverControl:GetName():find("^ZO_CharacterEquipmentSlots.+$")) then
			local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

			returnVal = ToggleSave(bagId, slotIndex)
		end
	else
		--if bagId is not nil, then function was called by another addon.
		returnVal = ToggleSave(bagId, slotIndex)
	end

	return returnVal
end
--[[END GLOBAL FUNCTIONS]]--------------------------------------------------------------

local function ItemSaver_Loaded(eventCode, addOnName)
	if(addOnName ~= "ItemSaver") then return end

	ISSettings = ItemSaverSettings:New()
	markedItems = ISSettings:GetMarkedItems()

    --Wobin, if you're reading this: <3
    for _,v in pairs(PLAYER_INVENTORY.inventories) do
		local listView = v.listView
		if listView and listView.dataTypes and listView.dataTypes[1] then
			local hookedFunctions = listView.dataTypes[1].setupCallback				
			
			listView.dataTypes[1].setupCallback = 
				function(rowControl, slot)						
					hookedFunctions(rowControl, slot)
					CreateMarkerControl(rowControl)
				end				
		end
	end

	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)
	ZO_PreHook("PlayOnEquippedAnimation", CreateMarkerControlForEquipment)

	RefreshEquipmentControls()

	--deconstruction hook
	local hookedFunctions = DECONSTRUCTION.dataTypes[1].setupCallback
	DECONSTRUCTION.dataTypes[1].setupCallback = function(rowControl, slot)
			hookedFunctions(rowControl, slot)
			CreateMarkerControl(rowControl)
		end

	--enchanting hook
	local hookedFunctions = ENCHANTING.dataTypes[1].setupCallback
	ENCHANTING.dataTypes[1].setupCallback = function(rowControl, slot)
			hookedFunctions(rowControl, slot)
			CreateMarkerControl(rowControl)
		end

	--research list hook
	local hookedFunctions = LIST_DIALOG.dataTypes[1].setupCallback
	LIST_DIALOG.dataTypes[1].setupCallback = function(rowControl, slot)
			hookedFunctions(rowControl, slot)
			CreateMarkerControl(rowControl)

			local data = rowControl.dataEntry.data
			local isSoulGem = false
			local bagId, slotIndex = GetInfoFromRowControl(rowControl)
			local signedItemInstanceId = SignItemId(GetItemInstanceId(bagId, slotIndex))

			if(data and GetSoulGemItemInfo(data.bag, data.index) > 0) then
				isSoulGem = true
			end
			if(ISSettings:IsFilterOn() and ISSettings:IsFilterResearch() and not isSoulGem and markedItems[signedItemInstanceId]) then
				rowControl:SetMouseEnabled(false)
				rowControl:GetNamedChild("Name"):SetColor(.75, 0, 0, 1)
			else
				rowControl:SetMouseEnabled(true)
			end
		end

	--ZO_ScrollList_RefreshVisible(BACKPACK)
	--ZO_ScrollList_RefreshVisible(BANK)
	--ZO_ScrollList_RefreshVisible(GUILD_BANK)
	RefreshAll()
	ItemSaver_ToggleFilters(ISSettings:IsFilterOn())

	ZO_CreateStringId("SI_BINDING_NAME_ITEM_SAVER_TOGGLE", "Toggle Item Saved")

	SLASH_COMMANDS["/itemsaver"] = function(arg)
			if(arg == "filters") then
				ISSettings:ToggleFilter()
				ItemSaver_ToggleFilters(ISSettings:IsFilterOn())
			end
		end
end

EVENT_MANAGER:RegisterForEvent("ItemSaverLoaded", EVENT_ADD_ON_LOADED, ItemSaver_Loaded)