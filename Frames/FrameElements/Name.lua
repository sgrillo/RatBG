local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildNameText(frame)
    local healthBar = frame.healthBar
    local nameText = healthBar:CreateFontString(nil,"ARTWORK", "GameFontNormal")
    nameText:BuildFont()

    nameText.staticUpdate = RBG.UpdateNameStatic
    R.fontStrings[nameText] = true

    nameText.IsActive = function() return true end

    RBG:RegisterUpdates(nameText)

    return nameText
end

function RBG:UpdateNameStatic(frame)
    rightBox, leftBox = frame.rightBox, frame.leftBox

    --all font changes are handled by Core methods

    self:ClearAllPoints()

    if leftBox:IsActive() then
        self:SetPoint("TOPLEFT",leftBox,"TOPRIGHT",border + 2,0)
    else
        self:SetPoint("TOPLEFT",frame,"TOPLEFT",border + 2,0)
    end
    if rightBox:IsActive() then
        self:SetPoint("BOTTOMRIGHT",rightBox,"BOTTOMLEFT",0,0)
    else
        self:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",0,0)
    end

    --Set Values
    if frame:hasEnemy() then
        self:SetText(RBG.db.fullName and frame.enemy.fullName or frame.enemy.name)
    end
end