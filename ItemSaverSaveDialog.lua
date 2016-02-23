local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function handleDialog(dialog)
	local MARKER_TEXTURES = ItemSaver_GetMarkerTextures()
	
    local editbox = ItemSaverDialogEditbox
    local iconpicker = ItemSaverDialogIconpicker
    local colorpicker = ItemSaverDialogColorpicker
    local storeCheckbox = ItemSaverDialogStoreCheckbox
    local deconstructionCheckbox = ItemSaverDialogDeconstructionCheckbox
    local researchCheckbox = ItemSaverDialogResearchCheckbox
    local guildStoreCheckbox = ItemSaverDialogGuildStoreCheckbox
    local mailCheckbox = ItemSaverDialogMailCheckbox
    local tradeCheckbox = ItemSaverDialogTradeCheckbox

	local setName = editbox.editbox:GetText()
	local setData = {}

	local texturePath = iconpicker.icon:GetTextureFileName()
	for name, path in pairs(MARKER_TEXTURES) do
		if path == texturePath then
			setData.markerTexture = name
		end
	end
    setData.markerColor = RGBToHex(iconpicker.icon.color:UnpackRGBA())

    setData.filterStore = storeCheckbox.value
    setData.filterDeconstruction = deconstructionCheckbox.value
    setData.filterResearch = researchCheckbox.value
	setData.filterGuildStore = guildStoreCheckbox.value
	setData.filterMail = mailCheckbox.value
	setData.filterTrade = tradeCheckbox.value

    ItemSaver_AddSet(setName, setData)
	ItemSaver_ToggleItemSave(setName, dialog.data[1], dialog.data[2])
end

local function SetupDialog(dialog)
	ItemSaverDialogEditbox:UpdateValue()
	ItemSaverDialogIconpicker:UpdateValue()
	ItemSaverDialogColorpicker:UpdateValue()
	ItemSaverDialogStoreCheckbox:UpdateValue()
	ItemSaverDialogDeconstructionCheckbox:UpdateValue()
	ItemSaverDialogResearchCheckbox:UpdateValue()
	ItemSaverDialogGuildStoreCheckbox:UpdateValue()
	ItemSaverDialogMailCheckbox:UpdateValue()
	ItemSaverDialogTradeCheckbox:UpdateValue()
end

function ItemSaver_SetupDialog(self)
    local info = {
        customControl = self,
        setup = SetupDialog,
        title = {
            text = SI_ITEMSAVER_ADDON_NAME,
        },
        buttons = {
            [1] = {
                control = GetControl(self, "Create"),
                text = SI_DIALOG_ACCEPT,
                callback = function(self)
					local setName = ItemSaverDialogEditbox.editbox:GetText()
					local setExists = ItemSaver_GetFilters(setName)
					if setName == "" then
						d(GetString(SI_ITEMSAVER_MISSING_NAME_WARNING))
					elseif setExists then
						d(GetString(SI_ITEMSAVER_USED_NAME_WARNING))
					else
						handleDialog(self)
					end
                end,
            },
            [2] = {
                control = GetControl(self, "Cancel"),
                text = SI_DIALOG_CANCEL,
            },
        }
    }

    ZO_Dialogs_RegisterCustomDialog("ITEMSAVER_SAVE", info)
end

