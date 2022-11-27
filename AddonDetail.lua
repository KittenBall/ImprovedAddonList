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
    local addonDetail = self:GetAddonDetail()

    local categoryOffsetX, categoryOffsetY = 10, -10
    local addonDetailOffsetX, addonDetailFirstOffsetY, addonDetailOffsetY = 15, -10, -8

    local preFrame, usedHeight = nil, 0
    for categoryIndex, category in pairs(ADDON_DETAILS) do
        local categoryFrame = addonDetail[category.Name]
        categoryFrame:ClearAllPoints()
        categoryFrame:SetPoint("TOPLEFT", categoryOffsetX, -usedHeight + categoryOffsetY)
        usedHeight = usedHeight + categoryFrame:GetHeight() - categoryOffsetY

        for detailIndex, detail in pairs(category.Details) do
            local detailLabel = addonDetail[detail.Name .. "Label"]
            local detailBody = addonDetail[detail.Name]
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
    addonDetail:SetHeight(usedHeight + 20)
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
end

local function onLoadButtonLeave(self)
end

function Addon:OnAddonDetailLoaded()
    local addonDetail = self:GetAddonDetail()

    for _, category in pairs(ADDON_DETAILS) do
        local categoryFrame = addonDetail:CreateFontString(nil, nil, "GameFontNormal")
        addonDetail[category.Name] = categoryFrame
        categoryFrame:SetText(category.Label)

        for _, detail in pairs(category.Details) do
            local detailLabel = addonDetail:CreateFontString(nil, nil, "ImprovedAddonListLabelFont")
            addonDetail[detail.Name .. "Label"] = detailLabel
            detailLabel:SetText(detail.Label)

            local detailBody = addonDetail:CreateFontString(nil, nil, "ImprovedAddonListBodyFont")
            addonDetail[detail.Name] = detailBody
            detailBody:SetNonSpaceWrap(true)
            detailBody:SetPoint("TOPLEFT", detailLabel, "TOPRIGHT", 5, 0)
            detailBody:SetPoint("RIGHT", addonDetail, "RIGHT", -10, 0)

            if detail.Color then
                detailBody:SetTextColor(detail.Color:GetRGB())
            end
        end
    end

    local addonDetailContainer = self:GetAddonDetailContainer()
    
    -- 加载按钮
    local loadButton = CreateDetailButton(addonDetailContainer)
    addonDetailContainer.LoadButton = loadButton
    loadButton:SetScript("OnEnter", onLoadButtonEnter)
    loadButton:SetScript("OnLeave", onLoadButtonLeave)
    loadButton:SetMotionScriptsWhileDisabled(true)
    loadButton:SetText(L["load_addon"])
    loadButton:SetPoint("BOTTOMRIGHT", -10, 5)
    loadButton:SetSize(88, 22)

    self:UpdateAddonDetailFramesPosition()
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

-- 显示插件详情
function Addon:ShowAddonDetail(addonInfo)
    local addonDetail = self:GetAddonDetail()
    addonDetail.AddonInfo = addonInfo

    addonDetail.Name:SetText(addonInfo.Name)
    addonDetail.Title:SetText(addonInfo.Title)
    addonDetail.Remark:SetText(self:GetAddonRemark(addonInfo.Name))
    addonDetail.Notes:SetText(addonInfo.Notes)
    addonDetail.Author:SetText(addonInfo.Author)
    addonDetail.Version:SetText(getAddonVersion(addonInfo.Version))
    addonDetail.LoadOnDemand:SetText(addonInfo.LoadOnDemand and L["true"] or L["false"])

    addonDetail.Dependencies:SetText(getAddonDeps(addonInfo.Deps))
    addonDetail.OptionalDeps:SetText(table.concat(addonInfo.OptionalDeps, "\n"))

    addonDetail.LoadStatus:SetText(addonInfo.Loaded and L["addon_detail_loaded"] or L["addon_detail_unload"])
    addonDetail.LoadStatus:SetTextColor(getStatusColor(addonInfo.Loaded):GetRGB())
    addonDetail.UnloadReason:SetText(addonInfo.UnLoadableReason)
    addonDetail.EnableStatus:SetText(addonInfo.Enabled and L["addon_detail_enabled"] or L["addon_detail_disabled"])
    addonDetail.EnableStatus:SetTextColor(getStatusColor(addonInfo.Enabled):GetRGB())

    UpdateAddOnMemoryUsage()
    addonDetail.MemoryUsage:SetText(formatMemUsage(GetAddOnMemoryUsage(addonInfo.Index)))

    self:UpdateAddonDetailFramesPosition()

    -- local addonDetailContainer = self:GetAddonDetailContainer()

    -- @todo 加载按钮启用条件
    -- local loadButton = addonDetailContainer.LoadButton
    -- if addonInfo.Loaded then
    --     loadButton.tooltipText = L["load_addon_unnecessary"]
    --     loadButton:SetEnabled(false)
    -- else
    --     if addonInfo.LoadOnDemand then
    --     else
    --         loadButton.tooltipText = L["load_addon_not_allowed_reason_not_on_demand"]
    --         loadButton:SetEnabled(false)
    --     end
    -- end
end