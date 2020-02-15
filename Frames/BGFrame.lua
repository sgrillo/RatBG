local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

--Lua functions
local _G, tinsert, twipe, tsort, tremove, min, format, rand = _G, tinsert, wipe, table.sort, table.remove, math.min, string.format, math.random
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown

local MAXFRAMES = T.general.maxFrames

RBG.frames = {}
RBG.statusbars = {}
RBG.borders = {}
RBG.activeFrames = {}
RBG.enemies = {}                -- Ordered table for sorting
RBG.frameNames = {}
RBG.pendingUpdate = {}
RBG.testenemies = {}

RBG.testMode = false


------Create Frames-------

function RBG:BuildHeader()
    local ParentFrame = CreateFrame("Frame","RatBG Frames", R.UIParent)
    local c = A.bgFrames.bgColor
    ParentFrame.background = ParentFrame:CreateTexture(nil,"BACKGROUND")
    ParentFrame.background:SetColorTexture(c.r,c.g,c.b,c.a)
    ParentFrame.background:SetAllPoints()
    ParentFrame:SetSize(R:Round(self.db.frameWidth,R.pix), R:Round(self.db.frameHeight,R.pix))
    ParentFrame.title = ParentFrame:CreateFontString(nil,"ARTWORK", "GameFontNormal")
    ParentFrame.title:SetAllPoints()
    ParentFrame.title:SetText(T.RatBlue.displayText.."RatBG Frames")
    ParentFrame.title:BuildFont()
    if R.db.locations[ParentFrame:GetName()] then 
        ParentFrame:SetPoint("TOPLEFT", R.UIParent, "BOTTOMLEFT", unpack(R.db.locations[ParentFrame:GetName()]))
    else
        ParentFrame:SetPoint("CENTER",R.UIParent,"CENTER",0,0)
    end
    R:MakeDraggable(ParentFrame)
    R.fontStrings[ParentFrame.title] = true

    ParentFrame:Hide()

    return ParentFrame

end

function RBG:BuildFrame(name)
    local frame = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    tinsert(RBG.frames, frame)

    frame.enemy = nil
    frame.testenemy = nil
    frame.elements = {}
    frame.staticUpdates = {}
    frame.dynamicUpdates = {}

    frame.leftBox, frame.rightBox = RBG:BuildContainers(frame)

    frame.healthBar = RBG:BuildHealthBar(frame)
    frame.powerBar = RBG:BuildPowerBar(frame)
    frame.Name = RBG:BuildNameText(frame)
    frame.flag = RBG:BuildFlag(frame)
    --frame.leftBox.Rank = RBG:BuildRank(frame)
    --frame.leftBox.Class = RBG:BuildClassIcon(frame)
    --frame.rightBox.Trinket = RBG:BuildTrinketIcon(frame)
    --frame.rightBox.Skull = RBG:BuildSkullIcon(frame)
    --frame.TargetCount = RBG:BuildTargetCount(frame)
    

    frame:SetAttribute("type1","macro")
    frame:SetAttribute("type2","macro")
    frame:SetAttribute("macrotext1","")
    frame:SetAttribute("macrotext2","")
    frame:RegisterForClicks("AnyDown")

    frame.init = false
    frame.active = false

    frame.GetEnemy = function() return RBG.testMode and frame.testenemy or frame.enemy end 

    frame.IsActive = function() return frame.active end

    RBG:RegisterUpdates(frame)

    frame.hoverLayer = CreateFrame("Frame",frame:GetName().."Hover",frame)
    frame.hoverLayer:SetAllPoints()
    frame.hoverLayer:SetFrameLevel(frame:GetFrameLevel()+100)                       --make sure this is on top
    frame.hoverLayer:AddBorder()

    frame:SetScript("OnUpdate", function() RBG:UpdateDynamic(frame) end)

    frame:Hide()

    return frame
end

function RBG:BuildGroup(header)
    local header = header or RBG.HeaderFrame
    local prevFrame
    for _,frame in ipairs(RBG.frames) do
        prevFrame = prevFrame or header
        frame:SetPoint("TOPLEFT",prevFrame,"BOTTOMLEFT",0,R:Round(-RBG.db.barSpacing,R.pix))  --if no spacing, overlap the borders
        prevFrame = frame
    end
end

