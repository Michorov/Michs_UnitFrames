local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Bars = addon.Options.Pages.Bars or {}

local Bars = addon.Options.Pages.Bars
local PP = addon.PixelPerfect
local page
local activeSubpage = "health"

local subpageOptions = {
	{ value = "health", text = "Health" },
	{ value = "background", text = "Background" },
	{ value = "absorbs", text = "Absorbs" },
	{ value = "healAbsorbs", text = "Heal Absorbs" },
}

function Bars:Ensure(parent)
	if page then
		return page
	end

	page = CreateFrame("Frame", nil, parent)
	page.header = CreateFrame("Frame", nil, page)
	page.header:SetPoint("TOPLEFT", page, "TOPLEFT", 0, 0)
	page.header:SetPoint("TOPRIGHT", page, "TOPRIGHT", 0, 0)

	page.body = CreateFrame("Frame", nil, page)
	page.body:SetPoint("BOTTOMLEFT", page, "BOTTOMLEFT", 0, 0)
	page.body:SetPoint("BOTTOMRIGHT", page, "BOTTOMRIGHT", 0, 0)

	page.header.title = page.header:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.header.title:SetPoint("LEFT", page.header, "LEFT", 0, 0)
	page.header.title:SetJustifyH("LEFT")
	page.header.title:SetTextColor(0.88, 0.89, 0.92, 1)
	page.header.title:SetText("Bars")

	page.subpageDropdown = addon.Options.Controls.Dropdown:Create(page.header, "")
	page.subpageDropdown:SetLayoutWidth(140)
	page.subpageDropdown:SetLabelVisible(false)
	page.subpageDropdown:SetOptions(subpageOptions)
	page.subpageDropdown:SetValue(activeSubpage)
	page.subpageDropdown:SetLayoutPoint("RIGHT", page.header, "RIGHT", -148, 0)
	page.subpageDropdown:SetOnValueChanged(function(_, value)
		page:SetActiveSubpage(value)
	end)

	page.subpages = {
		health = addon.Options.Pages.Bars.Health:Ensure(page.body),
		background = addon.Options.Pages.Bars.Background:Ensure(page.body),
		absorbs = addon.Options.Pages.Bars.Absorbs:Ensure(page.body),
		healAbsorbs = addon.Options.Pages.Bars.HealAbsorbs:Ensure(page.body),
	}

	for subpageKey, subpage in pairs(page.subpages) do
		subpage:SetAllPoints(page.body)
		subpage:SetShown(subpageKey == activeSubpage)
	end

	function page:SetActiveSubpage(subpageKey)
		if not self.subpages[subpageKey] then
			return
		end

		activeSubpage = subpageKey
		self.subpageDropdown:SetValue(activeSubpage)

		for key, subpage in pairs(self.subpages) do
			subpage:SetShown(key == activeSubpage)
		end

		self.subpages[activeSubpage]:UpdateState(
			addon.Database:GetProfile(),
			addon.Options.Sections.Content:GetSelectedUnit()
		)
	end

	function page:UpdateLayout()
		self.header:SetHeight(PP:ToUIScaled(32))
		self.header.title:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(20), "")
		self.body:SetPoint("TOPLEFT", self.header, "BOTTOMLEFT", 0, PP:ToUIScaled(-16))
		self.body:SetPoint("TOPRIGHT", self.header, "BOTTOMRIGHT", 0, PP:ToUIScaled(-16))
	end

	function page:UpdateState(profile, unit)
		self.subpageDropdown:SetValue(activeSubpage)
		self.subpages[activeSubpage]:UpdateState(profile, unit)
	end

	page:UpdateState(addon.Database:GetProfile(), addon.Options.Sections.Content:GetSelectedUnit())

	return page
end
