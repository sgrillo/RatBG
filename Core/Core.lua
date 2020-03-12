local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

---Lua Functions---
local gsub, strjoin, twipe, tinsert, tremove, tContains, floor, sign, strupper = gsub, strjoin, wipe, tinsert, tremove, tContains, floor, math.sign, strupper
---Wow API Functions---
local AddMessage = AddMessage
local CreateFrame = CreateFrame
local IsAddonLoaded = IsAddOnLoaded
local CreateColor = CreateColor
local GetClassColor = GetClassColor
---Libs---
local LSM = R.Libs.LSM
local ACR = R.Libs.AceConfigRegistry
local ACG = R.Libs.AceGUI
local AceEvent = LibStub("AceEvent-3.0")

---Constants---
R.title = format("|cFF3291BA%s |r", "RatBG")
R.myfaction, R.myLocalizedFaction = UnitFactionGroup("player")
R.myFactionID = R.myfaction == "Alliance" and 1 or 0
R.myname = UnitName("player")
R.myrealm = GetRealmName()

---Tables---
R.media = {}
R.frames = {}
R.statusbars = {}
R.fontStrings = {}
R.enemyData = {}
R.pix = 1

R.bgFrames = {}
R.scanner = {}
R.sync = {}

local RBG, Scanner = R.bgFrames, R.scanner

---Parent Frame---
R.UIParent = CreateFrame("Frame", "RatBGParent", _G.UIParent)
R.UIParent:SetSize(_G.UIParent:GetSize())
R.UIParent:SetPoint("CENTER")
R.UIParent:SetFrameLevel(0)

function R:Initialize()
	
	twipe(self.data)
	self.myguid = UnitGUID("player")
	self.data = R.Libs.AceDB:New("RatDB", self.DB)
	self.db = self.data.profile
	self.global = self.data.global
	self.db.locations = self.db.locations or {}

	AceEvent:Embed(RBG)		--Enable events for the bg frames
	AceEvent:Embed(Scanner)	--And in the target scanner
	
	
	self:LoadCommands()
	self:PixelScale()
	self:HookElvUISkins()			--applies elvui theme to custom widgets for consistency sake

	self:EnableSmoothing()

	RBG:OnInitialize()
	Scanner:OnInitialize()
end

function R:UpdateAll()
	print("updating!")
	RBG:UpdateAll()

end

--Chat Commands--

function R:LoadCommands()
	self:RegisterChatCommand("rbg", "TextInput")
	self:RegisterChatCommand("ratbg", "TextInput")
end

function R:TextInput(msg)
	local arg1, arg2 = self:GetArgs(msg, 2)
	if arg1 and strupper(arg1) == "HIDE" then
		RBG:Hide()
	elseif arg1 and strupper(arg1) == "LOCK" then
		RBG:Lock()
	elseif arg1 and strupper(arg1) == "UNLOCK" then
		RBG:Unlock()
	elseif arg1 and strupper(arg1) == "TEST" then
		RBG:TestToggle(arg2)
	else
		self:ToggleOptionsUI(msg)
	end
end



---Utility Functions---

function R:PixelScale()
	R.pix = (768.0/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))/0.64    --GetCVar("uiScale")
end

--Enable Smoothing--
function R:EnableSmoothing()
	local meta = getmetatable(CreateFrame("StatusBar")).__index
	if not meta.SetSmoothing then meta.SetSmoothing = R.SetSmoothing end
end


--dump a color as 3/4 outputs
function rgb(c)
	return c.r, c.g, c.b, c.a or 1
end

--get class color RGB
function R:classColor(class, mult, str)
	if type(class)~="string" then return end
	class = strupper(class)

	local r,g,b,hex = GetClassColor(class)

	if class == "SHAMAN" then
		local color = R.global.general.blueShamans and CreateColor(0.0, 0.44, 0.87) or CreateColor(0.96, 0.55, 0.73)
		hex = color:GenerateHexColor()
		r,g,b = color:GetRGB()
	end
		
	if str then
		return hex
	else
		mult = mult or 1.0
		return r*mult, g*mult, b*mult
	end
end

--Return rounded number
function R:Round(n, mult)
	if not n then return end
	mult = mult or 1
	return floor(n/mult + (n>=0 and 1 or -1) * 0.5) * mult
end



--Truncate a number off to n places
function R:Truncate(v, decimals)
	return v - (v % (0.1 ^ (decimals or 0)))
end

--Simpler Font Formatting--
local function BuildFont(f, font, size, outline, color, shadow)
	f.font, f.size, f.outline, f.color, f.shadow = font, size, outline, color, shadow
	font = font or LSM:Fetch("font", R.db.font.font)
	if not size or size <=0 then size = R.db.font.size end
	outline = outline or R.db.font.outline
	color = color or R.db.font.color
	shadow = shadow or R.db.font.shadow

	f:SetFont(font, size, outline)
	f:SetTextColor(rgb(color))
	
	if outline=="NONE" then
		f:SetShadowColor(rgb(shadow.Color))
		f:SetShadowOffset(shadow.Offset.x,shadow.Offset.y)
	end

	R.fontStrings[f] = true
