ItemSaverSettings = ZO_Object:Subclass()

local LAM = LibStub("LibAddonMenu-2.0")
local libFilters = LibStub("libFilters")

local MARKER_TEXTURES = {}
local MARKER_OPTIONS = {}
local TEXTURE_SIZE = 32
local ANCHOR_OPTIONS = { "Top left", "Top right", "Bottom left", "Bottom right", }
local SIGNED_INT_MAX = 2^32 / 2 - 1
local INT_MAX = 2^32
local DEFER_SUBMENU_OPTIONS = { "1", "2", "3", "4", "5", }

local settings = nil

local addonVersion = "2.0.2.1"
-----------------------------
--UTIL FUNCTIONS
-----------------------------
local function RGBAToHex(r, g, b, a)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255)
end

local function HexToRGBA(hex)
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255, tonumber(ahex, 16)/255
end

local function SignItemId(itemId)
	if itemId and itemId > SIGNED_INT_MAX then
		itemId = itemId - INT_MAX
	end
	return itemId
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

local function FilterSavedItemsForStore(slotOrBagId, slotIndex)
	local bagId, saved, filtered

	if slotIndex == nil then
		bagId, slotIndex = GetInfoFromRowControl(slotOrBagId)
	else
		bagId = slotOrBagId
	end

	--will be set name if saved
	saved = settings.savedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]

	if saved then
		filtered = settings.savedSetInfo[saved].filterStore
		if filtered == true then
			return false
		end
	end
	return true
end

local function FilterSavedItemsForDeconstruction(slotOrBagId, slotIndex)
	local bagId, saved, filtered

	if slotIndex == nil then
		bagId, slotIndex = GetInfoFromRowControl(slotOrBagId)
	else
		bagId = slotOrBagId
	end

	--will be set name if saved
	saved = settings.savedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]

	if saved then
		filtered = settings.savedSetInfo[saved].filterDeconstruction
		if filtered == true then
			return false
		end
	end
	return true
end

local function FilterSavedItemsForGuildStore(slotOrBagId, slotIndex)
	local bagId, saved, filtered

	if slotIndex == nil then
		bagId, slotIndex = GetInfoFromRowControl(slotOrBagId)
	else
		bagId = slotOrBagId
	end

	--will be set name if saved
	saved = settings.savedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]

	if saved then
		filtered = settings.savedSetInfo[saved].filterGuildStore
		if filtered == true then
			return false
		end
	end
	return true
end

local function FilterSavedItemsForMail(slotOrBagId, slotIndex)
	local bagId, saved, filtered

	if slotIndex == nil then
		bagId, slotIndex = GetInfoFromRowControl(slotOrBagId)
	else
		bagId = slotOrBagId
	end

	--will be set name if saved
	saved = settings.savedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]

	if saved then
		filtered = settings.savedSetInfo[saved].filterMail
		if filtered == true then
			return false
		end
	end
	return true
end

local function FilterSavedItemsForTrade(slotOrBagId, slotIndex)
	local bagId, saved, filtered

	if slotIndex == nil then
		bagId, slotIndex = GetInfoFromRowControl(slotOrBagId)
	else
		bagId = slotOrBagId
	end

	--will be set name if saved
	saved = settings.savedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]

	if saved then
		filtered = settings.savedSetInfo[saved].filterTrade
		if filtered == true then
			return false
		end
	end
	return true
end

local function ToggleStoreFilter(setName)
	local isRegistered = libFilters:IsFilterRegistered("ItemSaver_"..setName.."_Store", LAF_STORE)

	if settings.savedSetInfo[setName].filterStore == true and not isRegistered then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Store", LAF_STORE, FilterSavedItemsForStore)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Store", LAF_STORE)
	end
end

local function ToggleDeconstructionFilter(setName)
	local isRegistered = libFilters:IsFilterRegistered("ItemSaver_"..setName.."_Deconstruction", LAF_DECONSTRUCTION)
	if settings.savedSetInfo[setName].filterDeconstruction == true and not isRegistered then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Deconstruction", LAF_DECONSTRUCTION, FilterSavedItemsForDeconstruction)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Deconstruction", LAF_DECONSTRUCTION)
	end
