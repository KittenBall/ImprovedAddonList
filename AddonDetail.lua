local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 更新label位置，计算其上面的label和body哪个更高，然后将其锚定至高的那个框体
local function UpdateAddonDetailLabelPosition(topLabel, topBody, label)
    local topFrame = topLabel:GetHeight() > topBody:GetHeight() and topLabel or topBody
    
    label:ClearAllPoints()
    label:SetPoint("LEFT", topLabel, "LEFT", 0, 0)
    label:SetPoint("TOP", topFrame, "BOTTOM", 0, -8)
end

local ADDON_DETAILS = {
    {
        Name = "BasicInfo",
        Label = L["addon_detail_basic_info"],
        Details = {
            {
                Name = "Name",
                Label = L["addon_detail_name"]
            },
            {
                Name = "Title",
                Label = L["addon_detail_title"]
            },
            {
                Name = "Notes",
                Label = L["addon_detail_notes"]
            },
            {
                Name = "Author",
                Label = L["addon_detail_author"]
            },
            {
                Name = "Version",
                Label = L["addon_detail_version"]
            },
            {
                Name = "LoadOnDemand",
                Label = L["addon_detail_load_on_demand"]
            },
            {
                Name = "Remark",
                Label = L["addon_detail_remark"]
            }
        }
    },
    {
        Name = "StatusInfo",
        Label = L["addon_detail_status_info"],
        Details = {
            {
                Name = "LoadStatus",
                Label = L["addon_detail_load_status"]
            },
            {
                Name = "UnloadReason",
                Label = L["addon_detail_unload_reason"],
                Color = RED_FONT_COLOR
            },
            {
                Name = "EnableStatus",
                Label = L["addon_detail_enable_status"]
            },
            {
                Name = "MemoryUsage",
                Label = L["addon_detail_memory_usage"]
            }
        }
    },
    {
        Name = "DepInfo",
        Label = L["addon_detail_dep_info"],
        Details = {
            {
                Name = "Dependencies",
                Label = L["addon_detail_dependencies"]
            },
            {
                Name = "OptionalDeps",
                Label = L["addon_detail_optional_deps"]
            }
        }
    }
}

function Addon:UpdateAddonDetailFramesPosition()
    local addonDetailFrame = self:GetAddonDetailContainer()

    local categoryOffsetX, categoryOffsetY = 10, -10
    local addonDetailOffsetX, addonDetailFirstOffsetY, addonDetailOffsetY = 15, -10, -8

    local preFrame, usedHeight = nil, 0
    for categoryIndex, category in pairs(ADDON_DETAILS) do
        local categoryFrame = addonDetailFrame[category.Name]
        categoryFrame:ClearAllPoints()
        categoryFrame:SetPoint("TOPLEFT", categoryOffsetX, -usedHeight + categoryOffsetY)
        usedHeight = usedHeight + categoryFrame:GetHeight() - categoryOffsetY

        for detailIndex, detail in pairs(category.Details) do
            local detailLabel = addonDetailFrame[detail.Name .. "Label"]
            local detailBody = addonDetailFrame[detail.Name]
            local detailContent = detailBody:GetText() or ""
            if strlen(detailContent) <= 0 then
                detailLabel:SetShown(false)
                detailBody:SetShown(false)
            else
                detailLabel:SetShown(true)
                detailBody:SetShown(true)

                local detailHeight = math.max(detailLabel:GetHeight(), detailBody:GetHeight())
                local offsetY = detailIndex == 1 and addonDetailFirstOffsetY or addonDetailOffsetY
                detailLabel:SetPoint("TOPLEFT", addonDetailOffsetX, -usedHeight + offsetY)
                usedHeight = usedHeight + detailHeight - offsetY
            end
        end
    end

    -- 动态高度，方便滚动
    addonDetailFrame:SetHeight(usedHeight + 20)
	self:GetAddonDetailScrollBox():FullUpdate();
	self:GetAddonDetailScrollBox():ScrollToBegin(ScrollBoxConstants.NoScrollInterpolation)
end

local function CreateDetailButton(container)
    local button = CreateFrame("Button", nil, container)
    button:SetNormalFontObject(ImprovedAddonListButtonNormalFont)
    button:SetHighlightFontObject(ImprovedAddonListButtonHighlightFont)
    button:SetDisabledFontObject(ImprovedAddonListButtonDisabledFont)
    return button
end

local function onLoadButtonEnter(self)
    if self.tooltipText then
        GameTooltip:SetOwner(self)
        GameTooltip:AddLine(self.tooltipText, 1, 1, 1)
        GameTooltip:Show()
    end
end

local function onLoadButtonLeave(self)
    GameTooltip:Hide()
end

local function OnLoadButtonClick(self)
    local addonInfo = Addon:CurrentFocusAddonInfo()
    -- 加载按需加载的插件并修改其初始状态
    LoadAddOn(addonInfo.Name)
    if IsAddOnLoaded(addonInfo.Name) then
        Addon:UpdateAddonInitialEnableState(addonInfo.Name, true)
    end
    Addon:RefreshAddonInfo(addonInfo.Name)
