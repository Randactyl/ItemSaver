local function RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function handleDialog(dialog)

    ItemSaver_AddSet(setName, setData)
	ItemSaver_ToggleItemSave(setName, dialog.data[1], dialog.data[2])
end

local function SetupDialog(dialog)
end
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



