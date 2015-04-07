local strings = {
	["de"] = {
    },
	["en"] = {
		["SI_ITEMSAVER_GENERAL_OPTIONS_HEADER"] = "General Options",

		["SI_ITEMSAVER_RELOAD_UI_WARNING"] = "Will reload the UI",

		["SI_ITEMSAVER_APPLY_CHANGES_BUTTON"] = "Apply Changes",
		["SI_ITEMSAVER_APPLY_CHANGES_TOOLTIP"] = "Click this whenever you make a change below",

		["SI_ITEMSAVER_ICON_LABEL"] = "Icon Texture",
		["SI_ITEMSAVER_ICON_TOOLTIP"] = "Texture to use for your ItemSaver",

		["SI_ITEMSAVER_ICON_ANCHOR_LABEL"] = "Icon Position",
		["SI_ITEMSAVER_ICON_ANCHOR_TOOLTIP"] = "Position of the saved item marker",

		["SI_ITEMSAVER_TEXTURE_COLOR_LABEL"] = "Texture Color",
		["SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP"] = "Color to use for ItemSaver's texture",

		["SI_ITEMSAVER_FILTERS_TOGGLE_LABEL"] = "Use Filters?",
		["SI_ITEMSAVER_FILTERS_TOGGLE_TOOLTIP"] = "Toggle the filters on and off (\"/itemsaver filters\" slash command)",

		["SI_ITEMSAVER_FILTERS_SHOP_LABEL"] = "Filter Shop?",
		["SI_ITEMSAVER_FILTERS_SHOP_TOOLTIP"] = "Should saved items be removed from the sell list?",

		["SI_ITEMSAVER_FILTERS_DECONSCRUCTION_LABEL"] = "Filter Deconstruction?",
		["SI_ITEMSAVER_FILTERS_DECONSCRUCTION_TOOLTIP"] = "Should saved items be removed from the deconstruction list?",

		["SI_ITEMSAVER_FILTERS_RESEARCH_LABEL"] = "Filter Research?",
		["SI_ITEMSAVER_FILTERS_RESEARCH_TOOLTIP"] = "Should saved items be removed from the research menu?",
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