local IS = ItemSaver
IS.settings = {}

local util = IS.util
local settings = IS.settings
local vars

local function toggleFilter(setName, filterTagSuffix, filterType)
	local filterTag = "ItemSaver_"..setName..filterTagSuffix
	local isRegistered = util.libFilters:IsFilterRegistered(filterTag, filterType)

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
		util.libFilters:RegisterFilter(filterTag, filterType, filterCallback)
	else
		util.libFilters:UnregisterFilter(filterTag, filterType)
	end
end

local function toggleFilters()
	for setName, setInfo in pairs(vars.savedSetInfo) do
		if setInfo.filterStore then toggleFilter(setName, "_Store", LAF_STORE) end
		if setInfo.filterDeconstruction then toggleFilter(setName, "_Deconstruction", LAF_DECONSTRUCTION) end
		if setInfo.filterGuildStore then toggleFilter(setName, "_GuildStore", LAF_GUILDSTORE) end
		if setInfo.filterMail then toggleFilter(setName, "_Mail", LAF_MAIL) end
		if setInfo.filterTrade then toggleFilter(setName, "_Trade", LAF_TRADE) end
	end
end

function settings.InitializeSettings()
	local function createOptionsMenu()
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

		local panel = {
			type = "panel",
			name = "Item Saver",
			author = "Randactyl, ingeniousclown",
			version = IS.addonVersion,
			slashCommand = "/itemsaver",
			registerForRefresh = true,
		}

		local optionsData = {
			[1] = {
				type = "header",
				name = GetString(SI_ITEMSAVER_GENERAL_OPTIONS_HEADER),
			},
			[2] = {
				type = "dropdown",
				name = GetString(SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_LABEL),
				tooltip = GetString(SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_TOOLTIP),
				choices = ItemSaver_GetSaveSets(),
				getFunc = function() return vars.defaultSet end,
				setFunc = function(value)
					WINDOW_MANAGER:GetControlByName("IS_" .. vars.defaultSet .. "DeleteButton").data.disabled = false
					WINDOW_MANAGER:GetControlByName("IS_" .. value .. "DeleteButton").data.disabled = true

					vars.defaultSet = value
				end,
			},
			[3] = {
				type = "dropdown",
				name = GetString(SI_ITEMSAVER_MARKER_ANCHOR_LABEL),
				tooltip = GetString(SI_ITEMSAVER_MARKER_ANCHOR_TOOLTIP),
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
			[4] = {
				type = "checkbox",
				name = GetString(SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_LABEL),
				tooltip = GetString(SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_TOOLTIP),
				getFunc = function() return vars.deferSubmenu end,
				setFunc = function(value)
					vars.deferSubmenu = value
					local dropdown = WINDOW_MANAGER:GetControlByName("IS_DeferSubmenuDropdown")
					dropdown.data.disabled = not value
				end,
				width = "half",
			},
			[5] = {
				type = "dropdown",
				name = GetString(SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_LABEL),
				tooltip = GetString(SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_TOOLTIP),
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
			[6] = {
				type = "header",
				name = GetString(SI_ITEMSAVER_SET_DATA_HEADER),
			},
		}

		local markerTexturePaths, markerTextureNames = util.GetMarkerTextureArrays()

		for setName, setData in util.PairsByKeys(vars.savedSetInfo) do
			local submenuData = {
				type = "submenu",
				name = setName,
				tooltip = nil,
				controls = {
					[1] = {
						type = "iconpicker",
						name = GetString(SI_ITEMSAVER_MARKER_LABEL),
						tooltip = GetString(SI_ITEMSAVER_MARKER_TOOLTIP),
						choices = markerTexturePaths,
						choicesTooltips = markerTextureNames,
						getFunc = function()
							local markerTextureName = setData.markerTexture

							for i, name in ipairs(markerTextureNames) do
								if name == markerTextureName then
									return markerTexturePaths[i]
								end
							end
						end,
						setFunc = function(markerTexturePath)
							for i, path in ipairs(markerTexturePaths) do
								if path == markerTexturePath then
									setData.markerTexture = markerTextureNames[i]
								end
							end
						end,
						maxColumns = 5,
						visibleRows = zo_min(zo_max(zo_floor(#markerTexturePaths/5), 1), 4.5),
						iconSize = 32,
						defaultColor = ZO_ColorDef:New(util.HexToRGB(setData.markerColor)),
						width = "half",
						reference = "IS_" .. setName .. "IconPicker",
					},
					[2] = {
						type = "colorpicker",
						name = GetString(SI_ITEMSAVER_TEXTURE_COLOR_LABEL),
						tooltip = GetString(SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP),
						getFunc = function()
							return util.HexToRGB(setData.markerColor)
						end,
						setFunc = function(r, g, b)
							local iconPicker = WINDOW_MANAGER:GetControlByName("IS_"..setName.."IconPicker")
							iconPicker.icon.color.r = r
							iconPicker.icon.color.g = g
							iconPicker.icon.color.b = b
							iconPicker:SetColor(iconPicker.icon.color)

							setData.markerColor = util.RGBToHex(r, g, b)
						end,
						width = "half",
					},
					[3] = {
						type = "checkbox",
						name = GetString(SI_ITEMSAVER_FILTERS_STORE_LABEL),
						tooltip = GetString(SI_ITEMSAVER_FILTERS_STORE_TOOLTIP),
						getFunc = function() return setData.filterStore end,
						setFunc = function(value)
							setData.filterStore = value
							toggleFilter(setName, "_Store", LAF_STORE)
						end,
						width = "half",
					},
					[4] = {
						type = "checkbox",
						name = GetString(SI_ITEMSAVER_FILTERS_DECONSTRUCTION_LABEL),
						tooltip = GetString(SI_ITEMSAVER_FILTERS_DECONSTRUCTION_TOOLTIP),
						getFunc = function() return setData.filterDeconstruction end,
						setFunc = function(value)
							setData.filterDeconstruction = value
							toggleFilter(setName, "_Deconstruction", LAF_DECONSTRUCTION)
						end,
						width = "half",
					},
					[5] = {
						type = "checkbox",
						name = GetString(SI_ITEMSAVER_FILTERS_RESEARCH_LABEL),
						tooltip = GetString(SI_ITEMSAVER_FILTERS_RESEARCH_TOOLTIP),
						getFunc = function() return setData.filterResearch end,
						setFunc = function(value)
							setData.filterResearch = value
						end,
						width = "half",
					},
					[6] = {
						type = "checkbox",
						name = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORE_LABEL),
						tooltip = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORE_TOOLTIP),
						getFunc = function() return setData.filterGuildStore end,
						setFunc = function(value)
							setData.filterGuildStore = value
							toggleFilter(setName, "_GuildStore", LAF_GUILDSTORE)
						end,
						width = "half",
					},
					[7] = {
						type = "checkbox",
						name = GetString(SI_ITEMSAVER_FILTERS_MAIL_LABEL),
						tooltip = GetString(SI_ITEMSAVER_FILTERS_MAIL_TOOLTIP),
						getFunc = function() return setData.filterMail end,
						setFunc = function(value)
							setData.filterMail = value
							toggleFilter(setName, "_Mail", LAF_MAIL)
						end,
						width = "half",
					},
					[8] = {
						type = "checkbox",
						name = GetString(SI_ITEMSAVER_FILTERS_TRADE_LABEL),
						tooltip = GetString(SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP),
						getFunc = function() return setData.filterTrade end,
						setFunc = function(value)
							setData.filterTrade = value
							toggleFilter(setName, "_Trade", LAF_TRADE)
						end,
						width = "half",
					},
					[9] = {
						type = "button",
						name = GetString(SI_ITEMSAVER_CLEAR_SET_BUTTON),
						tooltip = GetString(SI_ITEMSAVER_CLEAR_SET_TOOLTIP),
						func = function()
							for savedItem, name in pairs(vars.savedItems) do
								if name == setName then
									vars.savedItems[savedItem] = nil
								end
							end

							d(GetString(SI_ITEMSAVER_CLEAR_SET_CONFIRMATION) .. " " .. setName)
						end,
					},
					[10] = {
						type = "button",
						name = GetString(SI_ITEMSAVER_DELETE_SET_BUTTON),
						tooltip = GetString(SI_ITEMSAVER_DELETE_SET_TOOLTIP),
						warning = GetString(SI_ITEMSAVER_RELOAD_UI_WARNING),
						func = function()
							vars.savedSetInfo[setName] = nil

							for savedItem, name in pairs(vars.savedItems) do
								if name == setName then
									vars.savedItems[savedItem] = vars.defaultSet
								end
							end

							if setName == "Default" then
								vars.shouldCreateDefault = false
							end

							ReloadUI()
						end,
						disabled = setName == vars.defaultSet,
						reference = "IS_" .. setName .. "DeleteButton",
					},
				},
			}
			table.insert(optionsData, submenuData)
		end

		util.lam:RegisterAddonPanel("ItemSaverSettingsPanel", panel)
		util.lam:RegisterOptionControls("ItemSaverSettingsPanel", optionsData)
	end

	local defaults = {
		markerAnchor = TOPLEFT,
		savedSetInfo = {},
		savedItems = {},
		deferSubmenu = false,
		deferSubmenuNum = 3,
		defaultSet = "Default",
		shouldCreateDefault = true,
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
	if setName == "" or vars.savedSetInfo[setName] then
		return false
	end

	vars.savedSetInfo[setName] = setData
	toggleFilter(setName, "_Store", LAF_STORE)
	toggleFilter(setName, "_Deconstruction", LAF_DECONSTRUCTION)
	toggleFilter(setName, "_GuildStore", LAF_GUILDSTORE)
	toggleFilter(setName, "_Mail", LAF_MAIL)
	toggleFilter(setName, "_Trade", LAF_TRADE)

	return true
end

function settings.GetFilters(setName)
	local setData = vars.savedSetInfo[setName]

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
	return vars.markerAnchor
end

function settings.GetMarkerInfo(bagId, slotIndex)
	local uIdString = Id64ToString(GetItemUniqueId(bagId, slotIndex))
	local setName = vars.savedItems[uIdString]

	if setName then
		local savedSet = vars.savedSetInfo[setName]

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

function settings.IsItemSaved(bagIdOrUniqueId, slotIndex)
	local uIdString

	if not slotIndex then --uniqueId
		uIdString = Id64ToString(bagIdOrUniqueId)
	else --bagId
		uIdString = Id64ToString(GetItemUniqueId(bagIdOrUniqueId, slotIndex))
	end

	if vars.savedItems[uIdString] then
		return true, vars.savedItems[uIdString]
	end

	return false
end

function settings.IsSubmenuDeferred()
	if vars.deferSubmenu then
		return vars.deferSubmenu, vars.deferSubmenuNum
	end

	return vars.deferSubmenu
end

function settings.ToggleItemSave(setName, bagIdOrUniqueId, slotIndex)
	if not setName then setName = vars.defaultSet end

	local uIdString

	if not slotIndex then --uniqueId
		uIdString = Id64ToString(bagIdOrUniqueId)
	else --bagId
		uIdString = Id64ToString(GetItemUniqueId(bagIdOrUniqueId, slotIndex))
	end

	if vars.savedItems[uIdString] then
		vars.savedItems[uIdString] = nil

		return false
	else
		vars.savedItems[uIdString] = setName

		return true
	end
end