local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local strupper, rand, tinsert = strupper, math.random, tinsert

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
    tinsert(frame.elements, powerBar)

    powerBar.active = false

    powerBar.IsActive = function() return powerBar.active end

    RBG:RegisterUpdates(powerBar)

    powerBar:AddBorder()
    
    return powerBar
end

local function LookupPowerType(enemy)
    if enemy.class then
        local powerTypes, class = T.general.powerTypes, enemy.class
        --handle druids because they're silly
        if class == "DRUID" then
            return RBG.db.trackPower == "All" and enemy.powerType or "Mana"
        end
        return powerTypes.Mana[class] and "Mana" or powerTypes.Energy[class] and "Energy" or powerTypes.Rage[class] and "Rage"
    end
    return nil
end

function RBG:UpdatePowerDynamic(frame)
    if RBG.testMode then return end
    if not frame.enemy then self:SetValue(1) return end
    local power, maxPower = frame.enemy.currentPower, frame.enemy.maxPower
    if frame.enemy.class == "DRUID" then     --need to check if we need to change bar color
        if RBG.db.trackPower == "All" then
            local type = frame.enemy.powerType or "Mana"
            self:SetStatusBarColor(rgb(T.general.powerColors[strupper(type)]))
        elseif RBG.db.trackPower == "Mana" then
            power, maxPower = frame.enemy.currentMana, frame.enemy.maxMana
        end
    end
    self:SetValue(power / maxPower)
end



function RBG:UpdatePowerStatic(frame)

    --print("powerBar", self:GetName(), "parent", frame)
    rightBox, leftBox = frame.rightBox, frame.leftBox
    local bottomHeight = RBG.powerBarHeight      --Only matters if this is displayed

    local bdColor, bgColor = RBG.db.bdColor, RBG.db.bgColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)

    self:ClearAllPoints()

    if leftBox:IsActive() then
        --print("left box anchor")
        self:SetPoint("BOTTOMLEFT",leftBox,"BOTTOMRIGHT",-R:Round(border, R.pix),0)
    else
        --print("left frame anchor")
        self:SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT")
    end
    if rightBox:IsActive() then
        --print("right box anchor")
        self:SetPoint("TOPRIGHT",rightBox,"BOTTOMLEFT",R:Round(border, R.pix),bottomHeight)
    else
        --print("right frame anchor")
        self:SetPoint("TOPRIGHT",frame,"BOTTOMRIGHT",0,bottomHeight)
    end
    

    --Handle powerBar Display Settings
    local type, enemy = "Mana", frame:GetEnemy()
    if enemy then
        type = LookupPowerType(enemy) or type
    end

    if RBG.db.trackPower == "None" then
        self.active = false
        self:Hide()
    elseif RBG.db.trackPower == "Mana" then
        if type ~= "Mana" then
            self.active = false
            self:Hide()
        else
            self.active = true
        end
    else
        self.active = true
    end
    self:SetStatusBarColor(rgb(T.general.powerColors[strupper(type)]))
    
    frame.healthBar:updateStatic(frame)             --make sure to force update the health bar to ensure its sized correctly

    if RBG.testMode then self:SetValue(rand())
    elseif frame.enemy and frame.enemy.currentPower and frame.enemy.maxPower then
        self:SetValue(frame.enemy.currentPower / frame.enemy.maxPower)
    else
        self:SetValue(1)
    end

    --self:SetValue(math.random())
    --print(self:GetName(), " width: ", self:GetWidth(), ", height: ", self:GetHeight())

end



