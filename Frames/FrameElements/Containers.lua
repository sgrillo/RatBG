local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

function RBG:UpdateContainerStatic(frame)
    print("Updating Container: "..frame:GetName())
    local width = 0
    local active = frame.active
    active = false
    for element, staticUpdateFunction in pairs(frame.staticUpdates) do
        staticUpdateFunction(frame)
        width = width + element:IsActive() and (element:GetWidth() + 2)     --add 2 for the border
        active = active or element:IsActive()
    end
    if active then
        frame:SetWidth(width)
        local parent = frame:GetParent()
        if frame.side == "Left" then
            frame:SetPoint("TOPLEFT",parent,"TOPLEFT")
            frame:SetPoint("BOTTOMLEFT",parent,"BOTTOMLEFT")
        else
            frame:SetPoint("TOPRIGHT",parent,"TOPRIGHT")
            frame:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT")
        end
    else
        frame:Hide()
    end
end

local function buildContainer(frame, side)
    local container = CreateFrame("Frame",frame:GetName()..side.."Box",frame)
    container.elements = {}
    container.staticUpdates = {}
    container.dynamicUpdates = {}
    container.active = false
    container.side = side

    --register everything
    frame.elements[container] = true

    RBG:RegisterUpdates(container, RBG.UpdateContainerStatic, RBG.UpdateContainerDynamic)

    --frame.staticUpdates[container] = UpdateContainerStatic
    --frame.dynamicUpdates[container] = RBG.UpdateContainerDynamic

    container.IsActive = function() return container.active end

    return container
end

function RBG:BuildContainers(frame)
    local leftBox = buildContainer(frame, "Left")
    local rightBox = buildContainer(frame, "Right")

    return leftBox, rightBox
end

function RBG:UpdateContainerDynamic(frame)
    for element, dynamicUpdateFunction in pairs(frame.dynamicUpdates) do
        dynamicUpdateFunction(frame)
    end
end