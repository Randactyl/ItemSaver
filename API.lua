local IS = ItemSaver
local util = IS.util
local settings = IS.settings

--returns true if the set was successfully registered.
--returns false if the set name is an empty string or already in use.
function ItemSaver_AddSet(setName, setData)
	return settings.AddSet(setName, setData)
end

--if the given set exists, returns a table with the following keys: store,
--deconstruction, research, guildStore, mail, trade.
--each will have a value of true if they are filtered or false if they are not.
--if the set does not exist, returns nil
function ItemSaver_GetFilters(setName)
	return settings.GetFilters(setName)
end

--returns preferred anchor position for markers.
function ItemSaver_GetMarkerAnchor()
    return settings.GetMarkerAnchor()
end

--returns texturePath, r, g, b if the item is saved.
--returns nil if the item is not saved.
function ItemSaver_GetMarkerInfo(bagId, slotIndex)
    return settings.GetMarkerInfo(bagId, slotIndex)
end

--returns array of the names of available markers.
function ItemSaver_GetMarkerOptions()
	return util.markerOptions
end

--returns table with key/value pairs of markerName/markerPath
function ItemSaver_GetMarkerTextures()
	return util.markerTextures
end

--returns an alphabetically sorted array of the names of available save sets.
function ItemSaver_GetSaveSets()
	return settings.GetSaveSets()
end

--returns true and the string set name if the item is saved. Returns false if
--the item is not saved.
function ItemSaver_IsItemSaved(bagId, slotIndex)
	return settings.IsItemSaved(bagId, slotIndex)
end

--returns true and the maximum number of sets that will be shown without a submenu
--if submenu creation is deferred.
--returns false if submenu creation is not deferred.
function ItemSaver_IsSubmenuDeferred()
    return settings.IsSubmenuDeferred()
end

--returns true if the marker was successfully registered, false if it was not.
function ItemSaver_RegisterMarker(markerInformation)
	local markerName = markerInformation.markerName

	if util.markerTextures[markerName] then
		return false
	end

	util.markerTextures[markerName] = markerInformation.texturePath
	table.insert(util.markerOptions, markerName)

	return true
end

--returns true if item was saved successfully. Returns false if item was unsaved.
--if setName is nil, the default set will be used.
function ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
	local returnVal

	if bagId == nil then --keybind
		local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()

		bagId, slotIndex = util.GetInfoFromRowControl(mouseOverControl)

		if not bagId then
			mouseOverControl = mouseOverControl:GetParent()
			bagId, slotIndex = util.GetInfoFromRowControl(mouseOverControl)
		end
	end

	if bagId then
		returnVal = settings.ToggleItemSave(setName, bagId, slotIndex)
		util.RefreshAll()

		return returnVal
	end
end