local IS = ItemSaver
IS.dialog = {}

local util = IS.util
local dialog = IS.dialog

function dialog.SetupDialog(self)
    local function acceptCallback()
        local function handleDialog(dialog)
            local markerTextures = ItemSaver_GetMarkerTextures()
            local editbox = ItemSaverDialogEditbox
            local saveTypeDropdown = ItemSaverDialogSaveTypeDropdown
            local iconpicker = ItemSaverDialogIconpicker
            local storeCheckbox = ItemSaverDialogStoreCheckbox
            local deconstructionCheckbox = ItemSaverDialogDeconstructionCheckbox
            local researchCheckbox = ItemSaverDialogResearchCheckbox
            local guildStoreCheckbox = ItemSaverDialogGuildStoreCheckbox
            local mailCheckbox = ItemSaverDialogMailCheckbox
            local tradeCheckbox = ItemSaverDialogTradeCheckbox
            local setName = editbox.editbox:GetText()
            local texturePath = iconpicker.icon:GetTextureFileName()
            local setData = {}

            local generalString = GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_GENERAL)
            local dropdownSelection = saveTypeDropdown.dropdown.m_selectedItemText:GetText()
            if dropdownSelection == generalString then
                setData.areItemsUnique = false
            else
                setData.areItemsUnique = true
            end

            for name, path in pairs(markerTextures) do
                if path == texturePath then
                    setData.markerTexture = name
                    break
                end
            end

            -- HotR temporary fix --setData.markerColor = util.RGBToHex(IS_COLOR_PICKER:GetColors())
            setData.markerColor = util.RGBToHex(1, 1, 0, 1)
            setData.filterStore = storeCheckbox.value
            setData.filterDeconstruction = deconstructionCheckbox.value
            setData.filterResearch = researchCheckbox.value
            setData.filterGuildStore = guildStoreCheckbox.value
            setData.filterMail = mailCheckbox.value
            setData.filterTrade = tradeCheckbox.value

            if ItemSaver_AddSet(setName, setData) then
                ItemSaver_ToggleItemSave(setName, dialog.data[1], dialog.data[2])
            end
        end

        local setName = ItemSaverDialogEditbox.editbox:GetText()
        local setExists = ItemSaver_GetFilters(setName)

        if setName == "" then
            d(GetString(SI_ITEMSAVER_MISSING_NAME_WARNING))
        elseif setExists then
            d(GetString(SI_ITEMSAVER_USED_NAME_WARNING))
        else
            handleDialog(self)
        end
    end

    local function setupDialog(dialog)
        ItemSaverDialogEditbox:UpdateValue()
        ItemSaverDialogSaveTypeDropdown:UpdateValue()
        ItemSaverDialogIconpicker:UpdateValue()

        --[[ HotR temporary fix
        local colorpicker = ItemSaverDialogColorpickerContent
        IS_COLOR_PICKER.initialR = 1
        IS_COLOR_PICKER.initialG = 1
        IS_COLOR_PICKER.initialB = 0
        IS_COLOR_PICKER:SetColor(1, 1, 0)
        IS_COLOR_PICKER.previewInitialTexture:SetColor(1, 1, 0)
        ]]

        ItemSaverDialogStoreCheckbox:UpdateValue()
        ItemSaverDialogDeconstructionCheckbox:UpdateValue()
        ItemSaverDialogResearchCheckbox:UpdateValue()
        ItemSaverDialogGuildStoreCheckbox:UpdateValue()
        ItemSaverDialogMailCheckbox:UpdateValue()
        ItemSaverDialogTradeCheckbox:UpdateValue()
    end

    local info = {
        customControl = self,
        setup = setupDialog,
        title = {
            text = SI_ITEMSAVER_ADDON_NAME,
        },
        buttons = {
            [1] = {
                control = GetControl(self, "Create"),
                text = SI_DIALOG_ACCEPT,
                callback = acceptCallback,
            },
            [2] = {
                control = GetControl(self, "Cancel"),
                text = SI_DIALOG_CANCEL,
            },
        },
    }

    ZO_Dialogs_RegisterCustomDialog("ITEMSAVER_SAVE", info)
end

