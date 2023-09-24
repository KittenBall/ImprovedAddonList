local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 插件方案列表按钮：鼠标滑入
local function onAddonSchemeListButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_scheme_list_button_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 插件方案列表按钮：鼠标移出
local function onAddonSchemeListButtonLeave(self)
    GameTooltip:Hide()
end

function Addon:OnAddonSchemeContainerLoad()
    local AddonSchemeContainer = self:GetAddonSchemeContainer()

    -- 插件方案列表
    local AddonSchemeListButton = CreateFrame("Button", nil, AddonSchemeContainer)
    AddonSchemeContainer.AddonSchemeListButton = AddonSchemeListButton
    AddonSchemeListButton:SetPoint("RIGHT", 0, -1)
    AddonSchemeListButton:SetSize(16, 16)
    AddonSchemeListButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\addon_schemes.png")
    AddonSchemeListButton:SetHighlightTexture("Interface\\Addons\\ImprovedAddonList\\Media\\addon_schemes_highlight.png")
    AddonSchemeListButton:SetScript("OnEnter", onAddonSchemeListButtonEnter)
    AddonSchemeListButton:SetScript("OnLeave", onAddonSchemeListButtonLeave)

    -- 提示按钮
    local AddonSchemeTipButton = CreateFrame("Button", nil, AddonSchemeContainer)
    AddonSchemeContainer.AddonSchemeTipButton = AddonSchemeTipButton
    AddonSchemeTipButton:SetSize(16, 16)
    AddonSchemeTipButton:SetPoint("LEFT", AddonSchemeListButton, "RIGHT", 4, 0)
    AddonSchemeTipButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\tip.png")
    AddonSchemeTipButton:Hide()

    local ActiveAddonSchemeContainer = CreateFrame("Frame", nil, AddonSchemeContainer, "InsetFrameTemplate3")
    ActiveAddonSchemeContainer:SetPoint("LEFT")
    ActiveAddonSchemeContainer:SetPoint("RIGHT", AddonSchemeListButton, "LEFT", -5, 0)
    ActiveAddonSchemeContainer:SetHeight(20)

    local ActiveAddonSchemeLabel = ActiveAddonSchemeContainer:CreateFontString(nil, nil, "GameFontNormalSmall2")
    ActiveAddonSchemeLabel:SetPoint("LEFT", 5, 0)
    ActiveAddonSchemeLabel:SetText(L["addon_scheme_active_label"])

    -- 当前加载方案
    local ActiveAddonScheme = ActiveAddonSchemeContainer:CreateFontString(nil, nil, "GameFontWhite")
    AddonSchemeContainer.ActiveAddonScheme = ActiveAddonScheme
    ActiveAddonScheme:SetJustifyH("RIGHT")
    ActiveAddonScheme:SetPoint("LEFT", ActiveAddonSchemeLabel, "RIGHT", 8, 0)
    ActiveAddonScheme:SetPoint("RIGHT", -5, 0)
    ActiveAddonScheme:SetMaxLines(1)

    self:RefreshAddonSchemeContainer()
end

-- 刷新插件方案
function Addon:RefreshAddonSchemeContainer()
    local activeAddonScheme = self:GetAddonSchemeContainer().ActiveAddonScheme
    local activeScheme = self:GetActiveAddonScheme()

    if activeScheme then
        activeAddonScheme:SetText(activeScheme.Name)
        activeAddonScheme:SetTextColor(WHITE_FONT_COLOR:GetRGB())
    else
        activeAddonScheme:SetText(L["addon_scheme_inactive_tip"])
        activeAddonScheme:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    end
end