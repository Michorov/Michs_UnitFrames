local _, addon = ...

local Database = {}
addon.Database = Database

local AceDB = LibStub("AceDB-3.0")
local defaultFont = LibStub("LibSharedMedia-3.0"):GetDefault("font")
local initialized = false

local DEFAULTS = {
	profile = {
		frames = {
			player = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = -300, y = -250 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 12,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = false,
					maxLength = 12,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 12,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
				},
			},
			target = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 200, height = 48 },
				position = { x = 300, y = -250 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 12,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = false,
					maxLength = 12,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 12,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
				},
			},
			pet = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 120, height = 28 },
				position = { x = -340, y = -290 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 10,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = true,
					maxLength = 8,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 10,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
				},
			},
			targettarget = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 120, height = 28 },
				position = { x = 340, y = -290 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 10,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = true,
					maxLength = 8,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 10,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
				},
			},
			focus = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 100, height = 24 },
				position = { x = -350, y = -180 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 8,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = true,
					maxLength = 8,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 8,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
				},
			},
			focustarget = {
				enabled = true,
				hideBlizzardFrame = true,
				size = { width = 100, height = 24 },
				position = { x = -250, y = -180 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 8,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = true,
					maxLength = 8,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 8,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
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
					format = "abbreviated",
					anchor = "RIGHT",
					font = defaultFont,
					outline = "",
					size = 12,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = -4, y = 0 },
				},
				nameText = {
					enabled = true,
					truncate = false,
					maxLength = 12,
					anchor = "LEFT",
					font = defaultFont,
					outline = "",
					size = 12,
					colorByClassOrReaction = false,
					color = { r = 1, g = 1, b = 1, a = 1 },
					position = { x = 4, y = 0 },
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
