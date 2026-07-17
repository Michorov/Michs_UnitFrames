local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Health = addon.Frames.Widgets.Health or {}

local Health = addon.Frames.Widgets.Health

function Health:Ensure(frame)
	if not frame.healthBar then
		local healthBar = CreateFrame("StatusBar", nil, frame)
		healthBar:SetAllPoints(frame)
		healthBar:SetMinMaxValues(0, 1)
		healthBar:SetValue(0)
		frame.healthBar = healthBar
	end

	self:UpdateSettings(frame)
end

function Health:UpdateSettings(frame, settings)
	local healthSettings = (settings and settings.health) or {}
	local color = healthSettings.color or {}
	local healthBar = frame.healthBar

	healthBar:SetStatusBarTexture(healthSettings.texture or "Interface\\Buttons\\WHITE8x8")
	healthBar:SetStatusBarColor(
		color.r or 0.10,
		color.g or 0.80,
		color.b or 0.10,
		color.a or 1
	)
end

function Health:UpdateState(frame)
	local unit = frame.unit
	if not unit then
		return
	end

	local currentHealth = UnitHealth(unit)
	local maximumHealth = UnitHealthMax(unit)

	frame.healthBar:SetMinMaxValues(0, maximumHealth)
	frame.healthBar:SetValue(currentHealth)
end