function dialog.InitializeDialog()
    local markerTexturePaths, markerTextureNames = util.GetMarkerTextureArrays()

    local controlData = {
        ["editbox"] = {
            type = "editbox",
            name = GetString(SI_ITEMSAVER_SET_NAME_LABEL),
            tooltip = GetString(SI_ITEMSAVER_SET_NAME_TOOLTIP),
            getFunc = function() end,
            setFunc = function(text) end,
            isMultiline = false,
            width = "full",
        },
        ["saveTypeDropdown"] = {
            type = "dropdown",
            name = GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_LABEL),
            tooltip = GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_TOOLTIP),
            choices = {GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_GENERAL),
              GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_UNIQUE)},
            getFunc = function()
                return GetString(SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_GENERAL)
            end,
            setFunc = function(value) end,
            width = "full",
        },
        ["iconpicker"] = {
            type = "iconpicker",
            name = GetString(SI_ITEMSAVER_MARKER_LABEL),
            tooltip = GetString(SI_ITEMSAVER_MARKER_TOOLTIP),
            choices = markerTexturePaths,
            choicesTooltips = markerTextureNames,
            getFunc = function()
                return [[/esoui/art/campaign/overview_indexicon_bonus_disabled.dds]]
            end,
            setFunc = function(markerTexturePath) end,
            maxColumns = 5,
            visibleRows = zo_min(zo_max(zo_floor(#markerTexturePaths/5), 1), 4.5),
            iconSize = 32,
            defaultColor = ZO_ColorDef:New(1, 1, 0),
            width = "full",
        },
        ["header"] = {
            type = "header",
            name = GetString(SI_ITEMSAVER_SELECT_FILTERS_LABEL),
            width = "half",
        },
        ["checkbox"] = {
            type = "checkbox",
            getFunc = function() return false end,
            setFunc = function(value) end,
            width = "half",
        },
    }
    local function GetCheckboxData(str)
        local lookup = {
            ["store"] = {
                name = GetString(SI_ITEMSAVER_FILTERS_VENDORSELL_LABEL),
                tooltip = GetString(SI_ITEMSAVER_FILTERS_VENDORSELL_TOOLTIP),
            },
            ["deconstruction"] = {
                name = GetString(SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_LABEL),
                tooltip = GetString(SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_TOOLTIP),
            },
            ["research"] = {
                name = GetString(SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_LABEL),
                tooltip = GetString(SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_TOOLTIP),
            },
            ["guildStore"] = {
                name = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORESELL_LABEL),
                tooltip = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORESELL_TOOLTIP),
            },
            ["mail"] = {
                name = GetString(SI_ITEMSAVER_FILTERS_MAILSEND_LABEL),
                tooltip = GetString(SI_ITEMSAVER_FILTERS_MAILSEND_TOOLTIP),
            },
            ["trade"] = {
                name = GetString(SI_ITEMSAVER_FILTERS_TRADE_LABEL),
                tooltip = GetString(SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP),
            },
        }
        local t = controlData.checkbox
        t.name = lookup[str].name
        t.tooltip = lookup[str].tooltip

        return t
    end

    local parent = ItemSaverDialog

    --set so LAM doesn't break
    parent.data = parent.data or {}
    parent.data.registerForRefresh = false
    parent.data.registerForDefaults = false

    local editbox = LAMCreateControl["editbox"](parent, controlData.editbox, "ItemSaverDialogEditbox")
    local saveTypeDropdown = LAMCreateControl["dropdown"](parent, controlData.saveTypeDropdown, "ItemSaverDialogSaveTypeDropdown")
    local iconpicker = LAMCreateControl["iconpicker"](parent, controlData.iconpicker, "ItemSaverDialogIconpicker")
    -- HotR temporary fix --local colorpicker = WINDOW_MANAGER:CreateControlFromVirtual("ItemSaverDialogColorpicker", parent, "IS_ColorPickerControl"):GetNamedChild("Content")
    local header = LAMCreateControl["header"](parent, controlData.header, "ItemSaverDialogHeader")
    local storeCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("store"), "ItemSaverDialogStoreCheckbox")
    local deconstructionCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("deconstruction"), "ItemSaverDialogDeconstructionCheckbox")
    local researchCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("research"), "ItemSaverDialogResearchCheckbox")
    local guildStoreCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("guildStore"), "ItemSaverDialogGuildStoreCheckbox")
    local mailCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("mail"), "ItemSaverDialogMailCheckbox")
    local tradeCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("trade"), "ItemSaverDialogTradeCheckbox")

    editbox:SetAnchor(TOPLEFT, ItemSaverDialogDivider, LEFT, 75, 16)
    saveTypeDropdown:SetAnchor(TOPLEFT, editbox, BOTTOMLEFT, 0, 16)
    iconpicker:SetAnchor(TOPLEFT, saveTypeDropdown, BOTTOMLEFT, 0, 16)
    -- HotR temporary fix --colorpicker:SetAnchor(TOP, iconpicker, BOTTOM, 0, 16)
    header:SetAnchor(TOPLEFT, iconpicker, BOTTOMLEFT, 0, 240)
    storeCheckbox:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 16)
    deconstructionCheckbox:SetAnchor(TOPLEFT, storeCheckbox, TOPRIGHT, 16)
    researchCheckbox:SetAnchor(TOPLEFT, storeCheckbox, BOTTOMLEFT, 0, 16)
    guildStoreCheckbox:SetAnchor(TOPLEFT, researchCheckbox, TOPRIGHT, 16)
    mailCheckbox:SetAnchor(TOPLEFT, researchCheckbox, BOTTOMLEFT, 0, 16)
    tradeCheckbox:SetAnchor(TOPLEFT, mailCheckbox, TOPRIGHT, 16)

    --prehook to change marker texture color
    --[[ HotR temporary fix
    local oldOnColorSet = IS_COLOR_PICKER.OnColorSet
    IS_COLOR_PICKER.OnColorSet = function(IS_COLOR_PICKER, r, g, b)
        iconpicker.icon.color.r = r
        iconpicker.icon.color.g = g
        iconpicker.icon.color.b = b
        iconpicker:SetColor(iconpicker.icon.color)

        oldOnColorSet(IS_COLOR_PICKER, r, g, b)
    end
    ]]
end