local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 插件集列表按钮：鼠标滑入
local function onAddonSetListButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_list"], 1, 1, 1)
    GameTooltip:Show()
end

-- 插件集列表按钮：鼠标移出
local function onAddonSetListButtonLeave(self)
    GameTooltip:Hide()
end

-- 插件集列表按钮：鼠标点击
local function onAddonSetListButtonClick(self)
    Addon:ShowAddonSetDialog()
end

function Addon:OnAddonSetContainerLoad()
    local AddonSetContainer = self:GetAddonSetContainer()

    -- 插件集列表
    local AddonSetListButton = CreateFrame("Button", nil, AddonSetContainer)
    AddonSetContainer.AddonSetListButton = AddonSetListButton
    AddonSetListButton:SetPoint("RIGHT", 0, -1)
    AddonSetListButton:SetSize(16, 16)
    AddonSetListButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\addon_sets.png")
    AddonSetListButton:SetHighlightTexture("Interface\\Addons\\ImprovedAddonList\\Media\\addon_sets_highlight.png")
    AddonSetListButton:SetScript("OnEnter", onAddonSetListButtonEnter)
    AddonSetListButton:SetScript("OnLeave", onAddonSetListButtonLeave)
    AddonSetListButton:SetScript("OnClick", onAddonSetListButtonClick)

    -- 提示按钮
    local AddonSetTipButton = CreateFrame("Button", nil, AddonSetContainer)
    AddonSetContainer.AddonSetTipButton = AddonSetTipButton
    AddonSetTipButton:SetSize(16, 16)
    AddonSetTipButton:SetPoint("LEFT", AddonSetListButton, "RIGHT", 4, 0)
    AddonSetTipButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\tip.png")
    AddonSetTipButton:Hide()

    local ActiveAddonSetContainer = CreateFrame("Frame", nil, AddonSetContainer, "InsetFrameTemplate3")
    ActiveAddonSetContainer:SetPoint("LEFT")
    ActiveAddonSetContainer:SetPoint("RIGHT", AddonSetListButton, "LEFT", -5, 0)
    ActiveAddonSetContainer:SetHeight(20)

    local ActiveAddonSetPrefix = ActiveAddonSetContainer:CreateFontString(nil, nil, "GameFontNormalSmall2")
    ActiveAddonSetPrefix:SetPoint("LEFT", 5, 0)
    ActiveAddonSetPrefix:SetText(L["addon_set_active_label"])

    -- 当前加载方案
    local ActiveAddonSetLabel = ActiveAddonSetContainer:CreateFontString(nil, nil, "GameFontWhite")
    AddonSetContainer.ActiveAddonSetLabel = ActiveAddonSetLabel
    ActiveAddonSetLabel:SetJustifyH("RIGHT")
    ActiveAddonSetLabel:SetPoint("LEFT", ActiveAddonSetPrefix, "RIGHT", 8, 0)
    ActiveAddonSetLabel:SetPoint("RIGHT", -5, 0)
    ActiveAddonSetLabel:SetMaxLines(1)

    self:RefreshAddonSetContainer()
end

-- 刷新插件集
function Addon:RefreshAddonSetContainer()
    local activeAddonSetLable = self:GetAddonSetContainer().ActiveAddonSetLabel
    local activeAddonSet = self:GetActiveAddonSet()

    if activeAddonSet then
        activeAddonSetLable:SetText(activeAddonSet.Name)
        activeAddonSetLable:SetTextColor(WHITE_FONT_COLOR:GetRGB())
    else
        activeAddonSetLable:SetText(L["addon_set_inactive_tip"])
        activeAddonSetLable:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
    end
end

-- 添加插件集：鼠标划入
local function onAddAddonSetButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_add_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 添加插件集：鼠标移出
local function onAddAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 添加插件集：点击
local function onAddAddonSetButtonClick(self)

end

-- 删除插件集：鼠标划入
local function onDeleteAddonSetButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["addon_set_remove_tips"], 1, 1, 1)
    GameTooltip:Show()
end

