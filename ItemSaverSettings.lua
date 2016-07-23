ItemSaverSettings = ZO_Object:Subclass()

local TEXTURE_SIZE = 32
local SIGNED_INT_MAX = 2^32 / 2 - 1
local INT_MAX = 2^32
local DEFER_SUBMENU_OPTIONS = {"1", "2", "3", "4", "5"}
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

local lam = LibStub("LibAddonMenu-2.0")
local libFilters = LibStub("libFilters")
local markerTextures = {}
local markerOptions = {}
local settings = nil
local addonVersion = "2.4.0.0"

-----------------------------
--UTIL FUNCTIONS
-----------------------------
local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0

	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function HexToRGB(hex)
    local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)
	
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

local function SignItemId(itemId)
	if itemId and itemId > SIGNED_INT_MAX then
		itemId = itemId - INT_MAX
	end

	return itemId
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

local function ToggleFilter(setName, filterTagSuffix, filterType)
	local filterTag = "ItemSaver_"..setName..filterTagSuffix
	local isRegistered = libFilters:IsFilterRegistered(filterTag, filterType)

	local function filterCallback(slot)
        local bagId, slotIndex = GetInfoFromRowControl(slot)
        local _, savedSet = ItemSaver_IsItemSaved(bagId, slotIndex)

        return not (savedSet == setName)
	end

	if not isRegistered then
		libFilters:RegisterFilter(filterTag, filterType, filterCallback)
	else
		libFilters:UnregisterFilter(filterTag, filterType)
	end
end

local function ToggleFilters()
	for setName, setInfo in pairs(settings.savedSetInfo) do
		if setInfo.filterStore then ToggleFilter(setName, "_Store", LAF_STORE) end
		if setInfo.filterDeconstruction then ToggleFilter(setName, "_Deconstruction", LAF_DECONSTRUCTION) end
		if setInfo.filterGuildStore then ToggleFilter(setName, "_GuildStore", LAF_GUILDSTORE) end
		if setInfo.filterMail then ToggleFilter(setName, "_Mail", LAF_MAIL) end
		if setInfo.filterTrade then ToggleFilter(setName, "_Trade", LAF_TRADE) end
	end
end

------------------------------
--OBJECT FUNCTIONS
------------------------------
function ItemSaverSettings:New()
	local obj = ZO_Object.New(self)
	obj:Initialize()
	return obj
end

function ItemSaverSettings:Initialize()
	local defaults = {
		markerAnchor = TOPLEFT,
		savedSetInfo = {},
		savedItems = {},
		deferSubmenu = false,
		deferSubmenuNum = 3,
		defaultSet = "Default",
		shouldCreateDefault = true,
	}

	settings = ZO_SavedVars:NewAccountWide("ItemSaver_Settings", 2.0, nil, defaults)

	if settings.shouldCreateDefault then
		settings.savedSetInfo["Default"] = {
			markerTexture = "Star",
			markerColor = RGBToHex(1, 1, 0),
			filterStore = true,
			filterDeconstruction = true,
			filterResearch = true,
			filterGuildStore = false,
			filterMail = false,
			filterTrade = false,
		}
		settings.shouldCreateDefault = false
	end

	ToggleFilters()

    self:CreateOptionsMenu()
end

