local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 创建带背景和边框的容器
local function CreateContainer(parent)
    local Container = CreateFrame("Frame", nil, parent)

    -- 背景
    local Background = Container:CreateTexture(nil, "BACKGROUND")
    Background:SetAtlas("Professions-background-summarylist")
    Background:SetAllPoints()
    Container.Background = Background

    -- 边框
    local BackgroundNineSlice = CreateFrame("Frame", nil, Container, "NineSlicePanelTemplate")
    BackgroundNineSlice.layoutType = "InsetFrameTemplate"
    BackgroundNineSlice:SetAllPoints(Background)
    BackgroundNineSlice:SetFrameLevel(Container:GetFrameLevel())
    BackgroundNineSlice:OnLoad()
    Container.BackgroundNineSlice = BackgroundNineSlice

    return Container
end

-- 创建AddonList
local UI = CreateFrame("Frame", "ImprovedAddonListDialog", UIParent, "PortraitFrameTemplate")
Addon.UI = UI

-- 基本样式
UI:SetSize(500, 600)
UI:ClearAllPoints()
UI:SetPoint("CENTER")
UI:SetTitle(ADDON_LIST)
UI:SetFrameStrata("HIGH")
-- UI:Hide()
ButtonFrameTemplateMinimizable_HidePortrait(UI)

-- 响应Escape
local function OnEscapePressed(self, key)
    if key == "ESCAPE" then
        self:Hide()
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end

UI:SetScript("OnKeyDown", OnEscapePressed)

-- 拖动
UI:SetMovable(true)
UI:EnableMouse(true)
UI:RegisterForDrag("LeftButton")
UI:SetClampedToScreen(true)
UI:SetScript("OnDragStart", function(self)
    self:StartMoving()
    self:SetUserPlaced(false)
end)
UI:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- 创建插件列表页
local AddonList = CreateContainer(UI)
UI.AddonList = AddonList
AddonList:SetSize(300, 505)
AddonList:SetPoint("TOPLEFT", 10, -40)

-- 创建插件列表搜索框
local AddonListSearchBox = CreateFrame("EditBox", nil, AddonList, "SearchBoxTemplate")
AddonList.SearchBox = AddonListSearchBox
AddonListSearchBox:SetPoint("TOPLEFT", 13, -8)
AddonListSearchBox:SetPoint("TOPRIGHT", -13, -8)
AddonListSearchBox:SetHeight(20)

-- 创建插件列表
-- 滚动框
local AddonListScrollBox = CreateFrame("Frame", nil, AddonList, "WowScrollBoxList")
AddonList.ScrollBox = AddonListScrollBox
AddonListScrollBox:SetPoint("TOPLEFT", AddonListSearchBox, "BOTTOMLEFT", -5, -7)
AddonListScrollBox:SetPoint("BOTTOMRIGHT", -20, 5)
-- 滚动条
local AddonListScrollBar = CreateFrame("EventFrame", nil, AddonList, "MinimalScrollBar")
AddonList.ScrollBar =  AddonListScrollBar
AddonListScrollBar:SetPoint("TOPLEFT", AddonListScrollBox, "TOPRIGHT")
AddonListScrollBar:SetPoint("BOTTOMLEFT", AddonListScrollBox, "BOTTOMRIGHT")


-- 暴雪插件列表显示的时候，鸠占鹊巢
-- local function OnBlizzardAddonListShow()
--     PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
--     Addon:HideUIPanel(GameMenuFrame)
--     UI:Show()
-- end

-- GameMenuButtonAddons:SetScript("OnClick", OnBlizzardAddonListShow)

-- UI函数
function Addon:GetAddonList()
    return self.UI.AddonList
end

function Addon:GetAddonListScrollBox()
    return self.UI.AddonList.ScrollBox
end

function Addon:GetAddonListScrollBar()
    return self.UI.AddonList.ScrollBar
end