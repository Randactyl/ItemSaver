function ItemSaver_ToggleItemSave(bagId, slotIndex)
	local returnVal
	--if bagId is nil, then keybind was pressed.
	if bagId == nil then
		local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()
		--if is a backpack row or child of one
		if(mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*")) then
			--check if the control IS the row
			if(mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*$")) then
				local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

				returnVal = ItemSaver.ItemSaverSettings.ToggleSave(bagId, slotIndex)
			else
				mouseOverControl = mouseOverControl:GetParent()
				--this SHOULD be the row control - if it isn't then idk how to handle it without going
				--iterating through parents. that shouldn't happen unless someone is doing something weird
				if(mouseOverControl:GetName():find("^ZO_%a+Backpack%dRow%d%d*$")) then
					local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

					returnVal = ItemSaver.ItemSaverSettings.ToggleSave(bagId, slotIndex)
				end
			end
		elseif(mouseOverControl:GetName():find("^ZO_CharacterEquipmentSlots.+$")) then
			local bagId, slotIndex = GetInfoFromRowControl(mouseOverControl)

			returnVal = ItemSaver.ItemSaverSettings.ToggleSave(bagId, slotIndex)
		end
	else
		--if bagId is not nil, then function was called by another addon.
		returnVal = ItemSaver.ItemSaverSettings.ToggleSave(bagId, slotIndex)
	end

	return returnVal
end