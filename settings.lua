local IS = ItemSaver
IS.settings = {}

local util = IS.util
local settings = IS.settings
local vars

local function refreshSettingsPanelSetChoices()
    local def = WINDOW_MANAGER:GetControlByName("IS_DefaultSetDropdown")
    local edit = WINDOW_MANAGER:GetControlByName("IS_EditSetDropdown")

    if not def then return end

    def:UpdateValue()
    edit:UpdateValue()
end

local function toggleFilter(setName, filterTagSuffix, filterType)
    local filterTag = "ItemSaver_"..setName..filterTagSuffix
    local isRegistered = util.LibFilters:IsFilterRegistered(filterTag, filterType)

    local function filterCallback(slotOrBagId, slotIndex)
        local bagId

        if type(slotOrBagId) == "number" then
            if not slotIndex then return false end

            bagId = slotOrBagId
        else
            bagId, slotIndex = util.GetInfoFromRowControl(slotOrBagId)
        end

        local _, savedSet = ItemSaver_IsItemSaved(bagId, slotIndex)

        return not (savedSet == setName)
    end

    if not isRegistered then
        util.LibFilters:RegisterFilter(filterTag, filterType, filterCallback)
        util.LibFilters:RequestUpdate(filterType)
    else
        util.LibFilters:UnregisterFilter(filterTag, filterType)
        util.LibFilters:RequestUpdate(filterType)
    end
end

local function toggleFilters()
    for setName, setInfo in pairs(vars.savedSetInfo) do
        if setInfo.filterStore then toggleFilter(setName, "_VendorSell", LF_VENDOR_SELL) end
        if setInfo.filterDeconstruction then toggleFilter(setName, "_Deconstruct", LF_SMITHING_DECONSTRUCT) end
        if setInfo.filterResearch then toggleFilter(setName, "_Research", LF_SMITHING_RESEARCH) end
        if setInfo.filterGuildStore then toggleFilter(setName, "_GuildStoreSell", LF_GUILDSTORE_SELL) end
        if setInfo.filterMail then toggleFilter(setName, "_MailSend", LF_MAIL_SEND) end
        if setInfo.filterTrade then toggleFilter(setName, "_Trade", LF_TRADE) end
    end
end

