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
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
				},
			},
			target = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = 400, y = -300 },
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
				},
			},
			pet = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 80, height = 24 },
				position = { x = -460, y = -338 },
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
				},
			},
			targettarget = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 80, height = 24 },
				position = { x = 460, y = -338 },
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
				},
			},
			focus = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 100, height = 24 },
				position = { x = -450, y = -220 },
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
				},
			},
			focustarget = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 100, height = 24 },
				position = { x = -350, y = -220 },
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
				},
			},
			boss = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = 500, y = 106 },
				spacing = -1,
				health = {
					colorByClassOrReaction = true,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				background = {
					colorByClassOrReaction = false,
					color = { r = 0.12, g = 0.12, b = 0.12, a = 1 },
				},
				absorbs = {
					enabled = true,
					color = { r = 0.2, g = 0.8, b = 1, a = 0.5 },
				},
				healAbsorbs = {
					enabled = true,
					color = { r = 1, g = 0, b = 0, a = 0.5 },
				},
				healthText = {
					enabled = true,
				},
				nameText = {
					enabled = true,
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
