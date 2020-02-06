local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

--Lua functions
local _G = _G
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown


local DATA = R.enemyData
local FRAMES = R.bgFrames


