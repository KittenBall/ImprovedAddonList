local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

function Addon:ExportAddonList()
    local locale = GetLocale()
    if locale == "zhCN" then
        self:ExportAddonListWithBBSCode()
    else
        self:ExportAddonListWithMarkDown()
    end
end

-- 导出为论坛代码
function Addon:ExportAddonListWithBBSCode()
    self:CreateExportDialog()
    local text = [====[
[collapse=<time> <title>]
[h]<enabled_addon_title>[/h]
[quote]
[list]
<enabled_addon_list>
[/list]
[/quote]
[h]<disabled_addon_title>[/h]
[quote]
[list]
<disabled_addon_list>
[/list]
[/quote]
[/collapse]
    ]====]

    local enabledData, disabledData = self:GetExportAddonData()
    local itemTemplate = "[*]%s   %s\n"

    local enabledAddonList = ""
    for i = 1, #enabledData do
       local data = enabledData[i]
       local item = format(itemTemplate, format(L["addon_name"], data.Name), format(L["version"], data.Version))
       enabledAddonList = enabledAddonList .. item
    end

    local disabledAddonList = ""
    for i = 1, #disabledData do
        local data = disabledData[i]
        local item = format(itemTemplate, format(L["addon_name"], data.Name), format(L["version"], data.Version))
        disabledAddonList = disabledAddonList .. item
    end

    text = text:gsub("<time>", date("%y-%m-%d %H:%M:%S"))
    text = text:gsub("<title>", L["addon_list"])
    text = text:gsub("<enabled_addon_title>", L["enabled_addons"])
    text = text:gsub("<enabled_addon_list>", enabledAddonList)
    text = text:gsub("<disabled_addon_title>", L["disabled_addons"])
    text = text:gsub("<disabled_addon_list>", disabledAddonList)

    self.ExportDialog:SetText(text)
end

-- 导出为Markdown
function Addon:ExportAddonListWithMarkDown()
    self:CreateExportDialog()
    local text = [====[
#### <time> <title>
##### <enabled_addon_title>
<enabled_addon_list>
##### <disabled_addon_title>
<disabled_addon_list>
    ]====]

    local enabledData, disabledData = self:GetExportAddonData()
    local itemTemplate = "- %s   %s\n"

    local enabledAddonList = ""
    for i = 1, #enabledData do
       local data = enabledData[i]
       local item = format(itemTemplate, format(L["addon_name"], data.Name), format(L["version"], data.Version))
       enabledAddonList = enabledAddonList .. item
    end

    local disabledAddonList = ""
    for i = 1, #disabledData do
        local data = disabledData[i]
        local item = format(itemTemplate, format(L["addon_name"], data.Name), format(L["version"], data.Version))
        disabledAddonList = disabledAddonList .. item
    end

    text = text:gsub("<time>", date("%y-%m-%d %H:%M:%S"))
    text = text:gsub("<title>", L["addon_list"])
    text = text:gsub("<enabled_addon_title>", L["enabled_addons"])
    text = text:gsub("<enabled_addon_list>", enabledAddonList)
    text = text:gsub("<disabled_addon_title>", L["disabled_addons"])
    text = text:gsub("<disabled_addon_list>", disabledAddonList)

    self.ExportDialog:SetText(text)
end

function Addon:CreateExportDialog()
    if not self.ExportDialog then
        local exportDialog = CreateFrame("Frame", nil, AddonList, "ButtonFrameTemplate")
        exportDialog:SetAllPoints()
        exportDialog:SetFrameStrata("DIALOG")
        exportDialog:EnableMouse()
        exportDialog.TitleText:SetText(L["export_title"])
        exportDialog.Inset:ClearAllPoints()
        exportDialog.Inset:SetPoint("TOPLEFT", 6, -28)
        exportDialog.Inset:SetPoint("BOTTOMRIGHT", -6, 10)
        ButtonFrameTemplate_HidePortrait(exportDialog)

        function exportDialog:SetText(text)
            self.EditBox:SetText(text)
        end

        local scrollFrame = CreateFrame("ScrollFrame", nil, exportDialog)
        scrollFrame:SetAllPoints(exportDialog.Inset)
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetPoint("TOPLEFT")
        scrollChild:SetSize(1, 1)
        scrollFrame:SetScrollChild(scrollChild)
        scrollFrame:SetScript("OnMouseWheel", function(v, delta)
            local scroll = -20 * delta + v:GetVerticalScroll()
            if scroll < 0 then
                scroll = 0
            elseif scroll > v:GetVerticalScrollRange() then
                scroll = v:GetVerticalScrollRange()
            end

            v:SetVerticalScroll(scroll)
        end)

        local editBox = CreateFrame("EditBox", nil, scrollChild)
        editBox:SetAutoFocus(false)
        editBox:SetMultiLine(true)
        editBox:SetPoint("TOPLEFT")
        editBox:SetFontObject(GameFontWhite)
        editBox:SetWidth(scrollFrame:GetWidth())
        editBox:SetJustifyV("TOP")
        editBox:SetTextInsets(6, 6, 6, 6)
        editBox:SetScript("OnEscapePressed", function(v) v:ClearFocus() end)
        exportDialog.EditBox = editBox

        self.ExportDialog = exportDialog
    end
    self.ExportDialog:Show()
end

function Addon:GetExportAddonData()
    local enabledData = {}
    local disabledData = {}
    for i = 1, GetNumAddOns() do
        local name, _, _, loadable = GetAddOnInfo(i)
        local version = GetAddOnMetadata(i, "Version")
        if name then
            local data = { Version = version or "", Name = name or "" }
            if loadable then
                tinsert(enabledData, data)
            else
                tinsert(disabledData, data)
            end
        end
    end
    return enabledData, disabledData
end