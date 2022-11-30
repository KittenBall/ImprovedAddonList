local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 插件列表项函数集
ImprovedAddonListAddonItemMixin = {}

function ImprovedAddonListAddonItemMixin:Init()
    self:Update()
end

function ImprovedAddonListAddonItemMixin:Update()
    local addonInfo = self:GetAddonInfo()

    self.Label:SetText(addonInfo.Title)
    self:SetLabelFontColor(self:GetLabelColor())
    self:SetSelected(self:IsSelected())
end

function ImprovedAddonListAddonItemMixin:SetLabelFontColor(color)
    self.Label:SetVertexColor(color:GetRGB())
end

function ImprovedAddonListAddonItemMixin:GetLabelColor()
    local addonInfo = self:GetAddonInfo()

    if addonInfo.Loaded then
        return WHITE_FONT_COLOR
    else
        return DISABLED_FONT_COLOR
    end
end

function ImprovedAddonListAddonItemMixin:OnEnter()
    self:SetLabelFontColor(NORMAL_FONT_COLOR) 
end

function ImprovedAddonListAddonItemMixin:OnLeave()
    self:SetLabelFontColor(self:GetLabelColor())
end

function ImprovedAddonListAddonItemMixin:OnClick()
    if self:IsSelected() then return end

    Addon:GetAddonListScrollBox().selectionBehavior:Select(self)
    PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
end

function ImprovedAddonListAddonItemMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected)
	self.HighlightOverlay:SetShown(not selected)

    if selected then
        Addon:ShowAddonDetail(self:GetAddonInfo())
    end
end

function ImprovedAddonListAddonItemMixin:GetAddonInfo()
    return self:GetElementData():GetData().AddonInfo
end

function ImprovedAddonListAddonItemMixin:IsSelected()
    return Addon:GetAddonListScrollBox().selectionBehavior:IsElementDataSelected(self:GetElementData())
end

function Addon:GetOrCreateOptionDropDown()
    local AddonList = self:GetAddonList()
    local OptionDropDown = AddonList.OptionDropDown
    if OptionDropDown then return OptionDropDown end
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
end

-- 列表长度
local function ElementExtentCalculator(index, node)
    local data = node:GetData()
    return 30
end

-- 插件列表加载
function Addon:OnAddonListLoad()
    local AddonList = self:GetAddonList()

    -- 选项
    local OptionButton = CreateFrame("Button", nil, AddonList, "UIResettableDropdownButtonTemplate")
    AddonList.OptionButton = OptionButton
    OptionButton:SetSize(80, 22)
    OptionButton:SetPoint("TOPRIGHT", -5, -8)
    OptionButton.Text:SetText(L["options"])

    -- 弹出菜单
    local OptionDropDown = CreateFrame("Frame", nil, AddonList)
    AddonList.OptionDropDown = OptionDropDown
    OptionDropDown.Border = CreateFrame("Frame", nil, OptionDropDown, "DialogBorderDarkTemplate")
    OptionDropDown.Backdrop = CreateFrame("Frame", nil, OptionDropDown, "TooltipBackdropTemplate")
    OptionDropDown.Backdrop:SetAllPoints()

    -- 创建插件列表搜索框
    local AddonListSearchBox = CreateFrame("EditBox", nil, AddonList, "SearchBoxTemplate")
    AddonList.SearchBox = AddonListSearchBox
    AddonListSearchBox:SetPoint("LEFT", 14, 0)
    AddonListSearchBox:SetPoint("TOPRIGHT", OptionButton, "TOPLEFT", -5, 0)
    AddonListSearchBox:SetPoint("BOTTOMRIGHT", OptionButton, "BOTTOMLEFT", -5, 0)
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
    AddonListScrollBox.selectionBehavior = ScrollUtil.AddSelectionBehavior(AddonListScrollBox)
    AddonListScrollBox.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, AddonListNodeOnSelectionChanged)

    addonListTreeView:SetElementFactory(AddonListTreeNodeUpdater)
    -- addonListTreeView:SetElementExtentCalculator(ElementExtentCalculator)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonListScrollBox, Addon:GetAddonListScrollBar(), addonListTreeView)
    
    AddonListScrollBox:SetDataProvider(self:GetAddonDataProvider())

    -- 默认选中第一个
    AddonListScrollBox.selectionBehavior:SelectElementDataByPredicate(function(node)
        return node:GetData().AddonInfo
    end)
end

function Addon:GetAddonListScrollBox()
    return self:GetAddonList().ScrollBox
end

function Addon:GetAddonListScrollBar()
    return self:GetAddonList().ScrollBar
end
