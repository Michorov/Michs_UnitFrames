local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Controls = addon.Options.Controls or {}
addon.Options.Controls.ColorPicker = addon.Options.Controls.ColorPicker or {}

local ColorPicker = addon.Options.Controls.ColorPicker
local PP = addon.PixelPerfect

local function ClampChannel(value, fallback)
	value = tonumber(value)
	if value == nil then
		return fallback
	end

	return math.max(0, math.min(1, value))
end

local function UpdateVisual(control)
	control.swatchFill:SetColorTexture(control.r, control.g, control.b, control.a)
	control.field.hoverTexture:SetShown(control.isHovered)
end

local function NotifyValueChanged(control)
	if control.onValueChanged then
		control.onValueChanged(control, control.r, control.g, control.b, control.a)
	end
end

local function OpenPicker(control)
	if not ColorPickerFrame or not ColorPickerFrame.SetupColorPickerAndShow then
		return
	end

	addon.Options.Controls.Dropdown:CloseOpenDropdown()

	local initialR, initialG, initialB, initialA = control:GetColor()
	local function ApplyFromPicker()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		local a = control.hasOpacity and (ColorPickerFrame:GetColorAlpha() or 1) or 1

		control:SetColor(r, g, b, a)
		NotifyValueChanged(control)
	end

	ColorPickerFrame:SetupColorPickerAndShow({
		swatchFunc = ApplyFromPicker,
		opacityFunc = ApplyFromPicker,
		cancelFunc = function(previousValues)
			if type(previousValues) == "table" then
				control:SetColor(
					previousValues.r or initialR,
					previousValues.g or initialG,
					previousValues.b or initialB,
					previousValues.a or previousValues.opacity or initialA
				)
			else
				control:SetColor(initialR, initialG, initialB, initialA)
			end

			NotifyValueChanged(control)
		end,
		hasOpacity = control.hasOpacity,
		opacity = initialA,
		r = initialR,
		g = initialG,
		b = initialB,
	})
end

