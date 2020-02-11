local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildPowerBar(frame)
    local powerBar = CreateFrame("StatusBar", frame:GetName().."PowerBar", frame.healthBar)
    powerBar.background = powerBar:CreateTexture(nil, "BORDER")
    powerBar.backdrop = CreateFrame("Frame", frame:GetName().."Border", powerBar)

    powerBar:SetFrameLevel(frame:GetFrameLevel()+10)                    -- make sure theres room to put stuff around this
    
    --setup border
    local bW = A.bgFrames.borderWidth
    powerBar.backdrop:SetPoint("TOPLEFT",powerBar,"TOPLEFT",-bW,bW)
    powerBar.backdrop:SetPoint("BOTTOMRIGHT",powerBar,"BOTTOMRIGHT", bW, -bW)
    powerBar.backdrop:SetFrameLevel(powerBar:GetFrameLevel()-2)
    powerBar.backdrop.tex=powerBar.backdrop:CreateTexture(nil, "BORDER")
    powerBar.backdrop.tex:SetAllPoints()

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
    
    return powerBar
end

function RBG:UpdatePowerDynamic(frame)

end

local function LookupPowerType(frame)
    local powerTypes, class = T.general.powerTypes, frame.enemy.class
    --handle druids because they're silly
    if class == "Druid" then
        return frame.enemy.powerType or "Mana"
    end
    return powerTypes.Mana[class] and "Mana" or powerTypes.Energy[class] and "Energy" or powerTypes.Rage[class] and "Rage"
end

function RBG:UpdatePowerStatic(frame)

    --print("powerBar", self:GetName(), "parent", frame)
    rightBox, leftBox, border = frame.rightBox, frame.leftBox, A.bgFrames.borderWidth
    local bottomHeight = border + RBG.powerBarHeight      --Only matters if this is displayed

    local bdColor, bgColor = RBG.db.bdColor, RBG.db.bgColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    self.backdrop.tex:SetColorTexture(bdColor.r, bdColor.g, bdColor.b, bdColor.a)

    --Handle powerBar Display Settings
    local type = "Mana"
    if frame:hasEnemy() then
        type = LookupPowerType(frame) or type
    end

    if RBG.db.trackPower == "None" then
        self.active = false
        frame.healthBar:updateStatic(frame)             --make sure to force update the health bar to ensure its sized correctly
        return
    elseif RBG.db.trackPower == "Mana" then
        if type ~= "Mana" then
            self.active = false
            frame.healthBar:updateStatic(frame)
            return
        end
    else
        self:SetStatusBarColor(rgb(T.general.powerColors[type]))
    end

    self:ClearAllPoints()

    if leftBox:IsActive() then
        --print("left box anchor")
        self:SetPoint("BOTTOMLEFT",leftBox,"BOTTOMRIGHT",border,border)
    else
        --print("left frame anchor")
        self:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT",border,border)
    end
    if rightBox:IsActive() then
        --print("right box anchor")
        self:SetPoint("TOPRIGHT",rightBox,"BOTTOMLEFT",-border,bottomHeight)
    else
        --print("right frame anchor")
        self:SetPoint("TOPRIGHT",frame,"BOTTOMRIGHT",-border,bottomHeight)
    end

    --print(self:GetName(), " width: ", self:GetWidth(), ", height: ", self:GetHeight())

end



