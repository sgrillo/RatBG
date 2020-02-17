local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local tinsert = tinsert

local RBG = R.bgFrames

function RBG:BuildRank(frame)

end

function RBG:UpdateRankStatic(frame)

    local rankIcon = CreateFrame("Frame", frame.."RankIcon")

    rankIcon.bg = rankIcon:CreateTexture(nil,"BORDER")

    rankIcon.icon = rankIcon.bg:CreateTexture(nil,"BORDER")

    rankIcon.staticUpdate = RBG.UpdateRankStatic

    --icon goes into container, not onto frame
    tinsert(frame.leftBox.elements, rankIcon)

    rankIcon.IsActive = function() return RBG.db.icons.rankIcon end

    RBG:RegisterUpdates(rankIcon)

end

function RBG:UpdateRankStatic()
    local enemy = frame:GetEnemy()

    self.bg:SetColorTexture(rgb(RBG.db.bgColor))

    if enemy and enemy.rank and enemy.rank > 0 then
    end


end

