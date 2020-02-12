local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

---Lua Functions---
local _G, gsub, strjoin, twipe, tinsert, tremove, tContains, floor, sign = _G, gsub, strjoin, wipe, tinsert, tremove, tContains, floor, math.sign
---Wow API Functions---
local AddMessage = AddMessage
local CreateFrame = CreateFrame
local IsAddonLoaded = IsAddOnLoaded
---Libs---
local LSM = R.Libs.LSM
local ACR = R.Libs.AceConfigRegistry
local ACG = R.Libs.AceGUI
local AceEvent = LibStub("AceEvent-3.0")

---Constants---
R.title = format("|cFF3291BA%s |r", "RatBG")
R.myfaction, R.myLocalizedFaction = UnitFactionGroup("player")
R.myname = UnitName("player")
R.myrealm = GetRealmName()

---Tables---
R.media = {}
R.frames = {}
R.statusbars = {}
R.fontStrings = {}
R.bgFrames = {}
R.enemyData = {}
R.pix = 1

local RBG = R.bgFrames

---Parent Frame---
R.UIParent = CreateFrame("Frame", "RatBGParent", _G.UIParent)
R.UIParent:SetSize(_G.UIParent:GetSize())
R.UIParent:SetPoint("CENTER")

function R:Initialize()
	
	twipe(self.data)
	self.myguid = UnitGUID("player")
	self.data = R.Libs.AceDB:New("RatDB", self.DB)
	self.db = self.data.profile
	self.global = self.data.global
	self.db.locations = self.db.locations or {}

	AceEvent:Embed(RBG)		--Enable events for the bg frames

	
	
	self:LoadCommands()
	self:PixelScale()
	self:HookElvUISkins()			--applies elvui theme to custom widgets for consistency sake

	self:EnableSmoothing()

	RBG:OnInitialize()
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
	local arg1 = self:GetArgs(msg)
	self:ToggleOptionsUI(msg)
end



---Utility Functions---

function R:PixelScale()
	R.pix = (768.0/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))/GetCVar("uiScale")
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
	--[[ if class == "SHAMAN" then					TURNS OUT I DONT NEED THIS
		return 1,1,1
	end ]]
	if str then
		return _G.RAID_CLASS_COLORS[class].colorStr
	else
		if not mult then mult = 1 end
		local r,g,b = _G.RAID_CLASS_COLORS[class]:GetRGB()
		return r*mult, g*mult, b*mult
	end
end

--Return rounded number
function R:Round(n, mult)
	mult = mult or 1
	return floor(n/mult + (n>=0 and 1 or -1) * 0.5) * mult
end



--Truncate a number off to n places
function R:Truncate(v, decimals)
	return v - (v % (0.1 ^ (decimals or 0)))
end

--Simpler Font Formatting--
local function BuildFont(f, font, size, outline, color, shadow)
	font = font or LSM:Fetch("font", R.db.font.font)
	if not size or size <=0 then size = R.db.font.size end
	outline = outline or R.db.font.outline
	color = color or R.db.font.color
	shadow = shadow or R.db.font.shadow

	f.font, f.size, f.outline, f.color, f.shadow = font, size, outline, color, shadow

	f:SetFont(font, size, outline)
	f:SetTextColor(color)
	
	if outline=="NONE" then
		f:SetShadowColor(shadow.color)
		f:SetShadowOffset(shadow.Offset.x,shadow.Offset.y)
	end

	R.fontStrings[f] = true
end

--Attach to font objects--
do
	local dummy = CreateFrame("Frame")
	getmetatable(dummy:CreateFontString()).__index.BuildFont = BuildFont
	getmetatable(_G.GameFontNormal).__index.BuildFont = BuildFont
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
	return	widget
end


function R:HookElvUISkins()
	self:RawHook(ACG, "Create",  "styleVarSliderBar")
	for k,v in pairs(R.hooks[ACG]) do print(k,v) end
end

--Bump a frame so it aligns to the pixel grid
local function BumpFrame(self)
	self:StopMovingOrSizing()
	local xOfs, yOfs = R.UIParent:GetLeft() - UIParent:GetLeft(), R.UIParent:GetTop() - UIParent:GetTop()
	local xPos, yPos = self:GetLeft(), self:GetTop()
	R:Print(xPos, yPos)
	xPos = R:Round(xPos - xOfs, R.pix)
	yPos = R:Round(yPos + yOfs, R.pix)
	R:Print(xPos, yPos, xOfs, yOfs)

	R.db.locations[self:GetName()] = {xPos, yPos}

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT",R.UIParent,"BOTTOMLEFT", xPos, yPos)
	
end

--Add mover to frame--
function R:MakeDraggable(frame)
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




