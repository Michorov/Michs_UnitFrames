local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.Content = addon.Options.Sections.Content or {}

local Content = addon.Options.Sections.Content
local PP = addon.PixelPerfect
local content
local pages
local activePage = "general"
local selectedUnit = "player"

local unitOptions = {
	{ value = "player", text = "Player" },
	{ value = "target", text = "Target" },
	{ value = "targettarget", text = "Target of Target" },
	{ value = "pet", text = "Pet" },
	{ value = "focus", text = "Focus" },
	{ value = "focustarget", text = "Focus Target" },
	{ value = "boss", text = "Boss" },
}

function Content:Ensure(parent)
	if content then
		return content
	end

	content = CreateFrame("Frame", nil, parent)
	pages = {
		general = addon.Options.Pages.General:Ensure(content),
		layout = addon.Options.Pages.Layout:Ensure(content),
		bars = addon.Options.Pages.Bars:Ensure(content),
		texts = addon.Options.Pages.Texts:Ensure(content),
		auras = addon.Options.Pages.Auras:Ensure(content),
		indicators = addon.Options.Pages.Indicators:Ensure(content),
		profiles = addon.Options.Pages.Profiles:Ensure(content),
	}

	content.unitDropdown = addon.Options.Controls.Dropdown:Create(content, "")
	content.unitDropdown:SetLayoutWidth(140)
	content.unitDropdown:SetLabelVisible(false)
	content.unitDropdown:SetOptions(unitOptions)
	content.unitDropdown:SetValue(selectedUnit)
	content.unitDropdown:SetLayoutPoint("RIGHT", pages[activePage].header, "RIGHT", 0, 0)
	content.unitDropdown:SetShown(activePage ~= "general" and activePage ~= "profiles")
	content.unitDropdown:SetOnValueChanged(function(_, value)
		Content:SetSelectedUnit(value)
	end)

	for pageKey, page in pairs(pages) do
		page:SetShown(pageKey == activePage)
	end

	local page = pages[activePage]
	if page.UpdateState then
		page:UpdateState(addon.Database:GetProfile(), selectedUnit)
	end

	return content
end

function Content:UpdateLayout()
	local inset = PP:ToUIScaled(32)

	for _, page in pairs(pages) do
		page:ClearAllPoints()
		page:SetPoint("TOPLEFT", content, "TOPLEFT", inset, -inset)
		page:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -inset, inset)
		page:UpdateLayout()
	end
end

function Content:SetActivePage(pageKey)
	if not pages[pageKey] then
		return
	end

	activePage = pageKey
	addon.Options.Controls.Dropdown:CloseOpenDropdown()

	for key, page in pairs(pages) do
		page:SetShown(key == activePage)
	end

	local pageHeader = pages[activePage].header
	if pageHeader then
		content.unitDropdown:SetLayoutPoint("RIGHT", pageHeader, "RIGHT", 0, 0)
	end
	content.unitDropdown:SetShown(activePage ~= "general" and activePage ~= "profiles")

	local page = pages[activePage]
	if page.UpdateState then
		page:UpdateState(addon.Database:GetProfile(), selectedUnit)
	end
end

function Content:RefreshProfile()
	if not content or not pages then
		return
	end

	local page = pages[activePage]
	if page.UpdateState then
		page:UpdateState(addon.Database:GetProfile(), selectedUnit)
	end
end

function Content:GetSelectedUnit()
	return selectedUnit
end

function Content:SetSelectedUnit(unit)
	for _, option in ipairs(unitOptions) do
		if option.value == unit then
			selectedUnit = unit

			if content then
				content.unitDropdown:SetValue(unit)

				local page = pages[activePage]
				if page.UpdateState then
					page:UpdateState(addon.Database:GetProfile(), selectedUnit)
				end
			end

			return selectedUnit
		end
	end

	return selectedUnit
end
