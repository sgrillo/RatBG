local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG, Scanner = R.bgFrames, R.scanner

--lua functions
local strmatch = strmatch
--Wow API
local InCombatLockdown, GetServerTime = InCombatLockdown, GetServerTime

Scanner.frame = CreateFrame("Frame")

local scanner, updateTimer = Scanner.frame, 0

--local BGSize = {"Warsong Gulch" = 10, "Arathi Basin" = 15, "Alterac Valley" = 40}

function Scanner:CheckZone()
    local zone = GetInstanceInfo()
    if zone == "Warsong Gulch" then
        Scanner:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
        --Scanner:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    else
        Scanner:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
        Scanner:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
    end

end

function Scanner:OnInitialize()
    self:RegisterEvent("PLAYER_ENTERING_WORLD","CheckZone")
end

--check the scoreboard for enemies 
function Scanner:UPDATE_BATTLEFIELD_SCORE()
    if InCombatLockdown() then
        Scanner:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
        Scanner:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    if GetServerTime() < updateTimer then return end

    updateTimer = GetServerTime() + 30

    local found = false
    for i=1,GetNumBattlefieldScores() do
        R:Print(GetBattlefieldScore(i))
        local pname, _, _, _, _, pfaction, prank, _, pclass = GetBattlefieldScore(i)
        if pfaction ~= R.myFactionID and not RBG.frameNames[pname] then           --not tracking this player
            found = true
            local enemy = {
                name = strmatch(pname,"(.-)%-(.*)$") or pname,
                fullname = pname,
                class = pclass,
                maxHealth = 100,
                currentHealth = 100,
                maxPower = 100,
                currentPower = 100,
                powerType = "Mana",
                rank = prank
            }
            RBG:AddEnemy(enemy)
        end
    end
    if found then
        RBG:AssignEnemies()
    end
end

function Scanner:PLAYER_REGEN_ENABLED()
    Scanner:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
end



