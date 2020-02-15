local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

min,max = math.min, math.max

function RBG:BuildFlag(frame)
    local flagIcon = CreateFrame("Frame", frame:GetName().."FlagIcon", frame)
    flagIcon.background = flagIcon:CreateTexture(nil, "BORDER")
    flagIcon:SetFrameLevel(frame:GetFrameLevel()+20)                --make sure this is on top

    flagIcon.tex = flagIcon:CreateTexture(nil,"BORDER")
    flagIcon.tex:SetAllPoints()
    flagIcon.tex:SetTexture(T.Media.flagIcons[R.myfaction])

    --set statusbar background
    flagIcon.background:SetAllPoints()

    flagIcon.staticUpdate = RBG.UpdateFlagStatic
    flagIcon.dynamicUpdate = RBG.UpdateFlagDynamic

    frame.elements[flagIcon] = true

    flagIcon.active = false

    flagIcon.IsActive = function() return flagIcon.active end

    RBG:RegisterUpdates(flagIcon)

    flagIcon:Hide()

end

function RBG:UpdateFlagStatic(frame)
    local offset = RBG.db.flag.flagOffset * R.pix
    R:Print("flag:",offset, R.pix)
    self:SetPoint("LEFT",frame,"LEFT", offset,0)
    local dim = RBG.db.flag.flagSize
    self:SetSize(dim, dim)
    if (not RBG.db.flag.trackFlag) or (not frame.enemy) or (not frame.enemy.flag) then 
        self.active = false
        self:Hide()
        return
    end
end

function RBG:UpdateFlagDynamic(frame)
    if RBG.db.flag.trackFlag and frame.enemy and frame.enemy.flag then
        self.active = true
        self:Show()
    else
        self.active = false
        self:Hide()
    end
end