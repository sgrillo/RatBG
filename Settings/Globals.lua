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
			r = 0,
			g = 0,
			b = 255
		},
		Rage = {
			r = 255,
			g = 0,
			b = 0
		},
		Energy = {
			r = 255,
			g = 255,
			b = 0
		}
	}
}

T.RatBlue = {
	r = 50,
	g = 145,
	b = 186,
	hex = "3291BA",
	displayText = "|cFF3291BA"
}
