local IS = ItemSaver
local util = IS.util
local settings = IS.settings

--returns true if the set was successfully registered.
--returns false if the set name is an empty string or already in use.
function ItemSaver_AddSet(setName, setData)
    return settings.AddSet(setName, setData)
end

--returns the default set name
function ItemSaver_GetDefaultSet()
    return settings.GetDefaultSet()
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

--returns a table with the full info of the provided set name.
--returns nil if the set doesn't exist.
function ItemSaver_GetSetData(setName)
    return settings.GetSetData(setName)
end

--returns the string set name if the supplied index is 1 - 5
--returns nil if the supplied index is out of range or if no set has been
--assigned to that index
function ItemSaver_GetSetNameByKeybindIndex(index)
    return settings.GetSetNameByKeybindIndex(index)
end

--returns true and the string set name if the item is saved. Returns false if
--the item is not saved.
function ItemSaver_IsItemSaved(bagId, slotIndex)
    return settings.IsItemSaved(bagId, slotIndex)
end

--returns true and the maximum number of sets that will be shown without a
--submenu if submenu creation is deferred.
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

--returns true if item was saved successfully. Returns false if item was
--unsaved.
--if setName is a number from 1 - 5, the set corresponding to that keybind index
--will be used.
--if setName is nil, the default set will be used.
function ItemSaver_ToggleItemSave(setName, bagId, slotIndex)
    if bagId == nil then --keybind
        local mouseOverControl = WINDOW_MANAGER:GetMouseOverControl()

        bagId, slotIndex = util.GetInfoFromRowControl(mouseOverControl)

        if not bagId then
            mouseOverControl = mouseOverControl:GetParent()
            bagId, slotIndex = util.GetInfoFromRowControl(mouseOverControl)
        end
    end

    if bagId then
        local returnVal = settings.ToggleItemSave(setName, bagId, slotIndex)
        util.RefreshAll()

        return returnVal
    end
end