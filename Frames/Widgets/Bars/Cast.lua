local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.Cast = addon.Frames.Widgets.Bars.Cast or {}

local Cast = addon.Frames.Widgets.Bars.Cast
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")

local supportedUnits = {
	player = true,
	pet = true,
	target = true,
	focus = true,
}

local function IsSupportedUnit(unit)
	return supportedUnits[unit] or unit:match("^boss%d+$") ~= nil
end

local function HideCastBar(castBar)
	castBar.duration = nil
	castBar.spellName:ClearText()
	castBar.castTime:ClearText()
	castBar:Hide()
	castBar.icon:Hide()
end

function Cast:Ensure(frame, settings)
	if not IsSupportedUnit(frame.unit) then
		return
	end

	if not frame.castBar then
		local castBar = CreateFrame("StatusBar", nil, frame)
		castBar:SetFrameLevel(20)
		castBar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
		castBar:SetStatusBarColor(1, 0.7, 0, 1)
		castBar:SetMinMaxValues(0, 1)
		castBar:SetValue(1)
		castBar:SetScript("OnUpdate", function(self)
			if self.duration and self.castTimeEnabled then
				self.castTime:SetFormattedText("%.1f", self.duration:GetRemainingDuration())
			end
		end)

		castBar.background = castBar:CreateTexture(nil, "BACKGROUND")
		castBar.background:SetAllPoints(castBar)
		castBar.background:SetColorTexture(0.08, 0.08, 0.08, 0.8)

		castBar.spellName = castBar:CreateFontString(nil, "OVERLAY")
		castBar.spellName:SetJustifyH("LEFT")
		castBar.spellName:SetMaxLines(1)
		castBar.spellName:SetWordWrap(false)

		castBar.castTime = castBar:CreateFontString(nil, "OVERLAY")
		castBar.castTime:SetJustifyH("RIGHT")
		castBar.castTime:SetMaxLines(1)

		local border = CreateFrame("Frame", nil, castBar)
		border:SetAllPoints(castBar)
		border:SetFrameLevel(castBar:GetFrameLevel() + 1)

		border.top = border:CreateTexture(nil, "OVERLAY")
		border.bottom = border:CreateTexture(nil, "OVERLAY")
		border.left = border:CreateTexture(nil, "OVERLAY")
		border.right = border:CreateTexture(nil, "OVERLAY")

		border.left:SetPoint("TOPLEFT", border, "TOPLEFT", 0, 0)
		border.left:SetPoint("BOTTOMLEFT", border, "BOTTOMLEFT", 0, 0)
		border.right:SetPoint("TOPRIGHT", border, "TOPRIGHT", 0, 0)
		border.right:SetPoint("BOTTOMRIGHT", border, "BOTTOMRIGHT", 0, 0)
		border.top:SetPoint("TOPLEFT", border.left, "TOPRIGHT", 0, 0)
		border.top:SetPoint("TOPRIGHT", border.right, "TOPLEFT", 0, 0)
		border.bottom:SetPoint("BOTTOMLEFT", border.left, "BOTTOMRIGHT", 0, 0)
		border.bottom:SetPoint("BOTTOMRIGHT", border.right, "BOTTOMLEFT", 0, 0)

		border.top:SetColorTexture(0, 0, 0, 1)
		border.bottom:SetColorTexture(0, 0, 0, 1)
		border.left:SetColorTexture(0, 0, 0, 1)
		border.right:SetColorTexture(0, 0, 0, 1)

		local icon = CreateFrame("Frame", nil, frame)
		icon:SetFrameLevel(castBar:GetFrameLevel())
		icon.texture = icon:CreateTexture(nil, "ARTWORK")
		icon.texture:SetAllPoints(icon)
		icon.texture:SetTexCoord(0.10, 0.90, 0.10, 0.90)

		local iconBorder = CreateFrame("Frame", nil, icon)
		iconBorder:SetAllPoints(icon)
		iconBorder:SetFrameLevel(icon:GetFrameLevel() + 1)
		iconBorder.top = iconBorder:CreateTexture(nil, "OVERLAY")
		iconBorder.bottom = iconBorder:CreateTexture(nil, "OVERLAY")
		iconBorder.left = iconBorder:CreateTexture(nil, "OVERLAY")
		iconBorder.right = iconBorder:CreateTexture(nil, "OVERLAY")

		iconBorder.left:SetPoint("TOPLEFT", iconBorder, "TOPLEFT", 0, 0)
		iconBorder.left:SetPoint("BOTTOMLEFT", iconBorder, "BOTTOMLEFT", 0, 0)
		iconBorder.right:SetPoint("TOPRIGHT", iconBorder, "TOPRIGHT", 0, 0)
		iconBorder.right:SetPoint("BOTTOMRIGHT", iconBorder, "BOTTOMRIGHT", 0, 0)
		iconBorder.top:SetPoint("TOPLEFT", iconBorder.left, "TOPRIGHT", 0, 0)
		iconBorder.top:SetPoint("TOPRIGHT", iconBorder.right, "TOPLEFT", 0, 0)
		iconBorder.bottom:SetPoint("BOTTOMLEFT", iconBorder.left, "BOTTOMRIGHT", 0, 0)
		iconBorder.bottom:SetPoint("BOTTOMRIGHT", iconBorder.right, "BOTTOMLEFT", 0, 0)

		iconBorder.top:SetColorTexture(0, 0, 0, 1)
		iconBorder.bottom:SetColorTexture(0, 0, 0, 1)
		iconBorder.left:SetColorTexture(0, 0, 0, 1)
		iconBorder.right:SetColorTexture(0, 0, 0, 1)

		icon.border = iconBorder
		icon:Hide()

		castBar.border = border
		castBar.icon = icon
		frame.castBar = castBar
	end

	self:UpdateSettings(frame, settings)
