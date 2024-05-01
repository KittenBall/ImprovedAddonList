local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ImprovedAddonListAddonListTooltipsItemMixin = {}

function ImprovedAddonListAddonListTooltipsItemMixin:Update()
    local item = self:GetElementData()
    self.Label:SetText(item.Addon.Title)
end

local AddonListTooltipsMixin = {}

function AddonListTooltipsMixin:Init()
    self:SetWidth(450)
    self:SetFrameStrata("DIALOG")
    self:SetFrameLevel(400)
    self:SetClampedToScreen(true)

    local Label = self:CreateFontString(nil, nil, "GameFontHighlight")
    self.Label = Label
    Label:SetPoint("TOP", 0, -10)
    Label:SetWidth(410)
    Label:SetSpacing(4)

    local ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
    self.ScrollBox = ScrollBox
    ScrollBox:SetHeight(600)
    ScrollBox:SetPoint("TOP", Label, "BOTTOM", 0, -15)
    ScrollBox:SetPoint("LEFT", 15, 0)
    ScrollBox:SetPoint("RIGHT", -20, 0)

    local ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    self.ScrollBar = ScrollBar
    ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT")
    ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT")

    local scrollView = CreateScrollBoxListGridView(2, 0, 0, 0, 0, 5, 5)
    scrollView:SetElementInitializer("ImprovedAddonListAddonListTooltipsItemTemplate", function(button, node)
        button:Update()
    end)
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, scrollView)

    self:SetScript("OnHide", self.ReleaseOwner)
end

function AddonListTooltipsMixin:GetDataProvider()
    self.DataProvider = self.DataProvider or CreateDataProvider()
    return self.DataProvider
end

function AddonListTooltipsMixin:RefreshAddons(addons)
    local dataProvider = self:GetDataProvider()
    dataProvider:Flush()

    if addons then
        for _, addon in ipairs(addons) do
            dataProvider:Insert({ Addon = Addon:GetAddonInfoByName(addon.Name), Prefix = addon.Prefix })
        end
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
end

function AddonListTooltipsMixin:SetupAddons(info)
    self.Label:SetText(info.Label or "")

    local rows = info.Addons and math.floor(#info.Addons/2) or 0
    local scrollBoxHeight = math.min(rows * 20, 600)
    self.ScrollBox:SetHeight(scrollBoxHeight)

    local height = self.Label:GetStringHeight() + scrollBoxHeight + 35
    self:SetHeight(height)
    self:RefreshAddons(info.Addons)

    local owner = info.Owner
    self:SetOwner(owner)

    local scaledHeight = height * self:GetEffectiveScale()
    local scaledWidth = self:GetWidth() * self:GetEffectiveScale()
    local ownerLeft, ownerBottom = owner:GetScaledRect()
    
    local relativePoint
    local verticalPoint
    if ownerBottom < scaledHeight then
        verticalPoint = "BOTTOM"
        relativePoint = "TOP"
    else
        verticalPoint = "TOP"
        relativePoint = "BOTTOM"
    end

    local horizontalPoint
    if ownerLeft < scaledWidth then
        horizontalPoint = "LEF"
    else
        horizontalPoint = "RIGHT"
    end

    local point = verticalPoint .. horizontalPoint
    self:ClearAllPoints()
    self:SetPoint(point, owner, relativePoint)


    self:Show()
end

function AddonListTooltipsMixin:ReleaseOwner()
    if self.Owner then
        self.Owner:SetScript("OnMouseWheel", self.OwnerOriginMouseWheel)
    end
end

function AddonListTooltipsMixin:SetOwner(owner)
    self:ReleaseOwner()
    self.Owner = owner
    self.OwnerOriginMouseWheel = owner:GetScript("OnMouseWheel")
    
    owner:SetScript("OnMouseWheel", function(_, delta)
        self.ScrollBox:OnMouseWheel(delta)
        if self.OwnerOriginMouseWheel then
            self.OwnerOriginMouseWheel(_, delta)
        end
    end)
end

function Addon:ShowAddonListTooltips(info)
    local UI = self:GetOrCreateUI()

    if UI.AddonListTooltips then
        UI.AddonListTooltips:SetupAddons(info)
        return 
    end

    local AddonListTooltips = Mixin(CreateFrame("Frame", nil, UI, "TooltipBackdropTemplate"), AddonListTooltipsMixin)
    UI.AddonListTooltips = AddonListTooltips

    AddonListTooltips:Init()
    AddonListTooltips:SetupAddons(info)
end

function Addon:HideAddonListTooltips()
    local UI = self:GetOrCreateUI()
    
    if UI.AddonListTooltips then
        UI.AddonListTooltips:Hide()
    end
end