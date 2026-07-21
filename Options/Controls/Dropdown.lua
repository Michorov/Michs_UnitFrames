local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Controls = addon.Options.Controls or {}
addon.Options.Controls.Dropdown = addon.Options.Controls.Dropdown or {}

local Dropdown = addon.Options.Controls.Dropdown
local PP = addon.PixelPerfect

local openDropdown
local defaultArrowColor = { 0.72, 0.74, 0.78, 1 }

local function HideOpenDropdown()
	if not openDropdown then
		return
	end

	openDropdown:SetArrowColor(defaultArrowColor)
	openDropdown.list:Hide()
	openDropdown = nil
end

local function GetOption(options, value)
	for _, option in ipairs(options or {}) do
		if option.value == value then
			return option
		end
	end
end

local function ApplyOptionTexture(texture, option)
	if option and option.texture then
		texture:SetTexture(option.texture)
		texture:Show()
	else
		texture:SetTexture(nil)
		texture:Hide()
	end
end

local function ApplyOptionTextStyle(control, fontString, option, isPlaceholder)
	local fontSize = PP:ScaleFont(control.layout.fontSize)
	if option and option.font then
		fontString:SetFont(option.font, fontSize, "")
	else
		fontString:SetFont("Fonts\\ARIALN.TTF", fontSize, "")
	end

	if option and option.texture then
		fontString:SetShadowColor(0, 0, 0, 1)
		fontString:SetShadowOffset(1, -1)
	else
		fontString:SetShadowColor(0, 0, 0, 0)
		fontString:SetShadowOffset(0, 0)
	end

	if option and option.textColor then
		fontString:SetTextColor(
			option.textColor[1] or 1,
			option.textColor[2] or 1,
			option.textColor[3] or 1,
			option.textColor[4] or 1
		)
	elseif isPlaceholder then
		fontString:SetTextColor(0.50, 0.52, 0.56, 1)
	else
		fontString:SetTextColor(0.85, 0.85, 0.88, 1)
	end
end

local function UpdateSelectionText(control)
	local selectedOption = GetOption(control.options, control.value)
	local selectedText = selectedOption and selectedOption.text
	local isPlaceholder = not selectedText

	control.selectionText:SetText(selectedText or control.placeholder or "")
	ApplyOptionTexture(control.selectionTexture, selectedOption)
	ApplyOptionTextStyle(control, control.selectionText, selectedOption, isPlaceholder)
end

local function SetArrowColor(control, color)
	control.arrow.leftStroke:SetColorTexture(color[1], color[2], color[3], color[4])
	control.arrow.rightStroke:SetColorTexture(color[1], color[2], color[3], color[4])
end

local function ScrollList(control, delta)
	if not control.list.scrollBar:IsShown() then
		return
	end

	local step = PP:ToUIScaled(control.layout.listRowHeight + control.layout.listRowSpacing)
	local value = control.list.scrollBar:GetValue() - (delta * step)
	control.list.scrollBar:SetValue(math.max(0, math.min(control.list.scrollRange, value)))
end

local function StopScrollBarDrag(control)
	control.list.scrollHitArea:SetScript("OnUpdate", nil)
	control.list.scrollDragOffset = nil
end

local function UpdateScrollBarDrag(control)
	if not IsMouseButtonDown("LeftButton") then
		StopScrollBarDrag(control)
		return
	end

	local scrollBar = control.list.scrollBar
	local scrollRange = control.list.scrollRange
	local thumbHeight = scrollBar.thumb:GetHeight()
	local thumbTravel = scrollBar:GetHeight() - thumbHeight
	if scrollRange <= 0 or thumbTravel <= 0 then
		return
	end

	local _, cursorY = GetCursorPosition()
	cursorY = cursorY / scrollBar:GetEffectiveScale()

	local thumbTop = cursorY + control.list.scrollDragOffset
	local topOffset = math.max(0, math.min(thumbTravel, scrollBar:GetTop() - thumbTop))
	scrollBar:SetValue((topOffset / thumbTravel) * scrollRange)
end

