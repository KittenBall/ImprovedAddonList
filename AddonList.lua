local addonName, Addon = ...

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

-- 插件列表加载
function Addon:OnAddonListLoad()
    local addonListScrollBox = self:GetAddonListScrollBox()
    
    local indent = 10
    local padLeft = 0
    local pad = 5
    local spacing = 1
    local addonListTreeView = CreateScrollBoxListTreeListView(indent, pad, pad, padLeft, pad, spacing)

    --添加选中特性
    addonListScrollBox.selectionBehavior = ScrollUtil.AddSelectionBehavior(addonListScrollBox)
    addonListScrollBox.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, AddonListNodeOnSelectionChanged)

    addonListTreeView:SetElementFactory(AddonListTreeNodeUpdater)
    ScrollUtil.InitScrollBoxListWithScrollBar(addonListScrollBox, Addon:GetAddonListScrollBar(), addonListTreeView)
    
    addonListScrollBox:SetDataProvider(self:GetAddonDataProvider())

    -- 默认选中第一个
    addonListScrollBox.selectionBehavior:SelectElementDataByPredicate(function(node)
        return node:GetData().AddonInfo
    end)
end