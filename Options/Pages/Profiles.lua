local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Pages = addon.Options.Pages or {}
addon.Options.Pages.Profiles = addon.Options.Pages.Profiles or {}

local Profiles = addon.Options.Pages.Profiles
local PP = addon.PixelPerfect
local page

local function PrintProfileMessage(message)
	print("|cffff9900Mich's UnitFrames:|r " .. message)
end

local function Trim(text)
	return (text or ""):match("^%s*(.-)%s*$")
end

local function BuildProfileOptions(includeDefault)
	local options = {}

	for _, name in ipairs(addon.Database:GetProfileNames()) do
		if includeDefault or name ~= "Default" then
			table.insert(options, { value = name, text = name })
		end
	end

	table.sort(options, function(a, b)
		return string.lower(a.text) < string.lower(b.text)
	end)

	return options
end

local function CreateProfile()
	local name = Trim(page.newProfileInput:GetText())
	if name == "" then
		PrintProfileMessage("Enter a profile name first.")
		return
	end

	if addon.Database:HasProfile(name) then
		PrintProfileMessage(("Profile '%s' already exists."):format(name))
		return
	end

	addon.Database:SetProfile(name)
	page.newProfileInput:SetText("")
	PrintProfileMessage(("Created '%s' and set it as the active profile."):format(name))
end

local function ResetProfile()
	local name = addon.Database:GetCurrentProfileName()
	addon.Database:ResetProfile()
	PrintProfileMessage(("Reset '%s' to its default settings."):format(name))
end

local function CopyProfile()
	local source = page.copyFromDropdown:GetValue()
	local name = Trim(page.copyProfileInput:GetText())

	if not source then
		PrintProfileMessage("Select a source profile.")
		return
	end

	if name == "" then
		PrintProfileMessage("Enter a new profile name.")
		return
	end

	if addon.Database:HasProfile(name) then
		PrintProfileMessage(("Profile '%s' already exists."):format(name))
		return
	end

	addon.Database:SetProfile(name)
	addon.Database:CopyProfile(source)
	page.copyFromDropdown:SetValue(nil)
	page.copyProfileInput:SetText("")
	PrintProfileMessage(
		("Created '%s' by copying '%s' and set it as the active profile."):format(
			name,
			source
		)
	)
end

local function DeleteProfile()
	local target = page.deleteProfileDropdown:GetValue()
	if not target then
		PrintProfileMessage("Select a profile to delete.")
		return
	end

	if target == "Default" then
		PrintProfileMessage("Default profile cannot be deleted.")
		return
	end

	if not addon.Database:HasProfile(target) then
		PrintProfileMessage(("Profile '%s' does not exist."):format(target))
		return
	end

	if addon.Database:GetCurrentProfileName() == target then
		addon.Database:SetProfile("Default")
	end

	addon.Database:DeleteProfile(target)
	page.deleteProfileDropdown:SetValue(nil)
	PrintProfileMessage(("Deleted profile '%s'."):format(target))
end