end

function Cast:UpdateSettings(frame, settings)
	if not frame.castBar then
		return
	end

	local castSettings = (settings and settings.cast) or {}
	local texture = castSettings.texture
	if texture == nil or texture == -1 then
		texture = addon.Database:GetProfile().general.texture
	end
	texture = texture or "Solid"

	if not LSM:IsValid("statusbar", texture) then
		texture = "Solid"
	end

	local iconSettings = castSettings.icon or {}
	local defaultFontSize = (frame.unit == "pet" or frame.unit == "focus") and 8 or 10
	local spellNameSettings = castSettings.spellName or {}
	local castTimeSettings = castSettings.castTime or {}
	local colors = castSettings.colors or {}
	local iconPosition = iconSettings.position or "LEFT"
	local spellNamePosition = spellNameSettings.position or "LEFT"
	local castTimePosition = castTimeSettings.position or "RIGHT"
	local font = castSettings.font
	if font == nil or font == -1 then
		font = addon.Database:GetProfile().general.font
	end
	frame.castBar.enabled = castSettings.enabled ~= false
	frame.castBar.font = font
	frame.castBar.showIcon = iconPosition ~= "HIDE"
	frame.castBar.iconPosition = iconPosition == "RIGHT" and "RIGHT" or "LEFT"
	frame.castBar.spellNameEnabled = spellNamePosition ~= "HIDE"
	frame.castBar.spellNamePosition = spellNamePosition == "RIGHT" and "RIGHT" or "LEFT"
	frame.castBar.castTimeEnabled = castTimePosition ~= "HIDE"
	frame.castBar.castTimePosition = castTimePosition == "LEFT" and "LEFT" or "RIGHT"
	frame.castBar.fontSize = castSettings.fontSize or defaultFontSize
	local castColor = colors.cast or { r = 1, g = 0.7, b = 0, a = 1 }
	local channelColor = colors.channel or { r = 0, g = 1, b = 0, a = 1 }
	local nonInterruptibleColor = colors.nonInterruptible
		or { r = 0.7, g = 0.7, b = 0.7, a = 1 }
	frame.castBar.castColor = CreateColor(castColor.r, castColor.g, castColor.b, castColor.a)
	frame.castBar.channelColor = CreateColor(
		channelColor.r,
		channelColor.g,
		channelColor.b,
		channelColor.a
	)
	frame.castBar.nonInterruptibleColor = CreateColor(
		nonInterruptibleColor.r,
		nonInterruptibleColor.g,
		nonInterruptibleColor.b,
		nonInterruptibleColor.a
	)
	frame.castBar.position = castSettings.position
		or (frame.unit == "focus" and "TOP" or "BOTTOM")
	frame.castBar.height = castSettings.height
		or ((frame.unit == "pet" or frame.unit == "focus") and 14 or 20)
	frame.castBar:SetStatusBarTexture(LSM:Fetch("statusbar", texture))
	self:UpdateLayout(frame)
	self:UpdateState(frame)
