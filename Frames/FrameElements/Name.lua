local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local tinsert = tinsert

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildNameText(frame)
    local healthBar = frame.healthBar
    local nameText = healthBar:CreateFontString(frame:GetName().."NameText","OVERLAY", "GameFontNormal")

    
    nameText:BuildFont()
    nameText:SetPoint("TOPLEFT",healthBar,"TOPLEFT")
    nameText:SetPoint("BOTTOMRIGHT",healthBar,"BOTTOMRIGHT",0,R.pix)

    nameText.staticUpdate = RBG.UpdateNameStatic
    R.fontStrings[nameText] = true

    nameText.IsActive = function() return true end

    tinsert(frame.elements, nameText)
    RBG:RegisterUpdates(nameText)

    return nameText
end

function RBG:UpdateNameStatic(frame)
    healthBar = frame.healthBar

    --all font changes are handled by Core methods


    self:ClearAllPoints()
    self:SetPoint("TOPLEFT",healthBar,"TOPLEFT")
    self:SetPoint("BOTTOMRIGHT",healthBar,"BOTTOMRIGHT",0,R.pix)

    --Set Values
    local enemy = RBG.testMode and frame.testenemy or frame.enemy
    if enemy then
        self:SetText(RBG.db.fullName and enemy.fullname or enemy.name)
        if RBG.db.classColorText then
            self:SetTextColor(R:classColor(enemy.class))
        else
            self:SetTextColor(rgb(R.db.font.color))
        end
    end
end