end

function R:UpdateFonts()
	--local font = LSM:Fetch("font", R.db.font.font)
	for fs in pairs(R.fontStrings) do
		fs:BuildFont(fs.font, fs.size, fs.outline, fs.color, fs.shadow)
	end
end

--Attach to font objects--
do
	local dummy = CreateFrame("Frame")
	getmetatable(dummy:CreateFontString()).__index.BuildFont = BuildFont
	if not getmetatable(_G.GameFontNormal).__index.BuildFont  then 
		getmetatable(_G.GameFontNormal).__index.BuildFont = BuildFont
	end
end

--Table Copy--
function R:CopyTable(to, from)
	if type(to) ~= "table" then to = {} end
	if type(from) == "table" then
		for option, value in pairs(from) do
			if type(value) == "table" then
				value = self:CopyTable(to[option], value)
			end
			to[option] = value
		end
	end
	return to
end

--Sneak variable slider widget into ElvUI for styling, it it's loaded--
function R:styleVarSliderBar(object, ...)
	widget = R.hooks[ACG].Create(object, ...)
	if widget and _G.ElvUI and _G.ElvUI[1].modules["Skins"] then
		if widget.type == 'Slider-Variable' then
			local frame = widget.slider
			local editbox = widget.editbox
			local lowtext = widget.lowtext
			local hightext = widget.hightext

			_G.ElvUI[1].modules["Skins"]:HandleSliderFrame(frame)

			editbox:SetTemplate()
			editbox:Height(15)
			editbox:Point('TOP', frame, 'BOTTOM', 0, -1)

			lowtext:Point('TOPLEFT', frame, 'BOTTOMLEFT', 2, -2)
			hightext:Point('TOPRIGHT', frame, 'BOTTOMRIGHT', -2, -2)
		end
	end
	return widget
end


function R:HookElvUISkins()
	if _G.ElvUI then
		self:RawHook(ACG, "Create",  "styleVarSliderBar")
	end
end

--Bump a frame so it aligns to the pixel grid
local function BumpFrame(self)
	self:StopMovingOrSizing()
	local xOfs, yOfs = R:Round(R.UIParent:GetLeft() - UIParent:GetLeft(),R.pix), R:Round(R.UIParent:GetTop() - UIParent:GetTop(),R.pix)
	local xPos, yPos = R:Round(self:GetLeft(),R.pix), R:Round(self:GetTop(),R.pix)
	xPos = xPos - xOfs
	yPos = yPos + yOfs

	R.db.locations[self:GetName()] = {xPos, yPos}

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT",R.UIParent,"BOTTOMLEFT", xPos, yPos)			--I don't actually think this is needed as long as I scale everything so it lines up
																			-- keeping it for now just in case
end

--Add mover to frame--
function R:BuildDragOverlay(frame)
	frame.defaultPosition = {}
	local defaultPosition = frame.defaultPosition
	defaultPosition.point, defaultPosition.relativeTo, defaultPosition.relativePoint, defaultPosition.xOfs, defaultPosition.yOfs = frame:GetPoint()
	if defaultPosition.relativeTo and defaultPosition.relativeTo:GetName() then defaultPosition.relativeTo = defaultPosition.relativeTo:GetName() end

	local moverFrame = CreateFrame("Frame",frame:GetName() and frame:GetName().."Mover" or nil, frame)
	moverFrame:SetAllPoints()
	moverFrame:SetFrameStrata("HIGH")
	moverFrame:SetScript("OnDragStart", function(self)
		self:GetParent():ClearAllPoints() 
		self:GetParent():StartMoving() 
	end)
	moverFrame:SetScript("OnDragStop", function(self)
		--self:GetParent():StopMovingOrSizing()
		BumpFrame(self:GetParent())
	end)


	moverFrame:Hide()
	frame.moverFrame = moverFrame
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)

	frame.unlock = function(self)
		self.moverFrame:Show()
		self.moverFrame:EnableMouse(true)
		self.moverFrame:RegisterForDrag("LeftButton")
	end

	frame.lock = function(self)
		self.moverFrame:Hide()
		self.moverFrame:EnableMouse(false)
		self.moverFrame:RegisterForDrag(nil)
	end

	frame.reset = function(self)
		if self.defaultPosition then
			self:ClearAllPoints()
			local p = self.defaultPosition
			if p.relativeTo and p.relativePoint then
				self:SetPoint(p.point or "CENTER", p.relativeTo, p.relativePoint, p.xOfs or 0, p.yOfs or 0)
			elseif p.relativeTo then
				self:SetPoint(p.point or "CENTER", p.relativeTo, p.xOfs or 0, p.yOfs or 0)
			else
				self:SetPoint(p.point or "CENTER", p.xOfs or 0, p.yOfs or 0)
			end
		else
			self:SetPoint("CENTER",0,0)
		end
	end
end