function ColorPicker:Create(parent, labelText)
	local control = CreateFrame("Frame", nil, parent)
	control.layout = {
		parent = parent,
		width = 220,
		pickerSize = 24,
		labelInset = 8,
		borderThickness = 1,
		swatchInnerInset = 2,
		fontSize = 12,
		point = nil,
		relativeTo = parent,
		relativePoint = nil,
		offsetX = 0,
		offsetY = 0,
	}
	control.labelVisible = true
	control.hasOpacity = false
	control.isHovered = false
	control.r = 1
	control.g = 1
	control.b = 1
	control.a = 1

	control.label = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	control.label:SetTextColor(0.85, 0.85, 0.88, 1)
	control.label:SetJustifyH("LEFT")
	control.label:SetJustifyV("MIDDLE")
	control.label:SetText(labelText or "Color")

	control.field = CreateFrame("Button", nil, control, "BackdropTemplate")
	control.field:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	control.field:SetBackdropColor(0.02, 0.03, 0.04, 1)

	control.field.topBorder = control.field:CreateTexture(nil, "OVERLAY")
	control.field.topBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.field.topBorder:SetPoint("TOPLEFT", control.field, "TOPLEFT", 0, 0)
	control.field.topBorder:SetPoint("TOPRIGHT", control.field, "TOPRIGHT", 0, 0)

	control.field.bottomBorder = control.field:CreateTexture(nil, "OVERLAY")
	control.field.bottomBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.field.bottomBorder:SetPoint("BOTTOMLEFT", control.field, "BOTTOMLEFT", 0, 0)
	control.field.bottomBorder:SetPoint("BOTTOMRIGHT", control.field, "BOTTOMRIGHT", 0, 0)

	control.field.leftBorder = control.field:CreateTexture(nil, "OVERLAY")
	control.field.leftBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.field.leftBorder:SetPoint("TOPLEFT", control.field, "TOPLEFT", 0, 0)
	control.field.leftBorder:SetPoint("BOTTOMLEFT", control.field, "BOTTOMLEFT", 0, 0)

	control.field.rightBorder = control.field:CreateTexture(nil, "OVERLAY")
	control.field.rightBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.field.rightBorder:SetPoint("TOPRIGHT", control.field, "TOPRIGHT", 0, 0)
	control.field.rightBorder:SetPoint("BOTTOMRIGHT", control.field, "BOTTOMRIGHT", 0, 0)

	control.field.hoverTexture = control.field:CreateTexture(nil, "OVERLAY", nil, 1)
	control.field.hoverTexture:SetColorTexture(1, 1, 1, 0.08)
	control.field.hoverTexture:SetAllPoints(control.field)

	control.swatchFill = control.field:CreateTexture(nil, "ARTWORK")

	function control:SetLabel(text)
		self.label:SetText(text or "")
	end

	function control:SetLayoutWidth(width)
		self.layout.width = width
		self:UpdateLayout()
	end

	function control:SetPickerSize(size)
		self.layout.pickerSize = size
		self:UpdateLayout()
	end

	function control:SetBorderSize(borderThickness)
		self.layout.borderThickness = borderThickness
		self:UpdateLayout()
	end

	function control:SetFontSize(fontSize)
		self.layout.fontSize = fontSize
		self:UpdateLayout()
	end

	function control:SetLabelVisible(isVisible)
		self.labelVisible = isVisible ~= false
		self:UpdateLayout()
	end

	function control:SetHasOpacity(hasOpacity)
		self.hasOpacity = hasOpacity == true
		self.a = self.hasOpacity and self.a or 1
		UpdateVisual(self)
	end

	function control:SetColor(r, g, b, a)
		if type(r) == "table" then
			a = r.a
			b = r.b
			g = r.g
			r = r.r
		end

		self.r = ClampChannel(r, self.r)
		self.g = ClampChannel(g, self.g)
		self.b = ClampChannel(b, self.b)
		self.a = self.hasOpacity and ClampChannel(a, self.a) or 1
		UpdateVisual(self)
	end

	function control:GetColor()
		return self.r, self.g, self.b, self.a
	end

	function control:SetOnValueChanged(callback)
		self.onValueChanged = callback
	end

	function control:SetLayoutPoint(point, relativeTo, relativePoint, offsetX, offsetY)
		self.layout.point = point
		self.layout.relativeTo = relativeTo or self.layout.parent
		self.layout.relativePoint = relativePoint or point
		self.layout.offsetX = offsetX or 0
		self.layout.offsetY = offsetY or 0
		self:UpdateLayout()
	end

	function control:UpdateLayout()
		local pickerSize = PP:ToUIScaled(self.layout.pickerSize)
		local borderThickness = PP:ToUIScaled(self.layout.borderThickness)
		local swatchInnerInset = PP:ToUIScaled(self.layout.swatchInnerInset)

		self:SetSize(PP:ToUIScaled(self.layout.width), pickerSize)
		self.label:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(self.layout.fontSize), "")

		self.field:ClearAllPoints()
		self.field:SetPoint("LEFT", self, "LEFT", 0, 0)
		self.field:SetSize(pickerSize, pickerSize)

		self.field.topBorder:SetHeight(borderThickness)
		self.field.bottomBorder:SetHeight(borderThickness)
		self.field.leftBorder:SetWidth(borderThickness)
		self.field.rightBorder:SetWidth(borderThickness)

		self.swatchFill:ClearAllPoints()
		self.swatchFill:SetPoint("TOPLEFT", self.field, "TOPLEFT", swatchInnerInset, -swatchInnerInset)
		self.swatchFill:SetPoint("BOTTOMRIGHT", self.field, "BOTTOMRIGHT", -swatchInnerInset, swatchInnerInset)

		self.label:ClearAllPoints()
		if self.labelVisible then
			self.label:Show()
			self.label:SetPoint("LEFT", self.field, "RIGHT", PP:ToUIScaled(self.layout.labelInset), 0)
			self.label:SetPoint("RIGHT", self, "RIGHT", 0, 0)
			self.label:SetPoint("TOP", self.field, "TOP", 0, 0)
			self.label:SetPoint("BOTTOM", self.field, "BOTTOM", 0, 0)
		else
			self.label:Hide()
		end

		if self.layout.point then
			self:ClearAllPoints()
			self:SetPoint(
				self.layout.point,
				self.layout.relativeTo,
				self.layout.relativePoint,
				PP:ToUIScaled(self.layout.offsetX),
				PP:ToUIScaled(self.layout.offsetY)
			)
		end
	end

	control.field:SetScript("OnEnter", function()
		control.isHovered = true
		UpdateVisual(control)
	end)

	control.field:SetScript("OnLeave", function()
		control.isHovered = false
		UpdateVisual(control)
	end)

	control.field:SetScript("OnClick", function()
		OpenPicker(control)
	end)

	PP:RegisterForUpdate(function()
		control:UpdateLayout()
	end)

	control:UpdateLayout()
	UpdateVisual(control)

	return control
end
