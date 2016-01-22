local BACKPACK = ZO_PlayerInventoryBackpack
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack
local DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
local ENCHANTING = ZO_EnchantingTopLevelInventoryBackpack
local LIST_DIALOG = ZO_ListDialog1List

local ISSettings = nil

local function SetupSubmenu(bagId, slotIndex)
	local LibCustomMenu = LibStub("LibCustomMenu")
	local entries = {
		[1] = {
			label = GetString(SI_ITEMSAVER_CREATE_SAVE_SET),
			callback = function()
				ZO_Dialogs_ShowDialog("ITEMSAVER_SAVE", { [1] = bagId, [2] = slotIndex })
				ClearMenu()
			end,
		},
	}
	local setNames = ItemSaver_GetSaveSets()

	for _,setName in pairs(setNames) do
		local entry = {
			label = GetString(SI_ITEMSAVER_SAVE_TO) .. " \"" .. setName .. "\"",
			callback = function()
				ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
				--[[if GetItemSaverControl(rowControl) then
					GetItemSaverControl(rowControl):SetHidden(false)
				end]]
				ClearMenu()
			end,
		}
		table.insert(entries, entry)
	end

	AddCustomSubMenuItem(GetString(SI_ITEMSAVER_ADDON_NAME), entries)
end

local function GetInfoFromRowControl(rowControl)
	--gotta do this in case deconstruction...
	local dataEntry = rowControl.dataEntry
	local bagId, slotIndex

	--case to handle equiped items
	if not dataEntry then
		bagId = rowControl.bagId
		slotIndex = rowControl.slotIndex
	else
		bagId = dataEntry.data.bagId
		slotIndex = dataEntry.data.slotIndex
	end

	--case to handle list dialog, list dialog uses index instead of slotIndex
	--and bag instead of badId...?
	if dataEntry and not bagId and not slotIndex then
		bagId = rowControl.dataEntry.data.bag
		slotIndex = rowControl.dataEntry.data.index
	end

	return bagId, slotIndex
end

local function AddContextMenuOption(rowControl)
	local bagId, slotIndex = GetInfoFromRowControl(rowControl)

	if not ItemSaver_IsItemSaved(bagId, slotIndex) then
		local deferSubmenu, deferSubmenuNum = ISSettings:GetSubmenuDeferredStatus()
		if deferSubmenu then
			local setNames = ItemSaver_GetSaveSets()
			if #setNames > deferSubmenuNum then
				SetupSubmenu(bagId, slotIndex)
			else
				for _, setName in pairs(setNames) do
					AddMenuItem(GetString(SI_ITEMSAVER_SAVE_TO) .. " \"" .. setName .. "\"", function()
						ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
					end, MENU_ADD_OPTION_LABEL)
				end
			end
		else
			SetupSubmenu(bagId, slotIndex)
		end
	else
		AddMenuItem(GetString(SI_ITEMSAVER_UNSAVE_ITEM), function()
				ItemSaver_ToggleItemSave(nil, bagId, slotIndex)

				--[[if GetItemSaverControl(rowControl) then
					GetItemSaverControl(rowControl):SetHidden(true)
				end]]
			end, MENU_ADD_OPTION_LABEL)
	end
	ShowMenu()
end

local function AddContextMenuOptionSoon(rowControl)
	if rowControl:GetOwningWindow() == ZO_TradingHouse then return end
	if BACKPACK:IsHidden() and BANK:IsHidden() and GUILD_BANK:IsHidden()
	  and DECONSTRUCTION:IsHidden() and ENCHANTING:IsHidden() then return end

	if rowControl:GetParent() ~= ZO_Character then
		zo_callLater(function() AddContextMenuOption(rowControl:GetParent()) end, 50)
	else
		zo_callLater(function() AddContextMenuOption(rowControl) end, 50)
	end
end

local function CreateMarkerControl(parent)
	local control = parent:GetNamedChild("ItemSaver")
	local bagId, slotIndex = GetInfoFromRowControl(parent)
	local texturePath, r, g, b, a = ISSettings:GetMarkerInfo(bagId, slotIndex)

	if not control then
		control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ItemSaver", parent, CT_TEXTURE)
		control:SetDimensions(32, 32)
	end

	if texturePath ~= nil then
		control:SetTexture(texturePath)
		control:SetColor(r, g, b, a)
	end

	if ItemSaver_IsItemSaved(bagId, slotIndex) then
		control:SetHidden(false)
	else
		control:SetHidden(true)
	end

	local markerAnchor = ISSettings:GetMarkerAnchor()
	if parent:GetWidth() - parent:GetHeight() < 5 then
		if parent:GetNamedChild("SellPrice") then
			parent:GetNamedChild("SellPrice"):SetHidden(true)
		end--what?
		control:SetDrawTier(DT_HIGH)
		control:ClearAnchors()
		control:SetAnchor(markerAnchor, parent, markerAnchor)
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
	for i = 1, ZO_Character:GetNumChildren() do
		local child = ZO_Character:GetChild(i)
		if child and child:GetName():find("ZO_CharacterEquipmentSlots") then
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

