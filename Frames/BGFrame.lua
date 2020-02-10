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

function RBG:CreateHeader()
    local ParentFrame = CreateFrame("Frame","RatBG Frames", UIParent)
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
    ParentFrame:unlock()

    return ParentFrame

end

function RBG:BuildFrame(name)
    local frame = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    tinsert(RBG.frames, frame)

    frame.elements = {}
    frame.staticUpdates = {}
    frame.dynamicUpdates = {}

    frame.leftBox, frame.rightBox = RBG:BuildContainers(frame)

    frame.healthBar = RBG:BuildHealthBar(frame)

    a,b = frame.healthBar:GetMinMaxValues()
    print(a,b)
    --frame.PowerBar = RBG:BuildPowerBar(frame)
    --frame.Name = RBG:BuildNameText(frame)
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

    return frame
end

function RBG:BuildGroup(header)
    local prevFrame
    for _,frame in ipairs(RBG.frames) do
        prevFrame = prevFrame or header
        frame:SetPoint("TOPLEFT",prevFrame,"BOTTOMLEFT",0,RBG.db.barSpacing)
        prevFrame = frame
    end
end

function RBG:ActivateFrames(numEnemies)
    twipe(RBG.activeFrames)
    for i=1,min(numEnemies,MAXFRAMES) do
        RBG.activeFrames[RBG.frames[i]]=true
        RBG.frames[i].active = true
    end
end

function RBG:ActivateFrame(frame)
    RBG.activeFrames[frame] = true
    frame.active = true
end

function RBG:AddActiveFrame()
    if RBG.activeFrames[RBG.frames[MAXFRAMES]] then return end -- frames added in order so we have no more space
    for i=1,#RBG.frames do
        if not RBG.activeFrames[RBG.frames[i]] then 
            activeFrames[RBG.frames[i]] = true 
            RBG.frames[i].active = true
            return 
        end
    end
end


function RBG:UpdateStatic(frame)
    print(frame:GetName())
    for element in pairs(frame.elements) do
        print("Attempting to update element: "..element:GetName())
        element:staticUpdate(frame)
    end
end

function RBG:UpdateAllStatic()
    self.powerBarHeight = self.db.frameHeight / 5
    self.UpdateBarTextures()
    for frame in pairs(self.activeFrames) do
        RBG:UpdateStatic(frame)
        if self.activeFrames[frame] then frame:Show() 
        else frame:Hide() end
    end
end

function RBG:UpdateBarTextures()
    for bar in pairs(RBG.statusbars) do
        if not bar:IsObjectType("StatusBar") then return end
        bar:SetStatusBarTexture(LSM:Fetch("stausbar",RBG.db.barTexture))
        if bar.background then
            local c = RBG.db.bgColor
            bar.background:SetColorTexture(c.r, c.g, c.b, c.a)
        end
    end
end

function RBG:RegisterUpdates(object, staticUpdateFunc, dynamicUpdateFunc)
    local updateMeta = getmetatable(object).__index
    updateMeta.staticUpdate = staticUpdateFunc
    updateMeta.dynamicUpdate = dynamicUpdateFunc
end

function RBG:OnInitialize()
    self.db = R.db.bgFrames
    self.statusbars = R.statusbars
    self.powerBarHeight = self.db.frameHeight / 5

    self.HeaderFrame = RBG:CreateHeader()

    self.HeaderFrame:Show()

    for i=1,MAXFRAMES do
        self:BuildFrame("RatBGFrame"..i)
    end

    self:ActivateFrames(10)
    self:UpdateAllStatic()
    self:BuildGroup(self.HeaderFrame)

end





