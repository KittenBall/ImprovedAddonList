local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_CONFIGURATION_NUM = 25

local INPUT_TYPE_SAVEAS = 1
local INPUT_TYPE_RESET = 2

local inputType

-- Do not change this string, because it is part of key in db
local CHAR_INDICATOR = "|TInterface\\Addons\\ImprovedAddonList\\Media\\char_indicator:18|t"

-- cmd
SlashCmdList["IMPROVED_ADDON_LIST_RESET"] = function(msg)
    msg = strlower(strtrim(msg))
    if msg == "reset" then
         Addon:Reset()
    elseif msg == "reset all" then
        Addon:ResetAll()
    end
end
SLASH_IMPROVED_ADDON_LIST_RESET1 = "/impal"

-- On Addon Load
function Addon:OnLoad()
    ImprovedAddonListDB = ImprovedAddonListDB or {}
    ImprovedAddonListDBPC = ImprovedAddonListDBPC or {}
    ImprovedAddonListDB.Configurations = ImprovedAddonListDB.Configurations or {}
    ImprovedAddonListDBPC.Configurations = ImprovedAddonListDBPC.Configurations or {}
    self:InitUI()
end

-- 重置当前角色配置
function Addon:Reset()
    ImprovedAddonListDBPC.Configurations = {}
    ImprovedAddonListDBPC.Active = nil
    Addon:RefreshDropDownAndList()
end

-- 重置所有角色配置
function Addon:ResetAll()
    ImprovedAddonListDB.Configurations = {}
    ImprovedAddonListDBPC.Configurations = {}
    ImprovedAddonListDBPC.Active = nil
    Addon:RefreshDropDownAndList()
end

local function GetDropDownInfo(name)
    local info = UIDropDownMenu_CreateInfo()
    info.text = name
    info.arg1 = name
    info.checked = ImprovedAddonListDBPC.Active and ImprovedAddonListDBPC.Active == name
    info.func = Addon.OnConfigurationSelected
    return info
end

-- 下拉菜单初始化
function Addon.OnDropDownMenuInitialize(dropDown, level, menuList)
    local configurations = Addon:GetConfigurations()
    for _, name in ipairs(configurations) do
        UIDropDownMenu_AddButton(GetDropDownInfo(name), level)
    end
end

-- 选择配置
function Addon.OnConfigurationSelected(_, configurationName)
    local addons = Addon:GetConfiguration(configurationName)
    if not addons then return end

    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        if tContains(addons, name) then
            EnableAddOn(name)
        else
            DisableAddOn(name)
        end
    end

    ImprovedAddonListDBPC.Active = configurationName
    CloseDropDownMenus()
    Addon:RefreshDropDownAndList()
end

-- 初始化UI
function Addon:InitUI()
    ImprovedAddonListSaveButton:SetScript("OnClick", self.OnSaveButtonClick)
    ImprovedAddonListSaveButton.tooltipText = L["save"]
    ImprovedAddonListSaveAsButton:SetScript("OnClick", self.SaveAsConfiguration)
    ImprovedAddonListSaveAsButton.tooltipText = L["save_as"]
    ImprovedAddonListDeleteButton:SetScript("OnClick", self.DeleteConfiguration)
    ImprovedAddonListDeleteButton.tooltipText = L["delete"]
    ImprovedAddonListTipsButton.tooltipText = L["tips"]
    ImprovedAddonListTipsButton:SetScript("OnDoubleClick", self.OnTipsButtonClick)

    ImprovedAddonListInputDialog.TitleText:SetText(L["input_dialog_title"])
    ImprovedAddonListInputDialog.OkayButton:SetScript("OnClick", Addon.OnInputDialogConfirm)
    ImprovedAddonListInputDialog.SaveToGlobal.Text:SetText(L["save_to_global"])
    ImprovedAddonListInputDialog.SaveToGlobal.tooltipText = L["save_to_global_tips"]

    self:RefreshDropDownAndList()
end

-- 刷新下拉菜单和列表
function Addon:RefreshDropDownAndList()
    UIDropDownMenu_Initialize(ImprovedAddonListDropDown, Addon.OnDropDownMenuInitialize)
    UIDropDownMenu_SetText(ImprovedAddonListDropDown, ImprovedAddonListDBPC.Active)
    AddonList_Update()
