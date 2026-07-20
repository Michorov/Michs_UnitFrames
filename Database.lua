local _, addon = ...

local Database = {}
addon.Database = Database

local AceDB = LibStub("AceDB-3.0")
local initialized = false

local DEFAULTS = {
	profile = {
		frames = {
			player = {
				enabled = true,
				size = { width = 200, height = 48 },
				position = { anchor = "CENTER", x = -400, y = -300 },
			},
			target = {
				enabled = true,
				size = { width = 200, height = 48 },
				position = { anchor = "CENTER", x = 400, y = -300 },
			},
			pet = {
				enabled = true,
				size = { width = 80, height = 24 },
				position = { anchor = "TOPLEFT", x = -500, y = -326 },
			},
			targettarget = {
				enabled = true,
				size = { width = 80, height = 24 },
				position = { anchor = "TOPRIGHT", x = 500, y = -326 },
			},
			focus = {
				enabled = true,
				size = { width = 99, height = 24 },
				position = { anchor = "LEFT", x = -500, y = -220 },
			},
			focustarget = {
				enabled = true,
				size = { width = 99, height = 24 },
				position = { anchor = "LEFT", x = -399, y = -220 },
			},
			bossContainer = {
				position = { anchor = "CENTER", x = 500, y = 106 },
				frame = {
					enabled = true,
					size = { width = 200, height = 48 },
					spacing = -1,
				},
			},
		},
	},
}

function Database:Initialize()
	if initialized then
		error("Database already initialized", 2)
	end

	self.db = AceDB:New("Michs_UnitFramesDB", DEFAULTS, true)
	initialized = true
end

function Database:GetProfile()
	if not initialized then
		error("Database is not initialized", 2)
	end

	return self.db.profile
end
