local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG, Scanner, fadetime = R.bgFrames, R.scanner, T.general.rangeFadeTime

--lua functions
local strmatch, strupper = strmatch, strupper
--Wow API
local InCombatLockdown, GetServerTime, GetTime, GetSpellInfo = InCombatLockdown, GetServerTime, GetTime, GetSpellInfo

Scanner.frame = CreateFrame("Frame")

local scanner, scoreTimer, updateTimer = Scanner.frame, 0, 0

local BGSize = {} BGSize["Warsong Gulch"] = 10 BGSize["Arathi Basin"] = 15

function Scanner:CheckZone()
    local zone = GetInstanceInfo()
    Scanner.zone = zone
    --R:Print(zone)
    if zone == "Warsong Gulch" then
        scanner:SetScript("OnUpdate", Scanner.search) 
        Scanner:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")
        Scanner:RegisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL", "UPDATE_BATTLEFIELD_SCORE")
        Scanner:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
        Scanner:RegisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE", "FlagMessage")
        Scanner:RegisterEvent("CHAT_MSG_BG_SYSTEM_HORDE", "FlagMessage")
        Scanner:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        if RBG.testMode then RBG:TestToggle() end
    else
        R:CancelAllTimers()
        RBG:Clear()
        scanner:SetScript("OnUpdate", nil)
        Scanner:UnregisterEvent("UPDATE_BATTLEFIELD_SCORE")
        Scanner:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
        Scanner:UnregisterEvent("CHAT_MSG_BG_SYSTEM_ALLIANCE")
        Scanner:UnregisterEvent("CHAT_MSG_BG_SYSTEM_HORDE")
        Scanner:UnregisterEvent("CHAT_MSG_BG_SYSTEM_NEUTRAL")
        Scanner:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end

end

local function GuessAlive(frame)
    local enemy = frame and frame.enemy
    if enemy and enemy.currentHealth == 0 then                    --if they cast something, then they're clearly not dead so speculatively set health/power to full
        enemy.currentHealth = enemy.maxHealth           --until receive a real update
        enemy.currentPower = enemy.maxPower
        enemy.currentMana = enemy.maxMana
        RBG.pendingUpdate[frame] = true 
    end
end

function Scanner:COMBAT_LOG_EVENT_UNFILTERED()
    local timestamp, event, _, _, srcName, srcFlags, _, _, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    local strFAP = GetSpellInfo(6615)
    local strFreedom = GetSpellInfo(1044)

    if bit.band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then              --enemy is the destination, used for buff/debuff tracking
        local frame = RBG.frameNames[destName]
        if frame then
            frame.rangeTime = timestamp + fadetime 
            if event == "SPELL_AURA_APPLIED" and (spellName == strFAP) then
                if frame.enemy then
                    frame.enemy.fapTime = timestamp + 30
                    RBG.pendingUpdate[frame] = true
                    frame.fapTimer = R:ScheduleTimer(function() 
                        RBG.pendingUpdate[frame] = true
                        RBG:UpdateDynamic(frame) end, 30)
                end
            end
            if event == "SPELL_AURA_REMOVED" and (spellName == strFAP) then
                if frame.enemy then
                    frame.enemy.fapTime = 0
                    RBG.pendingUpdate[frame] = true
                    if frame.fapTimer then R:CancelTimer(frame.timer) end
                end
            end
        end
    end
    if bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then              --enemy is the source, used for sanity tracking
        local frame = RBG.frameNames[srcName]
        if frame and (strmatch(event, "SPELL_CAST") or strmatch(event, "SWING")) then
            GuessAlive(frame)
            frame.rangeTime = timestamp + fadetime
        end   
    end        
end

function Scanner:search()
    if GetServerTime() > scoreTimer then
        scoreTimer = GetServerTime() + (#RBG.enemies == BGSize[Scanner.zone] and 30 or 1)           --only check every 30s if the bg is full, incase someone leaves
        RequestBattlefieldScoreData()
    end

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
            frame.rangeTime = GetServerTime() + fadetime
            local enemy = RBG.frameNames[name].enemy
            if enemy then
                --print("found enemy: "..name) 
                enemy.maxHealth = UnitHealthMax(id)
                enemy.currentHealth = UnitHealth(id)
                _, enemy.powerType = UnitPowerType(id)
                enemy.maxPower = UnitPowerMax(id)
                enemy.currentPower = UnitPower(id)
                if enemy.class == "DRUID" and enemy.powerType == "MANA" then
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

    local found, exists = false, {} 


    for _,enemy in pairs(RBG.enemies) do
        exists[enemy.fullname] = true
    end
    
    for i=1,GetNumBattlefieldScores() do
        local pname, _, _, _, _, pfaction, prank, _, _, pclass = GetBattlefieldScore(i)
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
                        maxMana = 100,
                        currentMana = 100,
                        powerType = "Mana",
                        rank = prank > 0 and (prank - 4) or 0,
                        flag = false
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

local function ClearFlags()
    for i,enemy in ipairs(RBG.enemies) do
        if enemy.flag then 
            enemy.flag = false
            RBG.pendingUpdate[RBG.frames[i]] = true
        end
    end
end

function Scanner:FlagMessage(event, ...)
    local friendly, msg = strmatch(event, strupper(R.myfaction)), select(1,...)
    if msg and strmatch(msg, "captured") then
        ClearFlags()
    elseif friendly and msg and strmatch(msg, "dropped") then
        ClearFlags()
    elseif not friendly and msg and strmatch(msg, "picked up") then
        ClearFlags()
        local name = select(5,...)
        local frame = RBG.frameNames[name]
        if frame and frame.enemy then
            frame.enemy.flag = true 
            RBG.pendingUpdate[frame] = true
        end
        GuessAlive(frame)
    end
end

function Scanner:OnInitialize()
    self:RegisterEvent("PLAYER_ENTERING_WORLD","CheckZone")
    
end


