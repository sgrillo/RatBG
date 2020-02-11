local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local RBG = R.bgFrames
local LSM = R.Libs.LSM

--Lua functions
local _G, tinsert, min, twipe= _G, tinsert, math.min, wipe
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown

local MAXFRAMES = T.general.maxFrames

RBG.frames = {}
RBG.statusbars = {}
RBG.activeFrames = {}
RBG.enemies = {}

local ParentFrame = CreateFrame("Frame","RatBG Frames", UIParent)
ParentFrame:SetMovable(true)
ParentFrame:SetUserPlaced(true)

function RBG:CreateHeader()
    local c = A.bgFrames.bgColor
    ParentFrame.background = ParentFrame:CreateTexture(nil,"BACKGROUND")
    ParentFrame.background:SetColorTexture(c.r,c.g,c.b,c.a)
    ParentFrame.background:SetAllPoints()
    ParentFrame:SetSize(self.db.frameWidth, self.db.frameHeight)
    ParentFrame.title = ParentFrame:CreateFontString(nil,"ARTWORK", "GameFontNormal")
    ParentFrame.title:SetAllPoints()
    ParentFrame.title:SetText(T.RatBlue.displayText.."RatBG Frames")
    ParentFrame.title:BuildFont()
    ParentFrame:SetPoint("CENTER")
    R:MakeDraggable(ParentFrame)
    R.fontStrings[ParentFrame.title] = true
    ParentFrame:unlock()

    return ParentFrame

end

function RBG:PLAYER_ENTERING_WORLD()
    self:UpdateAllStatic()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end

function RBG:BuildFrame(name)
    local frame = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    tinsert(RBG.frames, frame)

    frame.enemy = {}
    frame.elements = {}
    frame.staticUpdates = {}
    frame.dynamicUpdates = {}

    frame.leftBox, frame.rightBox = RBG:BuildContainers(frame)

    frame.healthBar = RBG:BuildHealthBar(frame)
    frame.powerBar = RBG:BuildPowerBar(frame)
    frame.Name = RBG:BuildNameText(frame)
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

    frame:Hide()

    frame.IsActive = function() return frame.active end
    frame.hasEnemy = function() return frame.enemy ~= nil end
    frame.getEnemy = function() return frame.enemy end

    --DEBUG--
    --frame.debug = frame:CreateTexture(nil,"BACKGROUND")
    --frame.debug:SetAllPoints()
    --frame.debug:SetColorTexture(255,0,0,1)

    return frame
end

function RBG:BuildGroup(header)
    local prevFrame
    for _,frame in ipairs(RBG.frames) do
        prevFrame = prevFrame or header
        frame:SetPoint("TOPLEFT",prevFrame,"BOTTOMLEFT",0,-RBG.db.barSpacing)  --if no spacing, overlap the borders
        prevFrame = frame
    end
end

---Activate Frames when in BG---

function RBG:ActivateFrames(numEnemies)
    twipe(RBG.activeFrames)
    for i=1,min(numEnemies,MAXFRAMES) do
        RBG:ActivateFrame(RBG.frames[i])
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

---Updates---

function RBG:UpdateAll()
    self.UpdateAllStatic()
    --self.UpdateAllDynamic()
end

function RBG:UpdateStatic(frame)
    --print(frame:GetName())
    frame:SetSize(RBG.db.frameWidth, RBG.db.frameHeight)
    for element in pairs(frame.elements) do
        element:updateStatic(frame)
        if element:IsActive() and element:GetParent():IsActive() then 
            element:Show() 
            print(element:GetName()," displayed")
        end
    end
end

function RBG:UpdateAllStatic()
    self.UpdateBarTextures()
    self.powerBarHeight = self.db.frameHeight / 5
    for frame in pairs(self.activeFrames) do
        RBG:UpdateStatic(frame)
        frame:Show() 
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
end

function RBG:OnInitialize()
    self.db = R.db.bgFrames
    self.statusbars = R.statusbars
    self.powerBarHeight = self.db.frameHeight / 5

    self.HeaderFrame = RBG:CreateHeader()

    self.HeaderFrame:Show()

    for i=1,MAXFRAMES do
        local frame = self:BuildFrame("RatBGFrame"..i)
        frame.healthBar:Show()
        frame:Show()
    end

    self:BuildGroup(self.HeaderFrame)
    self:ActivateFrames(10)


    ---DEBUG fill frames with dummy data---
    for frame in pairs(self.activeFrames) do
        local enemy = RBG:GenerateEnemy()
        frame.enemy = enemy
    end

    self:UpdateAllStatic()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    
end





