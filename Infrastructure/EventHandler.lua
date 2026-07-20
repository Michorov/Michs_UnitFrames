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
	eventFrame:RegisterEvent("UNIT_PET")
	eventFrame:RegisterEvent("UNIT_TARGET")
	eventFrame:RegisterEvent("UNIT_HEALTH")
	eventFrame:RegisterEvent("UNIT_MAXHEALTH")
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

function EventHandler:PLAYER_ENTERING_WORLD() end

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

function EventHandler:UNIT_PET(event, unit)
	if unit == "player" then
		addon.UpdateScheduler:Notify("unitChanged", "pet")
	end
end

function EventHandler:UNIT_TARGET(event, unit)
	if unit == "target" then
		addon.UpdateScheduler:Notify("unitChanged", "targettarget")
	end
end

function EventHandler:UNIT_HEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
end

function EventHandler:UNIT_MAXHEALTH(event, unit)
	addon.UpdateScheduler:Notify("healthStateChanged", unit)
end

function EventHandler:UNIT_FACTION(event, unit)
	addon.UpdateScheduler:Notify("unitColorStateChanged", unit)
end
