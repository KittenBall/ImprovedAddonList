local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 字体
local ImprovedAddonListLabelFont = CreateFont("ImprovedAddonListLabelFont")
ImprovedAddonListLabelFont:CopyFontObject(GameFontWhite)
ImprovedAddonListLabelFont:SetTextColor(0.8039, 0.6039, 0.3568)

local ImprovedAddonListBodyFont = CreateFont("ImprovedAddonListBodyFont")
ImprovedAddonListBodyFont:CopyFontObject(GameFontWhite)
ImprovedAddonListBodyFont:SetJustifyH("LEFT")

local ImprovedAddonListButtonNormalFont = CreateFont("ImprovedAddonListButtonNormalFont")
ImprovedAddonListButtonNormalFont:CopyFontObject(GameFontWhite)
ImprovedAddonListButtonNormalFont:SetTextColor(NORMAL_FONT_COLOR:GetRGB())

local ImprovedAddonListButtonHighlightFont = CreateFont("ImprovedAddonListButtonHighlightFont")
ImprovedAddonListButtonHighlightFont:CopyFontObject(GameFontWhite)
ImprovedAddonListButtonHighlightFont:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGB())

local ImprovedAddonListButtonDisabledFont = CreateFont("ImprovedAddonListButtonDisabledFont")
ImprovedAddonListButtonDisabledFont:CopyFontObject(GameFontWhite)
ImprovedAddonListButtonDisabledFont:SetTextColor(DISABLED_FONT_COLOR:GetRGB())

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

-- UI函数
function Addon:GetOrCreateUI()
    local UI = self.UI
    if UI then return UI end

    -- 创建UI
    UI = CreateFrame("Frame", "ImprovedAddonListDialog", UIParent, "PortraitFrameTemplate")
    self.UI = UI

    -- 基本样式
    UI:SetSize(650, 600)
    UI:ClearAllPoints()
    UI:SetPoint("CENTER")
    UI:SetTitle(ADDON_LIST)
    UI:SetFrameStrata("HIGH")
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
    AddonList:SetPoint("TOPLEFT", 10, -80)

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

    -- 创建插件详情

    -- 插件详情容器
    local AddonDetailContainer = CreateContainer(UI)
    UI.AddonDetailContainer = AddonDetailContainer
    AddonDetailContainer:SetWidth(300)
    AddonDetailContainer:SetPoint("TOPLEFT", AddonList, "TOPRIGHT", 10, 0)
    AddonDetailContainer:SetPoint("BOTTOMLEFT", AddonList, "BOTTOMRIGHT", 10, 0)

    -- 滚动框
    local AddonDetailScrollBox = CreateFrame("Frame", nil, AddonDetailContainer, "WowScrollBox")
    UI.AddonDetailScrollBox = AddonDetailScrollBox
    AddonDetailScrollBox:SetPoint("TOPLEFT", 0, -10)
    AddonDetailScrollBox:SetPoint("BOTTOMRIGHT", -20, 40)

    --插件详情
    local AddonDetail = CreateFrame("Frame", nil, AddonDetailScrollBox)
    UI.AddonDetail = AddonDetail
    AddonDetail.scrollable = true
    AddonDetail:SetWidth(AddonDetailScrollBox:GetWidth())

    AddonDetailScrollBox:Init(CreateScrollBoxLinearView(1, 1, 1, 1))

    -- 初始化
    self:OnAddonDetailLoaded()
    self:OnAddonListLoad()

    return UI
end

function Addon:ShowUI()
    self:HideUIPanel(GameMenuFrame)
    self:GetOrCreateUI():Show()
end

function Addon:GetAddonList()
    return self.UI.AddonList
end

function Addon:GetAddonListScrollBox()
    return self.UI.AddonList.ScrollBox
end

function Addon:GetAddonListScrollBar()
    return self.UI.AddonList.ScrollBar
end

function Addon:GetAddonDetail()
    return self.UI.AddonDetail
end

function Addon:GetAddonDetailContainer()
    return self.UI.AddonDetailContainer
end

function Addon:GetAddonDetailScrollBox()
    return self.UI.AddonDetailScrollBox
end

-- 暴雪插件列表显示的时候，鸠占鹊巢
local function OnBlizzardAddonListShow()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    Addon:HideUIPanel(GameMenuFrame)
    Addon:ShowUI()
end

GameMenuButtonAddons:SetScript("OnClick", OnBlizzardAddonListShow)