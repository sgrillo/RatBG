local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

local rand, tinsert = math.random, tinsert

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

    healthBar.color = RBG.db.barColor
    healthBar.colorMult = 1

    self.statusbars[healthBar] = true
    tinsert(frame.elements, healthBar)

    healthBar.IsActive = function() return true end

    RBG:RegisterUpdates(healthBar)

    healthBar:AddBorder()

    healthBar.HealthBarColor = function(self) 
        local c = {}
        c.r, c.g, c.b = rgb(healthBar.color)
        c.r, c.g, c.b = c.r*healthBar.colorMult, c.g*healthBar.colorMult, c.b*healthBar.colorMult
        healthBar:SetStatusBarColor(c.r, c.g, c.b, c.a)
    end

    return healthBar
end


function RBG:UpdateHealthDynamic(frame)
    if RBG.testMode then return end
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
    
    local bottomHeight = frame.powerBar:IsActive() and R:Round(RBG.powerBarHeight - border, R.pix) or 0

    local bdColor, bgColor, hpColor = RBG.db.bdColor, RBG.db.bgColor, RBG.db.barColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)

    local enemy = frame:GetEnemy()  
    local c = {}

    if enemy and enemy.class and RBG.db.classColorBars then
        c.r,c.g,c.b = R:classColor(enemy.class)
        c.a = 1
    else
        c = RBG.db.barColor
    end
    self:SetStatusBarColor(c.r, c.g, c.b, c.a)
    self.color = c
    self:ClearAllPoints()

    if leftBox:IsActive() then
        --print("left box anchor")
        self:SetPoint("TOPLEFT",leftBox,"TOPRIGHT",-R:Round(border, R.pix),0)
    else
        --print("left frame anchor")
        self:SetPoint("TOPLEFT",frame,"TOPLEFT")
    end
    if rightBox:IsActive() then
        --print("right box anchor")
        self:SetPoint("BOTTOMRIGHT",rightBox,"BOTTOMLEFT",R:Round(border, R.pix),bottomHeight)
    else
        --print("right frame anchor")
        self:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,bottomHeight)
    end

    if frame.Name then frame.Name:SetAllPoints(self) end            --reset the name text so it doesnt dissapear

    if RBG.db.trackHealth then
        if RBG.testMode then self:SetValue(rand())
        elseif enemy and enemy.currentHealth and enemy.maxHealth then
            self:SetValue(enemy.currentHealth / enemy.maxHealth)
        else
            self:SetValue(1)
        end
    else
        self:SetValue(1)
    end

end



