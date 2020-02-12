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
		Mana = {
			r = 79.0/255,
			g = 115.0/255,
			b = 161.0/255
		},
		Rage = {
			r = 199.0/255,
			g = 64.0/255,
			b = 64.0/255
		},
		Energy = {
			r = 166.0/255,
			g = 161.0/255,
			b = 89.0/255
		}
	},
	powerTypes = {
		Mana = {
			Mage = true,
			Priest = true,
			Warlock = true,
			Hunter = true,
			Shaman = true,
			Paladin = true,
			Druid = true,
		},
		Energy = {
			Rogue = true
		},
		Rage = {
			Warrior = true
		}
	}
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
	Mage = 5,
	Priest = 1,
	Warlock = 6,
	Hunter = 7,
	Shaman = 3,
	Paladin = 2,
	Druid = 4,
	Rogue = 9,
	Warrior = 8
}
