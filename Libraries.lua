local _, addon = ...

addon.PixelPerfect = LibStub("MichsPixelPerfectLib-2.0"):CreateScaler()

addon.OptionsUI = LibStub("MichsOptionsUILib-1.0"):CreateInstance({
	addonName = "Michs_UnitFrames",
	title = "Mich's UnitFrames",
})
