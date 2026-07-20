local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.Content = addon.Options.Sections.Content or {}

local Content = addon.Options.Sections.Content
local PP = addon.PixelPerfect
local content
local activePage = "general"

function Content:Ensure(parent)
	if content then
		return content
	end

	content = CreateFrame("Frame", nil, parent)
	content.pages = {
		general = addon.Options.Pages.General:Ensure(content),
		layout = addon.Options.Pages.Layout:Ensure(content),
		bars = addon.Options.Pages.Bars:Ensure(content),
		texts = addon.Options.Pages.Texts:Ensure(content),
		auras = addon.Options.Pages.Auras:Ensure(content),
		indicators = addon.Options.Pages.Indicators:Ensure(content),
		options = addon.Options.Pages.Options:Ensure(content),
	}

	for pageKey, page in pairs(content.pages) do
		page:SetShown(pageKey == activePage)
	end

	return content
end

function Content:UpdateLayout()
	local inset = PP:ToUIScaled(32)

	for _, page in pairs(content.pages) do
		page:ClearAllPoints()
		page:SetPoint("TOPLEFT", content, "TOPLEFT", inset, -inset)
		page:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -inset, inset)
		page:UpdateLayout()
	end
end

function Content:SetActivePage(pageKey)
	if not content.pages[pageKey] then
		return
	end

	activePage = pageKey

	for key, page in pairs(content.pages) do
		page:SetShown(key == activePage)
	end
end
