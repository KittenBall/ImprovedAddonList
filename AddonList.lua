local addonName, Addon = ...

-- 插件列表项函数集
ImprovedAddonListAddonItemMixin = {}

function ImprovedAddonListAddonItemMixin:Init(node)
    local data = node:GetData()
    self.addonInfo = data.addonInfo
    self:Update()
end

function ImprovedAddonListAddonItemMixin:Update()
    local addonInfo = self.addonInfo

    self.Label:SetText(addonInfo.Title)
end

function ImprovedAddonListAddonItemMixin:SetLabelFontColor(color)
    self.Label:SetVertexColor(color:GetRGB())
end

function ImprovedAddonListAddonItemMixin:GetLabelColor()
    return self.addonInfo and PROFESSION_RECIPE_COLOR or DISABLED_FONT_COLOR
end

function ImprovedAddonListAddonItemMixin:OnEnter()
    self:SetLabelFontColor(HIGHLIGHT_FONT_COLOR) 
end

function ImprovedAddonListAddonItemMixin:OnLeave()
    self:SetLabelFontColor(self:GetLabelColor())
end

function ImprovedAddonListAddonItemMixin:OnClick()
    Addon:GetAddonListScrollBox().selectionBehavior:Select(self)
end

function ImprovedAddonListAddonItemMixin:SetSelected(selected)
	self.SelectedOverlay:SetShown(selected);
	self.HighlightOverlay:SetShown(not selected);
end


-- 插件列表节点更新
local function AddonListTreeNodeUpdater(factory, node)
    local elementData = node:GetData()
    if elementData.addonInfo then
        local function Initializer(button, node)
            button:Init(node)
        
            -- 重置选中状态
            local selected = Addon:GetAddonListScrollBox().selectionBehavior:IsElementDataSelected(node)
            button:SetSelected(selected)
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
end