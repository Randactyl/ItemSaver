ItemSaver = {}
local IS = ItemSaver
IS.addonVersion = "3.3.2.0"

local util, settings
local LISTS = {
    BACKPACK = ZO_PlayerInventoryList,
    QUICKSLOT = ZO_QuickSlotList,
    BANK = ZO_PlayerBankBackpack,
    GUILD_BANK = ZO_GuildBankBackpack,
    CRAFTBAG = ZO_CraftBagList,
    DECONSTRUCTION = ZO_SmithingTopLevelDeconstructionPanelInventoryBackpack,
    IMPROVEMENT = ZO_SmithingTopLevelImprovementPanelInventoryBackpack,
    ENCHANTING = ZO_EnchantingTopLevelInventoryBackpack,
    ALCHEMY = ZO_AlchemyTopLevelInventoryBackpack,
    LIST_DIALOG = ZO_ListDialog1List,
}

local function addContextMenuOptionSoon(rowControl)
    if rowControl:GetOwningWindow() == ZO_TradingHouse then return end

    local function shouldAddContextMenu()
        for _, list in pairs(LISTS) do
            if not list:IsHidden() then
                return true
            end
        end
    end
    if not shouldAddContextMenu() then return end

    local function addContextMenuOption(rowControl)
        local bagId, slotIndex = util.GetInfoFromRowControl(rowControl)
        local setNames = ItemSaver_GetSaveSets()
        local createSetEntry = {
            label = GetString(SI_ITEMSAVER_CREATE_SAVE_SET),
            callback = function()
                ZO_Dialogs_ShowDialog("ITEMSAVER_SAVE", {bagId, slotIndex})
                ClearMenu()
            end,
        }

        local function setupSubmenu(bagId, slotIndex)
            local entries = {
                [1] = createSetEntry,
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

        local isSaved, setName = ItemSaver_IsItemSaved(bagId, slotIndex)

        if not isSaved then
            local deferSubmenu, deferSubmenuNum = ItemSaver_IsSubmenuDeferred()

            if deferSubmenu then
                if #setNames > deferSubmenuNum then
                    setupSubmenu(bagId, slotIndex)
                else
                    AddCustomMenuItem(createSetEntry.label, createSetEntry.callback, MENU_ADD_OPTION_LABEL)
                    for _, setName in pairs(setNames) do
                        AddCustomMenuItem(GetString(SI_ITEMSAVER_SAVE_TO) .. " \"" .. setName .. "\"", function()
                            ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
                        end, MENU_ADD_OPTION_LABEL)
                    end
                end
            else
                setupSubmenu(bagId, slotIndex)
            end
        else
            AddCustomMenuItem(GetString(SI_ITEMSAVER_UNSAVE_ITEM), function()
                ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
            end, MENU_ADD_OPTION_LABEL)
        end

        ShowMenu()
    end

    local parent = rowControl:GetParent()

    if parent ~= ZO_Character then
        zo_callLater(function() addContextMenuOption(parent) end, 50)
    elseif rowControl.stackCount > 0 then
        zo_callLater(function() addContextMenuOption(rowControl) end, 50)
    end
end

local function initializeHooks()
    --add marker initialization to slot setup callbacks
    local hookedSetupFunctions = {}
    local function newSetupCallback(rowControl, slot)
        local listViewName = rowControl:GetParent():GetParent():GetName()

        if hookedSetupFunctions[listViewName] then
            hookedSetupFunctions[listViewName](rowControl, slot)
        end

        util.CreateMarkerControl(rowControl)
    end

    --list hooks
    for _, list in pairs(LISTS) do
        hookedSetupFunctions[list:GetName()] = list.dataTypes[1].setupCallback
        list.dataTypes[1].setupCallback = newSetupCallback
    end

    --setup context menu entry
    ZO_PreHook("ZO_InventorySlot_ShowContextMenu", addContextMenuOptionSoon)
end

local function ItemSaver_Loaded(eventCode, addonName)
    if addonName ~= "ItemSaver" then return end

    --set local references
    util = IS.util
    settings = IS.settings

    --initialize LibFilters
    util.LibFilters:InitializeLibFilters()

    --initialize settings
    settings.InitializeSettings()

    --setup hooks
    initializeHooks()

    --create equipment markers
    util.RefreshEquipmentControls()

    --finish create set dialog initialization
    IS.dialog.InitializeDialog()
end
EVENT_MANAGER:RegisterForEvent("ItemSaverLoaded", EVENT_ADD_ON_LOADED,
  ItemSaver_Loaded)

local function handleEquipmentChange(eventCode, bagId, slotIndex, isNewItem,
  itemSoundCategory, inventoryUpdateReason)
    if bagId ~= BAG_WORN or isNewItem or inventoryUpdateReason ~= 0 then return end

    util.RefreshEquipmentControls()
end
EVENT_MANAGER:RegisterForEvent("ItemSaverEquipChange", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
  handleEquipmentChange)