end

local function ToggleGuildStoreFilter(setName)
	local isRegistered = libFilters:IsFilterRegistered("ItemSaver_"..setName.."_GuildStore", LAF_GUILDSTORE)
	if settings.savedSetInfo[setName].filterGuildStore == true and not isRegistered then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_GuildStore", LAF_GUILDSTORE, FilterSavedItemsForGuildStore)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_GuildStore", LAF_GUILDSTORE)
	end
end

local function ToggleMailFilter(setName)
	local isRegistered = libFilters:IsFilterRegistered("ItemSaver_"..setName.."_Mail", LAF_MAIL)
	if settings.savedSetInfo[setName].filterMail == true and not isRegistered then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Mail", LAF_MAIL, FilterSavedItemsForMail)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Mail", LAF_MAIL)
	end
end

local function ToggleTradeFilter(setName)
	local isRegistered = libFilters:IsFilterRegistered("ItemSaver_"..setName.."_Trade", LAF_TRADE)
	if settings.savedSetInfo[setName].filterTrade == true and not isRegistered then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Trade", LAF_TRADE, FilterSavedItemsForTrade)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Trade", LAF_TRADE)
	end
end

local function ToggleAllFilters()
	for setName,_ in pairs(settings.savedSetInfo) do
		ToggleStoreFilter(setName)
		ToggleDeconstructionFilter(setName)
		ToggleGuildStoreFilter(setName)
		ToggleMailFilter(setName)
		ToggleTradeFilter(setName)
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
		markerAnchor = TOPRIGHT,
		savedSetInfo = {
			--indexed by set name
			["Default"] = {
				markerTexture = "Star",
				markerColor = RGBAToHex(1, 1, 0, 1),
				filterStore = true,
				filterDeconstruction = true,
				filterResearch = true,
				filterGuildStore = false,
				filterMail = false,
				filterTrade = false,
			},
		},
		savedItems = {},
		deferSubmenu = false,
		deferSubmenuNum = 3,
		defaultSet = "Default",
	}

	settings = ZO_SavedVars:NewAccountWide("ItemSaver_Settings", 2.0, nil, defaults)

	ToggleAllFilters()

    self:CreateOptionsMenu()
end

