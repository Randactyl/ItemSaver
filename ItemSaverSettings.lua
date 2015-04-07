ItemSaverSettings = ZO_Object:Subclass()

local LAM = LibStub("LibAddonMenu-2.0")
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
local ANCHOR_OPTIONS = { "Top left", "Top right", "Bottom left", "Bottom right"}

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
				filterShop = true,
				filterDeconstruction = true,
				filterResearch = true,
				filterGuildStore = false,
				filterMail = false,
				filterTrade = false,
				filterImprovement = false,
				filterFence = false,
				filterLaunder = false,
			},
		},
		savedItems = {},
	}

	settings = ZO_SavedVars:NewAccountWide("ItemSaver_Settings", 2.0, nil, defaults)

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
						ReloadUI()
					end,
			warning = GetString(SI_ITEMSAVER_RELOAD_UI_WARNING),
		},
	}

	LAM:RegisterAddonPanel("ItemSaverSettingsPanel", panel)
	LAM:RegisterOptionControls("ItemSaverSettingsPanel", optionsData)
end