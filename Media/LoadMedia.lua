local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local format = string.format

T.Media = {
    rankIcons = {},
    flagIcons = {
        Alliance = "Interface\\WorldStateFrame\\AllianceFlag",
        Horde = "Interface\\WorldStateFrame\\HordeFlag"
    }
}

do
    for i=1,14 do
        T.Media.rankIcons["rank"..i] = format("Interface\\PvPRankBadges\\PvPRank%02d.blp",i)
    end
end