local function StartScrollBarDrag(control)
	local scrollBar = control.list.scrollBar
	local scrollRange = control.list.scrollRange
	local thumbHeight = scrollBar.thumb:GetHeight()
	local thumbTravel = scrollBar:GetHeight() - thumbHeight
	if scrollRange <= 0 or thumbTravel <= 0 then
		return
	end

	local _, cursorY = GetCursorPosition()
	cursorY = cursorY / scrollBar:GetEffectiveScale()

	local thumbTop = scrollBar:GetTop() - ((scrollBar:GetValue() / scrollRange) * thumbTravel)
	local thumbBottom = thumbTop - thumbHeight
	if cursorY <= thumbTop and cursorY >= thumbBottom then
		control.list.scrollDragOffset = thumbTop - cursorY
	else
		control.list.scrollDragOffset = thumbHeight / 2
	end

	control.list.scrollHitArea:SetScript("OnUpdate", function()
		UpdateScrollBarDrag(control)
	end)
	UpdateScrollBarDrag(control)
end

local function EnsureListRows(control)
	for index, option in ipairs(control.options) do
		local button = control.list.buttons[index]

		if not button then
			button = CreateFrame("Button", nil, control.list.scrollChild, "BackdropTemplate")
			button:SetBackdrop({
				bgFile = "Interface\\Buttons\\WHITE8x8",
			})
			button:SetBackdropColor(0, 0, 0, 0)

			button.previewTexture = button:CreateTexture(nil, "ARTWORK", nil, -1)
			button.previewTexture:SetAllPoints(button)
			button.previewTexture:SetAlpha(0.4)
			button.previewTexture:Hide()

			button.hoverTexture = button:CreateTexture(nil, "ARTWORK")
			button.hoverTexture:SetColorTexture(1, 1, 1, 0.03)
			button.hoverTexture:SetAllPoints(button)
			button.hoverTexture:Hide()

			button.text = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			button.text:SetJustifyH("LEFT")
			button.text:SetWordWrap(false)
			button.text:SetMaxLines(1)

			button:SetScript("OnEnter", function(self)
				self.hoverTexture:Show()
			end)

			button:SetScript("OnLeave", function(self)
				self.hoverTexture:Hide()
			end)

			button:EnableMouseWheel(true)
			button:SetScript("OnMouseWheel", function(_, delta)
				ScrollList(control, delta)
			end)

			button:SetScript("OnClick", function(self)
				control:SetValue(self.value)
				HideOpenDropdown()

				if control.onValueChanged then
					control.onValueChanged(control, self.value)
				end
			end)

			control.list.buttons[index] = button
		end

		button:SetFrameLevel(control.list.scrollFrame:GetFrameLevel() + 1)
		button.value = option.value
		ApplyOptionTexture(button.previewTexture, option)
		ApplyOptionTextStyle(control, button.text, option, false)
		button.text:SetText(option.text or "")
		button.text:ClearAllPoints()
		button.text:SetPoint("LEFT", button, "LEFT", PP:ToUIScaled(control.layout.textInset), 0)
		button.text:SetPoint("RIGHT", button, "RIGHT", PP:ToUIScaled(-control.layout.textInset), 0)
		button:Show()
	end

	for index = #control.options + 1, #control.list.buttons do
		control.list.buttons[index]:Hide()
	end
end