local function GenerateTestInfo(num)
    local num = num or 10
    twipe(RBG.testenemies)
    for i=1,num do
        local enemy = RBG:GenerateEnemy()
        tinsert(RBG.testenemies,enemy)
    end
    RBG.testenemies[rand(1,min(num,MAXFRAMES))].flag = true
end

function RBG:Hide()                         -- todo stop updates
    RBG.HeaderFrame:Hide()
    for i=1,#RBG.frames do
        RBG.frames[i]:Hide()
    end
end

function RBG:Show()                         -- todo stop updates
    RBG:AssignEnemies()
end

function RBG:Lock()
    RBG.HeaderFrame:lock()
    if not RBG.db.showHeader then RBG.HeaderFrame:Hide() end
end

function RBG:Unlock()
    RBG.HeaderFrame:Show()
    RBG.HeaderFrame:unlock()
end

function RBG:TestToggle(num)
    RBG.testMode = (not RBG.testMode)
    if RBG.testMode then 
        GenerateTestInfo(num)
        RBG:AssignEnemies(num)
    else
        RBG:AssignEnemies()
    end
    RBG:UpdateAll()
    R:Print("Test Mode ", RBG.testMode and "on" or "off")
end 
    

----Enemy Assignment-----

--No need to assign in these, handled by the scanner
function RBG:AddEnemy(enemy)
    tinsert(RBG.enemies, enemy)
end

function RBG:Evict(enemy)
    for i,e in pairs(RBG.enemies) do
        if e == enemy then
            tremove(RBG.enemies, i)
            RBG.frameNames[enemy.fullname] = nil
            return
        end
    end
end

--Temp sort order--
local sortOrder = {"class","name","rank"}

local function Compare(a, b, level)
    local level = level or 1
    if a[sortOrder[level]] == b[sortOrder[level]] and level < #sortOrder then
        return Compare(a, b, level+1)
    elseif sortOrder[level]=="class" then
        return T.SortOrder[a.class] < T.SortOrder[b.class]
    elseif sortOrder[level]=="rank" then
        return a.rank >= b.rank
    else
        return a[sortOrder[level]] <= b[sortOrder[level]]
    end
end

