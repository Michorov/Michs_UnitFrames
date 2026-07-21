local _, addon = ...

local EventHandler = {}
addon.EventHandler = EventHandler

local eventFrame = CreateFrame("Frame")
local initialized = false

function EventHandler:Initialize()
	if initialized then
		error("EventHandler already initialized", 2)
	end

	eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
	eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
	eventFrame:RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT")
	eventFrame:RegisterEvent("UNIT_PET")
	eventFrame:RegisterEvent("UNIT_TARGET")
	eventFrame:RegisterEvent("UNIT_TARGETABLE_CHANGED")
	eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
	eventFrame:RegisterEvent("UNIT_HEALTH")
	eventFrame:RegisterEvent("UNIT_MAXHEALTH")
	eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	eventFrame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
	eventFrame:RegisterEvent("UNIT_FACTION")
	eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

	eventFrame:SetScript("OnEvent", function(self, event, ...)
		if EventHandler[event] then
			EventHandler[event](EventHandler, event, ...)
		end
	end)

	initialized = true
end

function EventHandler:PLAYER_ENTERING_WORLD()
	addon.UpdateScheduler:Notify("unitChanged", "player")
	addon.UpdateScheduler:Notify("unitChanged", "target")
	addon.UpdateScheduler:Notify("unitChanged", "targettarget")
	addon.UpdateScheduler:Notify("unitChanged", "pet")
	addon.UpdateScheduler:Notify("unitChanged", "focus")
	addon.UpdateScheduler:Notify("unitChanged", "focustarget")
	addon.UpdateScheduler:Notify("unitChanged", "boss")
end

function EventHandler:PLAYER_REGEN_DISABLED()
	if addon.Options:IsOpen() then
		addon.Options:Close()
	end
end

function EventHandler:PLAYER_REGEN_ENABLED()
	if addon.Options:ShouldOpenAfterCombat() then
		addon.Options:Open()
	end
end

function EventHandler:PLAYER_TARGET_CHANGED()
	addon.UpdateScheduler:Notify("unitChanged", "target")
	addon.UpdateScheduler:Notify("unitChanged", "targettarget")
end

function EventHandler:PLAYER_FOCUS_CHANGED()
	addon.UpdateScheduler:Notify("unitChanged", "focus")
	addon.UpdateScheduler:Notify("unitChanged", "focustarget")
end

function EventHandler:INSTANCE_ENCOUNTER_ENGAGE_UNIT()
	addon.UpdateScheduler:Notify("unitChanged", "boss")
end

function EventHandler:UNIT_PET(event, unit)
	if unit == "player" then
		addon.UpdateScheduler:Notify("unitChanged", "pet")
	end
end

function EventHandler:UNIT_TARGET(event, unit)
	if unit == "target" then
		addon.UpdateScheduler:Notify("unitChanged", "targettarget")
	elseif unit == "focus" then
		addon.UpdateScheduler:Notify("unitChanged", "focustarget")
	end
end

function EventHandler:UNIT_TARGETABLE_CHANGED(event, unit)
	if unit and unit:match("^boss%d+$") then
		addon.UpdateScheduler:Notify("unitChanged", unit)
	end
end

function EventHandler:UNIT_NAME_UPDATE(event, unit)
	if unit then
		addon.UpdateScheduler:Notify("nameStateChanged", unit)
	end
end

function EventHandler:UNIT_HEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
	addon.UpdateScheduler:Notify("absorbsStateChanged", unit)
	addon.UpdateScheduler:Notify("healAbsorbsStateChanged", unit)
end

function EventHandler:UNIT_MAXHEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
	addon.UpdateScheduler:Notify("absorbsStateChanged", unit)
	addon.UpdateScheduler:Notify("healAbsorbsStateChanged", unit)
end

function EventHandler:UNIT_ABSORB_AMOUNT_CHANGED(event, unit)
	addon.UpdateScheduler:Notify("absorbsStateChanged", unit)
end

function EventHandler:UNIT_HEAL_ABSORB_AMOUNT_CHANGED(event, unit)
	addon.UpdateScheduler:Notify("healAbsorbsStateChanged", unit)
end

function EventHandler:UNIT_FACTION(event, unit)
	addon.UpdateScheduler:Notify("unitColorStateChanged", unit)
end
