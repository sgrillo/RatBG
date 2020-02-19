local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

---lua functions---
tsort = table.sort

R.Libs.AceConfig:RegisterOptionsTable(R.AddonName, R.Options)
R.Libs.AceConfigDialog:SetDefaultSize(R.AddonName, R:GetConfigDefaultSize())

local RBG = R.bgFrames
math_min = math.min

R.Options.childGroups = "tab"

local textOutlines = {
	["NONE"] = "None", ["OUTLINE"] = "Outline",
	["THICK OUTLINE"] = "Thick Outline", ["MONOCHROME"] = "Monochrome"
}

R.Options.args = {
	Header = {
		order = 0,
		type = "header",
		name = "Version" .. format(": %s%s|r", T.RatBlue.displayText, T.general.version),
		width = "full"
	}
}

R.Options.args.BattlegroundBars = {
	order = 1,
	type = "group",
	name = "BG Target Bars",
	childGroups = "tab",
	width = "full",
	args = {
		appearanceGroup = {
			order = 2,
			type = "group",
			name = "Bar Appearance",
			inline = true,
			get = function(info) return R.db.bgFrames[info[#info]] end,
			set = function(info,value) R.db.bgFrames[info[#info]] = value RBG:UpdateAllStatic() end,
			args = {
				frameWidth = {
					order = 0,
					type = "range",
					name = "Width",
					desc = "Total width of the BG bars",
					min = 0, max = 800, step = 1,
					get = function() return tonumber(R.db.bgFrames.frameWidth) end,
					set = function(info,value) 
						R.db.bgFrames[info[#info]] = value
						R.db.bgFrames.flag.flagOffset = math_min(value, R.db.bgFrames.flag.flagOffset)
						RBG:UpdateAllStatic()
					end
				},
				frameHeight = {
					order = 1,
					type = "range",
					name = "Height",
					desc = "Total height of the BG bars",
					min = 0, max = 100, step = 1,
					get = function() return tonumber(R.db.bgFrames.frameHeight) end
				},
				barSpacing = {
					order = 2,
					type = "range",
					name = "Bar Spacing",
					desc = "Vertical spacing between bars",
					min = 0, max = 10, step = 1,
					get = function() return tonumber(R.db.bgFrames.barSpacing) end,
					set = function(info,value) R.db.bgFrames[info[#info]] = value RBG:BuildGroup() end,
				},
				barTexture = {
					order = 4,
					type = "select",
					dialogControl = "LSM30_Statusbar",
					name = "Bar Texture",
					values = _G.AceGUIWidgetLSMlists.statusbar,
					get = function(info) return R.db.bgFrames[info[#info]] end,
				},
				classColors = {
					name = "Class Colors",
					type = "select",
					order = 5,
					desc = "Choose if bars or text is class-colored",
					values = {
						[0] = "Class-Colored Bars",
						[1] = "Class-Colored Text",
						[2] = "None"
					},
					set = function(info, value)
						R.db.bgFrames.classColorBars = (value == 0)
						R.db.bgFrames.classColorText = (value == 1)
						RBG:UpdateAllStatic()
					end,
					get = function(info)
						local bar,text = R.db.bgFrames.classColorBars, R.db.bgFrames.classColorText
						if bar == true and text == true then	---something weird happened, reset both
							bar = false text = false
						elseif bar == true then
							return 0
						elseif text == true then
							return 1
						end
						return 2
					end
				},
				smoothingAmount = {
					name = "Smoothing Amount",
					type = "range",
					order = 6,
					min=.20, max=.80, step = .01,
					isPercent = true,
					get = function(info) return R.db.general.smoothingAmount end,
					set = function(info, value) R.db.general.smoothingAmount = value R.SetSmoothingAmount(value) end
				},
				bdColor = {
					name = "Border Color",
					type = "color",
					order = 8,
					hasAlpha = true,
					width = 0.7,
					get = function(info)
						local c = R.db.bgFrames[info[#info]]
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a) 
						local c = R.db.bgFrames[info[#info]]
						c.r, c.g, c.b, c.a = r, g, b, a
						RBG:UpdateAllStatic()
					end
				},
				barColor = {
					name = "Health Color",
					type = "color",
					order = 7,
					disabled = function() return R.db.bgFrames.classColorBars end,
					hasAlpha = true,
					width = 0.7,
					get = function(info)
						local c = R.db.bgFrames[info[#info]]
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a) 
						local c = R.db.bgFrames[info[#info]]
						c.r, c.g, c.b, c.a = r, g, b, a
						RBG:UpdateAllStatic()
					end
				},
				bgColor = {
					name = "Background",
					type = "color",
					order = 9,
					hasAlpha = true,
					width = 0.72,
					get = function(info)
						local c = R.db.bgFrames[info[#info]]
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a) 
						local c = R.db.bgFrames[info[#info]]
						c.r, c.g, c.b, c.a = r, g, b, a
						RBG:UpdateAllStatic()
					end
				},
				borderWidth = {
					order = 10,
					type = "range",
					name = "Border Width",
					min = 0, max = 10, step = 1,
					get = function() return tonumber(R.db.bgFrames.borderWidth) end
				},
				trackPower = {
					order = 11,
					type = "select",
					name = "Power Bar",
					desc = "Dynamically update power bars on the enemy. Can optionally choose to only show mana.",
					values = { ["All"] = "All", ["Mana"] = "Mana Only", ["None"] = "None" }
				},
				powerBarPercent = {
					order = 12,
					type = "range",
					name = "Power Bar Height",
					desc = "Varies the height of the power bar frame relative to the overall frame",
					isPercent = true,
					min=.1, max=.90, step = .01,
					get = function(info) return tonumber(R.db.bgFrames[info[#info]]) end
				}
			}
		},
		fontGroup = {
			order = 3,
			type = "group",
			name = "Font",
			inline = true,
			get = function(info) return R.db.font[info[#info]] end,
			set = function(info, value) R.db.font[info[#info]] = value R:UpdateFonts() RBG:UpdateAllStatic() end,
			args = {
				font = {
					order = 1,
					type = "select",
					dialogControl = "LSM30_Font",
					name = "Font",
					values = _G.AceGUIWidgetLSMlists.font
				},
				size = {
					order = 2,
					type = "range",
					min = 8, max = 30, step = 1,
					name = "Font Size",
					get = function(info) return tonumber(R.db.font[info[#info]]) end,
				},
				outline = {
					order = 3,
					type = "select",
					name = "Outline Style",
					values = textOutlines
				},
				fontColor = {
					name = "Color",
					type = "color",
					order = 4,
					hasAlpha = true,
					disabled = function() return R.db.bgFrames.classColorText end,
					width = 0.5,
					get = function(info)
						local c = R.db.font.color
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a) 
						local c = R.db.font.color
						c.r, c.g, c.b, c.a = r, g, b, a
						R:UpdateFonts()
						RBG:UpdateAllStatic()
					end
				},
				shadowColor = {
					name = "Shadow",
					type = "color",
					order = 9,
					hasAlpha = true,
					width = 0.6,
					get = function(info)
						local c = R.db.font.shadow.Color
						return c.r, c.g, c.b, c.a
					end,
					set = function(info, r, g, b, a) 
						local c = R.db.font.shadow.Color
						c.r, c.g, c.b, c.a = r, g, b, a
						R:UpdateFonts()
						RBG:UpdateAllStatic()
					end
				}
			}
		},
		iconGroup = {
			name = "Icons",
			type = "group",
			order = 6,
			inline = true,
			get = function(info) return R.db.bgFrames.icons[info[#info]] end,
			set = function(info, value) R.db.bgFrames.icons[info[#info]] = value RBG:UpdateAllStatic() end,
			args = {
				classIcon = {
					order = 2,
					name = "Class Icon",
					type = "toggle"
				},
				rankIcon = {
					order = 1,
					name = "Rank Icon",
					type = "toggle"
				},
				trinketIcon = {
					order = 3,
					name = "Trinket Icon",
					type = "toggle"
				},
				skullIcon = {
					order = 4,
					type = "toggle",
					name = "Skull Icon",
					desc = "Shows when a player is affected by the Skull of Impending Doom and tracks the cooldown"
				}
			}
		},
		infoGroup = {
			name = "Player Information",
			type = "group",
			order = 7,
			inline = true,
			get = function(info) return R.db.bgFrames[info[#info]] end,
			set = function(info, value) R.db.bgFrames[info[#info]] = value RBG:UpdateAllStatic() end,
			args = {
				trackHealth = {
					order = 1,
					type = "toggle",
					name = "Health Bars",
					desc = "Dynamically update enemy health on the bar"
				},
				rangeFade = {
					order = 2,
					type = "toggle",
					name = "Range Fade",
					desc = "Fade the bar when the enemy is out of range.\nFade range is at least 30 yards for all classes"
				},
				targetCount = {
					order = 9,
					name = "Target Count",
					desc = "Shows how many members of your team are currently targetting the player",
					type = "toggle"
				},
				freedomHighlight = {
					order = 5,
					type = "toggle",
					name = "Freedom Highlight",
					desc = "Adds an orange highlight around the frame when the player recieves Blessing of Freedom"
				},
				fapHighlight = {
					order = 6,
					type = "toggle",
					name = "FAP Highlight",
					desc = "Adds a blue highlight around the frame when the player uses a Free Action Potion"
				},
				stealthAlert = {
					order = 7,
					type = "toggle",
					name = "Stealth Alert",
					desc = "Displays a warning when a stealthed player is detected near you. Currently not implemented.",
					disabled = true,
					get = function(info) return R.db.general[info[#info]] end,
					set = function(info, value) R.db.general[info[#info]] = value end,
				},
				stealthAlertSound = {
					order = 8,
					type = "select",
					name = "Stealth Alert Sound",
					desc = "Alert sound to play when detecting stealthed enemy player",
					values = _G.AceGUIWidgetLSMlists.sound,
					disabled = function() return not R.db.general.stealthAlert end
				},
				fullName = {
					order = 3,
					type = "toggle",
					name = "Realm",
					desc = "Lists the player's Realm name with their name"
				},
			}
		},
		miscGroup = {
			name = "Misc",
			type = "group",
			order = 8,
			inline = true,
			get = function(info) return R.db.bgFrames[info[#info]] end,
			set = function(info, value) R.db.bgFrames[info[#info]] = value RBG:UpdateAllStatic() end,
			args = {
				showHeader = {
					order = 1,
					type = "toggle",
					name = "Show Header Frame"
				},
				updateFreq = {
					order = 1,
					type = "range",
					name = "Scan Frequency",
					desc = "How often the scanner checks for nearby enemy players",
					min=0.1,max=5,step=0.05,
					get = function(info) return tonumber(R.db.scanner[info[#info]]) end,
					set = function(info, value) R.db.scanner[info[#info]] = value end
				}
			}
		}
	}
}

R.Options.args.BGFocus = {
	order = 2,
	type = "group",
	name = "BG Focus Frame",
	childGroups = "tab",
	width = "full",
	args = {
	}
}

local function flagOffsetMin() return -R.db.bgFrames.flag.flagSize or 0 end

local function flagOffsetMax() return R.db.bgFrames.frameWidth or 100 end

R.Options.args.WSG = {
	order = 3,
	type = "group",
	name = "Warsong Gulch",
	childGroups = "tab",
	width = "full",
	args = {
		flagGroup = {
			name = "Flag",
			type = "group",
			order = 5,
			inline = true,
			get = function(info) return R.db.bgFrames.flag[info[#info]] end,
			set = function(info, value) R.db.bgFrames.flag[info[#info]] = value RBG:UpdateAllStatic() end,
			args = {
				trackFlag = {
					order = 1,
					name = "Track Flag",
					desc = "Toggle tracking of the enemy flag in battlegrounds",
					type = "toggle",
				},
				flagSize = {
					order = 2,
					name = "Flag Size",
					type = "range",
					min = 2, max = 30, step = 1,
					disabled = function() return not R.db.bgFrames.flag.trackFlag end,
					get = function(info) return tonumber(R.db.bgFrames.flag[info[#info]]) end,
				},
				flagOffset = {
					order = 3,
					name = "Flag Offset",
					type = "range",
					dialogControl = "Slider-Variable",
					min = flagOffsetMin,
					max = flagOffsetMax,
					step = 1,
					disabled = function() return not R.db.bgFrames.flag.trackFlag end,
					get = function(info) return tonumber(R.db.bgFrames.flag[info[#info]]) end,
				}
			}
		}
	}
}

R.Options.args.AB = {
	order = 4,
	type = "group",
	name = "Arathi Basin",
	childGroups = "tab",
	width = "full",
	args = {
	}
}
