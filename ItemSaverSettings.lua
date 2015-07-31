ItemSaverSettings = ZO_Object:Subclass()

local LAM = LibStub("LibAddonMenu-2.0")
local libFilters = LibStub("libFilters")
local settings = nil
local MARKER_TEXTURES = {
	["Star"] = {
		texturePath = [[/esoui/art/campaign/overview_indexicon_bonus_disabled.dds]],
		textureSize = 32
	},
	["Padlock"] =  {
		texturePath = [[/esoui/art/campaign/campaignbrowser_fullpop.dds]],
		textureSize = 32
	},
	["Flag"] = {
		texturePath = [[/esoui/art/ava/tabicon_bg_score_disabled.dds]],
		textureSize = 32
	},
	["BoxStar"] = {
		texturePath = [[/esoui/art/guild/guild_rankicon_leader_large.dds]],
		textureSize = 32
	},
	["Medic"] = {
		texturePath = [[/esoui/art/miscellaneous/announce_icon_levelup.dds]],
		textureSize = 32
	},
	["Timer"] = {
		texturePath = [[/esoui/art/mounts/timer_icon.dds]],
		textureSize = 32
	},
}
local TEXTURE_OPTIONS = { "Star", "Padlock", "Flag", "BoxStar", "Medic", "Timer" }
local ANCHOR_OPTIONS = { "Top left", "Top right", "Bottom left", "Bottom right" }

-----------------------------
--UTIL FUNCTIONS
-----------------------------
local function RGBAToHex( r, g, b, a )
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255)
end

local function HexToRGBA( hex )
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

local function FilterSavedItems(bagId, slotIndex, ...)
	if(markedItems[SignItemId(GetItemInstanceId(bagId, slotIndex))]) then
		return false
	end
	return true
end

local function toggleStoreFilter(setName)
	if settings.savedSetInfo[setName].filterStore == true then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Store", LAF_STORE, FilterSavedItems)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Store", LAF_STORE)
	end
end

local function toggleDeconstructionFilter(setName)
	if settings.savedSetInfo[setName].filterDeconstruction == true then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Deconstruction", LAF_DECONSTRUCTION, FilterSavedItems)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Deconstruction", LAF_DECONSTRUCTION)
	end
end

local function toggleResearchFilter(setName)
	if settings.savedSetInfo[setName].filterResearch == true then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Research", LAF_RESEARCH, FilterSavedItems)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Research", LAF_RESEARCH)
	end
end

local function toggleGuildStoreFilter(setName)
	if settings.savedSetInfo[setName].filterGuildStore == true then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_GuildStore", LAF_GUILDSTORE, FilterSavedItems)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_GuildStore", LAF_GUILDSTORE)
	end
end

local function toggleMailFilter(setName)
	if settings.savedSetInfo[setName].filterMail == true then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Mail", LAF_MAIL, FilterSavedItems)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Mail", LAF_MAIL)
	end
end

local function toggleTradeFilter(setName)
	if settings.savedSetInfo[setName].filterTrade == true then
		libFilters:RegisterFilter("ItemSaver_"..setName.."_Trade", LAF_TRADE, FilterSavedItems)
	else
		libFilters:UnregisterFilter("ItemSaver_"..setName.."_Trade", LAF_TRADE)
	end
end

local function toggleAllFilters()
	for setName,_ in pairs(settings.savedSetInfo) do
		toggleStoreFilter(setName)
		toggleDeconstructionFilter(setName)
		toggleResearchFilter(setName)
		toggleGuildStoreFilter(setName)
		toggleMailFilter(setName)
		toggleTradeFilter(setName)
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
		iconAnchor = TOPRIGHT,
		savedSetInfo = {
		--indexed by set name
			["Default"] = {
				iconTexture = "Star",
				iconColor = RGBAToHex(1, 1, 0, 1),
				filterStore = true,
				filterDeconstruction = true,
				filterResearch = true,
				filterGuildStore = false,
				filterMail = false,
				filterTrade = false,
			},
		},
		savedItems = {},
	}

	settings = ZO_SavedVars:NewAccountWide("ItemSaver_Settings", 2.0, nil, defaults)

	toggleAllFilters()

    self:CreateOptionsMenu()
end

