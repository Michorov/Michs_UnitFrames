local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Health = addon.Frames.Widgets.Health or {}

local Health = addon.Frames.Widgets.Health

function Health:Ensure(frame, settings)
	if not frame.healthBar then
		local healthBar = CreateFrame("StatusBar", nil, frame)
		healthBar:SetAllPoints(frame)
		healthBar:SetMinMaxValues(0, 1)
		healthBar:SetValue(0)
		frame.healthBar = healthBar
	end

	self:UpdateSettings(frame, settings)
end

function Health:UpdateSettings(frame, settings)
	local healthSettings = (settings and settings.health) or {}
	frame.healthBar:SetStatusBarTexture(healthSettings.texture or "Interface\\Buttons\\WHITE8x8")
	self:UpdateColor(frame, settings)
end

function Health:UpdateColor(frame, settings)
	local healthSettings = (settings and settings.health) or {}
	local color = healthSettings.color or {}
	local r = color.r or 0.12
	local g = color.g or 0.12
	local b = color.b or 0.12
	local a = color.a or 1

	if healthSettings.colorByClassOrReaction then
		if UnitIsPlayer(frame.unit) then
			local _, class = UnitClass(frame.unit)
			local classColor = class and RAID_CLASS_COLORS[class]
			if classColor then
				r = classColor.r
				g = classColor.g
				b = classColor.b
			end
		else
			local reaction = UnitReaction(frame.unit, "player")
			local reactionColor = reaction and FACTION_BAR_COLORS[reaction]
			if reactionColor then
				r = reactionColor.r
				g = reactionColor.g
				b = reactionColor.b
			end
		end
	end

	frame.healthBar:SetStatusBarColor(r, g, b, a)
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
