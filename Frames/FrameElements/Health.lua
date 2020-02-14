local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildHealthBar(frame)
    local healthBar = CreateFrame("StatusBar", frame:GetName().."HealthBar", frame)
    healthBar.background = healthBar:CreateTexture(nil, "BORDER")

    healthBar:SetFrameLevel(frame:GetFrameLevel()+5)                    -- make sure theres room to put stuff around this

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

    healthBar:AddBorder()
    
    return healthBar
end

function RBG:UpdateHealthDynamic(frame)
    if frame.enemy and frame.enemy.maxHealth and frame.enemy.currentHealth then
        self:SetValue(frame.enemy.currentHealth / frame.enemy.maxHealth)
    else
        self:SetValue(1)
    end
end

function RBG:UpdateHealthStatic(frame)

    --print("healthBar", self:GetName(), "parent", frame:GetName())
    --print("parent dimensions: ", frame:GetWidth(), ", ", frame:GetHeight())
    rightBox, leftBox, border = frame.rightBox, frame.leftBox, RBG.db.borderWidth
    
    local bottomHeight = frame.powerBar:IsActive() and ((RBG.powerBarHeight + border) * R.pix) or 0

    local bdColor, bgColor, hpColor = RBG.db.bdColor, RBG.db.bgColor, RBG.db.barColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    

    if frame.enemy and frame.enemy.class and RBG.db.classColorBars then
        self:SetStatusBarColor(R:classColor(frame.enemy.class))
    else
        local c = RBG.db.barColor
        self:SetStatusBarColor(c.r, c.g, c.b, c.a)
    end

    self:ClearAllPoints()

    if leftBox:IsActive() then
        --print("left box anchor")
        self:SetPoint("TOPLEFT",leftBox,"TOPRIGHT")
    else
        --print("left frame anchor")
        self:SetPoint("TOPLEFT",frame,"TOPLEFT")
    end
    if rightBox:IsActive() then
        --print("right box anchor")
        self:SetPoint("BOTTOMRIGHT",rightBox,"BOTTOMLEFT",0,bottomHeight)
    else
        --print("right frame anchor")
        self:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,bottomHeight)
    end

    if frame.enemy and frame.enemy.currentHealth and frame.enemy.maxHealth then
        self:SetValue(frame.enemy.currentHealth / frame.enemy.maxHealth)
    else
        self:SetValue(1)
    end

end