end

-- On AddonList Show
function Addon.OnAddonListShow()
    ImprovedAddonListInputDialog:Hide()
end

-- On AddonList Update
function Addon.OnAddonListUpdate()
    local result = Addon:IsCurrentConfiguration()
    ImprovedAddonListTipsButton:SetShown(result ~=nil and not result)
end

-- 点击保存按钮
function Addon.OnSaveButtonClick(_, button)
    if button == "LeftButton" then
        Addon.SaveConfiguration()
    elseif button == "RightButton" then
        Addon.ResetConfiguration()
    end
end

-- 点击提示按钮
function Addon.OnTipsButtonClick()
    Addon.OnConfigurationSelected(nil, ImprovedAddonListDBPC.Active)
end

-- 保存配置
function Addon.SaveConfiguration()
    if not ImprovedAddonListDBPC.Active then
        Addon:ShowError(L["save_error"])
        return
    end
    local enableMe = GetAddOnEnableState(nil, addonName) > 0
    if not enableMe then
        Addon:ShowError(L["disable_me_tips"])
    end
    if Addon:IsConfigurationGlobal() then
        ImprovedAddonListDB.Configurations[ImprovedAddonListDBPC.Active] = Addon:GetEnabledAddons()
    else
        ImprovedAddonListDBPC.Configurations[ImprovedAddonListDBPC.Active] = Addon:GetEnabledAddons()
    end
    Addon:RefreshDropDownAndList()
    Addon:ShowMessage(L["save_success"])
end

--- 重设配置
function Addon.ResetConfiguration()
    if not ImprovedAddonListDBPC.Active then
        Addon:ShowError(L["reset_error"])
        return
    end
    inputType = INPUT_TYPE_RESET
    ImprovedAddonListInputDialog:SetShown(not ImprovedAddonListInputDialog:IsShown())
    ImprovedAddonListInputDialog.EditBox:SetText(ImprovedAddonListDBPC.Active:gsub(CHAR_INDICATOR, ""))
    ImprovedAddonListInputDialog.SaveToGlobal:SetChecked(Addon:IsConfigurationGlobal())
end

-- 另存为配置
function Addon.SaveAsConfiguration()
    if Addon:GetConfigurationsSize() >= MAX_CONFIGURATION_NUM then
        Addon:ShowError(L["max_configuration_num_limit"])
        return
    end
    local enableMe = GetAddOnEnableState(nil, addonName) > 0
    if not enableMe then
        Addon:ShowError(L["disable_me_tips"])
    end
    inputType = INPUT_TYPE_SAVEAS
    ImprovedAddonListInputDialog:SetShown(not ImprovedAddonListInputDialog:IsShown())
    ImprovedAddonListInputDialog.EditBox:SetText("")
end

-- 删除配置
function Addon.DeleteConfiguration()
    if not ImprovedAddonListDBPC.Active then
        Addon:ShowError(L["delete_error"])
        return
    end
    StaticPopupDialogs["DELETE_IMPROVED_ADDON_LIST_CONFIGURATION_CONFIRM"] = {
        text = string.format(L["delete_confirm"], ImprovedAddonListDBPC.Active),
        button1 = OKAY,
        button2 = CANCEL,
        OnAccept = function()
            -- 两个都删，因为角色配置的name前面一定会有角色图片
            --所以全部配置和角色配置的名字一定不一样，不会删错，无需判断删的是哪个配置
            ImprovedAddonListDB.Configurations[ImprovedAddonListDBPC.Active] = nil
            ImprovedAddonListDBPC.Configurations[ImprovedAddonListDBPC.Active] = nil
            ImprovedAddonListDBPC.Active = nil
            Addon:RefreshDropDownAndList()
        end,
        hideOnEscape = true
    }
    StaticPopup_Show("DELETE_IMPROVED_ADDON_LIST_CONFIGURATION_CONFIRM")
end

