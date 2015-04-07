local ISSettings = nil

local function ItemSaver_Loaded(eventCode, addOnName)
	if(addOnName ~= "ItemSaver") then return end

	ISSettings = ItemSaverSettings:New()
end

EVENT_MANAGER:RegisterForEvent("ItemSaverLoaded", EVENT_ADD_ON_LOADED, ItemSaver_Loaded)