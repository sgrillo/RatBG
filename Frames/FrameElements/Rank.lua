local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

function RBG:BuildRank(frame)

end

function RBG:UpdateRankStatic(frame)

    local rankIcon = CreateFrame("Frame", frame.."RankIcon")

    rankIcon.bg = rankIcon:CreateTexture(nil,"BORDER")

    rankIcon.icon = rankIcon.bg:CreateTexture(nil,"BORDER")

    rankIcon.staticUpdate = RBG.UpdateRankStatic
    rankIcon.dynamicUpdate = RBG.UpdateRankDynamic

    --icon goes into container, not onto frame



end

