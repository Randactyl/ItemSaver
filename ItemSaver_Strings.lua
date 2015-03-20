ItemSaver_Strings = {
	["de"] = {
		--Added headlines for the settings in LAM 2.0
		HEAD_GENERAL = "Generelle Optionen",
		HEAD_FILTER = "Filter Optionen",
 
        ICON_LABEL = "Symbol",
        ICON_TOOLTIP = "Symbol der markierten Items",
 
        TEXTURE_COLOR_LABEL = "Symbol Farbe",
        TEXTURE_COLOR_TOOLTIP = "Farbe für das Symbol der markierten Items",
 
        FILTERS_TOGGLE_LABEL = "Filter aktivieren",
        FILTERS_TOGGLE_TOOLTIP = "Die Filter aktivieren/deaktivieren (\"/itemsaver filters\" Chat Befehl)",
 
        FILTERS_SHOP_LABEL = "Shop filtern",
        FILTERS_SHOP_TOOLTIP = "Sollen markierte Items von der Verkaufsliste entfernt werden?",
 
        FILTERS_DECONSCRUCTION_LABEL = "Zerlegen filtern",
        FILTERS_DECONSCRUCTION_TOOLTIP = "Sollen markierte Items von der Zerlegen-/Dekonstruktionsliste entfernt werden?",
 
        FILTERS_RESEARCH_LABEL = "Analyse filtern",
        FILTERS_RESEARCH_TOOLTIP = "Sollen markierte Items von der Analyseliste entfernt werden?",
    },
	["en"] = {
		ICON_LABEL = "Icon Texture",
		ICON_TOOLTIP = "Texture to use for your ItemSaver",

		ICON_ANCHOR_LABEL = "Icon Position",
		ICON_ANCHOR_TOOLTIP = "Position of the saved item marker",

		TEXTURE_COLOR_LABEL = "Texture Color",
		TEXTURE_COLOR_TOOLTIP = "Color to use for ItemSaver's texture",

		FILTERS_TOGGLE_LABEL = "Use Filters?",
		FILTERS_TOGGLE_TOOLTIP = "Toggle the filters on and off (\"/itemsaver filters\" slash command)",

		FILTERS_SHOP_LABEL = "Filter Shop?",
		FILTERS_SHOP_TOOLTIP = "Should saved items be removed from the sell list?",

		FILTERS_DECONSCRUCTION_LABEL = "Filter Deconstruction?",
		FILTERS_DECONSCRUCTION_TOOLTIP = "Should saved items be removed from the deconstruction list?",

		FILTERS_RESEARCH_LABEL = "Filter Research?",
		FILTERS_RESEARCH_TOOLTIP = "Should saved items be removed from the research menu?",
	},
	["es"] = {
		ICON_LABEL = "Icono",
		ICON_TOOLTIP = "Icono para tu ItemSaver",

		TEXTURE_COLOR_LABEL = "Color",
		TEXTURE_COLOR_TOOLTIP = "Color que tendr195\161 tu icono ItemSaver",

		FILTERS_TOGGLE_LABEL = "Aplicar filtros",
		FILTERS_TOGGLE_TOOLTIP = "Activa/desactiva los filtros (\"/itemsaver filters\" slash command)",

		FILTERS_SHOP_LABEL = "Filtrar venta",
		FILTERS_SHOP_TOOLTIP = "Los objetos marcados no estar195\161n visibles en la ventana de venta",

		FILTERS_DECONSCRUCTION_LABEL = "Filtrar desconstrucci195\179n",
		FILTERS_DECONSCRUCTION_TOOLTIP = "Los objetos marcados no estar195\161n visibles en la ventana de desconstrucci195\179n",

		FILTERS_RESEARCH_LABEL = "Filtrar investigaci195\161n",
		FILTERS_RESEARCH_TOOLTIP = "Los objetos marcados no estar195\161n visibles en la ventana de investigaci195\161n",
	},
	["fr"] = {
		ICON_LABEL = "Ic\195\180ne",
		ICON_TOOLTIP = "Texture \195\160 utiliser avec ItemSaver",

		TEXTURE_COLOR_LABEL = "Couleur",
		TEXTURE_COLOR_TOOLTIP = "Couleur \195\160 appliquer \195\160 la texture d'ItemSaver",

		FILTERS_TOGGLE_LABEL = "Utiliser les filtres?",
		FILTERS_TOGGLE_TOOLTIP = "Active ou d\195\169sactive les filtres (commande \"/itemsaver filters\")",

		FILTERS_SHOP_LABEL = "Filtrage au niveau des magasins?",
		FILTERS_SHOP_TOOLTIP = "Si les articles sauvegard\195\169s doivent \195\170tre retir\195\169s de la liste des ventes?",

		FILTERS_DECONSCRUCTION_LABEL = "Filtrage au niveau de la d\195\169construction?",
		FILTERS_DECONSCRUCTION_TOOLTIP = "Si les articles sauvegard\195\169s doivent \195\170tre retir\195\169s de la liste de d\195\169construction?",

		FILTERS_RESEARCH_LABEL = "Filtrage au niveau de la recherche?",
		FILTERS_RESEARCH_TOOLTIP = "Si les articles sauvegard\195\169s doivent \195\170tre retir\195\169s du menu de recherche?",
	},
	["ru"] = {
	},
}

setmetatable(ItemSaver_Strings["de"], {__index = ItemSaver_Strings["en"]})
setmetatable(ItemSaver_Strings["fr"], {__index = ItemSaver_Strings["en"]})
setmetatable(ItemSaver_Strings["ru"], {__index = ItemSaver_Strings["en"]})
setmetatable(ItemSaver_Strings["es"], {__index = ItemSaver_Strings["en"]})