-- 删除插件集：鼠标移出
local function onDeleteAddonSetButtonLeave(self)
    GameTooltip:Hide()
end

-- 删除插件集：点击
local function onDeleteAddonSetButtonClick(self)
    
end

-- 显示插件集弹窗
function Addon:ShowAddonSetDialog()
    local UI = self:GetOrCreateUI()

    if UI.AddonSetDialog then
        UI.AddonSetDialog:Show()
        return
    end

    local AddonSetDialog = self:CreateDialog(nil, UI)
    UI.AddonSetDialog = AddonSetDialog
    AddonSetDialog:SetSize(700, 650)
    AddonSetDialog:SetPoint("CENTER")
    AddonSetDialog:SetFrameStrata("DIALOG")
    AddonSetDialog:SetTitle(L["addon_set_list"])

    -- 插件集列表
    local AddonSetListContainer = self:CreateContainer(AddonSetDialog)
    AddonSetDialog.AddonSetListContainer = AddonSetListContainer
    AddonSetListContainer:SetWidth(210)
    AddonSetListContainer:SetPoint("TOPLEFT", 10, -30)
    AddonSetListContainer:SetPoint("BOTTOMLEFT", 10, 10)

    local AddAddonSetButton = CreateFrame("Button", nil, AddonSetListContainer)
    AddonSetListContainer.AddAddonSetButton = AddAddonSetButton
    local addAddonSetButtonTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\add.png"
    AddAddonSetButton:SetSize(16, 16)
    AddAddonSetButton:SetNormalTexture(addAddonSetButtonTexure)
    AddAddonSetButton:SetHighlightTexture(addAddonSetButtonTexure)
    AddAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    AddAddonSetButton:SetPoint("TOPRIGHT", -8, -8)
    AddAddonSetButton:SetScript("OnEnter", onAddAddonSetButtonEnter)
    AddAddonSetButton:SetScript("OnLeave", onAddAddonSetButtonLeave)
    AddAddonSetButton:SetScript("OnClick", onAddAddonSetButtonClick)

    local DeleteAddonSetButton = CreateFrame("Button", nil, AddonSetListContainer)
    AddonSetListContainer.DeleteAddonSetButton = DeleteAddonSetButton
    local deleteAddonSetButtonTexure = "Interface\\AddOns\\ImprovedAddonList\\Media\\delete.png"
    DeleteAddonSetButton:SetSize(16, 16)
    DeleteAddonSetButton:SetNormalTexture(deleteAddonSetButtonTexure)
    DeleteAddonSetButton:SetHighlightTexture(deleteAddonSetButtonTexure)
    DeleteAddonSetButton:GetHighlightTexture():SetAlpha(0.2)
    DeleteAddonSetButton:SetPoint("RIGHT", AddAddonSetButton, "LEFT", -4, 0)
    DeleteAddonSetButton:SetScript("OnEnter", onDeleteAddonSetButtonEnter)
    DeleteAddonSetButton:SetScript("OnLeave", onDeleteAddonSetButtonLeave)
    DeleteAddonSetButton:SetScript("OnClick", onDeleteAddonSetButtonClick)

    -- 插件集列表搜索框
    local AddonSetSearchBox = CreateFrame("EditBox", nil, AddonSetListContainer, "SearchBoxTemplate")
    AddonSetListContainer.SearchBox = AddonSetSearchBox
    AddonSetSearchBox:SetPoint("LEFT", 14, 0)
    AddonSetSearchBox:SetPoint("TOPRIGHT", DeleteAddonSetButton, "TOPLEFT", -5, 0)
    AddonSetSearchBox:SetPoint("BOTTOMRIGHT", DeleteAddonSetButton, "BOTTOMLEFT", -5, 0)
    -- AddonSetSearchBox:HookScript("OnTextChanged", onAddonListSearchBoxTextChanged)
end

-- 隐藏插件集弹窗
function Addon:HideAddonSetDialog()
    local UI = self:GetOrCreateUI()

    if UI.AddonSetDialog then
        UI.AddonSetDialog:Hide()
    end
end