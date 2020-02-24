local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG, Scanner, Sync = R.bgFrames, R.scanner, R.sync

local syncTimer = 0

local syncFrame = CreateFrame("Frame")



function Sync:Enable()
end

function Sync:Disable()
end

function Sync:OnUpdate()
end