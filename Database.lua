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
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = -400, y = -300 },
			},
			target = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = 400, y = -300 },
			},
			pet = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 80, height = 24 },
				position = { x = -460, y = -338 },
			},
			targettarget = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 80, height = 24 },
				position = { x = 460, y = -338 },
			},
			focus = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 100, height = 24 },
				position = { x = -450, y = -220 },
			},
			focustarget = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 100, height = 24 },
				position = { x = -350, y = -220 },
			},
			boss = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = 500, y = 106 },
				spacing = -1,
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
