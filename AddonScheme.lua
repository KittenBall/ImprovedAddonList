local addonName, Addon = ...

function Addon:OnAddonSchemeLoad()
    local a = CreateFrame("Frame", nil, self.UI, "InsetFrameTemplate3")
    a:SetSize(180, 24)
    a:SetPoint("TOPLEFT", 10, -32)
end