end

local function onEnableButtonClick(self)
    local addonInfo = Addon:CurrentFocusAddonInfo()
    if addonInfo.Enabled then
        DisableAddOn(addonInfo.Name)
    else
        EnableAddOn(addonInfo.Name)
    end
    Addon:RefreshAddonInfo(addonInfo.Name)
end

local function onFavoriteButtonEnter(self)
    if self.tooltipText then
        GameTooltip:SetOwner(self)
        GameTooltip:AddLine(self.tooltipText, 1, 1, 1)
        GameTooltip:Show()
    end
end

local function onFavoriteButtonLeave(self)
    GameTooltip:Hide()
end

local function onFavoriteButtonClick(self)
    local addonInfo = Addon:CurrentFocusAddonInfo()
    Addon:SetAddonFavorite(addonInfo.Name, not addonInfo.IsFavorite)
    PlaySound(SOUNDKIT.UI_PROFESSION_TRACK_RECIPE_CHECKBOX)
    Addon:RefreshAddonInfo(addonInfo.Name)

    if GameTooltip:IsOwned(self) then
        onFavoriteButtonEnter(self)
    end
end

local function onRemarkButtonEnter(self)
    GameTooltip:SetOwner(self)
    GameTooltip:AddLine(L["edit_remark"], 1, 1, 1)
    GameTooltip:Show()
end

local function onRemarkButtonLeave(self)
    GameTooltip:Hide()
end

local function onRemarkButtonClick(self)
    -- @todo
end

function Addon:OnAddonDetailLoad()
    local AddonDetail = self:GetAddonDetail()
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

    for _, category in pairs(ADDON_DETAILS) do
        local categoryFrame = AddonDetailFrame:CreateFontString(nil, nil, "GameFontNormal")
        AddonDetailFrame[category.Name] = categoryFrame
        categoryFrame:SetText(category.Label)

        for _, detail in pairs(category.Details) do
            local detailLabel = AddonDetailFrame:CreateFontString(nil, nil, "ImprovedAddonListLabelFont")
            AddonDetailFrame[detail.Name .. "Label"] = detailLabel
            detailLabel:SetText(detail.Label)

            local detailBody = AddonDetailFrame:CreateFontString(nil, nil, "ImprovedAddonListBodyFont")
            AddonDetailFrame[detail.Name] = detailBody
            detailBody:SetNonSpaceWrap(true)
            detailBody:SetPoint("TOPLEFT", detailLabel, "TOPRIGHT", 5, 0)
            detailBody:SetPoint("RIGHT", AddonDetailFrame, "RIGHT", -10, 0)

            if detail.Color then
                detailBody:SetTextColor(detail.Color:GetRGB())
            end
        end
    end

    -- 收藏按钮
    local favoriteButton = CreateDetailButton(AddonDetailFrame)
    AddonDetail.FavoriteButton = favoriteButton
    favoriteButton:SetScript("OnEnter", onFavoriteButtonEnter)
    favoriteButton:SetScript("OnLeave", onFavoriteButtonLeave)
    favoriteButton:SetScript("OnClick", onFavoriteButtonClick)
    favoriteButton:SetSize(16, 16)
    favoriteButton:SetPoint("TOPRIGHT", -10, -10)

    -- 备注按钮
    local remarkButton = CreateDetailButton(AddonDetailFrame)
    AddonDetail.RemarkButton = remarkButton
    remarkButton:SetScript("OnEnter", onRemarkButtonEnter)
    remarkButton:SetScript("OnLeave", onRemarkButtonLeave)
    remarkButton:SetScript("OnClick", onRemarkButtonClick)
    remarkButton:SetNormalTexture("Interface\\Addons\\ImprovedAddonList\\Media\\remark")
    remarkButton:SetHighlightTexture("Interface\\Addons\\ImprovedAddonList\\Media\\remark")
    remarkButton:GetHighlightTexture():SetAlpha(0.2)
    remarkButton:SetSize(16, 16)
    remarkButton:SetPoint("RIGHT", favoriteButton, "LEFT", -4, 0)

    -- 启用按钮
    local enableButton = CreateDetailButton(AddonDetail)
    AddonDetail.EnableButton = enableButton
    enableButton:SetScript("OnClick", onEnableButtonClick)
    enableButton:SetPoint("BOTTOMRIGHT", 0, 5)
    enableButton:SetSize(88, 22)
    
    -- 加载按钮
    local loadButton = CreateDetailButton(AddonDetail)
    AddonDetail.LoadButton = loadButton
    loadButton:SetScript("OnEnter", onLoadButtonEnter)
    loadButton:SetScript("OnLeave", onLoadButtonLeave)
    loadButton:SetScript("OnClick", OnLoadButtonClick)
    loadButton:SetText(L["load_addon"])
    loadButton:SetPoint("RIGHT", enableButton, "LEFT", 0, 0)
    loadButton:SetSize(88, 22)

    self:UpdateAddonDetailFramesPosition()
