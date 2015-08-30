local strings = {
	["de"] = {
	},
	["en"] = {
		["SI_ITEMSAVER_ADDON_NAME"] = "Item Saver",

		["SI_ITEMSAVER_GENERAL_OPTIONS_HEADER"] = "General Options",

		["SI_ITEMSAVER_RELOAD_UI_WARNING"] = "Will reload UI",
		["SI_ITEMSAVER_APPLY_CHANGES_BUTTON"] = "Apply Changes",
		["SI_ITEMSAVER_APPLY_CHANGES_TOOLTIP"] = "Click this whenever you make a change below",
		["SI_ITEMSAVER_MARKER_ANCHOR_LABEL"] = "Marker Position",
		["SI_ITEMSAVER_MARKER_ANCHOR_TOOLTIP"] = "Position of the saved item marker",

		["SI_ITEMSAVER_SET_DATA_HEADER"] = "Set Data",

		["SI_ITEMSAVER_MARKER_LABEL"] = "Marker Texture",
		["SI_ITEMSAVER_MARKER_TOOLTIP"] = "Texture to use for the marker",

		["SI_ITEMSAVER_TEXTURE_COLOR_LABEL"] = "Texture Color",
		["SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP"] = "Color to use for the marker's texture",

		["SI_ITEMSAVER_FILTERS_STORE_LABEL"] = "Filter Store?",
		["SI_ITEMSAVER_FILTERS_STORE_TOOLTIP"] = "Should saved items be removed from the vendor sell list?",

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

		["SI_ITEMSAVER_DELETE_SET_BUTTON"] = "Delete Set",
		["SI_ITEMSAVER_DELETE_SET_TOOLTIP"] = "Removes the set and changes any items in the set to the default set",

		["SI_ITEMSAVER_CREATE_SAVE_SET"] = "+ Create Set",
		["SI_ITEMSAVER_UNSAVE_ITEM"] = "Unsave item",

		["SI_BINDING_NAME_ITEM_SAVER_TOGGLE"] = "Toggle Item Saved",
	},
	["es"] = {
	},
	["fr"] = {
	},
	["ru"] = {
	},
}

local function AddStringsToGame()
	local lang = GetCVar("language.2")
	if strings[lang] == nil then lang = "en" end

	for i,v in pairs(strings[lang]) do
		ZO_CreateStringId(i, v)
	end
end

AddStringsToGame()
