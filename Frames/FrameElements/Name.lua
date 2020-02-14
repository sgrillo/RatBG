local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

function RBG:BuildNameText(frame)
    local healthBar = frame.healthBar
    local nameText = healthBar:CreateFontString(frame:GetName().."NameText","OVERLAY", "GameFontNormal")

    
    nameText:BuildFont()
    nameText:SetAllPoints()

    nameText.staticUpdate = RBG.UpdateNameStatic
    R.fontStrings[nameText] = true

    nameText.IsActive = function() return true end

    frame.elements[nameText] = true
    RBG:RegisterUpdates(nameText)

    return nameText
end

function RBG:UpdateNameStatic(frame)
    healthBar = frame.healthBar

    --all font changes are handled by Core methods


    --self:ClearAllPoints()

    --self:SetPoint("BOTTOMLEFT",healthBar,"BOTTOMLEFT",2,0)
    --self:SetPoint("TOPRIGHT",healthBar,"RIGHT")

    --Set Values
    if frame.enemy then
        self:SetText(RBG.db.fullName and frame.enemy.fullname or frame.enemy.name)
        if RBG.db.classColorText then
            self:SetTextColor(R:classColor(frame.enemy.class))
        else
            self:SetTextColor(rgb(R.db.font.color))
        end
    end
end