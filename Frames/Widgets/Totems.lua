local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Totems = addon.Frames.Widgets.Totems or {}

local Totems = addon.Frames.Widgets.Totems
local PP = addon.PixelPerfect
local settingsCache = {}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit].totems
	local growsRight = settings.growthDirection == "UP_RIGHT" or settings.growthDirection == "DOWN_RIGHT"
	local growsUp = settings.growthDirection == "UP_RIGHT" or settings.growthDirection == "UP_LEFT"
	local result = {
		enabled = settings.enabled,
		containerPoint = (growsUp and "BOTTOM" or "TOP") .. (growsRight and "LEFT" or "RIGHT"),
		xDirection = growsRight and 1 or -1,
		yDirection = growsUp and 1 or -1,
		maxIcons = math.min(settings.maxIcons, #frame.totems.slots),
		columns = settings.iconsPerRow,
		iconSize = PP:ToUI(settings.iconSize),
		spacing = PP:ToUI(math.max(0, settings.spacing)),
		borderSize = PP:ToUI(1),
		showCooldown = settings.showCooldown,
		cooldownFontSize = PP:ToUI(settings.cooldownFontSize),
		position = {
			x = PP:ToUI(settings.position.x),
			y = PP:ToUI(settings.position.y),
		},
	}
	if result.spacing == 0 then
		result.spacing = -result.borderSize
	end
	result.columns = math.min(result.columns, result.maxIcons)
	result.rows = math.ceil(result.maxIcons / result.columns)
	result.iconStep = result.iconSize + result.spacing
	result.width = result.iconSize * result.columns + result.spacing * (result.columns - 1)
	result.height = result.iconSize * result.rows + result.spacing * (result.rows - 1)
	settingsCache[frame.settingsUnit] = result
end

function Totems:Ensure(frame)
	if frame.unit ~= "player" or frame.totems then
		return
	end

	local slotCount = GetNumTotemSlots()
	if slotCount == 0 then
		return
	end

	local container = CreateFrame("Frame", nil, frame)
	container:Hide()
	container:SetFrameStrata("MEDIUM")
	container:SetFrameLevel(frame:GetFrameLevel() + 5)
	container:EnableMouse(false)
	container.slots = {}
	frame.totems = container

	for slotIndex = 1, slotCount do
		local slot = CreateFrame("Frame", nil, container)
		slot:EnableMouse(false)

		local background = slot:CreateTexture(nil, "BACKGROUND")
		background:SetAllPoints(slot)
		background:SetColorTexture(0, 0, 0, 1)

		slot.icon = slot:CreateTexture(nil, "ARTWORK")
		slot.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		slot.cooldown = CreateFrame("Cooldown", nil, slot, "CooldownFrameTemplate")
		slot.cooldown:SetAllPoints(slot.icon)
		slot.cooldown:EnableMouse(false)
		slot.cooldown:SetReverse(true)
		slot.cooldown:SetDrawEdge(false)
		slot.cooldown:SetDrawBling(false)
		slot.cooldown:SetSwipeColor(0, 0, 0, 0.65)

		container.slots[slotIndex] = slot
	end

	self:UpdateSettings(frame)
end

function Totems:UpdateSettings(frame)
	if not frame or not frame.totems then
		return
	end

	UpdateSettingsCache(frame)
	local cachedSettings = settingsCache[frame.settingsUnit]
	local container = frame.totems
	if not cachedSettings.enabled then
		container:Hide()
		return
	end

	container:SetSize(cachedSettings.width, cachedSettings.height)
	local x = cachedSettings.position.x
	local y = cachedSettings.position.y
	container:ClearAllPoints()
	container:SetPoint(cachedSettings.containerPoint, frame, "TOPLEFT", x, y)

	for index, slot in ipairs(container.slots) do
		local column = (index - 1) % cachedSettings.columns
		local row = math.floor((index - 1) / cachedSettings.columns)
		slot:ClearAllPoints()
		slot:SetPoint(
			cachedSettings.containerPoint,
			container,
			cachedSettings.containerPoint,
			column * cachedSettings.iconStep * cachedSettings.xDirection,
			row * cachedSettings.iconStep * cachedSettings.yDirection
		)
		slot:SetSize(cachedSettings.iconSize, cachedSettings.iconSize)
		slot:SetShown(index <= cachedSettings.maxIcons)
		slot.icon:ClearAllPoints()
		slot.icon:SetPoint("TOPLEFT", slot, "TOPLEFT", cachedSettings.borderSize, -cachedSettings.borderSize)
		slot.icon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -cachedSettings.borderSize, cachedSettings.borderSize)

		slot.cooldown:SetHideCountdownNumbers(not cachedSettings.showCooldown)
		local countdown = slot.cooldown:GetCountdownFontString()
		countdown:SetFont("Fonts\\ARIALN.TTF", cachedSettings.cooldownFontSize, "OUTLINE")
		countdown:SetTextColor(1, 1, 1, 1)
	end

	self:UpdateState(frame)
	container:Show()
end

function Totems:UpdateState(frame)
	if not frame or not frame.totems then
		return
	end

	local cachedSettings = settingsCache[frame.settingsUnit]
	if not cachedSettings.enabled then
		return
	end

	for slotIndex, slot in ipairs(frame.totems.slots) do
		local haveTotem, _, _, _, icon = GetTotemInfo(slotIndex)

		slot.icon:SetTexture(icon)

		local duration = GetTotemDuration(slotIndex)
		if duration then
			slot.cooldown:SetCooldownFromDurationObject(duration, true)
		else
			slot.cooldown:Clear()
		end

		slot:SetAlphaFromBoolean(haveTotem, 1, 0)
	end
end
