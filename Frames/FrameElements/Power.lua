local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildPowerBar(frame)
    local powerBar = CreateFrame("StatusBar", frame:GetName().."PowerBar", frame)
    powerBar.background = powerBar:CreateTexture(nil, "BORDER")

    powerBar:SetFrameLevel(frame:GetFrameLevel()+4)         --ordered below the healthbars for a more consistent look
    

    --set statusbar background
    powerBar.background:SetAllPoints()

    --register with everything

    powerBar:SetMinMaxValues(0,1)
    powerBar:SetValue(1)

    powerBar.staticUpdate = RBG.UpdatePowerStatic
    powerBar.dynamicUpdate = RBG.UpdatePowerDynamic

    powerBar:SetSmoothing(true)

    self.statusbars[powerBar] = true
    frame.elements[powerBar] = true

    powerBar.active = false

    powerBar.IsActive = function() return powerBar.active end

    RBG:RegisterUpdates(powerBar)

    powerBar:AddBorder()
    
    return powerBar
end

function RBG:UpdatePowerDynamic(frame)

end

local function LookupPowerType(frame)
    local powerTypes, class = T.general.powerTypes, frame.enemy.class
    --handle druids because they're silly
    if class == "Druid" then
        return RBG.db.trackPower == "All" and frame.enemy.powerType or "Mana"
    end
    return powerTypes.Mana[class] and "Mana" or powerTypes.Energy[class] and "Energy" or powerTypes.Rage[class] and "Rage"
end

function RBG:UpdatePowerStatic(frame)

    --print("powerBar", self:GetName(), "parent", frame)
    rightBox, leftBox = frame.rightBox, frame.leftBox
    local bottomHeight = RBG.powerBarHeight * R.pix       --Only matters if this is displayed

    local bdColor, bgColor = RBG.db.bdColor, RBG.db.bgColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    

    --Handle powerBar Display Settings
    local type = "Mana"
    if frame:hasEnemy() then
        type = LookupPowerType(frame) or type
    end

    if RBG.db.trackPower == "None" then
        self.active = false
        self:Hide()
    elseif RBG.db.trackPower == "Mana" then
        if type ~= "Mana" then
            self.active = false
            self:Hide()
        end
    else
        self.active = true
    end
    self:SetStatusBarColor(rgb(T.general.powerColors[type]))
    
    frame.healthBar:updateStatic(frame)             --make sure to force update the health bar to ensure its sized correctly

    self:ClearAllPoints()

    if leftBox:IsActive() then
        --print("left box anchor")
        self:SetPoint("BOTTOMLEFT",leftBox,"BOTTOMRIGHT")
    else
        --print("left frame anchor")
        self:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT")
    end
    if rightBox:IsActive() then
        --print("right box anchor")
        self:SetPoint("TOPRIGHT",rightBox,"BOTTOMLEFT",0,bottomHeight)
    else
        --print("right frame anchor")
        self:SetPoint("TOPRIGHT",frame,"BOTTOMRIGHT",0,bottomHeight)
    end

    --self:SetValue(math.random())
    --print(self:GetName(), " width: ", self:GetWidth(), ", height: ", self:GetHeight())

end



