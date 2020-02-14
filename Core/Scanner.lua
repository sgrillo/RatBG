local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG, Scanner = R.bgFrames, R.scanner

--lua functions
local strmatch = strmatch
--Wow API
local InCombatLockdown, GetServerTime, GetTime = InCombatLockdown, GetServerTime, GetTime

Scanner.frame = CreateFrame("Frame")

local scanner, scoreTimer, updateTimer = Scanner.frame, 0, 0

local BGSize = {} BGSize["Warsong Gulch"] = 10 BGSize["Arathi Basin"] = 15

function Scanner:CheckZone()
    local zone = GetInstanceInfo()
    if zone == "Warsong Gulch" then
        Scanner.zone = zone 
        Scanner:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
        scanner:SetScript("OnUpdate", Scanner.search)
        Scanner:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    else
        RBG:Clear()
        Scanner:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
        Scanner:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
        scanner:SetScript("OnUpdate", nil)
    end

end

function Scanner:OnInitialize()
    self:RegisterEvent("PLAYER_ENTERING_WORLD","CheckZone")
    
end

function Scanner:search()
    if GetTime() < updateTimer then return end

    updateTimer = GetTime() + R.db.scanner.updateFreq

    local seen = {}
        
    local numRaid = GetNumGroupMembers(LE_PARTY_CATEGORY_INSTANCE)
    
    for i=1,numRaid do
        Scanner:scanTree("raid"..i.."target", seen)
    end
    for i=1,100 do
        Scanner:scanTree("nameplate"..i,seen)
    end
    Scanner:scanTree("target",seen)
    Scanner:scanTree("mouseover",seen)
    Scanner:updateUnits(seen) 
end

function Scanner:UPDATE_MOUSEOVER_UNIT()
    local seen = {}
    Scanner:scanTree("mouseover",seen)
    Scanner:updateUnits(seen)
end

function Scanner:updateUnits(seen)
    for name,id in pairs(seen) do
        local frame = RBG.frameNames[name]
        if frame then
            local enemy = RBG.frameNames[name].enemy
            if enemy then
                print("found enemy: "..name) 
                enemy.maxHealth = UnitHealthMax(id)
                enemy.currentHealth = UnitHealth(id)
                _, enemy.powerType = UnitPowerType(id)
                enemy.maxPower = UnitPowerMax(id)
                enemy.currentPower = UnitPower(id)
                if enemy.class == "Druid" and enemy.powerType == "MANA" then
                    enemy.maxMana = UnitPowerMax(id)
                    enemy.currentMana = UnitPower(id)
                end
                RBG.pendingUpdate[frame] = true
            end
        end
    end
end

function Scanner:scanTree(unitID, seen)
    if not UnitIsVisible(unitID) or UnitIsFriend(unitID, "player") then
        return
    end
    if UnitIsPlayer(unitID) then
        local name, realm = UnitFullName(unitID)
        name = name .. (realm and "-"..realm or "")
        if seen[name] then return end --already scanned this player
        seen[name] = unitID
    end
    Scanner:scanTree(unitID.."target", seen)
end

--check the scoreboard for enemies 
function Scanner:UPDATE_BATTLEFIELD_SCORE()
    if InCombatLockdown() then
        Scanner:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
        Scanner:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    if GetServerTime() < scoreTimer then return end

    local found, exists = false, {} 

    scoreTimer = GetServerTime() + (#RBG.enemies == BGSize[Scanner.zone] and 30 or 5)           --only check every 30s if the bg is full, incase someone leaves

    for _,enemy in pairs(RBG.enemies) do
        exists[enemy.fullname] = true
    end
    
    for i=1,GetNumBattlefieldScores() do
        local pname, _, _, _, _, pfaction, prank, _, pclass = GetBattlefieldScore(i)
        if pname then                                        --handle those stupid broken names
            if pfaction ~= R.myFactionID then
                if exists[pname] then exists[pname] = nil end
                if not RBG.frameNames[pname] then           --not tracking this player
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
        end
    end

    for enemy in pairs(exists) do            --these players are no longer in the bg
        RBG:Evict(enemy)
        found = true
    end
    if found then
        RBG:AssignEnemies()
    end
end

function Scanner:PLAYER_REGEN_ENABLED()
    Scanner:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
end



