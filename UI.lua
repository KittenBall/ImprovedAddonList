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

-- 创建对话框
function Addon:CreateDialog(name, parent)
    local dialog = CreateFrame("Frame", name, parent, "PortraitFrameTemplate")
    ButtonFrameTemplateMinimizable_HidePortrait(dialog)
    dialog.TitleContainer:ClearAllPoints()
    dialog.TitleContainer:SetPoint("TOPLEFT", 1, -1)
    dialog.TitleContainer:SetPoint("TOPRIGHT", -1, -1)
    dialog.CloseButton:SetFrameLevel(dialog.TitleContainer:GetFrameLevel() + 1)

    -- 响应Escape
    local function OnEscapePressed(self, key)
        if InCombatLockdown() then
            -- 战斗中，按下任意按键都隐藏面板
            -- 因为SetPropagateKeyboardInput战斗中无法调用
            self:Hide()
        else
            if key == "ESCAPE" then
                self:SetPropagateKeyboardInput(false)
                self:Hide()
            else
                self:SetPropagateKeyboardInput(true)
            end
        end
    end
    
    dialog:SetScript("OnKeyDown", OnEscapePressed)
    dialog:SetMouseMotionEnabled(true)
    dialog:SetMouseClickEnabled(true)

    -- 拖动
    dialog:SetMovable(true)
    dialog.TitleContainer:EnableMouse(true)
    dialog.TitleContainer:RegisterForDrag("LeftButton")
    dialog:SetClampedToScreen(true)
    dialog.TitleContainer:SetScript("OnDragStart", function(self)
        self:GetParent():StartMoving()
        self:GetParent():SetUserPlaced(false)
    end)
    dialog.TitleContainer:SetScript("OnDragStop", function(self)
        self:GetParent():StopMovingOrSizing()
    end)

    return dialog
end

-- 创建带背景和边框的容器
function Addon:CreateContainer(parent)
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

-- 获取环境信息
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

    return format("%s.%d(%s) on %s %s\nBuild on %s, current toc version:%s", patch, build, flavor, system, clientBit, date, tocNumber)
end

-- 启用过期插件按钮选中变化
local function OnEnableExpiredAddonsButtonCheckedChange(self)
    if self:GetChecked() then
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
        SetAddonVersionCheck(false);
    else
        PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
        SetAddonVersionCheck(true);
    end
    Addon:UpdateAddonInfos()
    Addon:RefreshAddonListContainer()
end

-- 重载插件指示器：鼠标划入
local function OnReloadUIIndicatorEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["reload_ui_tips_title"])
    
    for _, title in ipairs(Addon:GetAddonTitlesShouldReload()) do
        GameTooltip:AddLine(title, 1, 1, 1)
    end
    
    GameTooltip:Show()
end

-- 重载插件指示器：鼠标移出
local function OnReloadUIIndicatorLeave(self)
    GameTooltip:Hide()
end