function ItemSaverSettings:CreateOptionsMenu()
	local panel = {
		type = "panel",
		name = "Item Saver",
		author = "Randactyl, ingeniousclown",
		version = addonVersion,
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
			choices = self.GetSaveSets(),
			getFunc = function() return settings.defaultSet end,
			setFunc = function(value)
				WINDOW_MANAGER:GetControlByName("IS_" .. settings.defaultSet .. "DeleteButton").data.disabled = false
				WINDOW_MANAGER:GetControlByName("IS_" .. value .. "DeleteButton").data.disabled = true

				settings.defaultSet = value
			end,
		},
		[3] = {
			type = "dropdown",
			name = GetString(SI_ITEMSAVER_MARKER_ANCHOR_LABEL),
			tooltip = GetString(SI_ITEMSAVER_MARKER_ANCHOR_TOOLTIP),
			choices = ANCHOR_OPTIONS,
			getFunc = function()
				local anchor = settings.markerAnchor
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
				if value == ANCHOR_OPTIONS[1] then settings.markerAnchor = TOPLEFT end
				if value == ANCHOR_OPTIONS[2] then settings.markerAnchor = TOP end
				if value == ANCHOR_OPTIONS[3] then settings.markerAnchor = TOPRIGHT end
				if value == ANCHOR_OPTIONS[4] then settings.markerAnchor = RIGHT end
				if value == ANCHOR_OPTIONS[5] then settings.markerAnchor = BOTTOMRIGHT end
				if value == ANCHOR_OPTIONS[6] then settings.markerAnchor = BOTTOM end
				if value == ANCHOR_OPTIONS[7] then settings.markerAnchor = BOTTOMLEFT end
				if value == ANCHOR_OPTIONS[8] then settings.markerAnchor = LEFT end
				if value == ANCHOR_OPTIONS[9] then settings.markerAnchor = CENTER end
			end,
		},
		[4] = {
			type = "checkbox",
			name = GetString(SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_LABEL),
			tooltip = GetString(SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_TOOLTIP),
			getFunc = function() return settings.deferSubmenu end,
			setFunc = function(value)
				settings.deferSubmenu = value
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
				local num = settings.deferSubmenuNum
				if num == 1 then return DEFER_SUBMENU_OPTIONS[1] end
				if num == 2 then return DEFER_SUBMENU_OPTIONS[2] end
				if num == 3 then return DEFER_SUBMENU_OPTIONS[3] end
				if num == 4 then return DEFER_SUBMENU_OPTIONS[4] end
				if num == 5 then return DEFER_SUBMENU_OPTIONS[5] end
			end,
			setFunc = function(value)
				if value == DEFER_SUBMENU_OPTIONS[1] then settings.deferSubmenuNum = 1 end
				if value == DEFER_SUBMENU_OPTIONS[2] then settings.deferSubmenuNum = 2 end
				if value == DEFER_SUBMENU_OPTIONS[3] then settings.deferSubmenuNum = 3 end
				if value == DEFER_SUBMENU_OPTIONS[4] then settings.deferSubmenuNum = 4 end
				if value == DEFER_SUBMENU_OPTIONS[5] then settings.deferSubmenuNum = 5 end
			end,
			width = "half",
			disabled = not settings.deferSubmenu,
			reference = "IS_DeferSubmenuDropdown",
		},
		[6] = {
			type = "header",
			name = GetString(SI_ITEMSAVER_SET_DATA_HEADER),
		},
	}

	local function getMarkerTextureArrays()
		local arr1, arr2 = {}, {}
		for name, path in pairsByKeys(markerTextures) do
			table.insert(arr1, path)
			table.insert(arr2, name)
		end

		return arr1, arr2
	end

	for setName, setData in pairsByKeys(settings.savedSetInfo) do
		local markerTexturePaths, markerTextureNames = getMarkerTextureArrays()

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
					defaultColor = ZO_ColorDef:New(HexToRGB(setData.markerColor)),
					width = "half",
					reference = "IS_" .. setName .. "IconPicker",
				},
				[2] = {
					type = "colorpicker",
					name = GetString(SI_ITEMSAVER_TEXTURE_COLOR_LABEL),
					tooltip = GetString(SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP),
					getFunc = function()
						local r, g, b = HexToRGB(setData.markerColor)
						return r, g, b
					end,
					setFunc = function(r, g, b)
						local iconPicker = WINDOW_MANAGER:GetControlByName("IS_"..setName.."IconPicker")
						iconPicker.icon.color.r = r
						iconPicker.icon.color.g = g
						iconPicker.icon.color.b = b
						iconPicker:SetColor(iconPicker.icon.color)

						setData.markerColor = RGBToHex(r, g, b)
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
						ToggleFilter(setName, "_Store", LAF_STORE)
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
						ToggleFilter(setName, "_Deconstruction", LAF_DECONSTRUCTION)
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
						ToggleFilter(setName, "_GuildStore", LAF_GUILDSTORE)
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
						ToggleFilter(setName, "_Mail", LAF_MAIL)
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
						ToggleFilter(setName, "_Trade", LAF_TRADE)
					end,
					width = "half",
				},
				[9] = {
					type = "button",
					name = GetString(SI_ITEMSAVER_CLEAR_SET_BUTTON),
					tooltip = GetString(SI_ITEMSAVER_CLEAR_SET_TOOLTIP),
					func = function()
						for savedItem, name in pairs(settings.savedItems) do
							if name == setName then
								settings.savedItems[savedItem] = nil
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
						settings.savedSetInfo[setName] = nil

						for savedItem, name in pairs(settings.savedItems) do
							if name == setName then
								settings.savedItems[savedItem] = settings.defaultSet
							end
						end

						if setName == "Default" then
							settings.shouldCreateDefault = false
						end

						ReloadUI()
					end,
					disabled = setName == settings.defaultSet,
					reference = "IS_" .. setName .. "DeleteButton",
				},
			},
		}
		table.insert(optionsData, submenuData)
	end

	lam:RegisterAddonPanel("ItemSaverSettingsPanel", panel)
	lam:RegisterOptionControls("ItemSaverSettingsPanel", optionsData)
