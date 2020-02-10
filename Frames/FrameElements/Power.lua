local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildPowerBar(frame)
    local PowerBar = CreateFrame("StatusBar", frame:GetName().."PowerBar", frame.healthBar)
    PowerBar.background = PowerBar:CreateTexture(nil, "BORDER")
    PowerBar.backdrop = CreateFrame("Frame", frame:GetName().."Border", PowerBar)

    PowerBar:SetFrameLevel(frame:GetFrameLevel()+10)                    -- make sure theres room to put stuff around this
    
    --setup border
    local bW = A.bgFrames.borderWidth
    PowerBar.backdrop:SetPoint("TOPLEFT",PowerBar,"TOPLEFT",-bW,bW)
    PowerBar.backdrop:SetPoint("BOTTOMRIGHT",PowerBar,"BOTTOMRIGHT", bW, -bW)
    PowerBar.backdrop:SetFrameLevel(PowerBar:GetFrameLevel()-2)
    PowerBar.backdrop.tex=PowerBar.backdrop:CreateTexture(nil, "BORDER")
    PowerBar.backdrop.tex:SetAllPoints()

    --set statusbar background
    PowerBar.background:SetAllPoints()

    --register with everything

    PowerBar:SetMinMaxValues(0,1)
    PowerBar:SetValue(1)

    PowerBar.staticUpdate = RBG.UpdatePowerStatic
    PowerBar.dynamicUpdate = RBG.UpdatePowerDynamic

    self.statusbars[PowerBar] = true
    frame.elements[PowerBar] = true

    PowerBar.IsActive = function() return RBG.db.trackPower ~= "None" end

    RBG:RegisterUpdates(PowerBar)
    
    return PowerBar
end

function RBG:UpdatePowerDynamic(frame)

end

function RBG:UpdatePowerStatic(frame)

    --print("PowerBar", self:GetName(), "parent", frame)
    rightBox, leftBox, border = frame.rightBox, frame.leftBox, A.bgFrames.borderWidth
    local bottomHeight = border + RBG.powerBarHeight      --Only matters if this is displayed

    local bdColor, bgColor = RBG.db.bdColor, RBG.db.bgColor
    self.background:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    self.backdrop.tex:SetColorTexture(bdColor.r, bdColor.g, bdColor.b, bdColor.a)

    self:SetStatusBarColor(rgb(T.general.powerColors.Mana))

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

    --R:SetSmoothing(frame.PowerBar, true)
end



