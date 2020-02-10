local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

local function buildContainer(frame, side)
    local container = CreateFrame("Frame",frame:GetName()..side.."Box",frame)
    container.elements = {}
    container.staticUpdates = {}
    container.dynamicUpdates = {}
    container.active = false
    container.side = side

    --register everything
    frame.elements[container] = true

    container.staticUpdate = RBG.UpdateContainerStatic
    container.dynamicUpdate = RBG.UpdateContainerDynamic

    container.IsActive = function() return container.active end

    RBG:RegisterUpdates(container)

    return container
end

function RBG:BuildContainers(frame)
    local leftBox = buildContainer(frame, "Left")
    local rightBox = buildContainer(frame, "Right")

    return leftBox, rightBox
end

function RBG:UpdateContainerStatic(frame)
    --print("Container Update: ", self:GetName(), ", ", frame:GetName())
    local width = 0
    local active = frame.active
    self.active = false
    for element in pairs(self.elements) do
        --print("Attempting to update sub-element: "..element:GetName())
        element:updateStatic(frame)
        if element:IsActive() and frame:IsActive() then 
            self:Show() 
            element:Show()
            width = width + element:GetWidth()
            self.active = true            
        end
    end
    if self.active then
        self:SetWidth(width)

        if self.side == "Left" then
            self:SetPoint("TOPLEFT",frame,"TOPLEFT")
            self:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT")
        else
            self:SetPoint("TOPRIGHT",frame,"TOPRIGHT")
            self:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT")
        end
    end
end

function RBG:UpdateContainerDynamic(frame)
    for element, dynamicUpdateFunction in pairs(frame.dynamicUpdates) do
        dynamicUpdateFunction(frame)
    end
end