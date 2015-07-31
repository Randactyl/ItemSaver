local strings = {
	["de"] = {
    },
	["en"] = {
		["SI_ITEMSAVER_GENERAL_OPTIONS_HEADER"] = "General Options",

		["SI_ITEMSAVER_RELOAD_UI_WARNING"] = "Will reload UI",

		["SI_ITEMSAVER_APPLY_CHANGES_BUTTON"] = "Apply Changes",
		["SI_ITEMSAVER_APPLY_CHANGES_TOOLTIP"] = "Click this whenever you make a change below",

		["SI_ITEMSAVER_ICON_ANCHOR_LABEL"] = "Icon Position",
		["SI_ITEMSAVER_ICON_ANCHOR_TOOLTIP"] = "Position of the saved item marker",

		["SI_ITEMSAVER_SET_DATA_HEADER"] = "Set Data",

		["SI_ITEMSAVER_ICON_LABEL"] = "Icon Texture",
		["SI_ITEMSAVER_ICON_TOOLTIP"] = "Texture to use for your Item Saver",

		["SI_ITEMSAVER_TEXTURE_COLOR_LABEL"] = "Texture Color",
		["SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP"] = "Color to use for Item Saver's texture",

		["SI_ITEMSAVER_FILTERS_SHOP_LABEL"] = "Filter Shop?",
		["SI_ITEMSAVER_FILTERS_SHOP_TOOLTIP"] = "Should saved items be removed from the vendor sell list?",

		["SI_ITEMSAVER_FILTERS_DECONSTRUCTION_LABEL"] = "Filter Deconstruction?",
		["SI_ITEMSAVER_FILTERS_DECONSTRUCTION_TOOLTIP"] = "Should saved items be removed from the deconstruction list?",

		["SI_ITEMSAVER_FILTERS_RESEARCH_LABEL"] = "Filter Research?",
		["SI_ITEMSAVER_FILTERS_RESEARCH_TOOLTIP"] = "Should saved items be removed from the research list?",

		["SI_ITEMSAVER_FILTERS_GUILDSTORE_LABEL"] = "Filter Guild Store?",
		["SI_ITEMSAVER_FILTERS_GUILDSTORE_TOOLTIP"] = "Should saved items be removed from the guild store sell tab?",

		["SI_ITEMSAVER_FILTERS_MAIL_LABEL"] = "Filter Mail?",
		["SI_ITEMSAVER_FILTERS_MAIL_TOOLTIP"] = "Should saved items be removed from the mail attachment list?",

		["SI_ITEMSAVER_FILTERS_TRADE_LABEL"] = "Filter Trade?",
		["SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP"] = "Should saved items be removed from the trade list?",
	},
	["es"] = {
	},
	["fr"] = {
	},
	["ru"] = {
	},
}

--use metatables to set english as default language
setmetatable(strings["de"], {__index = strings["en"]})
setmetatable(strings["es"], {__index = strings["en"]})
setmetatable(strings["fr"], {__index = strings["en"]})
setmetatable(strings["ru"], {__index = strings["en"]})

local function AddStringsToGame()
	local lang = GetCVar("language.2")
	if strings[lang] == nil then lang = "en" end

	for i,v in pairs(strings[lang]) do
		ZO_CreateStringId(i, v)
	end
end

AddStringsToGame()
