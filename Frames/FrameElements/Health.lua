local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildHealthBar(frame)
    local healthBar = CreateFrame("StatusBar", frame:GetName().."HealthBar", frame)
    healthBar.background = healthBar:CreateTexture(nil, "BORDER")
    healthBar.backdrop = CreateFrame("Frame", frame:GetName().."Border", healthBar)

    healthBar:SetFrameLevel(frame:GetFrameLevel()+5)                    -- make sure theres room to put stuff around this
    
    --setup border
    local bW = A.bgFrames.borderWidth
    healthBar.backdrop:SetPoint("TOPLEFT",healthBar,"TOPLEFT",-bW,bW)
    healthBar.backdrop:SetPoint("BOTTOMRIGHT",healthBar,"BOTTOMRIGHT", bW, -bW)
    healthBar.backdrop:SetFrameLevel(healthBar:GetFrameLevel()-2)
    healthBar.backdrop.tex=healthBar.backdrop:CreateTexture(nil, "BORDER")
    healthBar.backdrop.tex:SetAllPoints()

    --set statusbar background
    healthBar.background:SetAllPoints()

    --register with everything
    healthBar.staticUpdate = RBG.UpdateHealthStatic
    healthBar.dynamicUpdate = RBG.UpdateHealthDynamic

    healthBar:SetMinMaxValues(0,1)
    healthBar:SetValue(1)

    healthBar:SetSmoothing(true)

    self.statusbars[healthBar] = true
    frame.elements[healthBar] = true

    healthBar.IsActive = function() return true end

    RBG:RegisterUpdates(healthBar)
    
    return healthBar
end

function RBG:UpdateHealthDynamic(frame)

end

function RBG:UpdateHealthStatic(frame)

    --print("healthBar", self:GetName(), "parent", frame:GetName())
    --print("parent dimensions: ", frame:GetWidth(), ", ", frame:GetHeight())
    rightBox, leftBox, border = frame.rightBox, frame.leftBox, A.bgFrames.borderWidth
    
    local bottomHeight = border + (frame.powerBar:IsActive() and (border + RBG.powerBarHeight) or 0)

    local bdColor, bgColor, hpColor = RBG.db.bdColor, RBG.db.bgColor, RBG.db.barColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    self.backdrop.tex:SetColorTexture(bdColor.r, bdColor.g, bdColor.b, bdColor.a)

    if frame:hasEnemy() and frame.enemy.class and RBG.db.classColorBars then
        self:SetStatusBarColor(R:classColor(frame.enemy.class))
    else
        local c = RBG.db.barColor
        self:SetStatusBarColor(c.r, c.g, c.b, c.a)
    end

    self:ClearAllPoints()

    if leftBox:IsActive() then
        print("left box anchor")
        self:SetPoint("TOPLEFT",leftBox,"TOPRIGHT",border,-border)
    else
        print("left frame anchor")
        self:SetPoint("TOPLEFT",frame,"TOPLEFT",border,-border)
    end
    if rightBox:IsActive() then
        print("right box anchor")
        self:SetPoint("BOTTOMRIGHT",rightBox,"BOTTOMLEFT",-border,bottomHeight)
    else
        print("right frame anchor")
        self:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-border,bottomHeight)
    end

end



