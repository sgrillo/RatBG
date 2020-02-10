local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

---Lua Functions---
local _G, gsub, strjoin, twipe, tinsert, tremove, tContains, floor = _G, gsub, strjoin, wipe, tinsert, tremove, tContains, floor
---Wow API Functions---
local AddMessage = AddMessage
local CreateFrame = CreateFrame
local IsAddonLoaded = IsAddOnLoaded
---Libs---
local LSM = R.Libs.LSM
local ACR = R.Libs.AceConfigRegistry
local ACG = R.Libs.AceGUI

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

---Parent Frame---
R.UIParent = CreateFrame("Frame", "RatBGParent", _G.UIParent)
R.UIParent:SetSize(_G.UIParent:GetSize())

function R:Initialize()
	
	twipe(self.data)
	self.myguid = UnitGUID("player")
	self.data = R.Libs.AceDB:New("RatDB", self.DB)
	self.db = self.data.profile
	self.global = self.data.global
	
	self:LoadCommands()
	self:HookElvUISkins()			--applies elvui theme to custom widgets for consistency sake
	
end

function R:Print(...)
	_G.DEFAULT_CHAT_FRAME:AddMessage(strjoin("|cFF", T.RatBlue.hex or "3291BA", "RatBG:|r ", ...)) 
end



---Utility Functions---

--get class color RGB
function R:classColor(class, rgb)
	if type(class)~="string" then return end
	class = strupper(class)
	return rgb and _G.RAID_CLASS_COLORS[class].getRGB or _G.RAID_CLASS_COLORS[class].colorStr
end

--Return rounded number
function R:Round(num, idp)
	if(idp and idp > 0) then
		local mult = 10 ^ idp
		return floor(num * mult + 0.5) / mult
	end
	return floor(num + 0.5)
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
		f:SetShadowOffset(shadow.offset)
	end

	R.fontStrings[f] = true
end

--Attach to font objects--
do
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