local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_CONFIGURATION_NUM = 27

local INPUT_TYPE_SAVEAS = 1
local INPUT_TYPE_RENAME = 2

local inputType

SlashCmdList["IMPROVED_ADDON_LIST_RESET"] = function(msg)
    if msg == "reset" then
         Addon:Reset()
    end
end
SLASH_IMPROVED_ADDON_LIST_RESET1 = "/impal"

-- On Addon Load
function Addon:OnLoad()
    ImprovedAddonListDB = ImprovedAddonListDB or {}
    ImprovedAddonListDB.Configurations = ImprovedAddonListDB.Configurations or {}
    self:InitUI()
end

-- 重置配置
function Addon:Reset()
    ImprovedAddonListDB.Configurations = {}
    ImprovedAddonListDB.Active = nil
    Addon:RefreshDropDownAndList()
end

local function GetDropDownInfo(name)
    local info = UIDropDownMenu_CreateInfo()
    info.text = name
    info.arg1 = name
    info.checked = ImprovedAddonListDB.Active and ImprovedAddonListDB.Active == name
    info.func = Addon.OnConfigurationSelected
    return info
end

-- 下拉菜单初始化
function Addon.OnDropDownMenuInitialize(dropDown, level, menuList)
    local infos = ImprovedAddonListDB.Configurations
    -- 全部启用和全部禁用放最前面
    UIDropDownMenu_AddButton(GetDropDownInfo(ENABLE_ALL_ADDONS), level)
    UIDropDownMenu_AddButton(GetDropDownInfo(DISABLE_ALL_ADDONS), level)
    for name in pairs(infos) do
        if name ~= ENABLE_ALL_ADDONS and name ~= DISABLE_ALL_ADDONS then
            UIDropDownMenu_AddButton(GetDropDownInfo(name), level)
        end
    end
end

-- 选择配置
function Addon.OnConfigurationSelected(_, configurationName)
    local addons = ImprovedAddonListDB.Configurations[configurationName]
    if not addons then return end

    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        if tContains(addons, name) then
            EnableAddOn(name)
        else
            DisableAddOn(name)
        end
    end

    ImprovedAddonListDB.Active = configurationName
    CloseDropDownMenus()
    Addon:RefreshDropDownAndList()
end

-- 初始化UI
function Addon:InitUI()
    ImprovedAddonListSaveButton:SetScript("OnClick", self.SaveConfiguration)
    ImprovedAddonListSaveButton:SetScript("OnDoubleClick", self.RenameConfiguration)
    ImprovedAddonListSaveButton.tooltipText = L["save"]
    ImprovedAddonListSaveAsButton:SetScript("OnClick", self.SaveAsConfiguration)
    ImprovedAddonListSaveAsButton.tooltipText = L["save_as"]
    ImprovedAddonListDeleteButton:SetScript("OnClick", self.DeleteConfiguration)
    ImprovedAddonListDeleteButton.tooltipText = L["delete"]
    ImprovedAddonListTipsButton.tooltipText = L["tips"]
    ImprovedAddonListInputDialog.TitleText:SetText(L["input_configuration_name"])
    ImprovedAddonListInputDialog.OkayButton:SetScript("OnClick", Addon.OnInputDialogConfirm)

    self:RefreshDropDownAndList()
end

-- 刷新下拉菜单和列表
function Addon:RefreshDropDownAndList()
    UIDropDownMenu_Initialize(ImprovedAddonListDropDown, Addon.OnDropDownMenuInitialize)
    UIDropDownMenu_SetText(ImprovedAddonListDropDown, ImprovedAddonListDB.Active)
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

-- 保存配置
function Addon.SaveConfiguration()
    if not ImprovedAddonListDB.Active then
        Addon:ShowError(L["save_error"])
        return
    end
    local enableMe = GetAddOnEnableState(nil, addonName) > 0
    if not enableMe then
        Addon:ShowError(L["disable_me_tips"])
    end
    ImprovedAddonListDB.Configurations[ImprovedAddonListDB.Active] = Addon:GetEnabledAddons()
    Addon:RefreshDropDownAndList()
end

--- 重命名配置
function Addon.RenameConfiguration()
    if not ImprovedAddonListDB.Active then
        Addon:ShowError(L["rename_error"])
        return
    end
    inputType = INPUT_TYPE_RENAME
    ImprovedAddonListInputDialog:SetShown(not ImprovedAddonListInputDialog:IsShown())
    ImprovedAddonListInputDialog.EditBox:SetText(ImprovedAddonListDB.Active)
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
    if not ImprovedAddonListDB.Active then
        Addon:ShowError(L["delete_error"])
        return
    end
    StaticPopupDialogs["DELETE_IMPROVED_ADDON_LIST_CONFIGURATION_CONFIRM"] = {
        text = string.format(L["delete_confirm"], ImprovedAddonListDB.Active),
        button1 = OKAY,
        button2 = CANCEL,
        OnAccept = function()
            ImprovedAddonListDB.Configurations[ImprovedAddonListDB.Active] = nil
            ImprovedAddonListDB.Active = nil
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

    if Addon:CheckDistinct(text) then
        Addon:ShowError(L["error_input_distinct"])
        return
    end

    -- 另存为
    if inputType == INPUT_TYPE_SAVEAS  then
        ImprovedAddonListDB.Configurations[text] = Addon:GetEnabledAddons()
        Addon.OnConfigurationSelected(nil, text)
    -- 重命名
    elseif inputType == INPUT_TYPE_RENAME then
        ImprovedAddonListDB.Configurations[text] = Addon:GetEnabledAddons()
        if ImprovedAddonListDB.Active then
            ImprovedAddonListDB.Configurations[ImprovedAddonListDB.Active] = nil
        end
        Addon.OnConfigurationSelected(nil, text)
    end
    ImprovedAddonListInputDialog:Hide()
end

-- 检查是否重复命名
function Addon:CheckDistinct(name)
    return ImprovedAddonListDB.Configurations[name] ~= nil
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
    if not ImprovedAddonListDB.Active then return end
    local currentEnabledAddons = self:GetEnabledAddons()
    local configurationAddons = ImprovedAddonListDB.Configurations[ImprovedAddonListDB.Active]

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

-- 获取配置数量
function Addon:GetConfigurationsSize()
    local count = 0
    for _, _ in pairs(ImprovedAddonListDB.Configurations) do
        count = count + 1
    end
    return count
end

-- 显示红字错误
function Addon:ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 3)
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