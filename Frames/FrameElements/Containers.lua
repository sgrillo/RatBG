local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local tinsert = tinsert

local RBG = R.bgFrames

local function buildContainer(frame, side)
    local container = CreateFrame("Frame",frame:GetName()..side.."Box",frame)
    container.elements = {}
    container.staticUpdates = {}
    container.dynamicUpdates = {}
    container.active = false
    container.side = side
    container.attach = container
    --register everything
    tinsert(frame.elements, container)

    container.staticUpdate = RBG.UpdateContainerStatic
    container.dynamicUpdate = RBG.UpdateContainerDynamic

    container.IsActive = function() return container.active end

    RBG:RegisterUpdates(container)

    return container
end

function RBG:BuildContainers(frame)
    local leftBox = buildContainer(frame, "LEFT")
    local rightBox = buildContainer(frame, "RIGHT")

    return leftBox, rightBox
end

function RBG:UpdateContainerStatic(frame)
    print("Container Update: ", self:GetName(), ", ", frame:GetName())
    local width = 0
    self.active = false
    self:SetHeight(frame:GetHeight())
    self.attach = self

    if self.side == "LEFT" then
        self:SetPoint("TOPLEFT",frame,"TOPLEFT")
    else
        self:SetPoint("TOPRIGHT",frame,"TOPRIGHT")
    end

    for _,element in ipairs(self.elements) do
        R:Print("Container Update")
        element:updateStatic(frame)
        if element:IsActive() then
            self.attach = element
            if frame:IsActive() then 
                self:Show() 
                element:Show()
                width = width + element:GetWidth()
                self.active = true
            end            
        end
    end
    if self.active then
        self:SetWidth(width)
    else
        self:Hide()
    end
end

function RBG:UpdateContainerDynamic(frame)
    for _,element in ipairs(self.elements) do
        element:updateDynamic(frame)
    end
end