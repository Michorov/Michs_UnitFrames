local _, addon = ...

addon.Frames = addon.Frames or {}
addon.Frames.Widgets = addon.Frames.Widgets or {}
addon.Frames.Widgets.Bars = addon.Frames.Widgets.Bars or {}
addon.Frames.Widgets.Bars.Power = addon.Frames.Widgets.Bars.Power or {}

local Power = addon.Frames.Widgets.Bars.Power
local PP = addon.PixelPerfect
local LSM = LibStub("LibSharedMedia-3.0")

local function UpdateColor(frame)
	local powerType, powerToken, typeR, typeG, typeB = UnitPowerType(frame.unit)
	local color = PowerBarColor[powerToken] or PowerBarColor[powerType]

	if color then
		frame.powerBar:SetStatusBarColor(color.r, color.g, color.b, color.a or 1)
	else
		frame.powerBar:SetStatusBarColor(typeR or 0, typeG or 0.45, typeB or 1, 1)
	end
end

function Power:Ensure(frame, settings)
	if not frame.powerBar then
		local powerBar = CreateFrame("StatusBar", nil, frame)
		powerBar:SetFrameLevel(20)
		powerBar:SetOrientation("HORIZONTAL")
		powerBar:SetMinMaxValues(0, 1)
		powerBar:SetValue(0)
		powerBar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
		powerBar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)

		powerBar.background = powerBar:CreateTexture(nil, "BACKGROUND")
		powerBar.background:SetAllPoints(powerBar)
		powerBar.background:SetColorTexture(0.04, 0.04, 0.04, 1)

		local border = CreateFrame("Frame", nil, powerBar)
		border:SetAllPoints(powerBar)
		border:SetFrameLevel(powerBar:GetFrameLevel() + 1)

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

		powerBar.border = border
		frame.powerBar = powerBar
	end

	self:UpdateSettings(frame, settings)
end

function Power:UpdateSettings(frame, settings)
	local powerSettings = (settings and settings.power) or {}
	local texture = powerSettings.texture
	if texture == -1 then
		texture = addon.Database:GetProfile().general.texture
	end
	texture = texture or "Solid"

	if not LSM:IsValid("statusbar", texture) then
		texture = "Solid"
	end

	local borderThickness = PP:ToUIScaled(1)
	local border = frame.powerBar.border

	frame.powerBar.enabled = powerSettings.enabled ~= false
	frame.powerBar:SetStatusBarTexture(LSM:Fetch("statusbar", texture))
	frame.powerBar:SetHeight(PP:ToUIScaled(powerSettings.height or 4))
	border.left:SetWidth(borderThickness)
	border.right:SetWidth(borderThickness)
	border.top:SetHeight(borderThickness)
	border.bottom:SetHeight(borderThickness)

	self:UpdateState(frame, settings)
end

function Power:UpdateState(frame)
	if not frame.powerBar.enabled or not frame.unit or not UnitExists(frame.unit) then
		frame.powerBar:Hide()
		return
	end

	frame.powerBar:SetMinMaxValues(0, UnitPowerMax(frame.unit))
	frame.powerBar:SetValue(UnitPower(frame.unit))
	UpdateColor(frame)
	frame.powerBar:Show()
end
