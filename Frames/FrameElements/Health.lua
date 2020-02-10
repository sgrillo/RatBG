local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.libs.LSM

function RBG:BuildHealthBar(frame)
    local healthBar = CreateFrame("StatusBar", nil, frame)
    local background = healthBar:CreateTexture(nil, "BORDER")
    local backdrop = healthBar:CreateTexture("Frame", nil)

    healthBar:SetFrameLevel(frame:GetFrameLevel()+5)                    -- make sure theres room to put stuff around this
    
    --setup border
    backdrop:SetColorTexture(c.r, c.g, c.b, c.a)
    backdrop:SetPoint("TOPLEFT",healthBar,"TOPLEFT",-1,1)
    backdrop:SetPoint("BOTTOMRIGHT",healthBar,"BOTTOMRIGHT", 1, -1)
    backdrop:SetFrameLevel(healthBar:GetFrameLevel()-2)

    --set statusbar background
    background:SetAllPoints()
    background:SetFrameLevel(healthBar:GetFrameLevel()-1)

    --register with everything
    self.statusbars[healthBar] = true
    frame.elements[healthBar] = true
    frame.staticUpdates[healthBar] = self.UpdateHealthStatic
    frame.dynamicUpdates[healthBar] = self.UpdateHealthDynamic

    return healthBar
end

function RBG:UpdateHealthStatic(frame)
    local healthBar, rightBox, leftBox, border = frame.healthBar, frame.rightBox, frame.leftBox, RBG.db.borderWidth
    local bottomHeight = border + RBG.db.trackPower ~= "None" and RBG.powerBarHeight or 0

    R:SetSmoothing(healthbar, true)

    local bdColor, bgColor = RBG.db.bdColor, RBG.db.bgColor
    healthBar.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    healthBar.backdrop:SetColorTexture(bdColor.r, bdColor.g, bdColor.b, bdColor.a)

    if frame.enemy and frame.enemy.class and RBG.db.classColorBars then
        healthBar:SetStatusBarColor(R:classColor(frame.enemy.class))
    else
        local c = RBG.db.barColor
        healthBar:SetStatusBarColor(c.r, c.b, c.g, c.a)
    end

    healthBar:ClearAllPoints()

    if leftBox:IsShown() then
        healthBar:SetPoint("TOPLEFT",leftBox,"TOPRIGHT",-border,-border)
    else
        healthBar:SetPoint("TOPLEFT",frame,"TOPLEFT",-border,-border)
    end
    if rightBox:IsShown() then
        healthBar:SetPoint("BOTTOMRIGHT",rightBox,"BOTTOMLEFT",border,bottomHeight)
    else
        healthBar:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT",border,bottomHeight)
    end
end

function RBG:UpdateHealthDynamic()

end


