local _, addon = ...

addon.Options = addon.Options or {}
addon.Options.Sections = addon.Options.Sections or {}
addon.Options.Sections.Content = addon.Options.Sections.Content or {}

local Content = addon.Options.Sections.Content
local content

function Content:Ensure(parent)
	if not content then
		content = CreateFrame("Frame", nil, parent)
	end

	return content
end
