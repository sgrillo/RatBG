local R, A, T = unpack(select(2, ...)); --Import: Engine, Profile DB, Global DB

---Profile Settings---
A.general = {
	smoothingAmount = 0.33,
	stealthAlert = false,
	stealthAlertSound = nil
}

A.bgFrames = {
	frameWidth = 200,
	frameHeight = 30,
	barSpacing = 1,
	borderWidth = 2,
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
	barTexture = nil,
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
	freedomHighlight = true,
	fapHighlight = true,
	targetCount = false,
	
}

A.font = {
	font = "Friz Quadrata TT",
	size = 12,
	outline = "NONE",
	justifyV = "MIDDLE",
	justifyH = "LEFT",
	spacing = 0.0,
	color = {
		r = 0,
		g = 0,
		b = 0,
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