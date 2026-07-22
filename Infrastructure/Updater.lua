local _, addon = ...

local Updater = {}
addon.Updater = Updater

local initialized = false

local function GetFrameSettings(frame)
	local settingsUnit = frame.unit:match("^boss%d+$") and "boss" or frame.unit
	return addon.Database:GetProfile().frames[settingsUnit]
end

local function UpdateUnitState(frame, settings)
	addon.Frames.Widgets.Bars.Health:UpdateState(frame, settings)
	addon.Frames.Widgets.Bars.Power:UpdateState(frame, settings)
	addon.Frames.Widgets.Bars.Cast:UpdateState(frame)
	addon.Frames.Widgets.Background:UpdateState(frame, settings)
	addon.Frames.Widgets.Bars.Absorbs:UpdateState(frame, settings)
	addon.Frames.Widgets.Bars.HealAbsorbs:UpdateState(frame, settings)
	addon.Frames.Widgets.Texts.Name:UpdateState(frame, settings)
	addon.Frames.Widgets.Texts.Health:UpdateState(frame, settings)
	addon.Frames.Widgets.Texts.Power:UpdateState(frame, settings)
	addon.Frames.Widgets.Indicators.Combat:UpdateState(frame)
	addon.Frames.Widgets.Indicators.RaidMarker:UpdateState(frame)
	addon.Frames.Widgets.Indicators.GroupStatus:UpdateState(frame)
end

local function UpdateUnitSettings(frame, settings)
	addon.Frames.Widgets.MouseoverHighlight:UpdateSettings(
		frame,
		addon.Database:GetProfile().general
	)
	addon.Frames.Widgets.Background:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Bars.Health:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Bars.Power:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Bars.Cast:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Bars.Absorbs:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Bars.HealAbsorbs:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Texts.Health:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Texts.Name:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Texts.Power:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Indicators.Combat:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Indicators.RaidMarker:UpdateSettings(frame, settings)
	addon.Frames.Widgets.Indicators.GroupStatus:UpdateSettings(frame, settings)
end

local function BuildSettingsUpdater(updateReasons, settings)
	return function(frame)
		local frameSettings = settings or GetFrameSettings(frame)

		if updateReasons.mouseoverHighlightSettingsChanged then
			addon.Frames.Widgets.MouseoverHighlight:UpdateSettings(
				frame,
				addon.Database:GetProfile().general
			)
		end

		if updateReasons.backgroundSettingsChanged then
			addon.Frames.Widgets.Background:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.healthSettingsChanged then
			addon.Frames.Widgets.Bars.Health:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.powerSettingsChanged then
			addon.Frames.Widgets.Bars.Power:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.castSettingsChanged then
			addon.Frames.Widgets.Bars.Cast:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.absorbsSettingsChanged then
			addon.Frames.Widgets.Bars.Absorbs:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.healAbsorbsSettingsChanged then
			addon.Frames.Widgets.Bars.HealAbsorbs:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.healthTextSettingsChanged then
			addon.Frames.Widgets.Texts.Health:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.nameTextSettingsChanged then
			addon.Frames.Widgets.Texts.Name:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.powerTextSettingsChanged then
			addon.Frames.Widgets.Texts.Power:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.combatIndicatorSettingsChanged then
			addon.Frames.Widgets.Indicators.Combat:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.raidMarkerSettingsChanged then
			addon.Frames.Widgets.Indicators.RaidMarker:UpdateSettings(frame, frameSettings)
		end

		if updateReasons.groupStatusSettingsChanged then
			addon.Frames.Widgets.Indicators.GroupStatus:UpdateSettings(frame, frameSettings)
		end
	end
end

local function BuildStateUpdater(updateReasons, settings)
	return function(frame)
		if updateReasons.unitChanged then
			UpdateUnitState(frame, settings)
			return
		end

		if updateReasons.healthStateChanged or updateReasons.unitColorStateChanged then
			addon.Frames.Widgets.Bars.Health:UpdateState(frame, settings)
		end

		if updateReasons.healthStateChanged then
			addon.Frames.Widgets.Texts.Health:UpdateState(frame, settings)
		end

		if updateReasons.absorbsStateChanged then
			addon.Frames.Widgets.Bars.Absorbs:UpdateState(frame, settings)
		end

		if updateReasons.healAbsorbsStateChanged then
			addon.Frames.Widgets.Bars.HealAbsorbs:UpdateState(frame, settings)
		end

		if updateReasons.unitColorStateChanged then
			addon.Frames.Widgets.Background:UpdateState(frame, settings)
			addon.Frames.Widgets.Texts.Name:UpdateState(frame, settings)
			addon.Frames.Widgets.Texts.Health:UpdateState(frame, settings)
		end

		if updateReasons.nameStateChanged then
			addon.Frames.Widgets.Texts.Name:UpdateState(frame, settings)
		end

		if updateReasons.powerStateChanged then
			addon.Frames.Widgets.Bars.Power:UpdateState(frame, settings)
			addon.Frames.Widgets.Texts.Power:UpdateState(frame, settings)
		end

		if updateReasons.castStateChanged then
			addon.Frames.Widgets.Bars.Cast:UpdateState(frame)
		end

		if updateReasons.combatStateChanged then
			addon.Frames.Widgets.Indicators.Combat:UpdateState(frame)
		end

		if updateReasons.raidMarkerStateChanged then
			addon.Frames.Widgets.Indicators.RaidMarker:UpdateState(frame)
		end

		if updateReasons.groupStatusStateChanged then
			addon.Frames.Widgets.Indicators.GroupStatus:UpdateState(frame)
		end
	end
end

local function Flush(updateReasons)
	if not addon.FrameRegistry:IsInitialized() then
		return
	end

	local globalReasons = updateReasons.global or {}
	local hasUnits = next(updateReasons.units or {}) ~= nil
	local hasGlobal = next(globalReasons) ~= nil
	if not hasUnits and not hasGlobal then
		return
	end

	for unit, unitReasons in pairs(updateReasons.units or {}) do
		if unitReasons.visibilityChanged then
			addon.FrameRegistry:UpdateVisibility(unit)
		end

		if unitReasons.layoutChanged then
			addon.FrameRegistry:UpdateLayout(unit)
		end

		local settingsUnit = unit:match("^boss%d+$") and "boss" or unit
		local settings = addon.Database:GetProfile().frames[settingsUnit]
		local stateUpdater = BuildStateUpdater(unitReasons, settings)
		local settingsUpdater = BuildSettingsUpdater(unitReasons, settings)

		addon.FrameRegistry:UpdateUnit(unit, stateUpdater, settingsUpdater)
	end

	if hasGlobal then
		if globalReasons.profileChanged then
			for unit in pairs(addon.Database:GetProfile().frames) do
				addon.FrameRegistry:UpdateVisibility(unit)
				addon.FrameRegistry:UpdateLayout(unit)
			end

			addon.FrameRegistry:UpdateAllUnits(
				function(frame)
					UpdateUnitState(frame, GetFrameSettings(frame))
				end,
				function(frame)
					UpdateUnitSettings(frame, GetFrameSettings(frame))
				end
			)
		else
			local stateUpdater = BuildStateUpdater(globalReasons)
			local settingsUpdater = BuildSettingsUpdater(globalReasons)

			addon.FrameRegistry:UpdateAllUnits(stateUpdater, settingsUpdater)
		end
	end
end

function Updater:CreateFlushCallback()
	if initialized then
		error("Flush Callback was already created", 2)
	end

	initialized = true

	return Flush
end