end

function ItemSaverSettings:GetMarkerAnchor()
	return settings.markerAnchor
end

function ItemSaverSettings:GetMarkerInfo(bagId, slotIndex)
	local signedId = SignItemId(GetItemInstanceId(bagId, slotIndex))
	local setName = settings.savedItems[signedId]

	if setName then
		local savedSet = settings.savedSetInfo[setName]

		return markerTextures[savedSet.markerTexture], HexToRGB(savedSet.markerColor)
	end

	return nil
end

function ItemSaverSettings:IsItemSaved(bagIdOrItemId, slotIndex)
	local signedId

	if not slotIndex then --itemId
		signedId = SignItemId(bagIdOrItemId)
	else --bagId
		signedId = SignItemId(GetItemInstanceId(bagIdOrItemId, slotIndex))
	end

	if settings.savedItems[signedId] then
		return true, settings.savedItems[signedId]
	end

	return false
end

function ItemSaverSettings:ToggleItemSave(setName, bagIdOrItemId, slotIndex)
	if not setName then setName = settings.defaultSet end

	local signedId

	if not slotIndex then --itemId
		signedId = SignItemId(bagIdOrItemId)
	else --bagId
		signedId = SignItemId(GetItemInstanceId(bagIdOrItemId, slotIndex))
	end

	if settings.savedItems[signedId] then
		settings.savedItems[signedId] = nil

		return false
	else
		settings.savedItems[signedId] = setName

		return true
	end
end

function ItemSaverSettings:GetFilters(setName)
	local setData = settings.savedSetInfo[setName]

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

function ItemSaverSettings:GetMarkerOptions()
	return markerOptions
end

function ItemSaverSettings:GetMarkerTextures()
	return markerTextures
end

function ItemSaverSettings:GetSaveSets()
	local setNames = {}

	for setName, _ in pairs(settings.savedSetInfo) do
		table.insert(setNames, setName)
	end

	table.sort(setNames)

	return setNames
end

function ItemSaverSettings:GetSubmenuDeferredStatus()
	if settings.deferSubmenu then
		return settings.deferSubmenu, settings.deferSubmenuNum
	end

	return settings.deferSubmenu
end

function ItemSaverSettings:AddSet(setName, setData)
	if setName == "" or settings.savedSetInfo[setName] then
		return false
	end

	settings.savedSetInfo[setName] = setData
	ToggleFilter(setName, "_Store", LAF_STORE)
	ToggleFilter(setName, "_Deconstruction", LAF_DECONSTRUCTION)
	ToggleFilter(setName, "_GuildStore", LAF_GUILDSTORE)
	ToggleFilter(setName, "_Mail", LAF_MAIL)
	ToggleFilter(setName, "_Trade", LAF_TRADE)

	return true
end

--returns true if the marker was successfully registered, false if it was not.
function ItemSaver_RegisterMarker(markerInformation)
	local markerName = markerInformation.markerName

	if markerTextures[markerName] then
		return false
	end

	markerTextures[markerName] = markerInformation.texturePath
	table.insert(markerOptions, markerName)

	return true
end