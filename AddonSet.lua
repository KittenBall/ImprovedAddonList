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

    -- 当前加载插件集
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

-- 插件集列表项
ImprovedAddonListAddonSetItemMixin = {}

function ImprovedAddonListAddonSetItemMixin:Update()
    local data = self:GetElementData()
    self.Label:SetText(data.Name)

    if data.Enabled then
        self.Label:SetVertexColor(WHITE_FONT_COLOR:GetRGB())
    else
        self.Label:SetVertexColor(DISABLED_FONT_COLOR:GetRGB())
    end

    self:SetSelected(self:IsSelected())
end

function ImprovedAddonListAddonSetItemMixin:OnClick()
    if self:IsSelected() then 
        return 
    end

    Addon:GetAddonSetListScrollBox().SelectionBehavior:Select(self)
    PlaySound(SOUNDKIT.UI_90_BLACKSMITHING_TREEITEMCLICK)
end

function ImprovedAddonListAddonSetItemMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected)
	self.HighlightOverlay:SetShown(not selected)
end

function ImprovedAddonListAddonSetItemMixin:IsSelected()
    return Addon:GetAddonSetListScrollBox().SelectionBehavior:IsElementDataSelected(self:GetElementData())
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
    local editInfo = {
        Title = L["addon_set_new"],
        Label = L["addon_set_new_label"],
        MaxLetters = Addon.ADDON_SET_NAME_MAX_LENGTH,
        MaxLines = 2,
        OnConfirm = function(_, name)
            if Addon:NewAddonSet(name) then
                Addon:RefreshAddonSetListContainer(name)
                return true
            end
        end
    }
    Addon:ShowEditDialog(editInfo)
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
    local node = Addon:GetAddonSetListScrollBox().SelectionBehavior:GetFirstSelectedElementData()
    if not node then return end

    local alertInfo = {
        Label = L["addon_set_delete_confirm"]:format(WrapTextInColor(node.Name, NORMAL_FONT_COLOR)),
        Extra = node.Name,
        OnConfirm = function(addonSetName)
            Addon:DeleteAddonSet(addonSetName)
            Addon:RefreshAddonSetListContainer()
            return true
        end
    }
    Addon:ShowAlertDialog(alertInfo)
end

local function AddonSetListNodeUpdater(factory, node)
    local function Initializer(button, node)
        button:Update()
    end

    factory("ImprovedAddonListAddonSetItemTemplate", Initializer)
end

local function ElementExtentCalculator(index, node)
    return 25
end

local function onAddonSetListSearchBoxTextChanged(self, userInput)
    if self.searchJob then
        self.searchJob:Cancel()
    end
    self.searchJob = C_Timer.NewTimer(0.25, function()
        Addon:RefreshAddonSetListContainer()
    end)
end