end

function Cast:UpdateLayout(frame)
	local castBar = frame.castBar
	if not castBar then
		return
	end

	local offset = PP:ToUIScaled(1)
	local height = PP:ToUIScaled(castBar.height)
	local borderThickness = PP:ToUIScaled(1)
	local border = castBar.border
	local icon = castBar.icon
	local iconBorder = icon.border
	local position = castBar.position == "TOP" and "TOP" or "BOTTOM"
	local point = position == "TOP" and "BOTTOM" or "TOP"
	local relativePoint = position
	local yOffset = position == "TOP" and offset or -offset
	local leftPoint = point .. "LEFT"
	local rightPoint = point .. "RIGHT"
	local relativeLeftPoint = relativePoint .. "LEFT"
	local relativeRightPoint = relativePoint .. "RIGHT"

	castBar:ClearAllPoints()
	castBar:SetHeight(height)
	border.left:SetWidth(borderThickness)
	border.right:SetWidth(borderThickness)
	border.top:SetHeight(borderThickness)
	border.bottom:SetHeight(borderThickness)

	icon:ClearAllPoints()
	icon:SetSize(height, height)
	iconBorder.left:SetWidth(borderThickness)
	iconBorder.right:SetWidth(borderThickness)
	iconBorder.top:SetHeight(borderThickness)
	iconBorder.bottom:SetHeight(borderThickness)

	castBar.spellName:ClearAllPoints()
	castBar.spellName:SetPoint(
		castBar.spellNamePosition,
		castBar,
		castBar.spellNamePosition,
		castBar.spellNamePosition == "LEFT" and PP:ToUIScaled(2) or PP:ToUIScaled(-2),
		0
	)
	castBar.spellName:SetJustifyH(castBar.spellNamePosition)
	castBar.spellName:SetFont(
		LSM:Fetch("font", castBar.font),
		PP:ScaleFont(castBar.fontSize),
		"OUTLINE"
	)
	castBar.spellName:SetShadowColor(0, 0, 0, 0.9)
	castBar.spellName:SetShadowOffset(1, -1)

	castBar.castTime:ClearAllPoints()
	castBar.castTime:SetPoint(
		castBar.castTimePosition,
		castBar,
		castBar.castTimePosition,
		castBar.castTimePosition == "LEFT" and PP:ToUIScaled(2) or PP:ToUIScaled(-2),
		0
	)
	castBar.castTime:SetJustifyH(castBar.castTimePosition)
	castBar.castTime:SetFont(
		LSM:Fetch("font", castBar.font),
		PP:ScaleFont(castBar.fontSize),
		"OUTLINE"
	)
	castBar.castTime:SetShadowColor(0, 0, 0, 0.9)
	castBar.castTime:SetShadowOffset(1, -1)

	if castBar.spellNameEnabled
		and castBar.castTimeEnabled
		and castBar.spellNamePosition == castBar.castTimePosition then
		castBar.spellName:ClearAllPoints()
		if castBar.spellNamePosition == "LEFT" then
			castBar.spellName:SetPoint(
				"LEFT",
				castBar.castTime,
				"RIGHT",
				PP:ToUIScaled(4),
				0
			)
			castBar.spellName:SetPoint("RIGHT", castBar, "RIGHT", PP:ToUIScaled(-2), 0)
		else
			castBar.spellName:SetPoint("LEFT", castBar, "LEFT", PP:ToUIScaled(2), 0)
			castBar.spellName:SetPoint(
				"RIGHT",
				castBar.castTime,
				"LEFT",
				PP:ToUIScaled(-4),
				0
			)
		end
	elseif castBar.spellNamePosition ~= castBar.castTimePosition then
		if castBar.spellNamePosition == "LEFT" then
			castBar.spellName:SetPoint(
				"RIGHT",
				castBar.castTime,
				"LEFT",
				PP:ToUIScaled(-4),
				0
			)
		else
			castBar.spellName:SetPoint(
				"LEFT",
				castBar.castTime,
				"RIGHT",
				PP:ToUIScaled(4),
				0
			)
		end
	end

	if not castBar.showIcon then
		castBar:SetPoint(leftPoint, frame, relativeLeftPoint, 0, yOffset)
		castBar:SetPoint(rightPoint, frame, relativeRightPoint, 0, yOffset)
	elseif castBar.iconPosition == "RIGHT" then
		icon:SetPoint(rightPoint, frame, relativeRightPoint, 0, yOffset)
		castBar:SetPoint(leftPoint, frame, relativeLeftPoint, 0, yOffset)
		castBar:SetPoint(rightPoint, icon, leftPoint, borderThickness, 0)
	else
		icon:SetPoint(leftPoint, frame, relativeLeftPoint, 0, yOffset)
		castBar:SetPoint(leftPoint, icon, rightPoint, -borderThickness, 0)
		castBar:SetPoint(rightPoint, frame, relativeRightPoint, 0, yOffset)
	end

	icon:SetShown(castBar:IsShown() and castBar.showIcon)
