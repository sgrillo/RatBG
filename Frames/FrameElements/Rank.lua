local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local tinsert = tinsert

local RBG = R.bgFrames

function RBG:BuildRank(frame)

    local rankIcon = CreateFrame("Frame", frame:GetName().."RankIcon", frame.leftBox)

    rankIcon.bg = rankIcon:CreateTexture(nil,"BORDER")
    rankIcon.icon = rankIcon:CreateTexture(nil,"ARTWORK")

    rankIcon.bg:SetAllPoints()
    rankIcon.icon:SetAllPoints()

    rankIcon.staticUpdate = RBG.UpdateRankStatic

    --icon goes into container, not onto frame

    tinsert(rankIcon:GetParent().elements, rankIcon)

    rankIcon.IsActive = function() return RBG.db.icons.rankIcon end

    RBG:RegisterUpdates(rankIcon)

    rankIcon:AddBorder()

end

function RBG:UpdateRankStatic(frame)
    if not RBG.db.icons.rankIcon then self:Hide() return end
    local enemy = frame:GetEnemy()

    self.bg:SetColorTexture(rgb(RBG.db.bgColor))

    local container = self:GetParent()

    if container.attach == container then
        self:SetPoint("TOPLEFT", container, "TOPLEFT")
    else
        local attachpoint = container.attach
        self:SetPoint("TOPLEFT", attachpoint, "TOPRIGHT")
    end

    local dim = frame:GetHeight()
    self:SetSize(dim, dim)

    self.bg:SetAllPoints()
    self.icon:SetAllPoints()

    if enemy and enemy.rank and enemy.rank > 0 then
        self.icon:SetTexture(T.Media.rankIcons["rank"..enemy.rank])
    end


end

