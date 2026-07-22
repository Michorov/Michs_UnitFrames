local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Controls = addon.Options.Controls or {}
addon.Options.Controls.Input = addon.Options.Controls.Input or {}

local Input = addon.Options.Controls.Input
local PP = addon.PixelPerfect

local function UpdatePlaceholder(control)
	local text = control.field:GetText() or ""
	local showPlaceholder = control.placeholder ~= ""
		and text == ""
		and not control.field:HasFocus()

	control.placeholderText:SetShown(showPlaceholder)
end

function Input:Create(parent, labelText)
	local control = CreateFrame("Frame", nil, parent)
	control.layout = {
		parent = parent,
		width = 220,
		fieldHeight = 24,
		labelHeight = 16,
		labelSpacing = 4,
		borderThickness = 1,
		textInset = 10,
		fontSize = 12,
		point = nil,
		relativeTo = parent,
		relativePoint = nil,
		offsetX = 0,
		offsetY = 0,
	}
	control.placeholder = ""
	control.labelVisible = true

	control.label = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	control.label:SetText(labelText or "Input")
	control.label:SetTextColor(0.85, 0.85, 0.88, 1)
	control.label:SetJustifyH("LEFT")

	control.field = CreateFrame("EditBox", nil, control, "BackdropTemplate")
	control.field:SetAutoFocus(false)
	control.field:SetTextColor(0.85, 0.85, 0.88, 1)
	control.field:SetJustifyH("LEFT")
	control.field:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	control.field:SetBackdropColor(0.04, 0.05, 0.07, 1)

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

	control.field.hoverTexture = control.field:CreateTexture(nil, "ARTWORK")
	control.field.hoverTexture:SetColorTexture(1, 1, 1, 0.03)
	control.field.hoverTexture:SetAllPoints(control.field)
	control.field.hoverTexture:Hide()

	control.placeholderText = control.field:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	control.placeholderText:SetTextColor(0.50, 0.52, 0.56, 1)
	control.placeholderText:SetJustifyH("LEFT")

	control.field:SetScript("OnEnter", function(self)
		self.hoverTexture:Show()
	end)

	control.field:SetScript("OnLeave", function(self)
		self.hoverTexture:Hide()
	end)

	control.field:SetScript("OnTextChanged", function(self, userInput)
		UpdatePlaceholder(control)
		if userInput and control.onTextChanged then
			control.onTextChanged(control, self:GetText())
		end
	end)

	control.field:SetScript("OnEnterPressed", function(self)
		if control.onEnterPressed then
			control.onEnterPressed(control, self:GetText())
		end
		self:ClearFocus()
	end)

	control.field:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	control.field:SetScript("OnEditFocusLost", function(self)
		UpdatePlaceholder(control)
		if control.onEditFocusLost then
			control.onEditFocusLost(control, self:GetText())
		end
	end)

	control.field:SetScript("OnEditFocusGained", function()
		UpdatePlaceholder(control)
	end)

	function control:SetText(value)
		self.field:SetText(value or "")
		UpdatePlaceholder(self)
	end

	function control:GetText()
		return self.field:GetText() or ""
	end

	function control:SetPlaceholder(text)
		self.placeholder = text or ""
		self.placeholderText:SetText(self.placeholder)
		UpdatePlaceholder(self)
	end

	function control:SetOnEnterPressed(callback)
		self.onEnterPressed = callback
	end

	function control:SetLayoutWidth(width)
		self.layout.width = width
		self:UpdateLayout()
	end

	function control:SetLayoutHeight(height)
		self.layout.fieldHeight = height
		self:UpdateLayout()
	end

	function control:SetLayoutSize(width, height)
		self.layout.width = width
		self.layout.fieldHeight = height
		self:UpdateLayout()
	end

	function control:SetLabelVisible(isVisible)
		self.labelVisible = isVisible ~= false
		self:UpdateLayout()
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
		local fieldHeight = PP:ToUIScaled(self.layout.fieldHeight)
		local labelHeight = PP:ToUIScaled(self.layout.labelHeight)
		local labelSpacing = PP:ToUIScaled(self.layout.labelSpacing)
		local borderThickness = PP:ToUIScaled(self.layout.borderThickness)
		local textInset = PP:ToUIScaled(self.layout.textInset)

		self:SetWidth(PP:ToUIScaled(self.layout.width))
		self.label:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(self.layout.fontSize), "")
		self.field:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(self.layout.fontSize), "")
		self.placeholderText:SetFont(
			"Fonts\\ARIALN.TTF",
			PP:ScaleFont(self.layout.fontSize),
			""
		)

		self.label:ClearAllPoints()
		self.field:ClearAllPoints()
		if self.labelVisible then
			self:SetHeight(labelHeight + labelSpacing + fieldHeight)
			self.label:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			self.label:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			self.label:SetHeight(labelHeight)
			self.label:Show()
			self.field:SetPoint(
				"TOPLEFT",
				self,
				"TOPLEFT",
				0,
				-(labelHeight + labelSpacing)
			)
			self.field:SetPoint(
				"TOPRIGHT",
				self,
				"TOPRIGHT",
				0,
				-(labelHeight + labelSpacing)
			)
		else
			self:SetHeight(fieldHeight)
			self.label:Hide()
			self.field:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			self.field:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		end

		self.field:SetHeight(fieldHeight)
		self.field:SetTextInsets(textInset, textInset, 0, 0)
		self.field.topBorder:SetHeight(borderThickness)
		self.field.bottomBorder:SetHeight(borderThickness)
		self.field.leftBorder:SetWidth(borderThickness)
		self.field.rightBorder:SetWidth(borderThickness)

		self.placeholderText:ClearAllPoints()
		self.placeholderText:SetPoint("LEFT", self.field, "LEFT", textInset, 0)
		self.placeholderText:SetPoint("RIGHT", self.field, "RIGHT", -textInset, 0)

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

		UpdatePlaceholder(self)
	end

	PP:RegisterForUpdate(function()
		control:UpdateLayout()
	end)

	control:UpdateLayout()
	return control
end
