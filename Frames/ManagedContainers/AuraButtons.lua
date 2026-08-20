local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.ManagedContainers = addon.Frames.ManagedContainers or {}
addon.Frames.ManagedContainers.AuraButtons = addon.Frames.ManagedContainers.AuraButtons or {}

local AuraButtons = addon.Frames.ManagedContainers.AuraButtons
local PP = addon.PixelPerfect

local function CreateBorderTexture(parent, fromPoint, toPoint)
	local texture = parent:CreateTexture(nil, "ARTWORK")
	texture:SetColorTexture(0, 0, 0, 1)
	texture:SetPoint(fromPoint, parent, fromPoint)
	texture:SetPoint(toPoint, parent, toPoint)

	return texture
end

function AuraButtons:ApplyTooltipSettings(button, cachedSettings)
	local enabled = cachedSettings.showTooltips == true

	if button.SetMouseClickEnabled then
		button:SetMouseClickEnabled(false)
	end

	if button.SetMouseMotionEnabled then
		button:SetMouseMotionEnabled(enabled)
	elseif button.EnableMouse then
		button:EnableMouse(enabled)
	end
end

function AuraButtons:Initialize(button, container)
	container.auraButtons = container.auraButtons or {}
	container.auraButtons[button] = true

	button:SetFrameLevel(container:GetFrameLevel())
	AuraButtons:ApplyTooltipSettings(button, { showTooltips = false })

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.icon = icon
	button:SetIcon(icon)

	local buttonFrameLevel = button:GetFrameLevel()
	local border = CreateFrame("Frame", nil, button)
	border:SetAllPoints(button)
	border:SetFrameLevel(buttonFrameLevel + 2)
	border.edges = {
		top = CreateBorderTexture(border, "TOPLEFT", "TOPRIGHT"),
		bottom = CreateBorderTexture(border, "BOTTOMLEFT", "BOTTOMRIGHT"),
		left = CreateBorderTexture(border, "TOPLEFT", "BOTTOMLEFT"),
		right = CreateBorderTexture(border, "TOPRIGHT", "BOTTOMRIGHT"),
	}
	button.border = border

	local textLayer = CreateFrame("Frame", nil, button)
	textLayer:SetAllPoints(button)
	textLayer:SetFrameLevel(buttonFrameLevel + 3)
	button.textLayer = textLayer

	local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	cooldown:SetAllPoints(icon)
	cooldown:SetReverse(true)
	cooldown:SetFrameLevel(buttonFrameLevel + 1)

	for _, region in ipairs({ cooldown:GetRegions() }) do
		if region and region.GetObjectType and region:GetObjectType() == "FontString" then
			region:SetParent(textLayer)
			region:ClearAllPoints()
			region:SetPoint("CENTER", cooldown, "CENTER")
			break
		end
	end

	button.cooldown = cooldown
	button:SetDurationCooldown(cooldown)

	local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
	count:SetTextColor(1, 1, 1, 1)
	count:SetParent(textLayer)
	count:SetDrawLayer("OVERLAY", 7)
	button.count = count
	button:SetApplicationCount(count, {})
end

function AuraButtons:ApplyIconSettings(button, cachedSettings)
	local iconSize = PP:ToUIScaled(cachedSettings.iconSize)
	local borderSize = PP:ToUIScaled(1)

	button:SetSize(iconSize, iconSize)
	button.icon:ClearAllPoints()
	button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", borderSize, -borderSize)
	button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -borderSize, borderSize)

	button.cooldown:ClearAllPoints()
	button.cooldown:SetAllPoints(button.icon)
end

function AuraButtons:ApplyBorderSettings(button)
	local borderSize = PP:ToUIScaled(1)
	local edges = button.border.edges

	button.border:Show()
	edges.top:SetHeight(borderSize)
	edges.bottom:SetHeight(borderSize)
	edges.left:SetWidth(borderSize)
	edges.right:SetWidth(borderSize)

	if button.SetHitRectInsets then
		button:SetHitRectInsets(borderSize, borderSize, borderSize, borderSize)
	end
end

function AuraButtons:ApplyCooldownSettings(button, cachedSettings)
	button.cooldown:SetHideCountdownNumbers(not cachedSettings.showCooldown)

	if cachedSettings.showCooldown and button.cooldown.SetCountdownFont then
		local fontSize = PP:ScaleFont(cachedSettings.cooldownFontSize)
		local fontName = "MUF_CooldownFont_" .. tostring(fontSize)
		local cooldownFont = _G[fontName]
		if not cooldownFont then
			cooldownFont = CreateFont(fontName)
		end

		cooldownFont:SetFont("Fonts\\ARIALN.TTF", fontSize, "OUTLINE")
		button.cooldown:SetCountdownFont(fontName)
	end
end

function AuraButtons:ApplyCountSettings(button, cachedSettings)
	local borderSize = PP:ToUIScaled(1)

	button.count:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(cachedSettings.stacksFontSize), "OUTLINE")
	button.count:SetTextColor(1, 1, 1, 1)
	button.count:ClearAllPoints()
	button.count:SetAlpha(cachedSettings.showStacks and 1 or 0)
	button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -borderSize, borderSize)
end
