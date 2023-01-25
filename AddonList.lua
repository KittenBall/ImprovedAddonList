local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 插件列表项函数集
ImprovedAddonListAddonItemMixin = {}

function ImprovedAddonListAddonItemMixin:Init()
    self:Update()
end

function ImprovedAddonListAddonItemMixin:Update()
    local addonInfo = self:GetAddonInfo()

    self.Label:SetText(addonInfo.Title:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
    self:SetLabelFontColor(self:GetLabelColor())
    self:SetSelected(self:IsSelected())
end

function ImprovedAddonListAddonItemMixin:SetLabelFontColor(color)
    self.Label:SetVertexColor(color:GetRGB())
end

function ImprovedAddonListAddonItemMixin:GetLabelColor()
    local addonInfo = self:GetAddonInfo()

    if addonInfo.Loaded then
        return NORMAL_FONT_COLOR
    else
        return DISABLED_FONT_COLOR
    end
end

function ImprovedAddonListAddonItemMixin:OnEnter()
    self:SetLabelFontColor(WHITE_FONT_COLOR) 
end

function ImprovedAddonListAddonItemMixin:OnLeave()
    self:SetLabelFontColor(self:GetLabelColor())
end

function ImprovedAddonListAddonItemMixin:OnClick()
    if self:IsSelected() then return end

    Addon:GetAddonListScrollBox().SelectionBehavior:Select(self)
    PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
end

function ImprovedAddonListAddonItemMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected)
	self.HighlightOverlay:SetShown(not selected)
end

function ImprovedAddonListAddonItemMixin:GetAddonInfo()
    return self:GetElementData():GetData().AddonInfo
end

function ImprovedAddonListAddonItemMixin:IsSelected()
    return Addon:GetAddonListScrollBox().SelectionBehavior:IsElementDataSelected(self:GetElementData())
end

-- 插件列表节点更新
local function AddonListTreeNodeUpdater(factory, node)
    local elementData = node:GetData()
    if elementData.AddonInfo then
        local function Initializer(button, node)
            button:Init()
        end
        factory("ImprovedAddonListAddonItemTemplate", Initializer)
    end
end

-- 选中变化
local function AddonListNodeOnSelectionChanged(_, elementData, selected)
    local button = Addon:GetAddonListScrollBox():FindFrame(elementData)
    
    if button then
        button:SetSelected(selected)
    end

    -- 显示插件详情
    local addonInfo = elementData:GetData().AddonInfo
    if addonInfo and selected then
        Addon:ShowAddonDetail(addonInfo.Name)
    end
end

-- 列表长度
local function ElementExtentCalculator(index, node)
    local data = node:GetData()
    return 30
end

local function onEnableAllButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["enable_all_tips"], 1, 1, 1)
    GameTooltip:Show()
end

local function onEnableAllButtonLeave(self)
    GameTooltip:Hide()
end

local function onEnableAllButtonClick(self)
    if Addon:IsAllAddonsEnabled() then return end

    Addon:EnableAllAddons()
    Addon:RefreshAddonList()
end

local function onDisableAllButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["disable_all_tips"], 1, 1, 1)
    GameTooltip:Show()
end

local function onDisableAllButtonLeave(self)
    GameTooltip:Hide()
end

local function onDisableAllButtonClick(self)
    if Addon:IsAllAddonsDisabled() then return end

    Addon:DisableAllAddons()
    Addon:RefreshAddonList()
end