function ItemSaverSettings:CreateOptionsMenu()
	--[[local icon = WINDOW_MANAGER:CreateControl("ItemSaver_Icon", ZO_OptionsWindowSettingsScrollChild, CT_TEXTURE)
	icon:SetColor(HexToRGBA(settings.textureColor))
	icon:SetHandler("OnShow", function()
			self:SetTexture(MARKER_TEXTURES[settings.textureName].texturePath)
			icon:SetDimensions(MARKER_TEXTURES[settings.textureName].textureSize, MARKER_TEXTURES[settings.textureName].textureSize)
		end)]]

	local panel = {
		type = "panel",
		name = "Item Saver",
		author = "Randactyl, ingeniousclown",
		version = "2.0.0.0",
		slashCommand = "/itemsaver",
		registerForRefresh = true,
	}

	local optionsData = {
		[1] = {
			type = "header",
			name = GetString(SI_ITEMSAVER_GENERAL_OPTIONS_HEADER),
		},
		[2] = {
			type = "button",
			name = GetString(SI_ITEMSAVER_APPLY_CHANGES_BUTTON),
			tooltip = GetString(SI_ITEMSAVER_APPLY_CHANGES_TOOLTIP),
			func = function() ReloadUI() end,
			warning = GetString(SI_ITEMSAVER_RELOAD_UI_WARNING),
		},
		[3] = {
			type = "dropdown",
			name = GetString(SI_ITEMSAVER_ICON_ANCHOR_LABEL),
			tooltip = GetString(SI_ITEMSAVER_ICON_ANCHOR_TOOLTIP),
			choices = ANCHOR_OPTIONS,
			getFunc = function()
					local anchor = settings.iconAnchor
					if anchor == TOPLEFT then return ANCHOR_OPTIONS[1] end
					if anchor == TOPRIGHT then return ANCHOR_OPTIONS[2] end
					if anchor == BOTTOMLEFT then return ANCHOR_OPTIONS[3] end
					if anchor == BOTTOMRIGHT then return ANCHOR_OPTIONS[4] end
				end,
			setFunc = function(value)
					if value == ANCHOR_OPTIONS[1] then settings.iconAnchor = TOPLEFT end
					if value == ANCHOR_OPTIONS[2] then settings.iconAnchor = TOPRIGHT end
					if value == ANCHOR_OPTIONS[3] then settings.iconAnchor = BOTTOMLEFT end
					if value == ANCHOR_OPTIONS[4] then settings.iconAnchor = BOTTOMRIGHT end
				end,
		},
		[4] = {
			type = "header",
			name = GetString(SI_ITEMSAVER_SET_DATA_HEADER)
		},
	}
	for setName,setData in pairs(settings.savedSetInfo) do
		local submenuData = {
			type = "submenu",
			name = setName,
			tooltip = nil,
			controls = {
				[1] = {
					type = "dropdown",
					name = GetString(SI_ITEMSAVER_ICON_LABEL),
					tooltip = GetString(SI_ITEMSAVER_ICON_TOOLTIP),
					choices = TEXTURE_OPTIONS,
					getFunc = function() return setData.iconTexture end,
					setFunc = function(value)
							setData.iconTexture = value
						end,
				},
				[2] = {
					type = "colorpicker",
					name = GetString(SI_ITEMSAVER_TEXTURE_COLOR_LABEL),
					tooltip = GetString(SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP),
					getFunc = function()
							local r, g, b, a = HexToRGBA(setData.iconColor)
							return r, g, b
						end,
					setFunc = function(r, g, b)
							setData.iconColor = RGBAToHex(r, g, b, 1)
							icon:SetColor(r, g, b, 1)
						end,
				},
				[3] = {
					type = "checkbox",
					name = GetString(SI_ITEMSAVER_FILTERS_STORE_LABEL),
					tooltip = GetString(SI_ITEMSAVER_FILTERS_STORE_TOOLTIP),
					getFunc = function() return setData.filterStore end,
					setFunc = function(value)
							setData.filterStore = value
							toggleStoreFilter(setName)
						end,
				},
				[4] = {
					type = "checkbox",
					name = GetString(SI_ITEMSAVER_FILTERS_DECONSTRUCTION_LABEL),
					tooltip = GetString(SI_ITEMSAVER_FILTERS_DECONSTRUCTION_TOOLTIP),
					getFunc = function() return setData.filterDeconstruction end,
					setFunc = function(value)
							setData.filterDeconstruction = value
							toggleDeconstructionFilter(setName)
						end,
				},
				[5] = {
					type = "checkbox",
					name = GetString(SI_ITEMSAVER_FILTERS_RESEARCH_LABEL),
					tooltip = GetString(SI_ITEMSAVER_FILTERS_RESEARCH_TOOLTIP),
					getFunc = function() return setData.filterResearch end,
					setFunc = function(value)
							setData.filterResearch = value
							toggleResearchFilter(setName)
						end,
				},
				[6] = {
					type = "checkbox",
					name = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORE_LABEL),
					tooltip = GetString(SI_ITEMSAVER_FILTERS_GUILDSTORE_TOOLTIP),
					getFunc = function() return setData.filterGuildStore end,
					setFunc = function(value)
							setData.filterGuildStore = value
							toggleGuildStoreFilter(setName)
						end,
				},
				[7] = {
					type = "checkbox",
					name = GetString(SI_ITEMSAVER_FILTERS_MAIL_LABEL),
					tooltip = GetString(SI_ITEMSAVER_FILTERS_MAIL_TOOLTIP),
					getFunc = function() return setData.filterMail end,
					setFunc = function(value)
							setData.filterMail = value
							toggleMailFilter(setName)
						end,
				},
				[8] = {
					type = "checkbox",
					name = GetString(SI_ITEMSAVER_FILTERS_TRADE_LABEL),
					tooltip = GetString(SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP),
					getFunc = function() return setData.filterTrade end,
					setFunc = function(value)
							setData.filterTrade = value
							toggleTradeFilter(setName)
						end,
				},
			},
		}
		table.insert(optionsData, submenuData)
	end

	LAM:RegisterAddonPanel("ItemSaverSettingsPanel", panel)
	LAM:RegisterOptionControls("ItemSaverSettingsPanel", optionsData)
end
