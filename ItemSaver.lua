local BACKPACK = ZO_PlayerInventoryList
local QUICKSLOT = ZO_QuickSlotList
local BANK = ZO_PlayerBankBackpack
local GUILD_BANK = ZO_GuildBankBackpack
local CRAFTBAG = ZO_CraftBagList
local DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack
local IMPROVEMENT = ZO_SmithingTopLevelImprovementPanelInventoryBackpack
local ENCHANTING = ZO_EnchantingTopLevelInventoryBackpack
local ALCHEMY = ZO_AlchemyTopLevelInventoryBackpack
local LIST_DIALOG = ZO_ListDialog1List

local ISSettings = nil

local function SetupSubmenu(bagId, slotIndex)
	local LibCustomMenu = LibStub("LibCustomMenu")
	local setNames = ItemSaver_GetSaveSets()
	local entries = {
		[1] = {
			label = GetString(SI_ITEMSAVER_CREATE_SAVE_SET),
			callback = function()
				ZO_Dialogs_ShowDialog("ITEMSAVER_SAVE", {bagId, slotIndex})
				ClearMenu()
			end,
		},
	}

	for _, setName in pairs(setNames) do
		local entry = {
			label = GetString(SI_ITEMSAVER_SAVE_TO) .. " \"" .. setName .. "\"",
			callback = function()
				ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
				ClearMenu()
			end,
		}

		table.insert(entries, entry)
	end

	AddCustomSubMenuItem(GetString(SI_ITEMSAVER_ADDON_NAME), entries)
end

local function GetInfoFromRowControl(rowControl)
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
		bagId = dataEntry.data.bag
		slotIndex = dataEntry.data.index
	end

	return bagId, slotIndex
end

local function ShouldAddContextMenu()
	return not (BACKPACK:IsHidden() and QUICKSLOT:IsHidden() and BANK:IsHidden()
	  and GUILD_BANK:IsHidden() and CRAFTBAG:IsHidden()
	  and DECONSTRUCTION:IsHidden() and IMPROVEMENT:IsHidden()
	  and ENCHANTING:IsHidden() and ALCHEMY:IsHidden())
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
					AddCustomMenuItem(GetString(SI_ITEMSAVER_SAVE_TO) .. " \"" .. setName .. "\"", function()
						ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
					end, MENU_ADD_OPTION_LABEL)
				end
			end
		else
			SetupSubmenu(bagId, slotIndex)
		end
	else
		AddCustomMenuItem(GetString(SI_ITEMSAVER_UNSAVE_ITEM), function()
			ItemSaver_ToggleItemSave(nil, bagId, slotIndex)
		end, MENU_ADD_OPTION_LABEL)
	end

	ShowMenu()
end

local function AddContextMenuOptionSoon(rowControl)
	if rowControl:GetOwningWindow() == ZO_TradingHouse then return end
	if not ShouldAddContextMenu() then return end

	local parent = rowControl:GetParent()

	if parent ~= ZO_Character then
		zo_callLater(function() AddContextMenuOption(parent) end, 50)
	elseif rowControl.stackCount > 0 then
		zo_callLater(function() AddContextMenuOption(rowControl) end, 50)
	end
end

local function GetMarkerControlAnchorOffsets(markerAnchor)
	local offsetValue = 10
	local offsets = {
		[TOPLEFT] = {
			x = -offsetValue,
			y = -offsetValue,
		},
		[TOP] = {
			y = -offsetValue,
		},
		[TOPRIGHT] = {
			x = offsetValue,
			y = -offsetValue,
		},
		[RIGHT] = {
			x = offsetValue,
		},
		[BOTTOMRIGHT] = {
			x = offsetValue,
			y = offsetValue,
		},
		[BOTTOM] = {
			y = offsetValue,
		},
		[BOTTOMLEFT] = {
			x = -offsetValue,
			y = offsetValue,
		},
		[LEFT] = {
			x = -offsetValue,
		},
		[CENTER] = {},
	}

	return offsets[markerAnchor].x, offsets[markerAnchor].y
end