local function AddonSetListNodeOnSelectionChanged(_, elementData, selected)
    local button = Addon:GetAddonSetListScrollBox():FindFrame(elementData)
    
    if button then
        button:SetSelected(selected)
    end

    -- todo
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
    AddonSetSearchBox:HookScript("OnTextChanged", onAddonSetListSearchBoxTextChanged)

    local AddonSetScrollBox = CreateFrame("Frame", nil, AddonSetListContainer, "WowScrollBoxList")
    AddonSetListContainer.ScrollBox = AddonSetScrollBox
    AddonSetScrollBox:SetPoint("TOP", AddonSetSearchBox, "BOTTOM", 0, -5)
    AddonSetScrollBox:SetPoint("LEFT", 5, 0)
    AddonSetScrollBox:SetPoint("BOTTOMRIGHT", -25, 7)
    -- 滚动条
    local AddonSetScrollBar = CreateFrame("EventFrame", nil, AddonSetListContainer, "MinimalScrollBar")
    AddonSetListContainer.ScrollBar =  AddonSetScrollBar
    AddonSetScrollBar:SetPoint("TOPLEFT", AddonSetScrollBox, "TOPRIGHT", 5, 0)
    AddonSetScrollBar:SetPoint("BOTTOMLEFT", AddonSetScrollBox, "BOTTOMRIGHT", 5, 0)

    local addonSetListView = CreateScrollBoxListLinearView(1, 1, 1, 1, 1)
    addonSetListView:SetElementFactory(AddonSetListNodeUpdater)
    addonSetListView:SetElementExtentCalculator(ElementExtentCalculator)
    ScrollUtil.InitScrollBoxListWithScrollBar(AddonSetScrollBox, AddonSetScrollBar, addonSetListView)

    AddonSetScrollBox.SelectionBehavior = ScrollUtil.AddSelectionBehavior(AddonSetScrollBox)
    AddonSetScrollBox.SelectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, AddonSetListNodeOnSelectionChanged)

    local AddonListContainer = self:CreateContainer(AddonSetDialog)
    AddonSetDialog.AddonListContainer = AddonListContainer
    AddonListContainer:SetWidth(300)
    AddonListContainer:SetPoint("TOPLEFT", AddonSetListContainer, "TOPRIGHT", 10, 0)
    AddonListContainer:SetPoint("BOTTOMLEFT", AddonSetListContainer, "BOTTOMRIGHT", 10, 0)

    self:RefreshAddonSetListContainer()
end

function Addon:GetAddonSetListScrollBox()
    return self:GetOrCreateUI().AddonSetDialog.AddonSetListContainer.ScrollBox
end

function Addon:GetAddonSetListSearchBox()
    return self:GetOrCreateUI().AddonSetDialog.AddonSetListContainer.SearchBox
end

-- 隐藏插件集弹窗
function Addon:HideAddonSetDialog()
    local UI = self:GetOrCreateUI()

    if UI.AddonSetDialog then
        UI.AddonSetDialog:Hide()
    end
end

function Addon:RefreshAddonSetListContainer(targetAddonSetName)
    self:RefreshAddonSetList()

    if not targetAddonSetName then
        local activeAddonSet = self:GetActiveAddonSet()
        if activeAddonSet then
            targetAddonSetName = activeAddonSet.Name
        end
    end

    local selectPredicate = function(node)
        if targetAddonSetName then
            return targetAddonSetName == node.Name 
        else
            return node
        end
    end

    self:GetAddonSetListScrollBox().SelectionBehavior:SelectElementDataByPredicate(selectPredicate)
    self:ScrollToSelectedAddonSet()
end

function Addon:ScrollToSelectedAddonSet()
    local selectedPredicate = function(elementData)
        return self:GetAddonSetListScrollBox().SelectionBehavior:IsElementDataSelected(elementData)
    end
    self:GetAddonSetListScrollBox():ScrollToElementDataByPredicate(selectedPredicate, ScrollBoxConstants.AlignCenter, ScrollBoxConstants.NoScrollInterpolation)
end

-- 刷新插件集列表
function Addon:RefreshAddonSetList()
    self.AddonSetDataProvider = self.AddonSetDataProvider or CreateDataProvider()
    local addonSetDataProvider = self.AddonSetDataProvider

    local searchText = self:GetAddonSetListSearchBox():GetText()
    searchText = searchText and strtrim(searchText)
    searchText = searchText and searchText:lower()

    addonSetDataProvider:Flush()

    local shouldFilter = searchText and strlen(searchText) > 0
    local addonSets = self:GetAddonSets()

    for _, addonSet in ipairs_reverse(addonSets) do
        if shouldFilter then
            if addonSet.Name:lower():match(searchText) then
                addonSetDataProvider:Insert(addonSet)
            end
        else
            addonSetDataProvider:Insert(addonSet)
        end
    end

    self:GetAddonSetListScrollBox():SetDataProvider(addonSetDataProvider, ScrollBoxConstants.RetainScrollPosition)
end