function Profiles:Ensure(parent)
	if page then
		return page
	end

	page = CreateFrame("Frame", nil, parent)

	page.activeSectionTitle = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.activeSectionTitle:SetJustifyH("LEFT")
	page.activeSectionTitle:SetTextColor(0.96, 0.66, 0.31, 1)
	page.activeSectionTitle:SetText("Active Profile")

	page.createSectionTitle = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.createSectionTitle:SetJustifyH("LEFT")
	page.createSectionTitle:SetTextColor(0.96, 0.66, 0.31, 1)
	page.createSectionTitle:SetText("Create New Profile")

	page.copySectionTitle = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.copySectionTitle:SetJustifyH("LEFT")
	page.copySectionTitle:SetTextColor(0.96, 0.66, 0.31, 1)
	page.copySectionTitle:SetText("Copy Profile")

	page.deleteSectionTitle = page:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	page.deleteSectionTitle:SetJustifyH("LEFT")
	page.deleteSectionTitle:SetTextColor(0.96, 0.66, 0.31, 1)
	page.deleteSectionTitle:SetText("Delete Profile")

	page.activeProfileDropdown = addon.Options.Controls.Dropdown:Create(page, "")
	page.activeProfileDropdown:SetLayoutWidth(200)
	page.activeProfileDropdown:SetLabelVisible(false)
	page.activeProfileDropdown:SetOnValueChanged(function(_, value)
		if value and value ~= addon.Database:GetCurrentProfileName() then
			addon.Database:SetProfile(value)
		end
	end)

	page.resetProfileButton = addon.Options.Controls.Button:Create(page, "Reset")
	page.resetProfileButton:SetLayoutSize(88, 24)
	page.resetProfileButton:SetOnClick(ResetProfile)

	page.newProfileInput = addon.Options.Controls.Input:Create(page, "")
	page.newProfileInput:SetLayoutWidth(200)
	page.newProfileInput:SetLabelVisible(false)
	page.newProfileInput:SetPlaceholder("New Profile Name")
	page.newProfileInput:SetOnEnterPressed(CreateProfile)

	page.createProfileButton = addon.Options.Controls.Button:Create(page, "Create")
	page.createProfileButton:SetLayoutSize(88, 24)
	page.createProfileButton:SetOnClick(CreateProfile)

	page.copyFromDropdown = addon.Options.Controls.Dropdown:Create(page, "")
	page.copyFromDropdown:SetLayoutWidth(200)
	page.copyFromDropdown:SetLabelVisible(false)

	page.copyProfileInput = addon.Options.Controls.Input:Create(page, "")
	page.copyProfileInput:SetLayoutWidth(200)
	page.copyProfileInput:SetLabelVisible(false)
	page.copyProfileInput:SetPlaceholder("New Profile Name")
	page.copyProfileInput:SetOnEnterPressed(CopyProfile)

	page.copyProfileButton = addon.Options.Controls.Button:Create(page, "Copy")
	page.copyProfileButton:SetLayoutSize(88, 24)
	page.copyProfileButton:SetOnClick(CopyProfile)

	page.deleteProfileDropdown = addon.Options.Controls.Dropdown:Create(page, "")
	page.deleteProfileDropdown:SetLayoutWidth(200)
	page.deleteProfileDropdown:SetLabelVisible(false)

	page.deleteProfileButton = addon.Options.Controls.Button:Create(page, "Delete")
	page.deleteProfileButton:SetLayoutSize(88, 24)
	page.deleteProfileButton:SetOnClick(DeleteProfile)

	page.activeProfileDropdown:SetLayoutPoint(
		"TOPLEFT",
		page.activeSectionTitle,
		"BOTTOMLEFT",
		0,
		-10
	)
	page.resetProfileButton:SetLayoutPoint(
		"TOPLEFT",
		page.activeProfileDropdown,
		"TOPRIGHT",
		1,
		0
	)
	page.newProfileInput:SetLayoutPoint(
		"TOPLEFT",
		page.createSectionTitle,
		"BOTTOMLEFT",
		0,
		-10
	)
	page.createProfileButton:SetLayoutPoint(
		"TOPLEFT",
		page.newProfileInput,
		"TOPRIGHT",
		1,
		0
	)
	page.copyFromDropdown:SetLayoutPoint(
		"TOPLEFT",
		page.copySectionTitle,
		"BOTTOMLEFT",
		0,
		-10
	)
	page.copyProfileInput:SetLayoutPoint(
		"TOPLEFT",
		page.copyFromDropdown,
		"TOPRIGHT",
		1,
		0
	)
	page.copyProfileButton:SetLayoutPoint(
		"TOPLEFT",
		page.copyProfileInput,
		"TOPRIGHT",
		1,
		0
	)
	page.deleteProfileDropdown:SetLayoutPoint(
		"TOPLEFT",
		page.deleteSectionTitle,
		"BOTTOMLEFT",
		0,
		-10
	)
	page.deleteProfileButton:SetLayoutPoint(
		"TOPLEFT",
		page.deleteProfileDropdown,
		"TOPRIGHT",
		1,
		0
	)

	function page:UpdateLayout()
		self.activeSectionTitle:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")
		self.createSectionTitle:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")
		self.copySectionTitle:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")
		self.deleteSectionTitle:SetFont("Fonts\\ARIALN.TTF", PP:ScaleFont(14), "")

		self.activeSectionTitle:ClearAllPoints()
		self.activeSectionTitle:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
		self.createSectionTitle:ClearAllPoints()
		self.createSectionTitle:SetPoint(
			"TOPLEFT",
			self.activeProfileDropdown,
			"BOTTOMLEFT",
			0,
			PP:ToUIScaled(-24)
		)
		self.copySectionTitle:ClearAllPoints()
		self.copySectionTitle:SetPoint(
			"TOPLEFT",
			self.newProfileInput,
			"BOTTOMLEFT",
			0,
			PP:ToUIScaled(-24)
		)
		self.deleteSectionTitle:ClearAllPoints()
		self.deleteSectionTitle:SetPoint(
			"TOPLEFT",
			self.copyFromDropdown,
			"BOTTOMLEFT",
			0,
			PP:ToUIScaled(-24)
		)
	end

	function page:UpdateState()
		local profileOptions = BuildProfileOptions(true)
		local currentCopySource = self.copyFromDropdown:GetValue()
		local currentDeleteTarget = self.deleteProfileDropdown:GetValue()

		self.activeProfileDropdown:SetOptions(profileOptions)
		self.activeProfileDropdown:SetValue(addon.Database:GetCurrentProfileName())
		self.copyFromDropdown:SetOptions(profileOptions)
		self.copyFromDropdown:SetValue(
			addon.Database:HasProfile(currentCopySource) and currentCopySource or nil
		)
		self.deleteProfileDropdown:SetOptions(BuildProfileOptions(false))
		self.deleteProfileDropdown:SetValue(
			addon.Database:HasProfile(currentDeleteTarget) and currentDeleteTarget or nil
		)
	end

	page:UpdateLayout()
	page:UpdateState()
	return page
end