-- 插件列表加载
function Addon:OnAddonListLoad()
    local AddonList = self:GetAddonList()

    -- 选项
    -- local OptionButton = CreateFrame("Button", nil, AddonList, "UIResettableDropdownButtonTemplate")
    -- AddonList.OptionButton = OptionButton
    -- OptionButton:SetSize(80, 22)
    -- OptionButton:SetPoint("TOPRIGHT", -5, -8)
    -- OptionButton.Text:SetText(L["options"])
    
    -- 弹出菜单
    -- local OptionDropDown = CreateFrame("Frame", nil, AddonList)
    -- AddonList.OptionDropDown = OptionDropDown
    -- OptionDropDown.Border = CreateFrame("Frame", nil, OptionDropDown, "DialogBorderDarkTemplate")
    -- OptionDropDown.Backdrop = CreateFrame("Frame", nil, OptionDropDown, "TooltipBackdropTemplate")
    -- OptionDropDown.Backdrop:SetAllPoints()

    -- 启用全部按钮
    local EnableAllButton = CreateFrame("Button", nil, AddonList)
    AddonList.EnableAllButton = EnableAllButton
    EnableAllButton:SetSize(16, 16)
    EnableAllButton:SetPoint("TOPRIGHT", -8, -8)
    EnableAllButton:SetScript("OnEnter", onEnableAllButtonEnter)
    EnableAllButton:SetScript("OnLeave", onEnableAllButtonLeave)
    EnableAllButton:SetScript("OnClick", onEnableAllButtonClick)

    -- 禁用全部按钮
    local DisableAllButton = CreateFrame("Button", nil, AddonList)
    AddonList.DisableAllButton = DisableAllButton
    DisableAllButton:SetSize(16, 16)
    DisableAllButton:SetPoint("RIGHT", EnableAllButton, "LEFT", -4, 0)
    DisableAllButton:SetScript("OnEnter", onDisableAllButtonEnter)
    DisableAllButton:SetScript("OnLeave", onDisableAllButtonLeave)
    DisableAllButton:SetScript("OnClick", onDisableAllButtonClick)

    -- 创建插件列表搜索框
    local AddonListSearchBox = CreateFrame("EditBox", nil, AddonList, "SearchBoxTemplate")
    AddonList.SearchBox = AddonListSearchBox
    AddonListSearchBox:SetPoint("LEFT", 14, 0)
    AddonListSearchBox:SetPoint("TOPRIGHT", DisableAllButton, "TOPLEFT", -5, 0)
    AddonListSearchBox:SetPoint("BOTTOMRIGHT", DisableAllButton, "BOTTOMLEFT", -5, 0)
    AddonListSearchBox:SetHeight(20)

    -- 创建插件列表
    -- 滚动框
    local AddonListScrollBox = CreateFrame("Frame", nil, AddonList, "WowScrollBoxList")
    AddonList.ScrollBox = AddonListScrollBox
    AddonListScrollBox:SetPoint("TOP", AddonListSearchBox, "BOTTOM", 0, -5)
    AddonListScrollBox:SetPoint("LEFT", 5, 0)
    AddonListScrollBox:SetPoint("BOTTOMRIGHT", -20, 7)
    -- 滚动条
    local AddonListScrollBar = CreateFrame("EventFrame", nil, AddonList, "MinimalScrollBar")
    AddonList.ScrollBar =  AddonListScrollBar
    AddonListScrollBar:SetPoint("TOPLEFT", AddonListScrollBox, "TOPRIGHT")
    AddonListScrollBar:SetPoint("BOTTOMLEFT", AddonListScrollBox, "BOTTOMRIGHT")

    local indent = 10
    local padLeft = 0
    local pad = 5
    local spacing = 1
    local addonListTreeView = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing)

    --添加选中特性
    AddonListScrollBox.SelectionBehavior = ScrollUtil.AddSelectionBehavior(AddonListScrollBox)
    AddonListScrollBox.SelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, AddonListNodeOnSelectionChanged)

    addonListTreeView:SetElementFactory(AddonListTreeNodeUpdater)
    addonListTreeView:SetElementExtentCalculator(ElementExtentCalculator)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonListScrollBox, Addon:GetAddonListScrollBar(), addonListTreeView)

    self:RefreshAddonList()
end

-- 刷新插件列表选项按钮的状态
function Addon:RefreshAddonListOptionButtonsStatus()
    local AddonList = self:GetAddonList()
    
    -- 更新启用全部按钮
    local EnableAllButton = AddonList.EnableAllButton
    local isAllAddonsEnabled = self:IsAllAddonsEnabled()
    local enableAllTexture = "Interface\\Addons\\ImprovedAddonList\\Media\\" .. (isAllAddonsEnabled and "enable_all_checked" or "enable_all" )
    EnableAllButton:SetNormalTexture(enableAllTexture)
    EnableAllButton:SetHighlightTexture(enableAllTexture)
    EnableAllButton:GetHighlightTexture():SetAlpha(0.2)
    
    -- 更新禁用全部按钮
    local DisableAllButton = AddonList.DisableAllButton
    local isAllAddonsDisabled = self:IsAllAddonsDisabled()
    local disableAllTexture = "Interface\\Addons\\ImprovedAddonList\\Media\\" .. (isAllAddonsDisabled and "disable_all_checked" or "disable_all" )
    DisableAllButton:SetNormalTexture(disableAllTexture)
    DisableAllButton:SetHighlightTexture(disableAllTexture)
    DisableAllButton:GetHighlightTexture():SetAlpha(0.2)
end

-- 刷新插件列表
function Addon:RefreshAddonList()
    self:UpdateAddonInfos()
    self:GetAddonListScrollBox():SetDataProvider(self:GetAddonDataProvider(), ScrollBoxConstants.RetainScrollPosition)

    local currentFocusAddonName = self:CurrentFocusAddonName()
    local predicate = function(node)
        local addonInfo = node:GetData().AddonInfo
        if currentFocusAddonName then
            -- 之前有选中插件，则刷新后再次选中
            return addonInfo and addonInfo.Name == currentFocusAddonName
        else
            -- 否则默认选中第一个
            return addonInfo
        end
    end

    self:GetAddonListScrollBox().SelectionBehavior:SelectElementDataByPredicate(predicate)

    -- 刷新按钮状态
    self:RefreshAddonListOptionButtonsStatus()
end

-- 刷新插件信息
function Addon:RefreshAddonInfo(addonName)
    self:UpdateAddonInfoByName(addonName)

    local predicate = function(frame, node)
        local addonInfo = node:GetData().AddonInfo
        return addonInfo and addonInfo.Name == addonName
    end

    self:GetAddonListScrollBox():FindFrameByPredicate(predicate):Update()
    self:RefreshAddonDetail()
    self:RefreshAddonListOptionButtonsStatus()
end

function Addon:GetAddonListScrollBox()
    return self:GetAddonList().ScrollBox
end

function Addon:GetAddonListScrollBar()
    return self:GetAddonList().ScrollBar
end
