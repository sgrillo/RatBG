local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

local tinsert = table.insert

local RBG = R.bgFrames
local LSM = R.libs.LSM

--Lua functions
local _G, tinsert = _G, tinsert
--WoW API / Variables
local CreateFrame = CreateFrame
local GetInstanceInfo = GetInstanceInfo
local InCombatLockdown = InCombatLockdown

RBG.frames = {}
RBG.statusbars = {}
RBG.activeFrames = {}
RBG.enemies = {}

function RBG:BuildFrame(name)
    local frame = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    tinsert(RBG.frames, frame)
    local leftBox = CreateFrame("Frame", nil, frame)
    local rightBox = CreateFrame("Frame", nil, frame)

    leftBox.SetPoint("TOPLEFT",frame,"TOPLEFT")
    leftBox.SetPoint("BOTTOMLEFT",frame,"BOTTOMLEFT")
    rightBox.SetPoint("TOPRIGHT",frame,"TOPRIGHT")
    rightBox.SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT")

    frame.elements = {}
    frame.staticUpdates = {}
    frame.dynamicUpdates = {}

    frame.HealthBar = RBG:BuildHealthBar(frame)
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

    return frame
end

function RBG:UpdateStatic(frame)
    self.UpdateBarTextures()
    for element, staticUpdateFunction in pairs(frame.staticUpdates) do
        staticUpdateFunction(frame)
    end
end

function RBG:UpdateAllStatic()
    for frame in pairs(self.activeFrames) do
        self.UpdateStatic(frame)
    end
end


function RBG:OnInitialize()
    local maxFrames = R.global.general.maxFrames
    self.db = r.db.bgFrames
    self.statusbars = R.statusbars
    self.powerBarHeight = self.db.FrameHeight / 5
    for i=1,maxFrames do
        self.BuildFrame("RatBGFrame"..i)
    end
end

function RBG:UpdateBarTextures()
    for bar in pairs(self.statusbars) do
        if not bar:IsObjectType("StatusBar") then return end
        bar:SetStatusBarTexture(LSM:Fetch("stausbar",self.db.barTexture))
        if bar.background then
            bar.background.SetColorTexture(self.db.bgColor)
        end
    end
end