end

function Addon:GetAddonDetailScrollBox()
    return self:GetAddonDetail().ScrollBox
end

function Addon:GetAddonDetailContainer()
    return self:GetAddonDetail().ScrollBox.Container
end

local function getAddonVersion(version)
    if not version then return end
    
    if strmatch(version, ".*project.*version.*") then
        return WrapTextInColor(L["addon_detail_version_debug"], EPIC_PURPLE_COLOR)
    end

    return version
end

local function getStatusColor(loaded)
    if loaded then
        return WHITE_FONT_COLOR
    else
        return RED_FONT_COLOR
    end
end

local function GetEnableButtonColor(enabled)
    if enabled then
        return RED_FONT_COLOR
    else
        return NORMAL_FONT_COLOR        
    end
end

local function formatMemUsage(size)
    if size <= 0 then
        return ""
    elseif size > 1000 then
        size = size / 1000
        return format("%.2f MB", size)
    else
        return format("%.2f KB", size)
    end
end

local function getAddonDeps(deps)
    if not deps or #deps <= 0 then
        return L["addon_detail_no_dependency"]
    else
        return table.concat(deps, "\n")
    end
end

local function syncFavoriteStatus(button, isFavorite)
    local tex = "Interface\\Addons\\ImprovedAddonList\\Media\\" .. (isFavorite and "favorite" or "unfavorite")
    button:SetNormalTexture(tex)
    button:SetHighlightTexture(tex, "ADD")
    button:GetHighlightTexture():SetAlpha(0.2)
    button.tooltipText = isFavorite and BATTLE_PET_UNFAVORITE or BATTLE_PET_FAVORITE
end

-- 刷新插件详情
function Addon:RefreshAddonDetail()
    self:ShowAddonDetail(self:CurrentFocusAddonName())
end

-- 显示插件详情
function Addon:ShowAddonDetail(addonName)
    local addonDetailFrame = self:GetAddonDetailContainer()
    local addonInfo = self:GetAddonInfoByName(addonName)
    self.FocusAddonInfo = addonInfo

    addonDetailFrame.Name:SetText(addonInfo.Name)
    addonDetailFrame.Title:SetText(addonInfo.Title)
    addonDetailFrame.Remark:SetText(addonInfo.Remark)
    addonDetailFrame.Notes:SetText(addonInfo.Notes)
    addonDetailFrame.Author:SetText(addonInfo.Author)
    addonDetailFrame.Version:SetText(getAddonVersion(addonInfo.Version))
    addonDetailFrame.LoadOnDemand:SetText(addonInfo.LoadOnDemand and L["true"] or L["false"])

    addonDetailFrame.Dependencies:SetText(getAddonDeps(addonInfo.Deps))
    addonDetailFrame.OptionalDeps:SetText(table.concat(addonInfo.OptionalDeps, "\n"))

    addonDetailFrame.LoadStatus:SetText(addonInfo.Loaded and L["addon_detail_loaded"] or L["addon_detail_unload"])
    addonDetailFrame.LoadStatus:SetTextColor(getStatusColor(addonInfo.Loaded):GetRGB())
    addonDetailFrame.UnloadReason:SetShown(not addonInfo.Loaded)
    addonDetailFrame.UnloadReason:SetText(addonInfo.UnloadableReason)
    addonDetailFrame.EnableStatus:SetText(addonInfo.Enabled and L["addon_detail_enabled"] or L["addon_detail_disabled"])
    addonDetailFrame.EnableStatus:SetTextColor(getStatusColor(addonInfo.Enabled):GetRGB())

    UpdateAddOnMemoryUsage()
    addonDetailFrame.MemoryUsage:SetText(formatMemUsage(GetAddOnMemoryUsage(addonInfo.Index)))

    self:UpdateAddonDetailFramesPosition()
    
    local addonDetail = self:GetAddonDetail()
    
    -- 启用/禁用按钮
    local enableButton = addonDetail.EnableButton
    if self:IsAddonShouldEnableAlways(addonInfo.Name) then
        enableButton:Hide()
    else
        enableButton:Show()
        enableButton:SetText(WrapTextInColor(addonInfo.Enabled and L["disable_addon"] or L["enable_addon"], GetEnableButtonColor(addonInfo.Enabled)))
    end
    -- 加载按钮
    addonDetail.LoadButton:SetShown(self:CanAddonLoadOnDemand(addonInfo.Name))
    -- 收藏按钮
    syncFavoriteStatus(addonDetail.FavoriteButton, addonInfo.IsFavorite)
end

-- 当前聚焦的插件
function Addon:CurrentFocusAddonName()
    return self.FocusAddonInfo and self.FocusAddonInfo.Name
end

function Addon:CurrentFocusAddonInfo()
    return self.FocusAddonInfo
end