local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Totems = addon.Frames.Widgets.Totems or {}

local Totems = addon.Frames.Widgets.Totems
local PP = addon.PixelPerfect
local settingsCache = {}

local anchorLayouts = {
	TOPLEFT = {
		containerPoint = "BOTTOMLEFT",
		framePoint = "TOPLEFT",
		xDirection = 1,
		yDirection = 1,
	},
	TOPRIGHT = {
		containerPoint = "BOTTOMRIGHT",
		framePoint = "TOPRIGHT",
		xDirection = -1,
		yDirection = 1,
	},
	BOTTOMLEFT = {
		containerPoint = "TOPLEFT",
		framePoint = "BOTTOMLEFT",
		xDirection = 1,
		yDirection = -1,
	},
	BOTTOMRIGHT = {
		containerPoint = "TOPRIGHT",
		framePoint = "BOTTOMRIGHT",
		xDirection = -1,
		yDirection = -1,
	},
}

local function UpdateSettingsCache(frame)
	local settings = addon.Database:GetProfile().frames[frame.settingsUnit].totems
	local result = {
		enabled = settings.enabled,
		anchor = settings.anchor,
		maxIcons = math.min(settings.maxIcons, #frame.totems.slots),
		iconsPerRow = settings.iconsPerRow,
		iconSize = settings.iconSize,
		spacing = math.max(0, settings.spacing),
		showCooldown = settings.showCooldown,
		cooldownFontSize = settings.cooldownFontSize,
		position = {
			x = settings.position.x,
			y = settings.position.y,
		},
	}
	result.iconsPerRow = math.min(result.iconsPerRow, result.maxIcons)
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

	local iconSize = PP:ToUI(cachedSettings.iconSize)
	local spacing = PP:ToUI(cachedSettings.spacing)
	local borderSize = PP:ToUI(1)
	if spacing == 0 then
		spacing = -borderSize
	end
	local columns = cachedSettings.iconsPerRow
	local rows = math.ceil(cachedSettings.maxIcons / columns)
	local layout = anchorLayouts[cachedSettings.anchor]

	container:ClearAllPoints()
	container:SetPoint(
		layout.containerPoint,
		frame,
		layout.framePoint,
		PP:ToUI(cachedSettings.position.x),
		PP:ToUI(cachedSettings.position.y)
	)
	container:SetSize(iconSize * columns + spacing * (columns - 1), iconSize * rows + spacing * (rows - 1))

	for index, slot in ipairs(container.slots) do
		local column = (index - 1) % columns
		local row = math.floor((index - 1) / columns)
		slot:ClearAllPoints()
		slot:SetPoint(
			layout.containerPoint,
			container,
			layout.containerPoint,
			column * (iconSize + spacing) * layout.xDirection,
			row * (iconSize + spacing) * layout.yDirection
		)
		slot:SetSize(iconSize, iconSize)
		slot:SetShown(index <= cachedSettings.maxIcons)
		slot.icon:ClearAllPoints()
		slot.icon:SetPoint("TOPLEFT", slot, "TOPLEFT", borderSize, -borderSize)
		slot.icon:SetPoint("BOTTOMRIGHT", slot, "BOTTOMRIGHT", -borderSize, borderSize)

		slot.cooldown:SetHideCountdownNumbers(not cachedSettings.showCooldown)
		local countdown = slot.cooldown:GetCountdownFontString()
		countdown:SetFont("Fonts\\ARIALN.TTF", PP:ToUI(cachedSettings.cooldownFontSize), "OUTLINE")
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
