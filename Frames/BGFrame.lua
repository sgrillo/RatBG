local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames

--Lua functions
local _G, tinsert = _G, tinsert
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown

RBG.frames = {}
RBG.activeFrames = {}
RBG.enemies = {}

function RBG:BuildFrame(name)
    local frame = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    RBG.frames[frame]=true
    frame.HealthBar = RBG:BuildHealthBar(frame)
    frame.PowerBar = RBG:BuildPowerBar(frame)
    frame.Name = RBG:BuildNameText(frame)
    frame.Rank = RBG:BuildRank(frame)
    frame.Class = RBG:BuildClassIcon(frame)
    frame.Trinket = RBG:BuildTrinketIcon(frame)
    frame.TargetCount = RBG:BuildTargetCount(frame)
    frame.Skull = RBG:BuildSkullIcon(frame)

    return frame
end







function RBG:OnInitialize()
    local maxFrames = R.global.general.maxFrames
    self.db = r.db.bgFrames
    for i,maxFrames do
        self.BuildFrame("RatBGFrame"..i)
    end
end







