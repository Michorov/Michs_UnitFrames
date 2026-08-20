local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Background = addon.Frames.Widgets.Background or {}

local Background = addon.Frames.Widgets.Background
local settingsCache = {}
local generalSettings

local function UpdateSettingsCache(frame)
	local profile = addon.Database:GetProfile()
	local settings = profile.frames[frame.settingsUnit].background or {}
	local color = settings.color or {}
	settingsCache[frame.settingsUnit] = {
		texture = settings.texture,
		colorByClassOrReaction = settings.colorByClassOrReaction == true,
		color = {
			r = color.r or 0.12,
			g = color.g or 0.12,
			b = color.b or 0.12,
			a = color.a or 1,
		},
	}
	generalSettings = {
		texture = profile.general.texture,
	}
end

function Background:UpdateColor(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	local color = cachedSettings.color
	local r = color.r
	local g = color.g
	local b = color.b
	local a = color.a

	local unit = frame.unit
	if cachedSettings.colorByClassOrReaction and unit and UnitExists(unit) then
		if UnitIsPlayer(unit) then
			local classColor = C_ClassColor.GetClassColor(select(2, UnitClass(unit)))
			if classColor then
				r, g, b = classColor:GetRGB()
			end
		else
			local reaction = UnitReaction(unit, "player")
			local reactionColor = reaction and FACTION_BAR_COLORS[reaction]
			if reactionColor then
				r = reactionColor.r
				g = reactionColor.g
				b = reactionColor.b
			end
		end
	end

	frame.background:SetVertexColor(r, g, b, a)
end

function Background:Ensure(frame)
	if not frame.background then
		local background = frame:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints(frame)
		frame.background = background
	end

	self:UpdateSettings(frame)
end

function Background:UpdateSettings(frame)
	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]

	local texture = cachedSettings.texture
	if texture == -1 then
		texture = generalSettings.texture
	end

	frame.background:SetTexture(addon.Style.Textures:Fetch(texture))
	self:UpdateState(frame)
end

function Background:UpdateState(frame)
	self:UpdateColor(frame)
end
