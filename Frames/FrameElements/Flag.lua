local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

function RBG:BuildFlag(frame)
    local flagIcon = CreateFrame("Frame", frame.."FlagIcon")
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

    flagIcon:IsActive = function() return flagIcon.active end

    RBG:RegisterUpdates(flagIcon)

end

function RBG:UpdateFlagStatic(frame)
    if not RBG.db.flag.trackFlag then 
        self.active = false
        self:Hide()
        return
    end
    self:SetPoint("LEFT",frame,"LEFT",RBG.db.flag.flagOffset*R.pix)
    local dim = RBG.db.flag.flagSize*R.pix
    self:SetSize(dim, dim)
end

function RBG:UpdateFlagDynamic(frame)
    if RBG.db.flag.trackFlag and frame.enemy and frame.enemy.flag then
        self.active = true
    else
        self.active = false
        self:Hide()
    end
end