function RBG:AssignEnemies(num)

    local table = (RBG.testMode and "test" or "") .. "enemies"
    local field = (RBG.testMode and "test" or "") .. "enemy"
    --all enemies are assigned simultaneously, since adding a new one requires resorting anyways
    sort(RBG[table], Compare)
    sort(RBG[table], Compare)
    sort(RBG[table], Compare)

    for i=1,#RBG[table] do
        local e, f = RBG[table][i], RBG.frames[i]
        f[field] = e
        f:SetAttribute("macrotext1", "/targetexact "..e.fullname)
        RBG.frameNames[e.fullname] = f
    end

    RBG:ActivateFrames(num or #RBG[table])
    RBG:UpdateAll()

end

function RBG:Clear()
    RBG.activeFrames = {}
    RBG.enemies = {}
    RBG.frameNames = {}
    RBG.pendingUpdate = {}
    for _,frame in pairs(RBG.frames) do
        frame.enemy = nil
        frame:Hide()
    end
    if not RBG.db.showHeader then RBG.HeaderFrame:Hide() end
end



function RBG:ActivateFrames(numEnemies)
    twipe(RBG.activeFrames)
    for i=1,MAXFRAMES do
        if i<=numEnemies then RBG:ActivateFrame(RBG.frames[i])
        else RBG.frames[i]:Hide() end
    end
end

function RBG:ActivateFrame(frame)
    RBG.activeFrames[frame] = true
    frame.active = true
end

function RBG:ActivateNextFrame()
    if RBG.activeFrames[RBG.frames[MAXFRAMES]] then return end -- frames added in order so we have no more space
    for i=1,#RBG.frames do
        if not RBG.activeFrames[RBG.frames[i]] then 
            RBG:ActivateFrame(RBG.frames[i])
            return 
        end
    end
end

--------Updates--------

function RBG:UpdateAll()
    self.UpdateAllStatic()
    self.UpdateAllDynamic()
end

function RBG:UpdateStatic(frame)
    --print(frame:GetName())
    frame:SetSize(R:Round(RBG.db.frameWidth,R.pix), R:Round(RBG.db.frameHeight,R.pix))
    for element in pairs(frame.elements) do
        element:updateStatic(frame)
        if element:IsActive() and element:GetParent():IsActive() then 
            element:Show() 
            --print(element:GetName()," displayed")
        end
    end
end

function RBG:UpdateAllStatic()
    RBG.HeaderFrame:SetSize(R:Round(RBG.db.frameWidth,R.pix), R:Round(RBG.db.frameHeight,R.pix))
    if RBG.db.showHeader and not RBG.HeaderFrame:IsShown() then RBG.HeaderFrame:Show()
    elseif not RBG.db.showHeader and RBG.HeaderFrame:IsShown() then RBG.HeaderFrame:Hide() end
    RBG.UpdateBarTextures()
    RBG:UpdateBorders()
    RBG.powerBarHeight = R:Round(RBG.db.frameHeight / 5, R.pix)
    for frame in pairs(RBG.activeFrames) do
        RBG:UpdateStatic(frame)
        frame:Show() 
    end
end

function RBG:UpdateDynamic(frame)
    if RBG.pendingUpdate[frame] then
        for element in pairs(frame.elements) do
            element:updateDynamic(frame)
        end
        RBG.pendingUpdate[frame] = nil
    end
end

function RBG:UpdateAllDynamic()
    for frame in pairs(RBG.activeFrames) do
        RBG:UpdateDynamic(frame)
    end
end

function RBG:UpdateBarTextures()
    for bar in pairs(RBG.statusbars) do
        if not bar:IsObjectType("StatusBar") then return end
        bar:SetStatusBarTexture(LSM:Fetch("statusbar", RBG.db.barTexture))
        if bar.background then
            local c = RBG.db.bgColor
            bar.background:SetColorTexture(c.r, c.g, c.b, c.a)
        end
    end
end



------------------------------------
--
--      Set frame.staticUpdate = func to run an update in the static cycle 
--      Set frame.dynamicUpdate = func to run an update in the dynamic cycle

function RBG:RegisterUpdates(object)
    local updateMeta = getmetatable(object).__index
    if not updateMeta.updateStatic then updateMeta.updateStatic = function(self, frame) if self.staticUpdate then self:staticUpdate(frame) end end end
    if not updateMeta.updateDynamic then updateMeta.updateDynamic = function(self, frame) if self.dynamicUpdate then self:dynamicUpdate(frame) end end end
    if not updateMeta.AddBorder then updateMeta.AddBorder = RBG.AddBorder end
    if not updateMeta.UpdateBorder then updateMeta.UpdateBorder = RBG.UpdateBorder end
end

function RBG:AddBorder()
    local frame = self
    --create border frames
    local borderFrames = {}
    
    borderFrames.t = CreateFrame("Frame","DONG1",frame)
    borderFrames.r = CreateFrame("Frame","DONG2",frame)
    borderFrames.b = CreateFrame("Frame","DONG3",frame)  
    borderFrames.l = CreateFrame("Frame","DONG4",frame) 
    borderFrames.tl = CreateFrame("Frame","DONG5",frame) 
    borderFrames.tr = CreateFrame("Frame","DONG6",frame) 
    borderFrames.bl = CreateFrame("Frame","DONG7",frame) 
    borderFrames.br = CreateFrame("Frame","DONG8",frame) 
    --[[borderFrames.t:SetPoint("BOTTOMLEFT",frame,"TOPLEFT") borderFrames.t:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT")
    borderFrames.r:SetPoint("TOPLEFT",frame,"TOPRIGHT") borderFrames.r:SetPoint("BOTTOMLEFT",frame,"BOTTOMRIGHT") 
    borderFrames.b:SetPoint("TOPLEFT",frame,"BOTTOMLEFT") borderFrames.b:SetPoint("TOPRIGHT",frame,"BOTTOMRIGHT")
    borderFrames.l:SetPoint("TOPRIGHT",frame,"TOPLEFT") borderFrames.l:SetPoint("BOTTOMRIGHT",frame,"BOTTOMLEFT")
    borderFrames.tl:SetPoint("TOPRIGHT",borderFrames.t,"TOPLEFT") borderFrames.tl:SetPoint("BOTTOMLEFT",borderFrames.l,"TOPLEFT")
    borderFrames.tr:SetPoint("TOPLEFT",borderFrames.t,"TOPRIGHT") borderFrames.tr:SetPoint("BOTTOMRIGHT",borderFrames.r,"TOPRIGHT")
    borderFrames.bl:SetPoint("BOTTOMRIGHT",borderFrames.b,"BOTTOMLEFT") borderFrames.bl:SetPoint("TOPLEFT",borderFrames.l,"BOTTOMLEFT")
    borderFrames.br:SetPoint("BOTTOMLEFT",borderFrames.b,"BOTTOMRIGHT") borderFrames.br:SetPoint("TOPRIGHT",borderFrames.r,"BOTTOMRIGHT") 
    borderFrames.t:SetHeight(R:Round(RBG.db.borderWidth,R.pix)) borderFrames.b:SetHeight(R:Round(RBG.db.borderWidth,R.pix))
    borderFrames.l:SetWidth(R:Round(RBG.db.borderWidth,R.pix)) borderFrames.r:SetWidth(R:Round(RBG.db.borderWidth,R.pix)) ]]

    
    borderFrames.tl:SetPoint("BOTTOMRIGHT",frame,"TOPLEFT",R.pix,-R.pix) 
    borderFrames.tr:SetPoint("BOTTOMLEFT",frame,"TOPRIGHT",-R.pix,-R.pix)
    borderFrames.bl:SetPoint("TOPRIGHT",frame,"BOTTOMLEFT",R.pix,R.pix) 
    borderFrames.br:SetPoint("TOPLEFT",frame,"BOTTOMRIGHT",-R.pix,R.pix)

    borderFrames.t:SetPoint("TOPLEFT",borderFrames.tl,"TOPRIGHT")   borderFrames.t:SetPoint("BOTTOMRIGHT",borderFrames.tr,"BOTTOMLEFT")
    borderFrames.r:SetPoint("TOPLEFT",borderFrames.tr,"BOTTOMLEFT") borderFrames.r:SetPoint("BOTTOMRIGHT",borderFrames.br,"TOPRIGHT")
    borderFrames.b:SetPoint("TOPLEFT",borderFrames.bl,"TOPRIGHT")   borderFrames.b:SetPoint("BOTTOMRIGHT",borderFrames.br,"BOTTOMLEFT")
    borderFrames.l:SetPoint("TOPLEFT",borderFrames.tl,"BOTTOMLEFT") borderFrames.l:SetPoint("BOTTOMRIGHT",borderFrames.bl,"TOPRIGHT")

    for _,b in pairs{borderFrames.tl, borderFrames.tr, borderFrames.bl, borderFrames.br} do 
        local dim = R:Round(RBG.db.borderWidth, R.pix)
        b:SetSize(dim,dim) 
    end
    
    for _,bd in pairs(borderFrames) do bd.tex=bd:CreateTexture(nil,"BORDER") bd.tex:SetVertexColor(rgb(RBG.db.bdColor)) bd.tex:SetAllPoints() bd:Show() bd:SetFrameLevel(50)end

    RBG.borders[borderFrames] = true

    frame.borders=borderFrames

end

function RBG:UpdateBorders()
    for border in pairs(RBG.borders) do
        RBG:UpdateBorder(border)
    end
end

function RBG:UpdateBorder(border, width, color, level)
    local border, width, color, level = border or self.borders, R:Round(width,R.pix) or R:Round(RBG.db.borderWidth,R.pix), color or RBG.db.bdColor, level or 20
    for _,b in pairs{border.tl, border.tr, border.bl, border.br} do 
        local dim = R:Round(RBG.db.borderWidth, R.pix)
        b:SetSize(dim,dim) 
    end
    for _,bd in pairs(border) do bd.tex:SetColorTexture(rgb(color)) bd.tex:SetAllPoints() bd:Show() bd:SetFrameLevel(level) end
end

function RBG:OnInitialize()
    self.db = R.db.bgFrames
    self.statusbars = R.statusbars
    self.powerBarHeight = R:Round(self.db.frameHeight / 5, R.pix)

    self.HeaderFrame = RBG:BuildHeader()
    --self.HeaderFrame:Show()

    for i=1,MAXFRAMES do
        local frame = self:BuildFrame("RatBGFrame"..i)
        frame.healthBar:Show()
        frame:Show()
    end

    self:BuildGroup(self.HeaderFrame)


    ---DEBUG fill frames with dummy data---
    self:AssignEnemies()
    self:UpdateAllStatic()
    
end





