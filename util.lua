local IS = ItemSaver
IS.util = {}

local util = IS.util
util.lam = LibStub("LibAddonMenu-2.0")
util.LibFilters = LibStub("LibFilters-2.0")
util.markerTextures = {}
util.markerOptions = {}

function util.SignItemInstanceId(itemInstanceId)
    local SIGNED_INT_MAX = 2^32 / 2 - 1
    local INT_MAX = 2^32

    if itemInstanceId and itemInstanceId > SIGNED_INT_MAX then
        itemInstanceId = itemInstanceId - INT_MAX
    end

    return itemInstanceId
end

function util.RGBToHex(r, g, b)
    r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0

    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

function util.HexToRGB(hex)
    local rhex, ghex, bhex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6)

    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255
end

function util.PairsByKeys(t)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a)
    local i = 0
    local iter = function()
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

function util.GetMarkerTextureArrays()
    local arr1, arr2 = {}, {}

    for name, path in util.PairsByKeys(util.markerTextures) do
        table.insert(arr1, path)
        table.insert(arr2, name)
    end

    return arr1, arr2
end

function util.GetInfoFromRowControl(rowControl)
    if not rowControl then return end

    local dataEntry = rowControl.dataEntry
    local bagId, slotIndex

    --case to handle equiped items
    if not dataEntry then
        bagId = rowControl.bagId
        slotIndex = rowControl.slotIndex
    else
        bagId = dataEntry.data.bagId
        slotIndex = dataEntry.data.slotIndex
    end

    --case to handle list dialog, list dialog uses index instead of slotIndex
    --and bag instead of badId...?
    if dataEntry and not bagId and not slotIndex then
        bagId = dataEntry.data.bag
        slotIndex = dataEntry.data.index
    end

    return bagId, slotIndex
end

function util.CreateMarkerControl(parent)
    local function getMarkerControlAnchorOffsets(markerAnchor)
        local offsetValue = 10
        local offsets = {
            [TOPLEFT] = {
                x = -offsetValue,
                y = -offsetValue,
            },
            [TOP] = {
                x = 0,
                y = -offsetValue,
            },
            [TOPRIGHT] = {
                x = offsetValue,
                y = -offsetValue,
            },
            [RIGHT] = {
                x = offsetValue,
                y = 0,
            },
            [BOTTOMRIGHT] = {
                x = offsetValue,
                y = offsetValue,
            },
            [BOTTOM] = {
                x = 0,
                y = offsetValue,
            },
            [BOTTOMLEFT] = {
                x = -offsetValue,
                y = offsetValue,
            },
            [LEFT] = {
                x = -offsetValue,
                y = 0,
            },
            [CENTER] = {
                x = 0,
                y = 0,
            },
        }

        return offsets[markerAnchor].x, offsets[markerAnchor].y
    end

    local control = parent:GetNamedChild("ItemSaver")
    if not control then
        control = WINDOW_MANAGER:CreateControl(parent:GetName() .. "ItemSaver", parent, CT_TEXTURE)
        control:SetDimensions(32, 32)
        control:SetDrawTier(DT_HIGH)
    end

    local bagId, slotIndex = util.GetInfoFromRowControl(parent)
    local texturePath, r, g, b = ItemSaver_GetMarkerInfo(bagId, slotIndex)

    --item isn't saved, don't continue
    if not texturePath then
        control:SetHidden(true)
        return
    end

    local markerAnchor, customOffsetX, customOffsetY = ItemSaver_GetMarkerAnchor()
    local offsetX, offsetY = getMarkerControlAnchorOffsets(markerAnchor)
    offsetX = offsetX + customOffsetX
    offsetY = offsetY + customOffsetY
    local anchorTarget = parent:GetNamedChild("Button")

    if anchorTarget then
        --list control
        anchorTarget = anchorTarget:GetNamedChild("Icon")
    else
        --equipment control
        anchorTarget = parent:GetNamedChild("Icon")
    end

    --there's no anchor target. How'd we get here?
    if not anchorTarget then return end

    control:SetHidden(false)
    control:SetTexture(texturePath)
    control:SetColor(r, g, b)
    control:ClearAnchors()
    control:SetAnchor(markerAnchor, anchorTarget, markerAnchor, offsetX, offsetY)
end

function util.RefreshEquipmentControls()
    for i = 1, ZO_Character:GetNumChildren() do
        local child = ZO_Character:GetChild(i)

        if child and child:GetName():find("ZO_CharacterEquipmentSlots") then
            util.CreateMarkerControl(ZO_Character:GetChild(i))
        end
    end
end

function util.RequestUpdate(filterTypes)
    for _, filterType in pairs(filterTypes) do
        util.LibFilters:RequestUpdate(filterType)
    end
end

function util.RefreshAll()
    local filterTypes = {
        LF_INVENTORY, LF_BANK_WITHDRAW, LF_BANK_DEPOSIT, LF_GUILDBANK_WITHDRAW,
        LF_GUILDBANK_DEPOSIT, LF_SMITHING_DECONSTRUCT, LF_SMITHING_IMPROVEMENT,
        LF_ENCHANTING_CREATION, LF_ENCHANTING_EXTRACTION, LF_CRAFTBAG,
    }

    util.RequestUpdate(filterTypes)
    util.RefreshEquipmentControls()
end