local function CreateMarkerControl(parent)
	local control = parent:GetNamedChild("ItemSaver")
	if not control then
		control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ItemSaver", parent, CT_TEXTURE)
		control:SetDimensions(32, 32)
		control:SetDrawTier(DT_HIGH)
	end

	local bagId, slotIndex = GetInfoFromRowControl(parent)
	local texturePath, r, g, b = ISSettings:GetMarkerInfo(bagId, slotIndex)

	--item isn't saved, don't continue
	if not texturePath then
		control:SetHidden(true)
		return
	end

	local markerAnchor = ISSettings:GetMarkerAnchor()
	local offsetX, offsetY = GetMarkerControlAnchorOffsets(markerAnchor)
	local anchorTarget = parent:GetNamedChild("Button")

	if anchorTarget then
		--list control
		anchorTarget = anchorTarget:GetNamedChild("Icon")
	else
		--equipment control
		anchorTarget = parent:GetNamedChild("Icon")
	end

	--there's no anchor target. How'd we get here?
	if not anchorTarget then return end

	control:SetHidden(false)
	control:SetTexture(texturePath)
	control:SetColor(r, g, b)
	control:ClearAnchors()
	control:SetAnchor(markerAnchor, anchorTarget, markerAnchor, offsetX, offsetY)
end

local function RefreshEquipmentControls()
	for i = 1, ZO_Character:GetNumChildren() do
		local child = ZO_Character:GetChild(i)

		if child and child:GetName():find("ZO_CharacterEquipmentSlots") then
			CreateMarkerControl(ZO_Character:GetChild(i))
		end
	end
end

local function RefreshAll()
	ZO_ScrollList_RefreshVisible(BACKPACK)
	ZO_ScrollList_RefreshVisible(QUICKSLOT)
	ZO_ScrollList_RefreshVisible(BANK)
	ZO_ScrollList_RefreshVisible(GUILD_BANK)
	ZO_ScrollList_RefreshVisible(CRAFTBAG)
	ZO_ScrollList_RefreshVisible(DECONSTRUCTION)
	ZO_ScrollList_RefreshVisible(IMPROVEMENT)
	ZO_ScrollList_RefreshVisible(ENCHANTING)
	ZO_ScrollList_RefreshVisible(ALCHEMY)
	ZO_ScrollList_RefreshVisible(LIST_DIALOG)
	RefreshEquipmentControls()
end

