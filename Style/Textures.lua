local _, addon = ...

addon.Style = addon.Style or {}
addon.Style.Textures = addon.Style.Textures or {}

local Textures = addon.Style.Textures
local LSM = LibStub("LibSharedMedia-3.0")

local excludedTextureNames = {
	play_icon = true,
	stop_icon = true,
	user_icon = true,
	users_icon = true,
}

function Textures:GetOptions(selectedTextureName, includeGlobal)
	local options = {}
	local selectedTextureListed = false

	if includeGlobal then
		options[#options + 1] = {
			value = -1,
			text = "Use Global Texture",
			textColor = { 0.50, 0.52, 0.56, 1 },
		}
	end

	for _, textureName in ipairs(LSM:List("statusbar")) do
		if not excludedTextureNames[textureName] and LSM:IsValid("statusbar", textureName) then
			options[#options + 1] = {
				value = textureName,
				text = textureName,
				texture = LSM:Fetch("statusbar", textureName),
			}

			if textureName == selectedTextureName then
				selectedTextureListed = true
			end
		end
	end

	if selectedTextureName and selectedTextureName ~= -1 and not selectedTextureListed then
		options[#options + 1] = {
			value = selectedTextureName,
			text = selectedTextureName .. " (Unavailable)",
		}
	end

	return options
end
