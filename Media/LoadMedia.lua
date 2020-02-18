local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local format = string.format

T.Media = {
    rankIcons = {},
    flagIcons = {
        Alliance = "Interface\\WorldStateFrame\\AllianceFlag",
        Horde = "Interface\\WorldStateFrame\\HordeFlag"
    },
    classTextures = "Interface\\WORLDSTATEFRAME\\Icons-Classes",
    classTextureCoords = {                                             
        WARRIOR = {0, 64/256, 0, 64/256},
        MAGE = {64/256, 128/256, 0, 64/256},
        ROGUE = {128/256, 192/256, 0, 64/256},
        DRUID = {192/256, 1, 0, 64/256},
        HUNTER = {0, 64/256, 64/256, 128/256},
        SHAMAN = {64/256, 128/256, 64/256, 128/256},
        PRIEST = {128/256, 192/256, 64/256, 128/256},
        WARLOCK = {192/256, 1, 64/256, 128/256},
        PALADIN = {0, 64/256, 128/256, 192/256}
    },
    fapColor = {
        r = 172.0/256.0,
        g = 216.0/256.0,
        b = 253.0/256.0,
        a = 1
    },
    freedomColor = {
        r = 248.0/256.0,
        g = 125.0/256.0,
        b = 47.0/256.0,
        a = 1
    }
}

do
    for i=1,14 do
        T.Media.rankIcons["rank"..i] = format("Interface\\PvPRankBadges\\PvPRank%02d.blp",i)
    end


end