local function ItemSaver_Loaded(eventCode, addonName)
	if addonName ~= "ItemSaver" then return end

	ISSettings = ItemSaverSettings:New()

	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)
	ZO_PreHook("PlayOnEquippedAnimation", CreateMarkerControlForEquipment)

	--hook each control to force a refresh and pick up changes to the marker control
	ZO_PreHookHandler(BACKPACK, "OnEffectivelyShown", function()
		ZO_ScrollList_RefreshVisible(BACKPACK)
		RefreshEquipmentControls()
	end)
	ZO_PreHookHandler(BANK, "OnEffectivelyShown", function()
		ZO_ScrollList_RefreshVisible(BANK)
		RefreshEquipmentControls()
	end)
	ZO_PreHookHandler(GUILD_BANK, "OnEffectivelyShown", function()
		ZO_ScrollList_RefreshVisible(GUILD_BANK)
		RefreshEquipmentControls()
	end)
	ZO_PreHookHandler(DECONSTRUCTION, "OnEffectivelyShown", function()
		ZO_ScrollList_RefreshVisible(DECONSTRUCTION)
		RefreshEquipmentControls()
	end)
	ZO_PreHookHandler(ENCHANTING, "OnEffectivelyShown", function()
		ZO_ScrollList_RefreshVisible(ENCHANTING)
		RefreshEquipmentControls()
	end)
	ZO_PreHookHandler(LIST_DIALOG, "OnEffectivelyShown", function()
		ZO_ScrollList_RefreshVisible(LIST_DIALOG)
	end)

	--inventory hooks
	--Wobin, if you're reading this: <3
    for _,inventory in pairs(PLAYER_INVENTORY.inventories) do
		local listView = inventory.listView
		if listView and listView.dataTypes and listView.dataTypes[1] then
			local hookedFunctions = listView.dataTypes[1].setupCallback
			listView.dataTypes[1].setupCallback = function(rowControl, slot)
				hookedFunctions(rowControl, slot)
				CreateMarkerControl(rowControl)
			end
		end
	end

	--deconstruction hook
	--hookedFunctions re-declared over and over again because the game was
	--freaking out otherwise?
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

		if data and GetSoulGemItemInfo(data.bag, data.index) > 0 then
			isSoulGem = true
		end

		local isSaved, setName = ItemSaver_IsItemSaved(bagId, slotIndex)

		if not isSoulGem and isSaved and ItemSaver_GetFilters(setName).research then
			rowControl:SetMouseEnabled(false)
			rowControl:GetNamedChild("Name"):SetColor(.75, 0, 0, 1)
		else
			rowControl:SetMouseEnabled(true)
		end
	end
end

EVENT_MANAGER:RegisterForEvent("ItemSaverLoaded", EVENT_ADD_ON_LOADED, ItemSaver_Loaded)

--[[GLOBAL FUNCTIONS]]----------------------------------------------------------
--returns true and the string set name if the item is saved. Returns false if
--the item is not saved.
function ItemSaver_IsItemSaved(bagIdOrItemId, slotIndex)
	return ISSettings:IsItemSaved(bagIdOrItemId, slotIndex)
end

--returns true if item was saved successfully. Returns false if item was unsaved.
--if setName is nil, the default set will be used.
function ItemSaver_ToggleItemSave(setName, bagIdOrItemId, slotIndex)
	local returnVal
	if setName == nil then setName = "Default" end

	if bagIdOrItemId == nil then --keybind
		local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
		--if is a backpack row or child of one
		if mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*") then
			--check if the control IS the row
			if mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*$") then
				local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

				returnVal = ISSettings:ToggleItemSave(setName, bagId, slotIndex)
				RefreshAll()
				return returnVal
			else
				mouseOverControl = mouseOverControl:GetParent()
				--this SHOULD be the row control - if it isn't then idk how to handle it without going iterating through parents
				--that shouldn't happen unless someone is doing something weird
				if mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*$") then
					local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

					returnVal = ISSettings:ToggleItemSave(setName, bagId, slotIndex)
					RefreshAll()
					return returnVal
				end
			end
		elseif mouseOverControl:GetName():find("^ZO_CharacterEquipmentSlots.+$") then
			local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

			returnVal = ISSettings:ToggleItemSave(setName, bagId, slotIndex)
			RefreshAll()
			return returnVal
		end
	else --called by other addon
		returnVal = ISSettings:ToggleItemSave(setName, bagIdOrItemId, slotIndex)
		RefreshAll()
		return returnVal
	end
end

--returns a table with the following keys: store, deconstruction, research,
--guildStore, mail, trade. Each will have a value of true if they are filtered
--or false otherwise.
function ItemSaver_GetFilters(setName)
	return ISSettings:GetFilters(setName)
end

--returns array of the names of available markers.
function ItemSaver_GetMarkerOptions()
	return ISSettings:GetMarkerOptions()
end

--returns an alphabetically sorted array of the names of available save sets.
function ItemSaver_GetSaveSets()
	return ISSettings:GetSaveSets()
end
--[[END GLOBAL FUNCTIONS]]------------------------------------------------------
