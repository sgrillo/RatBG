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
			r = .212,
			g = .3098,
			b = .4314
		},
		Rage = {
			r = 1,
			g = 0,
			b = 0
		},
		Energy = {
			r = 1,
			g = 1,
			b = 0
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
