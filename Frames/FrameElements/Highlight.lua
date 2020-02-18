local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

local tinsert, time = tinsert, GetServerTime

function RBG:BuildHighlight(frame)

    local highlight = CreateFrame("Frame",frame:GetName().."Hightlight",frame)
    highlight:SetAllPoints()
    highlight:SetFrameLevel(frame:GetFrameLevel()+100)                       --make sure this is on top
    
    highlight.staticUpdate = RBG.UpdateHighlight
    highlight.dynamicUpdate = RBG.UpdateHighlight

    highlight.IsActive = function() return true end

    tinsert(frame.elements, highlight)
    
    RBG:RegisterUpdates(healthBar)
    frame.hoverLayer:AddBorder()
end


function RBG:UpdateHighlight(frame)
    self:SetAllPoints()

    local enemy = frame:GetEnemy()

    if enemy and enemy.fapTime and enemy.fapTime > time then
        RBG:UpdateBorder(self.border, RBG.db.borderWidth + 1, rgb(T.Media.fapColor))
    elseif enemy and enemy.freedomTime and enemy.freedomTime > time then
        RBG:UpdateBorder(self.border, RBG.db.borderWidth + 1, rgb(T.Media.freedomColor))
    else
        RBG:UpdateBorder(self.border)
    end

end