local function UpdateListLayout(control)
	local borderThickness = PP:ToUIScaled(control.layout.borderThickness)
	local rowHeight = PP:ToUIScaled(control.layout.listRowHeight)
	local rowSpacing = PP:ToUIScaled(control.layout.listRowSpacing)
	local listPadding = PP:ToUIScaled(control.layout.listPadding)
	local optionCount = #control.options
	local visibleCount = math.min(optionCount, control.layout.maxVisibleRows)
	local contentHeight = (optionCount * rowHeight)
		+ (math.max(0, optionCount - 1) * rowSpacing)
	local visibleHeight = (visibleCount * rowHeight)
		+ (math.max(0, visibleCount - 1) * rowSpacing)
	local listHeight = visibleHeight
		+ (listPadding * 2)
	local isScrollable = optionCount > control.layout.maxVisibleRows
	local scrollBarWidth = PP:ToUIScaled(control.layout.scrollBarWidth)
	local scrollBarSpacing = PP:ToUIScaled(control.layout.scrollBarSpacing)
	local contentWidth = control:GetWidth() - (listPadding * 2)
	if isScrollable then
		contentWidth = contentWidth - scrollBarWidth - scrollBarSpacing
	end

	control.list:ClearAllPoints()
	control.list:SetPoint("TOPLEFT", control.field, "BOTTOMLEFT", 0, -borderThickness)
	control.list:SetWidth(control:GetWidth())
	control.list:SetHeight(listHeight)

	control.list.topBorder:SetHeight(borderThickness)
	control.list.bottomBorder:SetHeight(borderThickness)
	control.list.leftBorder:SetWidth(borderThickness)
	control.list.rightBorder:SetWidth(borderThickness)

	control.list.scrollFrame:ClearAllPoints()
	control.list.scrollFrame:SetPoint("TOPLEFT", control.list, "TOPLEFT", listPadding, -listPadding)
	control.list.scrollFrame:SetSize(contentWidth, visibleHeight)
	control.list.scrollChild:SetSize(contentWidth, math.max(contentHeight, PP:ToUIScaled(1)))

	EnsureListRows(control)

	local previousButton
	for _, button in ipairs(control.list.buttons) do
		if button:IsShown() then
			button:ClearAllPoints()
			button:SetHeight(rowHeight)

			if previousButton then
				button:SetPoint("TOPLEFT", previousButton, "BOTTOMLEFT", 0, -rowSpacing)
				button:SetPoint("TOPRIGHT", previousButton, "BOTTOMRIGHT", 0, -rowSpacing)
			else
				button:SetPoint("TOPLEFT", control.list.scrollChild, "TOPLEFT", 0, 0)
				button:SetPoint("TOPRIGHT", control.list.scrollChild, "TOPRIGHT", 0, 0)
			end

			previousButton = button
		end
	end

	control.list.scrollRange = math.max(0, contentHeight - visibleHeight)
	if isScrollable then
		local scrollTrackWidth = PP:ToUIScaled(control.layout.scrollTrackWidth)
		local scrollThumbWidth = PP:ToUIScaled(control.layout.scrollThumbWidth)
		local scrollThumbHeight = math.max(
			PP:ToUIScaled(control.layout.scrollThumbMinHeight),
			visibleHeight * (visibleHeight / contentHeight)
		)

		control.list.scrollBar:ClearAllPoints()
		control.list.scrollBar:SetPoint("TOPRIGHT", control.list, "TOPRIGHT", -listPadding, -listPadding)
		control.list.scrollBar:SetSize(scrollBarWidth, visibleHeight)
		control.list.scrollBar.track:SetWidth(scrollTrackWidth)
		control.list.scrollBar.thumb:SetSize(scrollThumbWidth, scrollThumbHeight)
		control.list.scrollBar:SetMinMaxValues(0, control.list.scrollRange)
		control.list.scrollBar:SetValue(0)
		control.list.scrollFrame:SetVerticalScroll(0)
		control.list.scrollBar:Show()

		control.list.scrollHitArea:ClearAllPoints()
		control.list.scrollHitArea:SetPoint(
			"TOPLEFT",
			control.list.scrollFrame,
			"TOPRIGHT",
			0,
			listPadding
		)
		control.list.scrollHitArea:SetPoint("BOTTOMRIGHT", control.list, "BOTTOMRIGHT", 0, 0)
		control.list.scrollHitArea:Show()
	else
		StopScrollBarDrag(control)
		control.list.scrollBar:Hide()
		control.list.scrollHitArea:Hide()
		control.list.scrollBar:SetMinMaxValues(0, 0)
		control.list.scrollBar:SetValue(0)
		control.list.scrollFrame:SetVerticalScroll(0)
	end
end

local function ToggleDropdown(control)
	if openDropdown == control then
		HideOpenDropdown()
		return
	end

	HideOpenDropdown()
	control.list:SetFrameLevel(control:GetFrameLevel() + 50)
	UpdateListLayout(control)
	control.list:Show()

	local hasFontOptions = false
	local fontSize = PP:ScaleFont(control.layout.fontSize)
	for index, option in ipairs(control.options) do
		if option.font then
			hasFontOptions = true
			local rowText = control.list.buttons[index].text
			rowText:SetText("")
			rowText:SetFont("Fonts\\ARIALN.TTF", fontSize, "")
			rowText:SetText(option.text or "")
		end
	end

	if hasFontOptions then
		C_Timer.After(0, function()
			if not control.list:IsShown() then
				return
			end

			for index, option in ipairs(control.options) do
				if option.font then
					local rowText = control.list.buttons[index].text
					rowText:SetText("")
					ApplyOptionTextStyle(control, rowText, option, false)
					rowText:SetText(option.text or "")
				end
			end
		end)
	end

	control:SetArrowColor({ 0.96, 0.66, 0.31, 1 })
	openDropdown = control