function settings.InitializeSettings()
    local function createOptionsMenu()
        local function clearSet(setName)
            for savedItem, name in pairs(vars.savedItems) do
                if name == setName then
                    vars.savedItems[savedItem] = nil
                end
            end

            d(GetString(SI_ITEMSAVER_CLEAR_SET_CONFIRMATION) .. " " .. setName)
        end
        local function updateEditSetSettings(setName)
            local setData = ItemSaver_GetSetData(setName)

            WINDOW_MANAGER:GetControlByName("IS_EditSetHeader").data.name = GetString(SI_ITEMSAVER_SET_DATA_HEADER) .. " - " .. setName
            WINDOW_MANAGER:GetControlByName("IS_DeleteButton").data.disabled = vars.defaultSet == setName
            local iconPicker = WINDOW_MANAGER:GetControlByName("IS_IconPicker")
            local r, g, b = util.HexToRGB(setData.markerColor)

            iconPicker.icon.color.r = r
            iconPicker.icon.color.g = g
            iconPicker.icon.color.b = b
            iconPicker:SetColor(iconPicker.icon.color)
        end

        local ANCHOR_OPTIONS = {
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_TOPLEFT),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_TOP),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_TOPRIGHT),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_RIGHT),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_BOTTOMRIGHT),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_BOTTOM),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_BOTTOMLEFT),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_LEFT),
            GetString(SI_ITEMSAVER_ANCHOR_LABEL_CENTER),
        }
        local DEFER_SUBMENU_OPTIONS = {"1", "2", "3", "4", "5"}
        local SAVE_TYPE_OPTIONS = {
            GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_GENERAL),
            GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_UNIQUE),
        }

        local markerTexturePaths, markerTextureNames = util.GetMarkerTextureArrays()
        local editSetName = vars.defaultSet
        local editSetData = ItemSaver_GetSetData(editSetName)

        local panel = {
            type = "panel",
            name = GetString(SI_ITEMSAVER_ADDON_NAME),
            author = "Randactyl",
            version = IS.addonVersion,
            website = "http://www.esoui.com/downloads/info300-ItemSaver.html",
            slashCommand = "/itemsaver",
            registerForRefresh = true,
        }

        local optionsData = {
            {
                type = "header",
                name = SI_ITEMSAVER_GENERAL_OPTIONS_HEADER,
            },
            {
                type = "dropdown",
                name = SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_LABEL,
                tooltip = SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_TOOLTIP,
                choices = ItemSaver_GetSaveSets(),
                getFunc = function()
                    this = WINDOW_MANAGER:GetControlByName("IS_DefaultSetDropdown")
                    this:UpdateChoices(ItemSaver_GetSaveSets())

                    return vars.defaultSet
                end,
                setFunc = function(value)
                    WINDOW_MANAGER:GetControlByName("IS_DeleteButton").data.disabled = value == editSetName

                    vars.defaultSet = value
                end,
                reference = "IS_DefaultSetDropdown",
            },
            {
                type = "dropdown",
                name = SI_ITEMSAVER_MARKER_ANCHOR_LABEL,
                tooltip = SI_ITEMSAVER_MARKER_ANCHOR_TOOLTIP,
                choices = ANCHOR_OPTIONS,
                getFunc = function()
                    local anchor = vars.markerAnchor
                    if anchor == TOPLEFT then return ANCHOR_OPTIONS[1] end
                    if anchor == TOP then return ANCHOR_OPTIONS[2] end
                    if anchor == TOPRIGHT then return ANCHOR_OPTIONS[3] end
                    if anchor == RIGHT then return ANCHOR_OPTIONS[4] end
                    if anchor == BOTTOMRIGHT then return ANCHOR_OPTIONS[5] end
                    if anchor == BOTTOM then return ANCHOR_OPTIONS[6] end
                    if anchor == BOTTOMLEFT then return ANCHOR_OPTIONS[7] end
                    if anchor == LEFT then return ANCHOR_OPTIONS[8] end
                    if anchor == CENTER then return ANCHOR_OPTIONS[9] end
                end,
                setFunc = function(value)
                    if value == ANCHOR_OPTIONS[1] then vars.markerAnchor = TOPLEFT end
                    if value == ANCHOR_OPTIONS[2] then vars.markerAnchor = TOP end
                    if value == ANCHOR_OPTIONS[3] then vars.markerAnchor = TOPRIGHT end
                    if value == ANCHOR_OPTIONS[4] then vars.markerAnchor = RIGHT end
                    if value == ANCHOR_OPTIONS[5] then vars.markerAnchor = BOTTOMRIGHT end
                    if value == ANCHOR_OPTIONS[6] then vars.markerAnchor = BOTTOM end
                    if value == ANCHOR_OPTIONS[7] then vars.markerAnchor = BOTTOMLEFT end
                    if value == ANCHOR_OPTIONS[8] then vars.markerAnchor = LEFT end
                    if value == ANCHOR_OPTIONS[9] then vars.markerAnchor = CENTER end
                end,
            },
            {
                type = "slider",
                name = SI_ITEMSAVER_OFFSET_X_SLIDER,
                tooltip = SI_ITEMSAVER_OFFSET_X_TOOLTIP,
                getFunc = function() return vars.offsetX end,
                setFunc = function(value) vars.offsetX = value end,
                min = -10,
                max = 10,
                step = 1,
                autoSelect = true,
                width = "half",
            },
            {
                type = "slider",
                name = SI_ITEMSAVER_OFFSET_Y_SLIDER,
                tooltip = SI_ITEMSAVER_OFFSET_Y_TOOLTIP,
                getFunc = function() return vars.offsetY end,
                setFunc = function(value) vars.offsetY = value end,
                min = -10,
                max = 10,
                step = 1,
                autoSelect = true,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_LABEL,
                tooltip = SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_TOOLTIP,
                getFunc = function() return vars.deferSubmenu end,
                setFunc = function(value)
                    vars.deferSubmenu = value
                    local dropdown = WINDOW_MANAGER:GetControlByName("IS_DeferSubmenuDropdown")
                    dropdown.data.disabled = not value
                end,
                width = "half",
            },
            {
                type = "dropdown",
                name = SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_LABEL,
                tooltip = SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_TOOLTIP,
                choices = DEFER_SUBMENU_OPTIONS,
                getFunc = function()
                    local num = vars.deferSubmenuNum
                    if num == 1 then return DEFER_SUBMENU_OPTIONS[1] end
                    if num == 2 then return DEFER_SUBMENU_OPTIONS[2] end
                    if num == 3 then return DEFER_SUBMENU_OPTIONS[3] end
                    if num == 4 then return DEFER_SUBMENU_OPTIONS[4] end
                    if num == 5 then return DEFER_SUBMENU_OPTIONS[5] end
                end,
                setFunc = function(value)
                    if value == DEFER_SUBMENU_OPTIONS[1] then vars.deferSubmenuNum = 1 end
                    if value == DEFER_SUBMENU_OPTIONS[2] then vars.deferSubmenuNum = 2 end
                    if value == DEFER_SUBMENU_OPTIONS[3] then vars.deferSubmenuNum = 3 end
                    if value == DEFER_SUBMENU_OPTIONS[4] then vars.deferSubmenuNum = 4 end
                    if value == DEFER_SUBMENU_OPTIONS[5] then vars.deferSubmenuNum = 5 end
                end,
                width = "half",
                disabled = not vars.deferSubmenu,
                reference = "IS_DeferSubmenuDropdown",
            },
            {
                type = "submenu",
                name = SI_ITEMSAVER_KEYBIND_SUBMENU_NAME,
                controls = {
                    {
                        type = "dropdown",
                        name = SI_ITEMSAVER_KEYBIND_SET_1_NAME,
                        choices = ItemSaver_GetSaveSets(),
                        getFunc = function()
                            this = WINDOW_MANAGER:GetControlByName("IS_KeybindSet1Dropdown")
                            this:UpdateChoices(ItemSaver_GetSaveSets())

                            return vars.keybindSetMap[1]
                        end,
                        setFunc = function(value)
                            vars.keybindSetMap[1] = value
                        end,
                        reference = "IS_KeybindSet1Dropdown",
                    },
                    {
                        type = "dropdown",
                        name = SI_ITEMSAVER_KEYBIND_SET_2_NAME,
                        choices = ItemSaver_GetSaveSets(),
                        getFunc = function()
                            this = WINDOW_MANAGER:GetControlByName("IS_KeybindSet2Dropdown")
                            this:UpdateChoices(ItemSaver_GetSaveSets())

                            return vars.keybindSetMap[2]
                        end,
                        setFunc = function(value)
                            vars.keybindSetMap[2] = value
                        end,
                        reference = "IS_KeybindSet2Dropdown",
                    },
                    {
                        type = "dropdown",
                        name = SI_ITEMSAVER_KEYBIND_SET_3_NAME,
                        choices = ItemSaver_GetSaveSets(),
                        getFunc = function()
                            this = WINDOW_MANAGER:GetControlByName("IS_KeybindSet3Dropdown")
                            this:UpdateChoices(ItemSaver_GetSaveSets())

                            return vars.keybindSetMap[3]
                        end,
                        setFunc = function(value)
                            vars.keybindSetMap[3] = value
                        end,
                        reference = "IS_KeybindSet3Dropdown",
                    },
                    {
                        type = "dropdown",
                        name = SI_ITEMSAVER_KEYBIND_SET_4_NAME,
                        choices = ItemSaver_GetSaveSets(),
                        getFunc = function()
                            this = WINDOW_MANAGER:GetControlByName("IS_KeybindSet4Dropdown")
                            this:UpdateChoices(ItemSaver_GetSaveSets())

                            return vars.keybindSetMap[4]
                        end,
                        setFunc = function(value)
                            vars.keybindSetMap[4] = value
                        end,
                        reference = "IS_KeybindSet4Dropdown",
                    },
                    {
                        type = "dropdown",
                        name = SI_ITEMSAVER_KEYBIND_SET_5_NAME,
                        choices = ItemSaver_GetSaveSets(),
                        getFunc = function()
                            this = WINDOW_MANAGER:GetControlByName("IS_KeybindSet5Dropdown")
                            this:UpdateChoices(ItemSaver_GetSaveSets())

                            return vars.keybindSetMap[5]
                        end,
                        setFunc = function(value)
                            vars.keybindSetMap[5] = value
                        end,
                        reference = "IS_KeybindSet5Dropdown",
                    },
                },
            },
            {
                type = "dropdown",
                name = SI_ITEMSAVER_EDIT_SET_DROPDOWN_LABEL,
                choices = ItemSaver_GetSaveSets(),
                getFunc = function()
                    this = WINDOW_MANAGER:GetControlByName("IS_EditSetDropdown")
                    this:UpdateChoices(ItemSaver_GetSaveSets())

                    return editSetName
                end,
                setFunc = function(setName)
                    editSetName = setName
                    editSetData = ItemSaver_GetSetData(setName)

                    updateEditSetSettings(setName)
                end,
                tooltip = SI_ITEMSAVER_EDIT_SET_DROPDOWN_TOOLTIP,
                reference = "IS_EditSetDropdown",
            },
            {
                type = "header",
                name = GetString(SI_ITEMSAVER_SET_DATA_HEADER) .. " - " .. editSetName,
                reference = "IS_EditSetHeader",
            },
            {
                type = "dropdown",
                name = SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_LABEL,
                tooltip = SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_TOOLTIP,
                choices = SAVE_TYPE_OPTIONS,
                getFunc = function()
                    local areItemsUnique = editSetData.areItemsUnique or false

                    if areItemsUnique then return SAVE_TYPE_OPTIONS[2] end

                    return SAVE_TYPE_OPTIONS[1]
                end,
                setFunc = function(value)
                    --get new selection
                    local newSelection = true

                    if value == SAVE_TYPE_OPTIONS[1] then
                        newSelection = false
                    end

                    --clear the set if the user has set this before (migration)
                    if editSetData.areItemsUnique ~= nil then
                        clearSet(editSetName)
                    end

                    --set selection
                    editSetData.areItemsUnique = newSelection
                end,
                warning = SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_WARNING,
                reference = "IS_SaveTypeDropdown",
            },
            {
                type = "iconpicker",
                name = SI_ITEMSAVER_MARKER_LABEL,
                tooltip = SI_ITEMSAVER_MARKER_TOOLTIP,
                choices = markerTexturePaths,
                choicesTooltips = markerTextureNames,
                getFunc = function()
                    local markerTextureName = editSetData.markerTexture

                    for i, name in ipairs(markerTextureNames) do
                        if name == markerTextureName then
                            return markerTexturePaths[i]
                        end
                    end
                end,
                setFunc = function(markerTexturePath)
                    for i, path in ipairs(markerTexturePaths) do
                        if path == markerTexturePath then
                            editSetData.markerTexture = markerTextureNames[i]
                        end
                    end
                end,
                maxColumns = 5,
                visibleRows = zo_min(zo_max(zo_floor(#markerTexturePaths/5), 1), 4.5),
                iconSize = 32,
                defaultColor = ZO_ColorDef:New(util.HexToRGB(editSetData.markerColor)),
                width = "half",
                reference = "IS_IconPicker",
            },
            {
                type = "colorpicker",
                name = SI_ITEMSAVER_TEXTURE_COLOR_LABEL,
                tooltip = SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP,
                getFunc = function()
                    return util.HexToRGB(editSetData.markerColor)
                end,
                setFunc = function(r, g, b)
                    local iconPicker = WINDOW_MANAGER:GetControlByName("IS_IconPicker")

                    iconPicker.icon.color.r = r
                    iconPicker.icon.color.g = g
                    iconPicker.icon.color.b = b
                    iconPicker:SetColor(iconPicker.icon.color)

                    editSetData.markerColor = util.RGBToHex(r, g, b)
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_FILTERS_VENDORSELL_LABEL,
                tooltip = SI_ITEMSAVER_FILTERS_VENDORSELL_TOOLTIP,
                getFunc = function() return editSetData.filterStore end,
                setFunc = function(value)
                    editSetData.filterStore = value
                    toggleFilter(editSetName, "_VendorSell", LF_VENDOR_SELL)
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_LABEL,
                tooltip = SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_TOOLTIP,
                getFunc = function() return editSetData.filterDeconstruction end,
                setFunc = function(value)
                    editSetData.filterDeconstruction = value
                    toggleFilter(editSetName, "_Deconstruct", LF_SMITHING_DECONSTRUCT)
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_LABEL,
                tooltip = SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_TOOLTIP,
                getFunc = function() return editSetData.filterResearch end,
                setFunc = function(value)
                    editSetData.filterResearch = value
                    toggleFilter(editSetName, "_Research", LF_SMITHING_RESEARCH)
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_FILTERS_GUILDSTORESELL_LABEL,
                tooltip = SI_ITEMSAVER_FILTERS_GUILDSTORESELL_TOOLTIP,
                getFunc = function() return editSetData.filterGuildStore end,
                setFunc = function(value)
                    editSetData.filterGuildStore = value
                    toggleFilter(editSetName, "_GuildStoreSell", LF_GUILDSTORE_SELL)
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_FILTERS_MAILSEND_LABEL,
                tooltip = SI_ITEMSAVER_FILTERS_MAILSEND_TOOLTIP,
                getFunc = function() return editSetData.filterMail end,
                setFunc = function(value)
                    editSetData.filterMail = value
                    toggleFilter(editSetName, "_MailSend", LF_MAIL_SEND)
                end,
                width = "half",
            },
            {
                type = "checkbox",
                name = SI_ITEMSAVER_FILTERS_TRADE_LABEL,
                tooltip = SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP,
                getFunc = function() return editSetData.filterTrade end,
                setFunc = function(value)
                    editSetData.filterTrade = value
                    toggleFilter(editSetName, "_Trade", LF_TRADE)
                end,
                width = "half",
            },
            {
                type = "button",
                name = SI_ITEMSAVER_CLEAR_SET_BUTTON,
                tooltip = SI_ITEMSAVER_CLEAR_SET_TOOLTIP,
                func = function() clearSet(editSetName) end,
                isDangerous = true,
            },
            {
                type = "button",
                name = SI_ITEMSAVER_DELETE_SET_BUTTON,
                tooltip = SI_ITEMSAVER_DELETE_SET_TOOLTIP,
                func = function()
                    vars.savedSetInfo[editSetName] = nil

                    clearSet(editSetName)

                    if setName == "Default" then
                        vars.shouldCreateDefault = false
                    end

                    editSetName = vars.defaultSet
                    editSetData = ItemSaver_GetSetData(vars.defaultSet)

                    WINDOW_MANAGER:GetControlByName("IS_DefaultSetDropdown"):UpdateValue()
                    WINDOW_MANAGER:GetControlByName("IS_EditSetDropdown"):UpdateValue()
                    updateEditSetSettings(vars.defaultSet)
                end,
                disabled = editSetName == vars.defaultSet,
                isDangerous = true,
                reference = "IS_DeleteButton",
            },
        }

        util.lam:RegisterAddonPanel("ItemSaverSettingsPanel", panel)
        util.lam:RegisterOptionControls("ItemSaverSettingsPanel", optionsData)
    end

    local defaults = {
        markerAnchor = TOPLEFT,
        offsetX = 0,
        offsetY = 0,
        savedSetInfo = {},
        savedItems = {},
        deferSubmenu = false,
        deferSubmenuNum = 3,
        defaultSet = "Default",
        shouldCreateDefault = true,
        keybindSetMap = {},
    }

    settings.vars = ZO_SavedVars:NewAccountWide("ItemSaver_Settings", 2.0, nil, defaults)
    vars = settings.vars

    if vars.shouldCreateDefault then
        vars.savedSetInfo["Default"] = {
            markerTexture = "Star",
            markerColor = util.RGBToHex(1, 1, 0),
            filterStore = true,
            filterDeconstruction = true,
            filterResearch = true,
            filterGuildStore = false,
            filterMail = false,
            filterTrade = false,
        }
        vars.shouldCreateDefault = false
    end

    toggleFilters()
    createOptionsMenu()
end

function settings.AddSet(setName, setData)
    if setName == "" or ItemSaver_GetSetData(setName) then
        return false
    end

    vars.savedSetInfo[setName] = setData
    toggleFilter(setName, "_VendorSell", LF_VENDOR_SELL)
    toggleFilter(setName, "_Deconstruct", LF_SMITHING_DECONSTRUCT)
    toggleFilter(setName, "_GuildStoreSell", LF_GUILDSTORE_SELL)
    toggleFilter(setName, "_MailSend", LF_MAIL_SEND)
    toggleFilter(setName, "_Trade", LF_TRADE)

    refreshSettingsPanelSetChoices()

    return true
end

function settings.GetDefaultSet()
    return vars.defaultSet
end

function settings.GetFilters(setName)
    local setData = ItemSaver_GetSetData(setName)

    if setData then
        return {
            store = setData.filterStore,
            deconstruction = setData.filterDeconstruction,
            research = setData.filterResearch,
            guildStore = setData.filterGuildStore,
            mail = setData.filterMail,
            trade = setData.filterTrade,
        }
    end
end

function settings.GetMarkerAnchor()
    return vars.markerAnchor, vars.offsetX, vars.offsetY
end

function settings.GetMarkerInfo(bagId, slotIndex)
    local uIdString = Id64ToString(GetItemUniqueId(bagId, slotIndex))
    local signedInstanceId = util.SignItemInstanceId(GetItemInstanceId(bagId, slotIndex))
    local _, setName = ItemSaver_IsItemSaved(bagId, slotIndex)

    if setName then
        local savedSet = ItemSaver_GetSetData(setName)

        return util.markerTextures[savedSet.markerTexture], util.HexToRGB(savedSet.markerColor)
    end

    return nil
end

function settings.GetSaveSets()
    local setNames = {}

    for setName, _ in pairs(vars.savedSetInfo) do
        table.insert(setNames, setName)
    end

    table.sort(setNames)

    return setNames
end

function settings.GetSetData(setName)
    return vars.savedSetInfo[setName]
end

function settings.GetSetNameByKeybindIndex(index)
    return vars.keybindSetMap[index]
end

function settings.IsItemSaved(bagId, slotIndex)
    local uIdString = Id64ToString(GetItemUniqueId(bagId, slotIndex))
    local signedInstanceId = util.SignItemInstanceId(GetItemInstanceId(bagId, slotIndex))

    if vars.savedItems[signedInstanceId] then
        local setData = ItemSaver_GetSetData(vars.savedItems[signedInstanceId])

        if not setData.areItemsUnique then
            return true, vars.savedItems[signedInstanceId]
        end
    elseif vars.savedItems[uIdString] then
        local setData = ItemSaver_GetSetData(vars.savedItems[uIdString])

        if setData.areItemsUnique then
            return true, vars.savedItems[uIdString]
        end
    end

    return false
end

function settings.IsSubmenuDeferred()
    if vars.deferSubmenu then
        return vars.deferSubmenu, vars.deferSubmenuNum
    end

    return vars.deferSubmenu
end

function settings.ToggleItemSave(setName, bagId, slotIndex)
    if type(setName) == "number" then
        setName = ItemSaver_GetSetNameByKeybindIndex(setName)
    end
    if not setName then
        local isSaved
        isSaved, setName = ItemSaver_IsItemSaved(bagId, slotIndex)

        if not isSaved then setName = ItemSaver_GetDefaultSet() end
    end

    local areItemsUnique = ItemSaver_GetSetData(setName).areItemsUnique or false
    local id

    if areItemsUnique then
        id = Id64ToString(GetItemUniqueId(bagId, slotIndex))
    else
        id = util.SignItemInstanceId(GetItemInstanceId(bagId, slotIndex))
    end

    if vars.savedItems[id] then
        vars.savedItems[id] = nil

        return false
    else
        vars.savedItems[id] = setName

        return true
    end
end