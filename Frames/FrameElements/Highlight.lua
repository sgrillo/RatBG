local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

local tinsert, servertime = tinsert, GetServerTime

function RBG:BuildHighlight(frame)

    local highlight = CreateFrame("Frame",frame:GetName().."Hightlight",frame)
    highlight:SetAllPoints()
    highlight:SetFrameLevel(frame:GetFrameLevel()+15)                       --make sure this is on top
    
    highlight.staticUpdate = RBG.UpdateHighlight
    highlight.dynamicUpdate = RBG.UpdateHighlight

    highlight.IsActive = function() return true end

    tinsert(frame.elements, highlight)
    
    RBG:RegisterUpdates(highlight)
    highlight:AddBorder()

    return highlight
end


function RBG:UpdateHighlight(frame)
    self:SetAllPoints()

    local enemy = frame:GetEnemy()

    if enemy and enemy.fapTime and enemy.fapTime > servertime() then
        self:UpdateBorder(RBG.db.borderWidth + 1, T.Media.fapColor, "OVERLAY")
    elseif enemy and enemy.freedomTime and enemy.freedomTime > servertime() then
        self:UpdateBorder(RBG.db.borderWidth + 1, T.Media.freedomColor, "OVERLAY")
    else
        self:UpdateBorder()
    end

end