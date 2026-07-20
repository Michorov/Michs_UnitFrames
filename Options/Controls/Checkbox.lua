local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Controls = addon.Options.Controls or {}
addon.Options.Controls.Checkbox = addon.Options.Controls.Checkbox or {}

local Checkbox = addon.Options.Controls.Checkbox
local PP = addon.PixelPerfect

local function UpdateVisual(checkbox)
	if checkbox.checked then
		if checkbox.isHovered then
			checkbox.check:SetColorTexture(1, 0.74, 0.42, 1)
		else
			checkbox.check:SetColorTexture(0.96, 0.66, 0.31, 1)
		end

		checkbox.check:Show()
	else
		checkbox.check:Hide()
	end
end

function Checkbox:Create(parent, text)
	local checkbox = CreateFrame("Button", nil, parent, "BackdropTemplate")

	checkbox.layout = {
		parent = parent,
		width = 220,
		height = 16,
		boxSize = 16,
		borderThickness = 1,
		fontSize = 12,
		textInset = 8,
		checkInset = 3,
		point = nil,
		relativeTo = parent,
		relativePoint = nil,
		offsetX = 0,
		offsetY = 0,
	}

	checkbox.checked = false
	checkbox.isHovered = false

	checkbox.box = CreateFrame("Frame", nil, checkbox, "BackdropTemplate")
	checkbox.box:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	checkbox.box:SetBackdropColor(0.04, 0.05, 0.07, 1)

	checkbox.boxHover = checkbox.box:CreateTexture(nil, "ARTWORK")
	checkbox.boxHover:SetColorTexture(1, 1, 1, 0.03)
	checkbox.boxHover:SetAllPoints(checkbox.box)
	checkbox.boxHover:Hide()

	checkbox.boxTopBorder = checkbox.box:CreateTexture(nil, "OVERLAY")
	checkbox.boxTopBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	checkbox.boxTopBorder:SetPoint("TOPLEFT", checkbox.box, "TOPLEFT", 0, 0)
	checkbox.boxTopBorder:SetPoint("TOPRIGHT", checkbox.box, "TOPRIGHT", 0, 0)

	checkbox.boxBottomBorder = checkbox.box:CreateTexture(nil, "OVERLAY")
	checkbox.boxBottomBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	checkbox.boxBottomBorder:SetPoint("BOTTOMLEFT", checkbox.box, "BOTTOMLEFT", 0, 0)
	checkbox.boxBottomBorder:SetPoint("BOTTOMRIGHT", checkbox.box, "BOTTOMRIGHT", 0, 0)

	checkbox.boxLeftBorder = checkbox.box:CreateTexture(nil, "OVERLAY")
	checkbox.boxLeftBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	checkbox.boxLeftBorder:SetPoint("TOPLEFT", checkbox.box, "TOPLEFT", 0, 0)
	checkbox.boxLeftBorder:SetPoint("BOTTOMLEFT", checkbox.box, "BOTTOMLEFT", 0, 0)

	checkbox.boxRightBorder = checkbox.box:CreateTexture(nil, "OVERLAY")
	checkbox.boxRightBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	checkbox.boxRightBorder:SetPoint("TOPRIGHT", checkbox.box, "TOPRIGHT", 0, 0)
	checkbox.boxRightBorder:SetPoint("BOTTOMRIGHT", checkbox.box, "BOTTOMRIGHT", 0, 0)

	checkbox.check = checkbox.box:CreateTexture(nil, "ARTWORK")
	checkbox.check:Hide()

	checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	checkbox.text:SetJustifyH("LEFT")
	checkbox.text:SetTextColor(0.85, 0.85, 0.88, 1)
	checkbox.text:SetText(text or "Checkbox")

	function checkbox:SetChecked(checked)
		self.checked = checked and true or false
		UpdateVisual(self)
	end

	function checkbox:GetChecked()
		return self.checked
	end

	function checkbox:SetText(value)
		self.text:SetText(value or "")
	end

	function checkbox:SetOnValueChanged(callback)
		self.onValueChanged = callback
	end

	function checkbox:SetLayoutWidth(width)
		self.layout.width = width
		self:UpdateLayout()
	end

	function checkbox:SetLayoutHeight(height)
		self.layout.height = height
		self:UpdateLayout()
	end

	function checkbox:SetLayoutSize(width, height)
		self.layout.width = width
		self.layout.height = height
		self:UpdateLayout()
	end

	function checkbox:SetBorderSize(borderThickness)
		self.layout.borderThickness = borderThickness
		self:UpdateLayout()
	end

	function checkbox:SetFontSize(fontSize)
		self.layout.fontSize = fontSize
		self:UpdateLayout()
	end

	function checkbox:SetLayoutPoint(point, relativeTo, relativePoint, offsetX, offsetY)
		self.layout.point = point
		self.layout.relativeTo = relativeTo or self.layout.parent
		self.layout.relativePoint = relativePoint or point
		self.layout.offsetX = offsetX or 0
		self.layout.offsetY = offsetY or 0
		self:UpdateLayout()
	end

	function checkbox:UpdateLayout()
		local borderThickness = PP:ToUIScaled(self.layout.borderThickness)
		local checkInset = PP:ToUIScaled(self.layout.checkInset)

		self:SetSize(PP:ToUIScaled(self.layout.width), PP:ToUIScaled(self.layout.height))
		self.box:ClearAllPoints()
		self.box:SetPoint("LEFT", self, "LEFT", 0, 0)
		self.box:SetSize(PP:ToUIScaled(self.layout.boxSize), PP:ToUIScaled(self.layout.boxSize))

		self.boxTopBorder:SetHeight(borderThickness)
		self.boxBottomBorder:SetHeight(borderThickness)
		self.boxLeftBorder:SetWidth(borderThickness)
		self.boxRightBorder:SetWidth(borderThickness)

		self.check:ClearAllPoints()
		self.check:SetPoint("TOPLEFT", self.box, "TOPLEFT", checkInset, -checkInset)
		self.check:SetPoint("BOTTOMRIGHT", self.box, "BOTTOMRIGHT", -checkInset, checkInset)

		self.text:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(self.layout.fontSize), "")
		self.text:ClearAllPoints()
		self.text:SetPoint(
			"LEFT",
			self,
			"LEFT",
			PP:ToUIScaled(self.layout.boxSize + self.layout.textInset),
			0
		)
		self.text:SetPoint("RIGHT", self, "RIGHT", 0, 0)

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

	checkbox:SetScript("OnEnter", function(self)
		self.isHovered = true
		self.boxHover:Show()
		UpdateVisual(self)
	end)

	checkbox:SetScript("OnLeave", function(self)
		self.isHovered = false
		self.boxHover:Hide()
		UpdateVisual(self)
	end)

	checkbox:SetScript("OnClick", function(self)
		self:SetChecked(not self:GetChecked())

		if self.onValueChanged then
			self.onValueChanged(self, self:GetChecked())
		end
	end)

	PP:RegisterForUpdate(function()
		checkbox:UpdateLayout()
	end)

	return checkbox
end