function ItemSaver_InitializeDialog()
	local MARKER_TEXTURES = ItemSaver_GetMarkerTextures()
	local function pairsByKeys(t)
		local a = {}
		for n in pairs(t) do table.insert(a, n) end
		table.sort(a)
		local i = 0
		local iter = function()
			i = i + 1
			if a[i] == nil then return nil
			else return a[i], t[a[i]]
			end
		end
		return iter
	end
	local function getMarkerTextureArrays()
		local arr1, arr2 = {}, {}
		for name, path in pairsByKeys(MARKER_TEXTURES) do
			table.insert(arr1, path)
			table.insert(arr2, name)
		end

		return arr1, arr2
	end
	local markerTexturePaths, markerTextureNames = getMarkerTextureArrays()

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
			visibleRows = zo_min(zo_max(zo_floor(#MARKER_TEXTURES/5), 1), 4.5),
			iconSize = 32,
			defaultColor = ZO_ColorDef:New(1, 1, 0),
			width = "half",
		},
		["colorpicker"] = {
			type = "colorpicker",
			name = GetString(SI_ITEMSAVER_TEXTURE_COLOR_LABEL),
			tooltip = GetString(SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP),
			getFunc = function() return 1, 1, 0 end,
			setFunc = function(r, g, b)
				local iconPicker = WINDOW_MANAGER:GetControlByName("ItemSaverDialogIconpicker")
				iconPicker.icon.color.r = r
				iconPicker.icon.color.g = g
				iconPicker.icon.color.b = b
				iconPicker:SetColor(iconPicker.icon.color)
			end,
			width = "half",
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
				name = GetString(SI_ITEMSAVER_FILTERS_STORE_LABEL),
				tooltip = GetString(SI_ITEMSAVER_FILTERS_STORE_TOOLTIP),
			},
			["deconstruction"] = {
				name = GetString(SI_ITEMSAVER_FILTERS_DECONSTRUCTION_LABEL),
				tooltip = GetString(SI_ITEMSAVER_FILTERS_DECONSTRUCTION_TOOLTIP),
			},
			["research"] = {
				name = GetString(SI_ITEMSAVER_FILTERS_RESEARCH_LABEL),
				tooltip = GetString(SI_ITEMSAVER_FILTERS_RESEARCH_TOOLTIP),
			},
			["guildStore"] = {
				name = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORE_LABEL),
				tooltip = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORE_TOOLTIP),
			},
			["mail"] = {
				name = GetString(SI_ITEMSAVER_FILTERS_MAIL_LABEL),
				tooltip = GetString(SI_ITEMSAVER_FILTERS_MAIL_TOOLTIP),
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
	local iconpicker = LAMCreateControl["iconpicker"](parent, controlData.iconpicker, "ItemSaverDialogIconpicker")
	local colorpicker = LAMCreateControl["colorpicker"](parent, controlData.colorpicker, "ItemSaverDialogColorpicker")
	local header = LAMCreateControl["header"](parent, controlData.header, "ItemSaverDialogHeader")
	local storeCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("store"), "ItemSaverDialogStoreCheckbox")
	local deconstructionCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("deconstruction"), "ItemSaverDialogDeconstructionCheckbox")
	local researchCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("research"), "ItemSaverDialogResearchCheckbox")
	local guildStoreCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("guildStore"), "ItemSaverDialogGuildStoreCheckbox")
	local mailCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("mail"), "ItemSaverDialogMailCheckbox")
	local tradeCheckbox = LAMCreateControl["checkbox"](parent, GetCheckboxData("trade"), "ItemSaverDialogTradeCheckbox")

	editbox:SetAnchor(TOPLEFT, ItemSaverDialogDivider, LEFT, 75, 16)
	iconpicker:SetAnchor(TOPLEFT, editbox, BOTTOMLEFT, 0, 16)
	colorpicker:SetAnchor(TOPLEFT, iconpicker, TOPRIGHT, 16)
	header:SetAnchor(TOPLEFT, iconpicker, BOTTOMLEFT, 0, 48)
	storeCheckbox:SetAnchor(TOPLEFT, header, BOTTOMLEFT, 0, 16)
	deconstructionCheckbox:SetAnchor(TOPLEFT, storeCheckbox, TOPRIGHT, 16)
	researchCheckbox:SetAnchor(TOPLEFT, storeCheckbox, BOTTOMLEFT, 0, 16)
	guildStoreCheckbox:SetAnchor(TOPLEFT, researchCheckbox, TOPRIGHT, 16)
	mailCheckbox:SetAnchor(TOPLEFT, researchCheckbox, BOTTOMLEFT, 0, 16)
	tradeCheckbox:SetAnchor(TOPLEFT, mailCheckbox, TOPRIGHT, 16)
end