-- 输入窗确认按钮
function Addon.OnInputDialogConfirm()
    local text = ImprovedAddonListInputDialog.EditBox:GetText()
    if text == nil or strlen(text) == 0 then
        Addon:ShowError(L["error_input_empty"])
        return
    end

    local saveToGlobal = ImprovedAddonListInputDialog.SaveToGlobal:GetChecked()
    if not saveToGlobal then
        text = CHAR_INDICATOR..text
    end

    if Addon:CheckDistinct(text) then
        Addon:ShowError(L["error_input_distinct"])
        return
    end

    local db = saveToGlobal and ImprovedAddonListDB or ImprovedAddonListDBPC
    local anotherDb = saveToGlobal and ImprovedAddonListDBPC or ImprovedAddonListDB

    -- 另存为
    if inputType == INPUT_TYPE_SAVEAS  then
        db.Configurations[text] = Addon:GetEnabledAddons()
        Addon.OnConfigurationSelected(nil, text)
    -- 重新设定
    elseif inputType == INPUT_TYPE_RESET then
        db.Configurations[text] = Addon:GetEnabledAddons()
        anotherDb.Configurations[text] = nil
        if ImprovedAddonListDBPC.Active then
            db.Configurations[ImprovedAddonListDBPC.Active] = nil
            anotherDb.Configurations[ImprovedAddonListDBPC.Active] = nil
        end
        Addon.OnConfigurationSelected(nil, text)
    end
    ImprovedAddonListInputDialog:Hide()
end

-- 检查是否重复命名
function Addon:CheckDistinct(name)
    return ImprovedAddonListDBPC.Configurations[name] ~= nil or ImprovedAddonListDB.Configurations[name] ~= nil
end

-- 当前配置是否为角色通用配置
function Addon:IsConfigurationGlobal()
    if not ImprovedAddonListDBPC.Active then return end
    return ImprovedAddonListDB.Configurations[ImprovedAddonListDBPC.Active] ~= nil
end

-- 获取启用插件列表
function Addon:GetEnabledAddons()
    local addons = {}
    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        local enabledState = GetAddOnEnableState(nil, i)
        if enabledState > 0 then
            tinsert(addons, name)
        end
    end
    return addons
end

-- 获取所有插件列表
function Addon:GetAllAddons()
    local addons = {}
    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        tinsert(addons, name)
    end
    return addons
end

-- 当前启用插件是否与当前配置相同
function Addon:IsCurrentConfiguration()
    if not ImprovedAddonListDBPC.Active then return end
    local currentEnabledAddons = self:GetEnabledAddons()
    local configurationAddons = self:GetConfiguration(ImprovedAddonListDBPC.Active)

    -- 这个判断没必要，以防万一
    if not configurationAddons then return end

    local currentEnabledAddonsLength = #currentEnabledAddons
    local configurationAddonsLength = #configurationAddons
    if currentEnabledAddonsLength ~= configurationAddonsLength then
        return false
    end

    for _, name in ipairs(configurationAddons) do
        if not tContains(currentEnabledAddons, name) then
            return false
        end
    end

    return true
end

-- 根据配置名获取配置
function Addon:GetConfiguration(name)
    return ImprovedAddonListDBPC.Configurations[name] or ImprovedAddonListDB.Configurations[name]
end

-- 获取所有配置
function Addon:GetConfigurations()
    local configurations = {}
    for name in pairs(ImprovedAddonListDBPC.Configurations) do
        tinsert(configurations, name)
    end
    for name in pairs(ImprovedAddonListDB.Configurations) do
        tinsert(configurations, name)
    end
    return configurations
end

-- 获取配置数量
function Addon:GetConfigurationsSize()
    local count = 0
    for _, _ in pairs(ImprovedAddonListDBPC.Configurations) do
        count = count + 1
    end
    for _, _ in pairs(ImprovedAddonListDB.Configurations) do
        count = count + 1
    end
    return count
end

-- 显示红字错误
function Addon:ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 3)
end

function Addon:ShowMessage(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.82, 0.0, 1, 3)
end

AddonList:HookScript("OnShow", Addon.OnAddonListShow)
hooksecurefunc("AddonList_Update", Addon.OnAddonListUpdate)

Addon.Frame = CreateFrame("Frame")
Addon.Frame:Hide()
Addon.Frame:RegisterEvent("ADDON_LOADED")
Addon.Frame:SetScript("OnEvent", function(self, _, name)
    if name == addonName then
        self:UnregisterEvent("ADDON_LOADED")
        Addon:OnLoad()
    end
end)