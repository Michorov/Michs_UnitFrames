local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Controls = addon.Options.Controls or {}
addon.Options.Controls.Button = addon.Options.Controls.Button or {}

local Button = addon.Options.Controls.Button
local PP = addon.PixelPerfect

function Button:Create(parent, text)
	local button = CreateFrame("Button", nil, parent, "BackdropTemplate")

	button.layout = {
		parent = parent,
		width = 48,
		height = 24,
		borderThickness = 1,
		fontSize = 14,
		point = nil,
		relativeTo = parent,
		relativePoint = nil,
		offsetX = 0,
		offsetY = 0,
	}

	button:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	button:SetBackdropColor(0.12, 0.12, 0.14, 1)

	button.borderTop = button:CreateTexture(nil, "OVERLAY")
	button.borderTop:SetColorTexture(0.15, 0.17, 0.20, 1)
	button.borderTop:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.borderTop:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)

	button.borderBottom = button:CreateTexture(nil, "OVERLAY")
	button.borderBottom:SetColorTexture(0.15, 0.17, 0.20, 1)
	button.borderBottom:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)
	button.borderBottom:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

	button.borderLeft = button:CreateTexture(nil, "OVERLAY")
	button.borderLeft:SetColorTexture(0.15, 0.17, 0.20, 1)
	button.borderLeft:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	button.borderLeft:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 0, 0)

	button.borderRight = button:CreateTexture(nil, "OVERLAY")
	button.borderRight:SetColorTexture(0.15, 0.17, 0.20, 1)
	button.borderRight:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
	button.borderRight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)

	button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	button.text:SetPoint("CENTER", button, "CENTER", 0, 0)
	button.text:SetText(text or "Button")
	button.text:SetTextColor(0.85, 0.85, 0.88, 1)

	button:SetScript("OnEnter", function(self)
		self:SetBackdropColor(0.18, 0.18, 0.22, 1)
		self.text:SetTextColor(0.96, 0.66, 0.31, 1)
	end)

	button:SetScript("OnLeave", function(self)
		self:SetBackdropColor(0.12, 0.12, 0.14, 1)
		self.text:SetTextColor(0.85, 0.85, 0.88, 1)
	end)

	function button:SetOnClick(callback)
		self:SetScript("OnClick", callback)
	end

	function button:SetText(value)
		self.text:SetText(value or "")
	end

	function button:SetLayoutWidth(width)
		self.layout.width = width
		self:UpdateLayout()
	end

	function button:SetLayoutHeight(height)
		self.layout.height = height
		self:UpdateLayout()
	end

	function button:SetLayoutSize(width, height)
		self.layout.width = width
		self.layout.height = height
		self:UpdateLayout()
	end

	function button:SetBorderSize(borderThickness)
		self.layout.borderThickness = borderThickness
		self:UpdateLayout()
	end

	function button:SetFontSize(fontSize)
		self.layout.fontSize = fontSize
		self:UpdateLayout()
	end

	function button:SetLayoutPoint(point, relativeTo, relativePoint, offsetX, offsetY)
		self.layout.point = point
		self.layout.relativeTo = relativeTo or self.layout.parent
		self.layout.relativePoint = relativePoint or point
		self.layout.offsetX = offsetX or 0
		self.layout.offsetY = offsetY or 0
		self:UpdateLayout()
	end

	function button:UpdateLayout()
		self:SetSize(PP:ToUIScaled(self.layout.width), PP:ToUIScaled(self.layout.height))
		self.text:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(self.layout.fontSize), "")

		if self.layout.borderThickness == 0 then
			self.borderTop:Hide()
			self.borderBottom:Hide()
			self.borderLeft:Hide()
			self.borderRight:Hide()
		else
			local borderThickness = PP:ToUIScaled(self.layout.borderThickness)
			self.borderTop:SetHeight(borderThickness)
			self.borderBottom:SetHeight(borderThickness)
			self.borderLeft:SetWidth(borderThickness)
			self.borderRight:SetWidth(borderThickness)

			self.borderTop:Show()
			self.borderBottom:Show()
			self.borderLeft:Show()
			self.borderRight:Show()
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

	PP:RegisterForUpdate(function()
		button:UpdateLayout()
	end)

	return button
end
