local _, addon = ...

local Updater = {}
addon.Updater = Updater

local initialized = false

local function Flush(updateReasons)
end

function Updater:CreateFlushCallback()
	if initialized then
		error("Flush Callback was already created", 2)
	end

	initialized = true

	return Flush
end