end

function Cast:UpdateState(frame)
	local castBar = frame.castBar
	if not castBar or not castBar.enabled or not frame.unit or not UnitExists(frame.unit) then
		if castBar then
			HideCastBar(castBar)
		end
		return
	end

	local direction = Enum.StatusBarTimerDirection.ElapsedTime
	local name, _, iconTexture, _, _, _, _, notInterruptible = UnitCastingInfo(frame.unit)
	local duration
	local isChannel

	if name then
		duration = UnitCastingDuration(frame.unit)
	else
		local isEmpowered
		name, _, iconTexture, _, _, _, notInterruptible, _, isEmpowered = UnitChannelInfo(frame.unit)
		isChannel = true

		if isEmpowered then
			duration = UnitEmpoweredChannelDuration(frame.unit)
		else
			duration = UnitChannelDuration(frame.unit)
			direction = Enum.StatusBarTimerDirection.RemainingTime
		end
	end

	if not name or not duration then
		HideCastBar(castBar)
		return
	end

	local color = isChannel and castBar.channelColor or castBar.castColor
	color = C_CurveUtil.EvaluateColorFromBoolean(
		notInterruptible,
		castBar.nonInterruptibleColor,
		color
	)
	castBar:SetStatusBarColor(color:GetRGBA())

	castBar:SetTimerDuration(duration, Enum.StatusBarInterpolation.Immediate, direction)
	castBar.duration = duration
	if castBar.spellNameEnabled then
		castBar.spellName:SetText(name)
	else
		castBar.spellName:ClearText()
	end
	if castBar.castTimeEnabled then
		castBar.castTime:SetFormattedText("%.1f", duration:GetRemainingDuration())
	else
		castBar.castTime:ClearText()
	end
	castBar.icon.texture:SetTexture(iconTexture or 136243)
	castBar:Show()
	castBar.icon:SetShown(castBar.showIcon)
	castBar.spellName:SetShown(castBar.spellNameEnabled)
	castBar.castTime:SetShown(castBar.castTimeEnabled)
end
