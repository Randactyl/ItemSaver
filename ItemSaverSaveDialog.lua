local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function handleDialog(dialog)
    local editBox = ItemSaverDialogNameEditbox
    local comboBox = ItemSaverDialogIconSelectDropdown.m_comboBox
    --local markerColor = ItemSaverDialogIconColorPickerTexture
    local shopButton = ItemSaverDialogFilterStoreButton
    local deconstructionButton = ItemSaverDialogFilterDeconstructionButton
    local researchButton = ItemSaverDialogFilterResearchButton
    local guildStoreButton = ItemSaverDialogFilterGuildStoreButton
    local mailButton = ItemSaverDialogFilterMailButton
    local tradeButton = ItemSaverDialogFilterTradeButton

    local setData = {}

	local setName = editBox:GetText()

    setData.markerTexture = comboBox.m_selectedItemData["name"]
    setData.markerColor = RGBToHex(1, 1, 0)
    if shopButton:GetState() == 1 then
        setData.filterStore = true
    else
        setData.filterStore = false
    end
    if deconstructionButton:GetState() == 1 then
        setData.filterDeconstruction = true
    else
        setData.filterDeconstruction = false
    end
    if researchButton:GetState() == 1 then
        setData.filterResearch = true
    else
        setData.filterResearch = false
    end
    if guildStoreButton:GetState() == 1 then
        setData.filterGuildStore = true
    else
        setData.filterGuildStore = false
    end
    if mailButton:GetState() == 1 then
        setData.filterMail = true
    else
        setData.filterMail = false
    end
    if tradeButton:GetState() == 1 then
        setData.filterTrade = true
    else
        setData.filterTrade = false
    end

    ItemSaver_AddSet(setName, setData)
	ItemSaver_ToggleItemSave(setName, dialog.data[1], dialog.data[2])
end

local function SetupDialog(dialog)
    local editBox = ItemSaverDialogNameEditbox
    local comboBox = ItemSaverDialogIconSelectDropdown.m_comboBox
    --local markerColor = ItemSaverDialogIconColorPickerTexture
    local shopButton = ItemSaverDialogFilterStoreButton
    local deconstructionButton = ItemSaverDialogFilterDeconstructionButton
    local researchButton = ItemSaverDialogFilterResearchButton
    local guildStoreButton = ItemSaverDialogFilterGuildStoreButton
    local mailButton = ItemSaverDialogFilterMailButton
    local tradeButton = ItemSaverDialogFilterTradeButton

    editBox:Clear()

    if comboBox then comboBox:ClearItems() end
    for _,name in pairs(ItemSaver_GetMarkerOptions()) do
        local itemEntry = ZO_ComboBox:CreateItemEntry(name)
        comboBox:AddItem(itemEntry)
    end
    comboBox:SelectFirstItem()

    --markerColor:SetColor(1, 1, 0, 1)

    shopButton:SetState(0)
    deconstructionButton:SetState(0)
    researchButton:SetState(0)
    guildStoreButton:SetState(0)
    mailButton:SetState(0)
    tradeButton:SetState(0)
end
test = {}
function ItemSaver_SetupDialog(self)
    local info = {
        customControl = self,
        setup = SetupDialog,
        title = {
            text = SI_ITEMSAVER_ADDON_NAME,
        },
        buttons = {
            [1] = {
                control = GetControl(self, "Create"),
                text = SI_DIALOG_ACCEPT,
                callback = function(self)
					local setName = ItemSaverDialogNameEditbox:GetText()
					local setExists = ItemSaver_GetFilters(setName)
					if setName == "" then
						d(GetString(SI_ITEMSAVER_MISSING_NAME_WARNING))
					elseif setExists then
						d(GetString(SI_ITEMSAVER_USED_NAME_WARNING))
					else
						handleDialog(self)
					end
                end,
            },
            [2] = {
                control = GetControl(self, "Cancel"),
                text = SI_DIALOG_CANCEL,
            },
        }
    }

    ZO_Dialogs_RegisterCustomDialog("ITEMSAVER_SAVE", info)
end

--[[local function ColorPickerCallback(r, g, b, a)
    local markerColor = ItemSaverDialogIconColorPickerTexture
    markerColor:SetColor(r, g, b, a)
end

function ItemSaver_ColorPicker(self, button, upInside)
    local markerColor = ItemSaverDialogIconColorPickerTexture
    local r, g, b, a = markerColor:GetColor()

    COLOR_PICKER:Show(ColorPickerCallback, r, g, b, a)
    d("ksjgks")
end]]