end

function Dropdown:Create(parent, labelText)
	local control = CreateFrame("Frame", nil, parent)

	control.layout = {
		parent = parent,
		width = 220,
		fieldHeight = 24,
		labelHeight = 16,
		labelSpacing = 4,
		borderThickness = 1,
		fontSize = 12,
		textInset = 10,
		arrowInset = 12,
		arrowWidth = 10,
		arrowHeight = 8,
		arrowStrokeThickness = 2,
		selectionRightInset = 30,
		listRowHeight = 24,
		listRowSpacing = 2,
		listPadding = 4,
		maxVisibleRows = 10,
		scrollBarWidth = 8,
		scrollBarSpacing = 4,
		scrollTrackWidth = 2,
		scrollThumbWidth = 6,
		scrollThumbMinHeight = 16,
		point = nil,
		relativeTo = parent,
		relativePoint = nil,
		offsetX = 0,
		offsetY = 0,
	}

	control.options = {}
	control.value = nil
	control.placeholder = "Select..."
	control.labelVisible = true

	control.label = control:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	control.label:SetTextColor(0.85, 0.85, 0.88, 1)
	control.label:SetJustifyH("LEFT")
	control.label:SetText(labelText or "Dropdown")

	control.field = CreateFrame("Button", nil, control, "BackdropTemplate")
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

	control.selectionTexture = control.field:CreateTexture(nil, "ARTWORK", nil, -1)
	control.selectionTexture:SetAllPoints(control.field)
	control.selectionTexture:SetAlpha(0.4)
	control.selectionTexture:Hide()

	control.selectionText = control.field:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	control.selectionText:SetJustifyH("LEFT")
	control.selectionText:SetWordWrap(false)
	control.selectionText:SetMaxLines(1)
	control.selectionText:SetText(control.placeholder)

	control.arrow = CreateFrame("Frame", nil, control.field)
	control.arrow.leftStroke = control.arrow:CreateTexture(nil, "OVERLAY")
	control.arrow.rightStroke = control.arrow:CreateTexture(nil, "OVERLAY")

	control.field.hoverTexture = control.field:CreateTexture(nil, "ARTWORK")
	control.field.hoverTexture:SetColorTexture(1, 1, 1, 0.03)
	control.field.hoverTexture:SetAllPoints(control.field)
	control.field.hoverTexture:Hide()

	control.list = CreateFrame("Frame", nil, control, "BackdropTemplate")
	control.list:SetFrameStrata("DIALOG")
	control.list:SetFrameLevel(control:GetFrameLevel() + 50)
	control.list:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8x8",
	})
	control.list:SetBackdropColor(0.04, 0.05, 0.07, 1)
	control.list:Hide()
	control.list.buttons = {}
	control.list.scrollRange = 0

	control.list.scrollFrame = CreateFrame("ScrollFrame", nil, control.list)
	control.list.scrollFrame:SetFrameLevel(control.list:GetFrameLevel() + 1)
	control.list.scrollFrame:EnableMouseWheel(true)
	control.list.scrollFrame:SetScript("OnMouseWheel", function(_, delta)
		ScrollList(control, delta)
	end)

	control.list.scrollChild = CreateFrame("Frame", nil, control.list.scrollFrame)
	control.list.scrollChild:SetPoint("TOPLEFT", control.list.scrollFrame, "TOPLEFT", 0, 0)
	control.list.scrollFrame:SetScrollChild(control.list.scrollChild)

	control.list.scrollBar = CreateFrame("Slider", nil, control.list)
	control.list.scrollBar:EnableMouse(false)
	control.list.scrollBar:SetOrientation("VERTICAL")
	control.list.scrollBar:SetFrameLevel(control.list:GetFrameLevel() + 2)
	control.list.scrollBar:SetScript("OnValueChanged", function(_, value)
		control.list.scrollFrame:SetVerticalScroll(value)
	end)

	control.list.scrollBar.track = control.list.scrollBar:CreateTexture(nil, "ARTWORK")
	control.list.scrollBar.track:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.list.scrollBar.track:SetPoint("TOP", control.list.scrollBar, "TOP", 0, 0)
	control.list.scrollBar.track:SetPoint("BOTTOM", control.list.scrollBar, "BOTTOM", 0, 0)

	control.list.scrollBar.thumb = control.list.scrollBar:CreateTexture(nil, "OVERLAY")
	control.list.scrollBar.thumb:SetColorTexture(0.55, 0.57, 0.61, 1)
	control.list.scrollBar:SetThumbTexture(control.list.scrollBar.thumb)

	control.list.scrollHitArea = CreateFrame("Button", nil, control.list)
	control.list.scrollHitArea:SetFrameLevel(control.list.scrollBar:GetFrameLevel() + 1)
	control.list.scrollHitArea:EnableMouse(true)
	control.list.scrollHitArea:EnableMouseWheel(true)
	control.list.scrollHitArea:SetScript("OnMouseWheel", function(_, delta)
		ScrollList(control, delta)
	end)
	control.list.scrollHitArea:SetScript("OnMouseDown", function(_, button)
		if button == "LeftButton" then
			StartScrollBarDrag(control)
		end
	end)
	control.list.scrollHitArea:SetScript("OnMouseUp", function(_, button)
		if button == "LeftButton" then
			StopScrollBarDrag(control)
		end
	end)
	control.list.scrollHitArea:Hide()

	control.list:SetScript("OnHide", function()
		StopScrollBarDrag(control)
	end)

	control.list.topBorder = control.list:CreateTexture(nil, "OVERLAY")
	control.list.topBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.list.topBorder:SetPoint("TOPLEFT", control.list, "TOPLEFT", 0, 0)
	control.list.topBorder:SetPoint("TOPRIGHT", control.list, "TOPRIGHT", 0, 0)

	control.list.bottomBorder = control.list:CreateTexture(nil, "OVERLAY")
	control.list.bottomBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.list.bottomBorder:SetPoint("BOTTOMLEFT", control.list, "BOTTOMLEFT", 0, 0)
	control.list.bottomBorder:SetPoint("BOTTOMRIGHT", control.list, "BOTTOMRIGHT", 0, 0)

	control.list.leftBorder = control.list:CreateTexture(nil, "OVERLAY")
	control.list.leftBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.list.leftBorder:SetPoint("TOPLEFT", control.list, "TOPLEFT", 0, 0)
	control.list.leftBorder:SetPoint("BOTTOMLEFT", control.list, "BOTTOMLEFT", 0, 0)

	control.list.rightBorder = control.list:CreateTexture(nil, "OVERLAY")
	control.list.rightBorder:SetColorTexture(0.15, 0.17, 0.20, 1)
	control.list.rightBorder:SetPoint("TOPRIGHT", control.list, "TOPRIGHT", 0, 0)
	control.list.rightBorder:SetPoint("BOTTOMRIGHT", control.list, "BOTTOMRIGHT", 0, 0)

	function control:SetArrowColor(color)
		SetArrowColor(self, color)
	end

	function control:SetOptions(options)
		self.options = options or {}
		UpdateSelectionText(self)
		UpdateListLayout(self)
	end

	function control:SetValue(value)
		self.value = value
		UpdateSelectionText(self)
	end

	function control:GetValue()
		return self.value
	end

	function control:SetPlaceholder(text)
		self.placeholder = text or ""
		UpdateSelectionText(self)
	end

	function control:SetLabel(text)
		self.label:SetText(text or "")
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

	function control:SetLayoutPoint(point, relativeTo, relativePoint, offsetX, offsetY)
		self.layout.point = point
		self.layout.relativeTo = relativeTo or self.layout.parent
		self.layout.relativePoint = relativePoint or point
		self.layout.offsetX = offsetX or 0
		self.layout.offsetY = offsetY or 0
		self:UpdateLayout()
	end

	function control:SetOnValueChanged(callback)
		self.onValueChanged = callback
	end

	function control:UpdateLayout()
		local labelHeight = PP:ToUIScaled(self.layout.labelHeight)
		local labelSpacing = PP:ToUIScaled(self.layout.labelSpacing)
		local fieldHeight = PP:ToUIScaled(self.layout.fieldHeight)
		local borderThickness = PP:ToUIScaled(self.layout.borderThickness)
		local textInset = PP:ToUIScaled(self.layout.textInset)
		local selectionRightInset = PP:ToUIScaled(self.layout.selectionRightInset)
		local arrowWidth = self.layout.arrowWidth
		local arrowHeight = self.layout.arrowHeight
		local arrowStrokeThickness = self.layout.arrowStrokeThickness
		local arrowSideInset = math.max(1, arrowStrokeThickness / 2)
		local usableArrowWidth = math.max(2, arrowWidth - (arrowSideInset * 2))
		local usableArrowHeight = math.max(2, arrowHeight - 2)
		local arrowHalfRun = usableArrowWidth / 2
		local arrowStrokeLength = math.sqrt((arrowHalfRun * arrowHalfRun) + (usableArrowHeight * usableArrowHeight))
		local arrowStrokeCenterOffsetX = usableArrowWidth / 4
		local arrowStrokeRotation = math.atan2(usableArrowHeight, arrowHalfRun)

		self:SetWidth(PP:ToUIScaled(self.layout.width))
		self.label:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(self.layout.fontSize), "")
		UpdateSelectionText(self)

		self.label:ClearAllPoints()
		self.field:ClearAllPoints()

		if self.labelVisible then
			self:SetHeight(labelHeight + labelSpacing + fieldHeight)
			self.label:Show()
			self.label:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			self.label:SetHeight(labelHeight)
			self.field:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -(labelHeight + labelSpacing))
			self.field:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -(labelHeight + labelSpacing))
		else
			self:SetHeight(fieldHeight)
			self.label:Hide()
			self.field:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
			self.field:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		end

		self.field:SetHeight(fieldHeight)
		self.field.topBorder:SetHeight(borderThickness)
		self.field.bottomBorder:SetHeight(borderThickness)
		self.field.leftBorder:SetWidth(borderThickness)
		self.field.rightBorder:SetWidth(borderThickness)

		self.selectionText:ClearAllPoints()
		self.selectionText:SetPoint("LEFT", self.field, "LEFT", textInset, 0)
		self.selectionText:SetPoint("RIGHT", self.field, "RIGHT", -selectionRightInset, 0)

		self.arrow:SetSize(PP:ToUIScaled(arrowWidth), PP:ToUIScaled(arrowHeight))
		self.arrow:ClearAllPoints()
		self.arrow:SetPoint(
			"CENTER",
			self.field,
			"RIGHT",
			PP:ToUIScaled(-(self.layout.arrowInset + (arrowWidth / 2))),
			0
		)

		self.arrow.leftStroke:ClearAllPoints()
		self.arrow.leftStroke:SetPoint("CENTER", self.arrow, "CENTER", PP:ToUIScaled(-arrowStrokeCenterOffsetX), 0)
		self.arrow.leftStroke:SetSize(PP:ToUIScaled(arrowStrokeLength), PP:ToUIScaled(arrowStrokeThickness))
		self.arrow.leftStroke:SetRotation(-arrowStrokeRotation)

		self.arrow.rightStroke:ClearAllPoints()
		self.arrow.rightStroke:SetPoint("CENTER", self.arrow, "CENTER", PP:ToUIScaled(arrowStrokeCenterOffsetX), 0)
		self.arrow.rightStroke:SetSize(PP:ToUIScaled(arrowStrokeLength), PP:ToUIScaled(arrowStrokeThickness))
		self.arrow.rightStroke:SetRotation(arrowStrokeRotation)

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

		if openDropdown == self then
			UpdateListLayout(self)
		end
	end

	control:SetArrowColor(defaultArrowColor)

	control.field:SetScript("OnEnter", function(self)
		self.hoverTexture:Show()
		control:SetArrowColor({ 0.96, 0.66, 0.31, 1 })
	end)

	control.field:SetScript("OnLeave", function(self)
		self.hoverTexture:Hide()
		if openDropdown ~= control then
			control:SetArrowColor(defaultArrowColor)
		end
	end)

	control.field:SetScript("OnClick", function()
		ToggleDropdown(control)
	end)

	control:SetScript("OnHide", function(self)
		if openDropdown == self then
			HideOpenDropdown()
		end
	end)

	PP:RegisterForUpdate(function()
		control:UpdateLayout()
	end)

	return control
end

function Dropdown:CloseOpenDropdown()
	HideOpenDropdown()
end
