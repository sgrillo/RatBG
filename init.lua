--local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB


--The Code in this section is from ElvUI
--Credit goes to Tukz and the ElvUI team

--Lua functions
local pairs, gsub, strsplit, unpack, wipe, type, tcopy = pairs, gsub, strsplit, unpack, wipe, type, table.copy
--WoW API / Variables
local CreateFrame = CreateFrame
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT


local AceAddon, AceAddonMinor = _G.LibStub("AceAddon-3.0")
local CallbackHandler = _G.LibStub("CallbackHandler-1.0")

local AddonName, Engine = ...

local Addon = AceAddon:NewAddon(AddonName, "AceConsole-3.0", "AceEvent-3.0", 'AceHook-3.0', "AceTimer-3.0")
Addon.callbacks = Addon.callbacks or CallbackHandler:New(Addon)
Addon.Options = {type = "group", name = AddonName, args = {}}
Addon.DB = {profile = {}, global = {}} -- Defaults
Addon.AddonName = AddonName

Engine[1] = Addon
Engine[2] = Addon.DB.profile
Engine[3] = Addon.DB.global
_G.RatBG = Engine

do
	Addon.Libs = {}
	Addon.LibsMinor = {}
	function Addon:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == "table" and type(minor) == "number" then
			self.Libs[name], self.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			self.Libs[name], self.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	Addon:AddLib("AceAddon", AceAddon, AceAddonMinor)
	Addon:AddLib("AceDB", "AceDB-3.0")
	Addon:AddLib("AceDBO", "AceDBOptions-3.0")
	Addon:AddLib("LSM", "LibSharedMedia-3.0")
	--Addon:AddLib("LCD", "LibClassicDurations")
	--Addon:AddLib("LCC", "LibClassicCasterino")
	Addon:AddLib("RC", "LibRangeCheck-2.0")
	Addon:AddLib("AceGUI", "AceGUI-3.0")
	Addon:AddLib("AceConfig", "AceConfig-3.0-RatBG")
	Addon:AddLib("AceConfigDialog", "AceConfigDialog-3.0-RatBG")
	Addon:AddLib("AceConfigRegistry", "AceConfigRegistry-3.0-RatBG")
	

end

function Addon:OnInitialize()
	
	if not RatPrivateDB then
		RatPrivateDB = {}
	end
	
	self.data = tcopy(self.DB, true)

	local RatDB = RatDB
	if RatDB and RatDB.global then
		self:CopyTable(self.data, RatDB)
	end
	
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.loadedtime = GetTime()
end

local LoadUI=CreateFrame("Frame")
LoadUI:RegisterEvent("PLAYER_LOGIN")
LoadUI:SetScript("OnEvent", function()
	Addon:Initialize()
end)

function Addon:PLAYER_REGEN_ENABLED()
	self:ToggleOptionsUI()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end

function Addon:PLAYER_REGEN_DISABLED()
	local err
	local ACD = self.Libs.AceConfigDialog
	if ACD and ACD.OpenFrames and ACD.OpenFrames[AddonName] then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		ACD:Close(AddonName)
		err = true
	end

	if err then
		self:Print(ERR_NOT_IN_COMBAT)
	end
end

function Addon:ToggleOptionsUI(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		
		return
	end

	local ACD = self.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddonName]

	local mode = "Close"
	if ConfigOpen then
		mode = "Close"
	else
		mode = "Open"
	end
	
	if ACD then
		ACD[mode](ACD, AddonName)
	end
	
	if mode == "Open" then
		ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddonName]
		if ConfigOpen then
			local frame = ConfigOpen.frame
			if frame and not self.GUIFrame then
				self.GUIFrame = frame
				_G.RatGUIFrame = self.GUIFrame

				self:UpdateConfigSize()
				hooksecurefunc(frame, "StopMovingOrSizing", Addon.ConfigStopMovingOrSizing)
			end
		end
	end
end

--Config Loading---

function Addon:ResetConfigSettings()
	Addon.configSavedPositionTop, Addon.configSavedPositionLeft = nil, nil
	Addon.global.general.AceGUI = Addon:CopyTable({}, Addon.DB.global.general.AceGUI)
end

function Addon:GetConfigPosition()
	return Addon.configSavedPositionTop, Addon.configSavedPositionLeft
end

function Addon:GetConfigSize()
	return Addon.DB.global.general.AceGUI.width, Addon.DB.global.general.AceGUI.height
end

function Addon:UpdateConfigSize(reset)
	local frame = self.GUIFrame
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	frame:SetMinResize(600, 500)
	frame:SetMaxResize(maxWidth-50, maxHeight-50)

	self.Libs.AceConfigDialog:SetDefaultSize(AddonName, self:GetConfigDefaultSize())

	local status = frame.obj and frame.obj.status
	if status then
		if reset then
			self:ResetConfigSettings()

			status.top, status.left = self:GetConfigPosition()
			status.width, status.height = self:GetConfigDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = self:GetConfigPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end
	end
end

function Addon:GetConfigDefaultSize()
	local width, height = Addon:GetConfigSize()
	local maxWidth, maxHeight = Addon.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function Addon:ConfigStopMovingOrSizing()
	if self.obj and self.obj.status then
		Addon.configSavedPositionTop, Addon.configSavedPositionLeft = Addon:Round(self:GetTop(), 2), Addon:Round(self:GetLeft(), 2)
		Addon.global.general.AceGUI.width, Addon.global.general.AceGUI.height = Addon:Round(self:GetWidth(), 2), Addon:Round(self:GetHeight(), 2)
	end
end





