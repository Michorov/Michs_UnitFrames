local _, addon = ...

local Updater = {}
addon.Updater = Updater

local initialized = false

local function BuildSettingsUpdater(updateReasons)
	return function(frame)
		if updateReasons.backgroundSettingsChanged then
			addon.Frames.Widgets.Background:UpdateSettings(frame)
		end

		if updateReasons.healthSettingsChanged then
			addon.Frames.Widgets.Health:UpdateSettings(frame)
		end

		if updateReasons.borderSettingsChanged then
			addon.Frames.Widgets.Border:UpdateSettings(frame)
		end
	end
end

local function BuildStateUpdater(updateReasons)
	return function(frame)
		if updateReasons.healthStateChanged or updateReasons.healthSettingsChanged then
			addon.Frames.Widgets.Health:UpdateState(frame)
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
		local stateUpdater = BuildStateUpdater(unitReasons)
		local settingsUpdater = BuildSettingsUpdater(unitReasons)

		addon.FrameRegistry:UpdateUnit(unit, stateUpdater, settingsUpdater)
	end

	if hasGlobal then
		local stateUpdater = BuildStateUpdater(globalReasons)
		local settingsUpdater = BuildSettingsUpdater(globalReasons)

		addon.FrameRegistry:UpdateAllUnits(stateUpdater, settingsUpdater)
	end
end

function Updater:CreateFlushCallback()
	if initialized then
		error("Flush Callback was already created", 2)
	end

	initialized = true

	return Flush
end
