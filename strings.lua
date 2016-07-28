local strings = {
	["de"] = {
        ["SI_ITEMSAVER_ADDON_NAME"] = "Item Saver",
		["SI_ITEMSAVER_RELOAD_UI_WARNING"] = "UI wird neu geladen",

        ["SI_ITEMSAVER_GENERAL_OPTIONS_HEADER"] = "Allgemeine Optionen",

		["SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_LABEL"] = "Default Set",
		["SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_TOOLTIP"] = "This set will be used for the keybind, when deleting other sets, and when a set is not specified.",

        ["SI_ITEMSAVER_MARKER_ANCHOR_LABEL"] = "Markierungsposition",
        ["SI_ITEMSAVER_MARKER_ANCHOR_TOOLTIP"] = "Position der Markierung bei geschützten Gegenständen",
		["SI_ITEMSAVER_ANCHOR_LABEL_TOPLEFT"] = "Top Left",
		["SI_ITEMSAVER_ANCHOR_LABEL_TOP"] = "Top",
		["SI_ITEMSAVER_ANCHOR_LABEL_TOPRIGHT"] = "Top Right",
		["SI_ITEMSAVER_ANCHOR_LABEL_RIGHT"] = "Right",
		["SI_ITEMSAVER_ANCHOR_LABEL_BOTTOMRIGHT"] = "Bottom Right",
		["SI_ITEMSAVER_ANCHOR_LABEL_BOTTOM"] = "Bottom",
		["SI_ITEMSAVER_ANCHOR_LABEL_BOTTOMLEFT"] = "Bottom Left",
		["SI_ITEMSAVER_ANCHOR_LABEL_LEFT"] = "Left",
		["SI_ITEMSAVER_ANCHOR_LABEL_CENTER"] = "Center",

		["SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_LABEL"] = "Defer Submenu Creation",
		["SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_TOOLTIP"] = "Only use a submenu if there are more than the specified number of sets.",
		["SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_LABEL"] = "Number of Sets",
		["SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_TOOLTIP"] = "A submenu will be used if there are more than this number of sets.",

        ["SI_ITEMSAVER_SET_DATA_HEADER"] = "Setdaten",

		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_LABEL"] = "Save Type",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_TOOLTIP"] = "Changes the way items are saved to this set. General will mark all stacks of an item. Unique will mark only the selected stack and will persist if that item undergoes a change such as enchantment or improvement.",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_WARNING"] = "Changing this option will clear all items in this set.",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_GENERAL"] = "General",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_UNIQUE"] = "Unique",

        ["SI_ITEMSAVER_MARKER_LABEL"] = "Aussehen der Markierung",
        ["SI_ITEMSAVER_MARKER_TOOLTIP"] = "Die Textur die für die Markierung verwendet wird",

        ["SI_ITEMSAVER_TEXTURE_COLOR_LABEL"] = "Markierungsfarbe",
        ["SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP"] = "Die Farbe die für die Markierung verwendet wird",

        ["SI_ITEMSAVER_FILTERS_VENDORSELL_LABEL"] = "Händler filtern?",
        ["SI_ITEMSAVER_FILTERS_VENDORSELL_TOOLTIP"] = "Sollen die geschützten Gegenstände beim NPC Händler verborgen werden?",

        ["SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_LABEL"] = "Verwertung filtern?",
		["SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_TOOLTIP"] = "Sollen die geschützten Gegenstände beim Verwerten an der Handwerksstation verborgen werden?",

        ["SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_LABEL"] = "Analyse filtern?",
        ["SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_TOOLTIP"] = "Sollen die geschützten Gegenstände beim Analysieren an der Handwerksstation verborgen werden?",

        ["SI_ITEMSAVER_FILTERS_GUILDSTORESELL_LABEL"] = "Gildenladen filtern?",
        ["SI_ITEMSAVER_FILTERS_GUILDSTORESELL_TOOLTIP"] = "Sollen die geschützten Gegenstände im Gildenladenverkaufsfenster verborgen werden?",

        ["SI_ITEMSAVER_FILTERS_MAILSEND_LABEL"] = "Post filtern?",
        ["SI_ITEMSAVER_FILTERS_MAILSEND_TOOLTIP"] = "Sollen die geschützten Gegenstände im Postanhangfenster verborgen werden?",

        ["SI_ITEMSAVER_FILTERS_TRADE_LABEL"] = "Handel filtern?",
        ["SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP"] = "Sollen die geschützten Gegenstände beim Handel mit anderen Spielern verborgen werden?",

		["SI_ITEMSAVER_CLEAR_SET_BUTTON"] = "Clear Set",
		["SI_ITEMSAVER_CLEAR_SET_TOOLTIP"] = "Unsaves any items currently in this set.",
		["SI_ITEMSAVER_CLEAR_SET_CONFIRMATION"] = "Removed all items from set:",

        ["SI_ITEMSAVER_DELETE_SET_BUTTON"] = "Set löschen",
        ["SI_ITEMSAVER_DELETE_SET_TOOLTIP"] = "Entfernt das Set und weist alle Gegenstände im Set dem \"Default\" Set zu",

        ["SI_ITEMSAVER_CREATE_SAVE_SET"] = "+ Set erstellen",
        ["SI_ITEMSAVER_UNSAVE_ITEM"] = "Gegenstand nicht mehr schützen",
		["SI_ITEMSAVER_SAVE_TO"] = "Save to",

		["SI_ITEMSAVER_SET_NAME_LABEL"] = "Name",
		["SI_ITEMSAVER_SET_NAME_TOOLTIP"] = "The name that will be given to the new set.",
		["SI_ITEMSAVER_MISSING_NAME_WARNING"] = "Set not saved - no name was given for the set.",
		["SI_ITEMSAVER_USED_NAME_WARNING"] = "Set not saved - given set name is already in use.",
		["SI_ITEMSAVER_SELECT_FILTERS_LABEL"] = "Filters",

        ["SI_BINDING_NAME_ITEM_SAVER_TOGGLE"] = "Gegenstand schützen",
    },
	["en"] = {
		["SI_ITEMSAVER_ADDON_NAME"] = "Item Saver",
		["SI_ITEMSAVER_RELOAD_UI_WARNING"] = "Will reload UI",

		["SI_ITEMSAVER_GENERAL_OPTIONS_HEADER"] = "General Options",

		["SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_LABEL"] = "Default Set",
		["SI_ITEMSAVER_DEFAULT_SET_DROPDOWN_TOOLTIP"] = "This set will be used for the keybind, when deleting other sets, and when a set is not specified.",

		["SI_ITEMSAVER_MARKER_ANCHOR_LABEL"] = "Marker Position",
		["SI_ITEMSAVER_MARKER_ANCHOR_TOOLTIP"] = "Position of the saved item marker.",
		["SI_ITEMSAVER_ANCHOR_LABEL_TOPLEFT"] = "Top Left",
		["SI_ITEMSAVER_ANCHOR_LABEL_TOP"] = "Top",
		["SI_ITEMSAVER_ANCHOR_LABEL_TOPRIGHT"] = "Top Right",
		["SI_ITEMSAVER_ANCHOR_LABEL_RIGHT"] = "Right",
		["SI_ITEMSAVER_ANCHOR_LABEL_BOTTOMRIGHT"] = "Bottom Right",
		["SI_ITEMSAVER_ANCHOR_LABEL_BOTTOM"] = "Bottom",
		["SI_ITEMSAVER_ANCHOR_LABEL_BOTTOMLEFT"] = "Bottom Left",
		["SI_ITEMSAVER_ANCHOR_LABEL_LEFT"] = "Left",
		["SI_ITEMSAVER_ANCHOR_LABEL_CENTER"] = "Center",

		["SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_LABEL"] = "Defer Submenu Creation",
		["SI_ITEMSAVER_DEFER_SUBMENU_CHECKBOX_TOOLTIP"] = "Only use a submenu if there are more than the specified number of sets.",
		["SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_LABEL"] = "Number of Sets",
		["SI_ITEMSAVER_DEFER_SUBMENU_DROPDOWN_TOOLTIP"] = "A submenu will be used if there are more than this number of sets.",

		["SI_ITEMSAVER_SET_DATA_HEADER"] = "Set Data",

		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_LABEL"] = "Save Type",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_TOOLTIP"] = "Changes the way items are saved to this set. General will mark all stacks of an item. Unique will mark only the selected stack and will persist if that item undergoes a change such as enchantment or improvement.",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_WARNING"] = "Changing this option will clear all items in this set.",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_GENERAL"] = "General",
		["SI_ITEMSAVER_SAVE_TYPE_DROPDOWN_UNIQUE"] = "Unique",

		["SI_ITEMSAVER_MARKER_LABEL"] = "Marker Texture",
		["SI_ITEMSAVER_MARKER_TOOLTIP"] = "Texture to use for the marker.",

		["SI_ITEMSAVER_TEXTURE_COLOR_LABEL"] = "Texture Color",
		["SI_ITEMSAVER_TEXTURE_COLOR_TOOLTIP"] = "Color to use for the marker's texture.",

		["SI_ITEMSAVER_FILTERS_VENDORSELL_LABEL"] = "Filter Store?",
		["SI_ITEMSAVER_FILTERS_VENDORSELL_TOOLTIP"] = "Should saved items be removed from the vendor sell list?",

		["SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_LABEL"] = "Filter Deconstruction?",
		["SI_ITEMSAVER_FILTERS_SMITHINGDECONSTRUCT_TOOLTIP"] = "Should saved items be removed from the deconstruction list?",

		["SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_LABEL"] = "Filter Research?",
		["SI_ITEMSAVER_FILTERS_SMITHINGRESEARCH_TOOLTIP"] = "Should saved items be removed from the research list?",

		["SI_ITEMSAVER_FILTERS_GUILDSTORESELL_LABEL"] = "Filter Guild Store?",
		["SI_ITEMSAVER_FILTERS_GUILDSTORESELL_TOOLTIP"] = "Should saved items be removed from the guild store sell tab?",

		["SI_ITEMSAVER_FILTERS_MAILSEND_LABEL"] = "Filter Mail?",
		["SI_ITEMSAVER_FILTERS_MAILSEND_TOOLTIP"] = "Should saved items be removed from the mail attachment list?",

		["SI_ITEMSAVER_FILTERS_TRADE_LABEL"] = "Filter Trade?",
		["SI_ITEMSAVER_FILTERS_TRADE_TOOLTIP"] = "Should saved items be removed from the trade list?",

		["SI_ITEMSAVER_CLEAR_SET_BUTTON"] = "Clear Set",
		["SI_ITEMSAVER_CLEAR_SET_TOOLTIP"] = "Unsaves any items currently in this set.",
		["SI_ITEMSAVER_CLEAR_SET_CONFIRMATION"] = "Removed all items from set:",

		["SI_ITEMSAVER_DELETE_SET_BUTTON"] = "Delete Set",
		["SI_ITEMSAVER_DELETE_SET_TOOLTIP"] = "Removes the set and changes any items in the set to the default set.",

		["SI_ITEMSAVER_CREATE_SAVE_SET"] = "+ Create Set",
		["SI_ITEMSAVER_UNSAVE_ITEM"] = "Unsave item",
		["SI_ITEMSAVER_SAVE_TO"] = "Save to",

		["SI_ITEMSAVER_SET_NAME_LABEL"] = "Name",
		["SI_ITEMSAVER_SET_NAME_TOOLTIP"] = "The name that will be given to the new set.",
		["SI_ITEMSAVER_MISSING_NAME_WARNING"] = "Set not saved - no name was given for the set.",
		["SI_ITEMSAVER_USED_NAME_WARNING"] = "Set not saved - given set name is already in use.",
		["SI_ITEMSAVER_SELECT_FILTERS_LABEL"] = "Filters",

		["SI_BINDING_NAME_ITEM_SAVER_TOGGLE"] = "Toggle Item Saved",
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