local function ItemSaver_Loaded(eventCode, addonName)
	if addonName ~= "ItemSaver" then return end

	ISSettings = ItemSaverSettings:New()

	ZO_PreHook("ZO_InventorySlot_ShowContextMenu", AddContextMenuOptionSoon)

	--hook each control to force a refresh and pick up filtered results
	local function hookFragment(fragment, control)
		local function onFragmentShowing()
			ZO_ScrollList_RefreshVisible(BACKPACK)
			RefreshEquipmentControls()
		end

		local function onFragmentStateChange(oldState, newState)
			if newState == SCENE_FRAGMENT_SHOWING then
				onFragmentShowing()
			end
		end

		fragment:RegisterCallback("StateChange", onFragmentStateChange)
	end
	hookFragment(INVENTORY_FRAGMENT, BACKPACK)
	hookFragment(QUICKSLOT_FRAGMENT, QUICKSLOT)
	hookFragment(BANK_FRAGMENT, BANK)
	hookFragment(GUILD_BANK_FRAGMENT, GUILD_BANK)
	hookFragment(SMITHING_FRAGMENT, DECONSTRUCTION)
	hookFragment(ENCHANTING_FRAGMENT, ENCHANTING)

	--add marker initialization to slot setup callbacks
	local hookedSetupFunctions = {}
	local function newSetupCallback(rowControl, slot)
		local listViewName = rowControl:GetParent():GetParent():GetName()

		if hookedSetupFunctions[listViewName] then
			hookedSetupFunctions[listViewName](rowControl, slot)
		end

		CreateMarkerControl(rowControl)
	end
	local function newSetupCallbackForResearch(rowControl, slot)
		newSetupCallback(rowControl, slot)

		local data = rowControl.dataEntry.data
		local isSoulGem = false
		local bagId, slotIndex = GetInfoFromRowControl(rowControl)

		if data and GetSoulGemItemInfo(data.bag, data.index) > 0 then
			isSoulGem = true
		end

		local isSaved, setName = ItemSaver_IsItemSaved(bagId, slotIndex)

		if not isSoulGem and isSaved and ItemSaver_GetFilters(setName).research then
			rowControl:SetMouseEnabled(false)
			rowControl:GetNamedChild("Name"):SetColor(.75, 0, 0)
		else
			rowControl:SetMouseEnabled(true)
		end
	end
	--inventory hooks
    for _,inventory in pairs(PLAYER_INVENTORY.inventories) do
		local listView = inventory.listView

		if listView and listView.dataTypes and listView.dataTypes[1] then
			hookedSetupFunctions[listView:GetName()] = listView.dataTypes[1].setupCallback
			listView.dataTypes[1].setupCallback = newSetupCallback
		end
	end
	--quickslot hook
	hookedSetupFunctions[QUICKSLOT:GetName()] = QUICKSLOT.dataTypes[1].setupCallback
	QUICKSLOT.dataTypes[1].setupCallback = newSetupCallback
	--deconstruction hook
	hookedSetupFunctions[DECONSTRUCTION:GetName()] = DECONSTRUCTION.dataTypes[1].setupCallback
	DECONSTRUCTION.dataTypes[1].setupCallback = newSetupCallback
	--improvement hook
	hookedSetupFunctions[IMPROVEMENT:GetName()] = IMPROVEMENT.dataTypes[1].setupCallback
	IMPROVEMENT.dataTypes[1].setupCallback = newSetupCallback
	--enchanting hook
	hookedSetupFunctions[ENCHANTING:GetName()] = ENCHANTING.dataTypes[1].setupCallback
	ENCHANTING.dataTypes[1].setupCallback = newSetupCallback
	--alchemy hook
	hookedSetupFunctions[ALCHEMY:GetName()] = ALCHEMY.dataTypes[1].setupCallback
	ALCHEMY.dataTypes[1].setupCallback = newSetupCallback
	--research list hook
	hookedSetupFunctions[LIST_DIALOG:GetName()] = LIST_DIALOG.dataTypes[1].setupCallback
	LIST_DIALOG.dataTypes[1].setupCallback = newSetupCallbackForResearch

	--finish create set dialog initialization
	ItemSaver_InitializeDialog()
end
EVENT_MANAGER:RegisterForEvent("ItemSaverLoaded", EVENT_ADD_ON_LOADED, ItemSaver_Loaded)

local function handleEquipmentChange(eventCode, bagId, slotIndex, isNewItem, itemSoundCategory, inventoryUpdateReason)
	if bagId ~= BAG_WORN or isNewItem or inventoryUpdateReason ~= 0 then return end

	RefreshEquipmentControls()
end
EVENT_MANAGER:RegisterForEvent("ItemSaverEquipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, handleEquipmentChange)

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

	if bagIdOrItemId == nil then --keybind
		local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()

		bagIdOrItemId, slotIndex = GetInfoFromRowControl(mouseOverControl)

		if not bagIdOrItemId then
			mouseOverControl = mouseOverControl:GetParent()
			bagIdOrItemId, slotIndex = GetInfoFromRowControl(mouseOverControl)
		end
	end

	if bagIdOrItemId then
		returnVal = ISSettings:ToggleItemSave(setName, bagIdOrItemId, slotIndex)
		RefreshAll()

		return returnVal
	end
end

--if the given set exists, returns a table with the following keys: store,
--deconstruction, research, guildStore, mail, trade.
--each will have a value of true if they are filtered or false if they are not.
--if the set does not exist, returns nil
function ItemSaver_GetFilters(setName)
	return ISSettings:GetFilters(setName)
end

--returns array of the names of available markers.
function ItemSaver_GetMarkerOptions()
	return ISSettings:GetMarkerOptions()
end

--returns table with key/value pairs of markerName/markerPath
function ItemSaver_GetMarkerTextures()
	return ISSettings:GetMarkerTextures()
end

--returns an alphabetically sorted array of the names of available save sets.
function ItemSaver_GetSaveSets()
	return ISSettings:GetSaveSets()
end

--returns true if the set was successfully registered.
--returns false if the set name is an empty string or already in use.
function ItemSaver_AddSet(setName, setData)
	return ISSettings:AddSet(setName, setData)
end
--[[END GLOBAL FUNCTIONS]]------------------------------------------------------