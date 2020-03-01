local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

---Profile Settings---
A.general = {
	smoothingAmount = 0.33,
	stealthAlert = false,
	stealthAlertSound = nil
}

A.bgFrames = {
	frameWidth = 200,
	frameHeight = 25,
	barSpacing = 0,
	borderWidth = 1,
	fullName = true,
	barColor = {
		r = 0.32,
		g = 0.32,
		b = 0.32,
		a = 1
	},
	bdColor = {
		r = 0.0,
		g = 0.0,
		b = 0.0,
		a = 1
	},
	bgColor = {
		r = 0.06,
		g = 0.06,
		b = 0.06,
		a = 1
	},
	barTexture = "Blizzard",
	classColorText = false,
	classColorBars = false,
	flag = {
		trackFlag = true,
		flagSize = 16,
		flagOffset = 184,
		flagOffsetMin = -16,
		flagOffsetMax = 230
	},
	icons = {
		classIcon = true,
		trinketIcon = false,
		skullIcon = false,
		rankIcon = false
	},
	trackHealth = true,
	rangeFade = true,
	trackPower = "All",
	powerBarPercent = 0.25,
	freedomHighlight = true,
	fapHighlight = true,
	targetCount = false,
	showHeader = false
}

A.font = {
	font = "2002",
	size = 11,
	outline = "NONE",
	justifyV = "MIDDLE",
	justifyH = "LEFT",
	spacing = 0.0,
	color = {
		r = 1,
		g = 1,
		b = 1,
		a = 1
	},
	shadow = {
		Color = {
			r = 0,
			g = 0,
			b = 0,
			a = 1
		},
		Offset = {
			x = 1,
			y = -1
		}
	}
}

A.scanner = {
	updateFreq = 0.3
}