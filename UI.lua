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

local function GetEnvInfo()
    local patch, build, date, tocNumber = GetBuildInfo()
    local clientBit = Is64BitClient() and "64" or "32"

    -- 系统
    local system
    if IsWindowsClient() then
        system = "Windows"
    elseif IsMacClient() then
        system = "Mac"
        clientBit = ""
    elseif IsLinuxClient() then
        system = "Linux"
    else
        system = "Unknown"
    end

    -- 游戏版本，虽然并没有判断的必要，因为本插件只支持正式服
    local flavor
    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        flavor = "Retail"
    elseif WOW_PROJECT_ID == WOW_PROJECT_CLASSIC then
        flavor = "CLASSIC"
    elseif WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
        flavor = "WOTLKC"
    else
        flavor = "UNKNOWN"
    end

    return format("%s.%d(%s) on %s %s\nBuild in %s, current toc version:%s", patch, build, flavor, system, clientBit, date, tocNumber)
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

    -- 游戏Build信息
    local BuildInfo = UI:CreateFontString(nil, nil, "GameFontDisableTiny")
    UI.BuildInfo = BuildInfo
    BuildInfo:SetJustifyH("LEFT")
    BuildInfo:SetPoint("BOTTOMLEFT", 10, 10)
    BuildInfo:SetText(GetEnvInfo())

    -- 创建插件列表页
    local AddonList = CreateContainer(UI)
    UI.AddonList = AddonList
    AddonList:SetWidth(300)
    AddonList:SetPoint("BOTTOMLEFT", 10, 40)
    AddonList:SetPoint("TOPLEFT", 10, -40)

    -- 创建插件列表搜索框
    local AddonListSearchBox = CreateFrame("EditBox", nil, AddonList, "SearchBoxTemplate")
    AddonList.SearchBox = AddonListSearchBox
    AddonListSearchBox:SetPoint("TOPLEFT", 13, -25)
    AddonListSearchBox:SetPoint("TOPRIGHT", -13, -25)
    AddonListSearchBox:SetHeight(20)

    -- 创建插件列表
    -- 滚动框
    local AddonListScrollBox = CreateFrame("Frame", nil, AddonList, "WowScrollBoxList")
    AddonList.ScrollBox = AddonListScrollBox
    AddonListScrollBox:SetPoint("TOPLEFT", AddonListSearchBox, "BOTTOMLEFT", -5, -7)
    AddonListScrollBox:SetPoint("BOTTOMRIGHT", -20, 7)
    -- 滚动条
    local AddonListScrollBar = CreateFrame("EventFrame", nil, AddonList, "MinimalScrollBar")
    AddonList.ScrollBar =  AddonListScrollBar
    AddonListScrollBar:SetPoint("TOPLEFT", AddonListScrollBox, "TOPRIGHT")
    AddonListScrollBar:SetPoint("BOTTOMLEFT", AddonListScrollBox, "BOTTOMRIGHT")

    -- 创建插件详情

    -- 插件详情
    local AddonDetail = CreateContainer(UI)
    UI.AddonDetail = AddonDetail
    AddonDetail:SetWidth(300)
    AddonDetail:SetPoint("TOPLEFT", AddonList, "TOPRIGHT", 10, 0)
    AddonDetail:SetPoint("BOTTOMLEFT", AddonList, "BOTTOMRIGHT", 10, 0)

    -- 滚动框
    local AddonDetailScrollBox = CreateFrame("Frame", nil, AddonDetail, "WowScrollBox")
    AddonDetail.ScrollBox = AddonDetailScrollBox
    AddonDetailScrollBox:SetPoint("TOPLEFT", 5, -7)
    AddonDetailScrollBox:SetPoint("BOTTOMRIGHT", -5, 40)

    --插件详情框体
    local AddonDetailFrame = CreateFrame("Frame", nil, AddonDetailScrollBox)
    AddonDetailScrollBox.Container = AddonDetailFrame
    AddonDetailFrame.scrollable = true
    AddonDetailFrame:SetWidth(AddonDetailScrollBox:GetWidth())

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

function Addon:GetAddonDetailScrollBox()
    return self.UI.AddonDetail.ScrollBox
end

function Addon:GetAddonDetailContainer()
    return self.UI.AddonDetail.ScrollBox.Container
end

-- 暴雪插件列表显示的时候，鸠占鹊巢
local function OnBlizzardAddonListShow()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    Addon:HideUIPanel(GameMenuFrame)
    Addon:ShowUI()
end

GameMenuButtonAddons:SetScript("OnClick", OnBlizzardAddonListShow)