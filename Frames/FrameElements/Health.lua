local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildHealthBar(frame)
    local healthBar = CreateFrame("StatusBar", frame:GetName().."HealthBar", frame)
    healthBar.background = healthBar:CreateTexture(nil, "BORDER")
    healthBar.backdrop = CreateFrame("Frame", frame:GetName().."Border", healthBar)

    healthBar:SetFrameLevel(frame:GetFrameLevel()+5)                    -- make sure theres room to put stuff around this
    
    --setup border
    healthBar.backdrop:SetPoint("TOPLEFT",healthBar,"TOPLEFT",-1,1)
    healthBar.backdrop:SetPoint("BOTTOMRIGHT",healthBar,"BOTTOMRIGHT", 1, -1)
    healthBar.backdrop:SetFrameLevel(healthBar:GetFrameLevel()-2)
    healthBar.backdrop.tex=healthBar.backdrop:CreateTexture(nil, "BORDER")
    healthBar.backdrop.tex:SetAllPoints()

    --set statusbar background
    healthBar.background:SetAllPoints()

    --register with everything

    --local updateMeta = getmetatable(healthbar).__index
    --updateMeta.staticUpdate = RBG.UpdateHealthStatic
    --updateMeta.dynamicUpdate = RBG.UpdateHealthDynamic

    healthBar:SetMinMaxValues(0,1)
    healthBar:SetValue(1)

    a,b = healthBar:GetMinMaxValues()
    print(a,b)

    self.statusbars[healthBar] = true
    frame.elements[healthBar] = true
    --frame.staticUpdates[healthBar] = RBG.UpdateHealthStatic
    --frame.dynamicUpdates[healthBar] = RBG.UpdateHealthDynamic

    healthBar.IsActive = function() return true end

    RBG:RegisterUpdates(healthBar, RBG.UpdateHealthStatic, RBG.UpdateHealthDynamic)
    
    return healthBar
end

function RBG:UpdateHealthDynamic(frame)

end

function RBG:UpdateHealthStatic(frame)

    print("healthBar", self:GetName(), "parent", frame)
    rightBox, leftBox, border = frame.rightBox, frame.leftBox, RBG.db.borderWidth
    local bottomHeight = border + (RBG.db.trackPower ~= "None" and RBG.powerBarHeight or 0)

    local bdColor, bgColor = RBG.db.bdColor, RBG.db.bgColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    self.backdrop.tex:SetColorTexture(bdColor.r, bdColor.g, bdColor.b, bdColor.a)

    if frame.enemy and frame.enemy.class and RBG.db.classColorBars then
        self:SetStatusBarColor(R:classColor(frame.enemy.class))
    else
        local c = RBG.db.barColor
        self:SetStatusBarColor(c.r, c.b, c.g, c.a)
    end

    self:ClearAllPoints()

    if leftBox:IsActive() then
        self:SetPoint("TOPLEFT",leftBox,"TOPRIGHT",-border,-border)
    else
        self:SetPoint("TOPLEFT",frame,"TOPLEFT",-border,-border)
    end
    if rightBox:IsActive() then
        self:SetPoint("BOTTOMRIGHT",rightBox,"BOTTOMLEFT",border,bottomHeight)
    else
        self:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT",border,bottomHeight)
    end

    R:SetSmoothing(frame.healthBar, true)
end