function ItemSaverSettings:CreateOptionsMenu()
	--[[local icon = WINDOW_MANAGER:CreateControl("ItemSaver_Icon", ZO_OptionsWindowSettingsScrollChild, CT_TEXTURE)
	icon:SetColor(HexToRGBA(settings.textureColor))
	icon:SetHandler("OnShow", function()
			self:SetTexture(MARKER_TEXTURES[settings.textureName])
			icon:SetDimensions(TEXTURE_SIZE, TEXTURE_SIZE)
		end)]]--this is going to need to be reworked if I want it in each of the undetermined number of submenus
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
			warning = GetString(SI_ITEMSAVER_RELOAD_UI_WARNING),
			choices = self.GetSaveSets(),
			getFunc = function() return settings.defaultSet end,
			setFunc = function(value)
					local deleteButton = WINDOW_MANAGER:GetControlByName("IS_" .. settings.defaultSet .. "DeleteButton")
					deleteButton.disabled = false
					deleteButton = WINDOW_MANAGER:GetControlByName("IS_" .. value .. "DeleteButton")
					deleteButton.disabled = true

					settings.defaultSet = value

					ReloadUI()
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
					if anchor == TOPRIGHT then return ANCHOR_OPTIONS[2] end
					if anchor == BOTTOMLEFT then return ANCHOR_OPTIONS[3] end
					if anchor == BOTTOMRIGHT then return ANCHOR_OPTIONS[4] end
				end,
			setFunc = function(value)
					if value == ANCHOR_OPTIONS[1] then settings.markerAnchor = TOPLEFT end
					if value == ANCHOR_OPTIONS[2] then settings.markerAnchor = TOPRIGHT end
					if value == ANCHOR_OPTIONS[3] then settings.markerAnchor = BOTTOMLEFT end
					if value == ANCHOR_OPTIONS[4] then settings.markerAnchor = BOTTOMRIGHT end
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
			name = GetString(SI_ITEMSAVER_SET_DATA_HEADER)
		},
	}
	for setName,setData in pairsByKeys(settings.savedSetInfo) do
		local submenuData = {
			type = "submenu",
			name = setName,
			tooltip = nil,
			controls = {
				[1] = {
					type = "dropdown",
					name = GetString(SI_ITEMSAVER_MARKER_LABEL),
					tooltip = GetString(SI_ITEMSAVER_MARKER_TOOLTIP),
					choices = MARKER_OPTIONS,
					getFunc = function() return setData.markerTexture end,
					setFunc = function(value)
							setData.markerTexture = value
							--icon:SetTexture(MARKER_TEXTURES[value])
							--icon:SetDimensions(TEXTURE_SIZE, TEXTURE_SIZE)
						end,
					width = "half",
				},
				[2] = {
					type = "colorpicker",
					name = GetString(SI_ITEMSAVER_TEXTURE_COLOR_LABEL),
					tooltip = GetString(SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP),
					getFunc = function()
							local r, g, b, a = HexToRGBA(setData.markerColor)
							return r, g, b
						end,
					setFunc = function(r, g, b)
							setData.markerColor = RGBAToHex(r, g, b, 1)
							--icon:SetColor(r, g, b, 1)
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
							ToggleStoreFilter(setName)
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
							ToggleDeconstructionFilter(setName)
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
							ToggleGuildStoreFilter(setName)
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
							ToggleMailFilter(setName)
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
							ToggleTradeFilter(setName)
						end,
					width = "half",
				},
				[9] = {
					type = "button",
					name = GetString(SI_ITEMSAVER_DELETE_SET_BUTTON),
					tooltip = GetString(SI_ITEMSAVER_DELETE_SET_TOOLTIP),
					func = function()
						settings.savedSetInfo[setName] = nil

						for savedItem, name in pairs(settings.savedItems) do
							if name == setName then
								settings.savedItems[savedItem] = settings.defaultSet
							end
						end
					end,
					disabled = setName == settings.defaultSet,
					reference = "IS_" .. setName .. "DeleteButton",
				},
			},
		}
		table.insert(optionsData, submenuData)
	end

	LAM:RegisterAddonPanel("ItemSaverSettingsPanel", panel)
	LAM:RegisterOptionControls("ItemSaverSettingsPanel", optionsData)
end

function ItemSaverSettings:GetMarkerAnchor()
	return settings.markerAnchor
end

function ItemSaverSettings:GetMarkerInfo(bagId, slotIndex)
	if self:IsItemSaved(bagId, slotIndex) then
		local signedId = SignItemId(GetItemInstanceId(bagId, slotIndex))
		local savedSet = settings.savedSetInfo[settings.savedItems[signedId]]

		return MARKER_TEXTURES[savedSet.markerTexture], HexToRGBA(savedSet.markerColor)
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
	return {
		store = settings.savedSetInfo[setName].filterStore,
		deconstruction = settings.savedSetInfo[setName].filterDeconstruction,
		research = settings.savedSetInfo[setName].filterResearch,
		guildStore = settings.savedSetInfo[setName].filterGuildStore,
		mail = settings.savedSetInfo[setName].filterMail,
		trade = settings.savedSetInfo[setName].filterTrade,
	}
end

function ItemSaverSettings:GetMarkerOptions()
	return MARKER_OPTIONS
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

function ItemSaver_RegisterMarker(markerInformation)
	MARKER_TEXTURES[markerInformation.markerName] = markerInformation.texturePath
	table.insert(MARKER_OPTIONS, markerInformation.markerName)
end

function ItemSaver_AddSet(setName, setData)
	settings.savedSetInfo[setName] = setData
	ToggleStoreFilter(setName)
	ToggleDeconstructionFilter(setName)
	ToggleGuildStoreFilter(setName)
	ToggleMailFilter(setName)
	ToggleTradeFilter(setName)
end