-- UI函数
function Addon:GetOrCreateUI()
    local UI = self.UI
    if UI then return UI end

    -- 创建UI
    UI = self:CreateDialog("ImprovedAddonListDialog", UIParent)
    self.UI = UI

    -- 基本样式
    UI:SetSize(630, 600)
    UI:ClearAllPoints()
    UI:SetPoint("CENTER")
    UI:SetTitle(ADDON_LIST)
    UI:SetFrameStrata("HIGH")

    -- 启用过期插件按钮
    local EnableExpiredAddonsButton = CreateFrame("CheckButton", nil, UI, "UICheckButtonTemplate")
    UI.EnableExpiredAddonsButton = EnableExpiredAddonsButton
    EnableExpiredAddonsButton:SetSize(26, 26)
    EnableExpiredAddonsButton.text:SetFontObject(GameFontWhite)
    EnableExpiredAddonsButton.text:SetText(ADDON_FORCE_LOAD)
    EnableExpiredAddonsButton:SetChecked(not IsAddonVersionCheckEnabled())
    EnableExpiredAddonsButton:SetPoint("TOPRIGHT", -(EnableExpiredAddonsButton.text:GetStringWidth() + 20), -30)
    EnableExpiredAddonsButton:SetScript("OnClick", OnEnableExpiredAddonsButtonCheckedChange)

    -- 重载界面按钮
    local ReloadUIButton = CreateFrame("Button", nil, UI, "SharedButtonSmallTemplate")
    UI.ReloadUIButton = ReloadUIButton
    ReloadUIButton:SetSize(120, 22)
    ReloadUIButton:SetText(RELOADUI)
    ReloadUIButton:SetPoint("BOTTOMRIGHT", -10, 10)
    -- 点击重载界面
    ReloadUIButton:SetScript("OnClick", function() ReloadUI() end)

    -- 重载界面指示器
    local ReloadUIIndicator = CreateFrame("Button", nil, UI)
    UI.ReloadUIIndicator = ReloadUIIndicator
    ReloadUIIndicator:SetSize(16, 16)
    ReloadUIIndicator:SetNormalTexture("Interface\\AddOns\\ImprovedAddonList\\Media\\reload_indicator.png")
    ReloadUIIndicator:SetHighlightTexture("Interface\\AddOns\\ImprovedAddonList\\Media\\reload_indicator.png")
    ReloadUIIndicator:GetHighlightTexture():SetAlpha(0.2)
    ReloadUIIndicator:SetPoint("RIGHT", ReloadUIButton, "LEFT", -8, 0)
    ReloadUIIndicator:SetScript("OnEnter", OnReloadUIIndicatorEnter)
    ReloadUIIndicator:SetScript("OnLeave", OnReloadUIIndicatorLeave)
    -- 动画
    local Animation = ReloadUIIndicator:CreateAnimationGroup()
    Animation:SetLooping("BOUNCE")
    ReloadUIIndicator.Animation = Animation
    local alpha = Animation:CreateAnimation("Alpha")
    alpha:SetFromAlpha(0)
    alpha:SetToAlpha(1)
    alpha:SetDuration(1.5)

    -- 游戏Build信息
    local BuildInfo = UI:CreateFontString(nil, nil, "GameFontDisableTiny")
    UI.BuildInfo = BuildInfo
    BuildInfo:SetJustifyH("LEFT")
    BuildInfo:SetPoint("BOTTOMLEFT", 10, 10)
    BuildInfo:SetText(GetEnvInfo())

    -- 插件集
    local AddonSetContainer = CreateFrame("Frame", nil, UI)
    UI.AddonSetContainer = AddonSetContainer
    AddonSetContainer:SetSize(240, 24)
    AddonSetContainer:SetPoint("TOPLEFT", 10, -32)

    -- 创建插件列表页
    local AddonListContainer = self:CreateContainer(UI)
    UI.AddonListContainer = AddonListContainer
    AddonListContainer:SetWidth(300)
    AddonListContainer:SetPoint("BOTTOMLEFT", 10, 40)
    AddonListContainer:SetPoint("TOPLEFT", 10, -60)

    -- 创建插件详情页
    local AddonDetailContainer = self:CreateContainer(UI)
    UI.AddonDetailContainer = AddonDetailContainer
    AddonDetailContainer:SetWidth(300)
    AddonDetailContainer:SetPoint("TOPLEFT", AddonListContainer, "TOPRIGHT", 10, 0)
    AddonDetailContainer:SetPoint("BOTTOMLEFT", AddonListContainer, "BOTTOMRIGHT", 10, 0)

    -- 初始化
    self:OnAddonDetailContainerLoad()
    self:OnAddonListContainerLoad()
    self:OnAddonSetContainerLoad()

    return UI
end

function Addon:ShowUI()
    self:HideUIPanel(GameMenuFrame)
    self:GetOrCreateUI():Show()
end

function Addon:GetAddonListContainer()
    return self.UI.AddonListContainer
end

function Addon:GetAddonDetailContainer()
    return self.UI.AddonDetailContainer
end

function Addon:GetAddonSetContainer()
    return self.UI.AddonSetContainer
end

function Addon:GetReloadUIIndicator()
    return self.UI.ReloadUIIndicator
end

-- 暴雪插件列表显示的时候，鸠占鹊巢
local function OnBlizzardAddonListShow()
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
    Addon:ShowUI()
end

GameMenuButtonAddons:SetScript("OnClick", OnBlizzardAddonListShow)