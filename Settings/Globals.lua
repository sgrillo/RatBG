local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

--Global Settings
T.general = {
	version = 1.01,
	AceGUI = {
		width = 800,
		height = 1000
	},
	maxFrames = 15,
	powerColors = {
		MANA = {
			r = 79.0/255,
			g = 115.0/255,
			b = 161.0/255
		},
		RAGE = {
			r = 199.0/255,
			g = 64.0/255,
			b = 64.0/255
		},
		ENERGY = {
			r = 166.0/255,
			g = 161.0/255,
			b = 89.0/255
		}
	},
	powerTypes = {
		Mana = {
			MAGE = true,
			PRIEST = true,
			WARLOCK = true,
			HUNTER = true,
			SHAMAN = true,
			PALADIN = true,
			DRUID = true,
		},
		Energy = {
			ROGUE = true
		},
		Rage = {
			WARRIOR = true
		}
	},
	rangeFadeTime = 10
}

T.RatBlue = {
	r = 104,
	g = 31,
	b = 128,
	hex = "681f80",
	displayText = "|cFF681f80"
}

--Table is kind of "backwards" to look up values quick
T.SortOrder = {
	MAGE = 5,
	PRIEST = 1,
	WARLOCK = 6,
	HUNTER = 7,
	SHAMAN = 3,
	PALADIN = 2,
	DRUID = 4,
	ROGUE = 9,
	WARRIOR = 0
}
