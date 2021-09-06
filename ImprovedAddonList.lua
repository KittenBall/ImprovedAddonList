local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local MAX_CONFIGURATION_NUM = 30

local INPUT_TYPE_SAVEAS = 1
local INPUT_TYPE_RESET = 2

local inputType

-- Do not change this string, because it is part of key in db
local CHAR_INDICATOR = "|TInterface\\Addons\\ImprovedAddonList\\Media\\char_indicator:18|t"
local UNSELECT = "|TInterface\\Addons\\ImprovedAddonList\\Media\\unselect:18|t"..L["unselect_configuration"]

Addon.Frame = CreateFrame("Frame")
Addon.Frame:Hide()
Addon.Frame:RegisterEvent("ADDON_LOADED")
Addon.Frame:SetScript("OnEvent", function (self, event, ...)
    if type(Addon[event]) == "function" then return Addon[event](Addon, ...) end
end)

-- 显示红字错误
function Addon:ShowError(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.0, 0.0, 1, 4)
end

-- 显示黄字消息
function Addon:ShowMessage(text)
    UIErrorsFrame:AddMessage(text, 1.0, 0.82, 0.0, 1, 3)
end

-- 输入备注确认弹窗
StaticPopupDialogs["IMPROVED_ADDON_LIST_REMARK_CONFIRM"] = {
    text = L["remark_confirm"],
    button1 = OKAY,
    button2 = CANCEL,
    OnAccept = function(self, data)
        ImprovedAddonListDB.Remarks[data.addonName] = data.remark
        AddonList_Update()
    end,
    hideOnEscape = true
}

-- 删除备注确认弹窗
StaticPopupDialogs["IMPROVED_ADDON_LIST_REMARK_DELETE_CONFIRM"] = {
    text = L["remark_delete_confirm"],
    button1 = OKAY,
    button2 = CANCEL,
    OnAccept = function(self, data)
        ImprovedAddonListDB.Remarks[data] = nil
        AddonList_Update()
    end,
    hideOnEscape = true
}

-- 删除配置确认弹窗
StaticPopupDialogs["DELETE_IMPROVED_ADDON_LIST_CONFIGURATION_CONFIRM"] = {
    text = L["delete_confirm"],
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
    showAlert = true,
    hideOnEscape = true
}

----------  Cmd   -----------------
SlashCmdList["IMPROVED_ADDON_LIST_RESET"] = function(msg)
    msg = strlower(strtrim(msg))
    if msg == "reset" then
         Addon:Reset()
    elseif msg == "reset all" then
        Addon:ResetAll()
    end
end
SLASH_IMPROVED_ADDON_LIST_RESET1 = "/impal"
-----------------------------------

-- On Addon Load
function Addon:ADDON_LOADED(name)
    if name ~= addonName then return end
    Addon.Frame:UnregisterEvent("ADDON_LOADED")
    self:InitData()
    self:InitUI()
end

-- 重置当前角色配置
function Addon:Reset()
    ImprovedAddonListDBPC = {}
    self:InitData()
    self:RefreshDropDownAndList()
end

-- 重置所有角色配置
function Addon:ResetAll()
    ImprovedAddonListDB = {}
    ImprovedAddonListDBPC = {}
    self:InitData()
    self:RefreshDropDownAndList()
end

-- 初始化数据
function Addon:InitData()
    ImprovedAddonListDB = ImprovedAddonListDB or {}
    ImprovedAddonListDBPC = ImprovedAddonListDBPC or {}
    ImprovedAddonListDB.Configurations = ImprovedAddonListDB.Configurations or {}
    ImprovedAddonListDB.Remarks = ImprovedAddonListDB.Remarks or {}
    ImprovedAddonListDBPC.Configurations = ImprovedAddonListDBPC.Configurations or {}

    -- 初始化的做个检查，如果当前角色的配置被删了，则重置当前选择
    if ImprovedAddonListDBPC.Active and not self:GetConfiguration(ImprovedAddonListDBPC.Active) then
        ImprovedAddonListDBPC.Active = nil
    end
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
    UIDropDownMenu_AddButton(GetDropDownInfo(UNSELECT), level)
end

-- 选择配置
function Addon.OnConfigurationSelected(_, configurationName)
    -- 取消选择
    if configurationName == UNSELECT then
        ImprovedAddonListDBPC.Active = nil
        Addon:RefreshDropDownAndList()
        return
    end
    local configuration = Addon:GetConfiguration(configurationName)
    if not configuration then return end
    
    local addons = configuration.addons
    if not addons then return end

    for i = 1, GetNumAddOns() do
        local name = GetAddOnInfo(i)
        if tIndexOf(addons, name) then
            EnableAddOn(name)
        else
            DisableAddOn(name)
        end
    end

    ImprovedAddonListDBPC.Active = configurationName
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
    ImprovedAddonListRemarkButton.tooltipText = L["remark"]
    ImprovedAddonListRemarkButton:SetScript("OnClick", self.ShowOrHideRemarkButtons)

    ImprovedAddonListInputDialog.ConditionLabel:SetText(L["load_condition_title"])
    ImprovedAddonListInputDialog.ConditionTips:SetText(L["load_condition_tips"])
    ImprovedAddonListInputDialog.OkayButton:SetScript("OnClick", Addon.OnInputDialogConfirm)
    ImprovedAddonListInputDialog.SaveToGlobal.Text:SetText(L["save_to_global"])
    ImprovedAddonListInputDialog.SaveToGlobal.tooltipText = L["save_to_global_tips"]
    ImprovedAddonListInputDialog.EditBoxLabel:SetText(L["input_configuration_name"])
    ImprovedAddonListInputRemarkDialog.TitleText:SetText(L["remark_input_dialog_title"])
    ImprovedAddonListInputRemarkDialog.EditBox:SetScript("OnEnterPressed", Addon.OnInputRemarkConfirm)

    self:InitConditionContent()
    
    UIDropDownMenu_Initialize(ImprovedAddonListDropDown, Addon.OnDropDownMenuInitialize)
    self:RefreshDropDownAndList()
end

-- 刷新下拉菜单和列表
function Addon:RefreshDropDownAndList()
    CloseDropDownMenus()
    UIDropDownMenu_SetText(ImprovedAddonListDropDown, ImprovedAddonListDBPC.Active)
    AddonList_Update()
end

-- On AddonList Show
function Addon.OnAddonListShow()
    ImprovedAddonListInputDialog:Hide()
    ImprovedAddonListInputRemarkDialog:Hide()
    Addon.HideRemarkButtons()
end

-- On AddonList Update
function Addon.OnAddonListUpdate()
    local result = Addon:IsCurrentConfiguration()
    ImprovedAddonListTipsButton:SetShown(result ~=nil and not result)

    -- 设置备注
    if not ImprovedAddonListDB or not ImprovedAddonListDB.Remarks then return end
    for i = 1, MAX_ADDONS_DISPLAYED do
        local entry = _G["AddonListEntry"..i]
        if entry:IsShown() then
            local title = _G["AddonListEntry"..i.."Title"]
            local remark = ImprovedAddonListDB.Remarks[GetAddOnInfo(entry:GetID())]
            if remark and strlen(remark) > 0 then
                title:SetText(remark)
            end
        end
    end
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

    Addon:GetConfiguration(ImprovedAddonListDBPC.Active).addons = Addon:GetEnabledAddons()

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
    Addon:ShowOrHideInputDialog()
end

-- 另存为配置
function Addon.SaveAsConfiguration()
    if Addon:GetConfigurationsSize() >= MAX_CONFIGURATION_NUM then
        Addon:ShowError(L["max_configuration_num_limit"]:format(MAX_CONFIGURATION_NUM))
        return
    end
    local enableMe = GetAddOnEnableState(nil, addonName) > 0
    if not enableMe then
        Addon:ShowError(L["disable_me_tips"])
    end
    inputType = INPUT_TYPE_SAVEAS
    Addon:ShowOrHideInputDialog()
end

-- 删除配置
function Addon.DeleteConfiguration()
    if not ImprovedAddonListDBPC.Active then
        Addon:ShowError(L["delete_error"])
        return
    end
    StaticPopup_Show("DELETE_IMPROVED_ADDON_LIST_CONFIGURATION_CONFIRM", ImprovedAddonListDBPC.Active)
end

-- 显示或隐藏输入弹窗
function Addon:ShowOrHideInputDialog()
    if ImprovedAddonListInputDialog:IsShown() then
        ImprovedAddonListInputDialog:Hide()
    else
        if inputType == INPUT_TYPE_RESET then
            ImprovedAddonListInputDialog.TitleText:SetText(L["save_input_dialog_title"])
            ImprovedAddonListInputDialog.EditBox:SetText(ImprovedAddonListDBPC.Active:gsub(CHAR_INDICATOR, ""))
            ImprovedAddonListInputDialog.SaveToGlobal:SetChecked(Addon:IsConfigurationGlobal())
            self:ResetConditions(self:GetConfiguration(ImprovedAddonListDBPC.Active))
        else
            ImprovedAddonListInputDialog.TitleText:SetText(L["save_as_input_dialog_title"])
            ImprovedAddonListInputDialog.EditBox:SetText("")
            ImprovedAddonListInputDialog.SaveToGlobal:SetChecked(false)
            self:ResetConditions()
        end
        ImprovedAddonListInputDialog:Show()
    end
end

-- 输入窗确认按钮
function Addon.OnInputDialogConfirm()
    local text = strtrim(ImprovedAddonListInputDialog.EditBox:GetText() or "")
    if strlen(text) == 0 then
        Addon:ShowError(L["error_input_empty"])
        return
    end

    local saveToGlobal = ImprovedAddonListInputDialog.SaveToGlobal:GetChecked()

    if Addon:MustbeSaveToGlobal() and not saveToGlobal then
        Addon:ShowError(L["error_must_save_to_global"])
        return
    end

    if not saveToGlobal then
        text = CHAR_INDICATOR..text
    end

    -- 是否需要检查重名
    local checkDistinct = false
    if inputType == INPUT_TYPE_SAVEAS then
        checkDistinct = true
    elseif inputType == INPUT_TYPE_RESET then
        if Addon:IsConfigurationGlobal() ~= saveToGlobal then
            checkDistinct = true
        end
    end

    if checkDistinct and Addon:CheckDistinct(text) then
        Addon:ShowError(L["error_input_distinct"])
        return
    end

    local db = saveToGlobal and ImprovedAddonListDB or ImprovedAddonListDBPC
    local anotherDb = saveToGlobal and ImprovedAddonListDBPC or ImprovedAddonListDB

    -- 另存为
    if inputType == INPUT_TYPE_SAVEAS  then
        db.Configurations[text] = Addon:GetConfigurationWithConditions()
        Addon.OnConfigurationSelected(nil, text)
    -- 重新设定
    elseif inputType == INPUT_TYPE_RESET then
        if ImprovedAddonListDBPC.Active then
            db.Configurations[ImprovedAddonListDBPC.Active] = nil
            anotherDb.Configurations[ImprovedAddonListDBPC.Active] = nil
        end
        db.Configurations[text] = Addon:GetConfigurationWithConditions()
        anotherDb.Configurations[text] = nil
        Addon.OnConfigurationSelected(nil, text)
    end
    ImprovedAddonListInputDialog:Hide()
end

-- 显示或隐藏备注按钮
function Addon.ShowOrHideRemarkButtons()
    if not AddonList.CreateImpalRemarkButtons then
        for i = 1, MAX_ADDONS_DISPLAYED do
            local button = _G["AddonListEntry"..i]
            button.RemarkButton = CreateFrame("Button", nil, button, "ImprovedAddonListRemarkButtonTemplate")
            button.RemarkButton:SetPoint("RIGHT", -65, 0)
            button.RemarkButton.tooltipText = L["remark"]
            button.RemarkButton:SetScript("OnClick", Addon.OnRemarkButtonClick)
        end
        AddonList.CreateImpalRemarkButtons = true
    else
        for i = 1, MAX_ADDONS_DISPLAYED do
            local button = _G["AddonListEntry"..i]
            button.RemarkButton:SetShown(not button.RemarkButton:IsShown())
        end
    end
end

-- 隐藏备注按钮
function Addon.HideRemarkButtons()
    if AddonList.CreateImpalRemarkButtons then
        for i = 1, MAX_ADDONS_DISPLAYED do
            local button = _G["AddonListEntry"..i]
            button.RemarkButton:Hide()
        end
    end
end

-- 点击备注按钮
function Addon.OnRemarkButtonClick(remarkButton)
    local parent = remarkButton:GetParent()
    if not ImprovedAddonListInputRemarkDialog:IsShown() then
        local addonName = GetAddOnInfo(parent:GetID())
        -- xml内定义了OnHide时候会清除这个变量
        ImprovedAddonListInputRemarkDialog.addonName = addonName
        ImprovedAddonListInputRemarkDialog:ClearAllPoints()
        ImprovedAddonListInputRemarkDialog:SetPoint("TOP", parent, "BOTTOM", 0, -10)
        ImprovedAddonListInputRemarkDialog.Label:SetText(addonName)
        ImprovedAddonListInputRemarkDialog.EditBox:SetText(ImprovedAddonListDB.Remarks[addonName] or "")
        ImprovedAddonListInputRemarkDialog:Show()
    else
        ImprovedAddonListInputRemarkDialog:Hide()
    end
end

-- 备注输入确认
function Addon.OnInputRemarkConfirm(editBox)
    if not ImprovedAddonListInputRemarkDialog.addonName then return end
    local text = strtrim(editBox:GetText() or "")
    if text ~= ImprovedAddonListDB.Remarks[ImprovedAddonListInputRemarkDialog.addonName] then
        if strlen(text) == 0 then
            StaticPopup_Show("IMPROVED_ADDON_LIST_REMARK_DELETE_CONFIRM", ImprovedAddonListInputRemarkDialog.addonName, "", ImprovedAddonListInputRemarkDialog.addonName)
        else
            StaticPopup_Show("IMPROVED_ADDON_LIST_REMARK_CONFIRM", ImprovedAddonListInputRemarkDialog.addonName, text, {
                addonName = ImprovedAddonListInputRemarkDialog.addonName,
                remark = text
            })
        end
    end
    ImprovedAddonListInputRemarkDialog:Hide()
end

-- 检查是否重复命名
function Addon:CheckDistinct(name)
    return ImprovedAddonListDBPC.Configurations[name] ~= nil or ImprovedAddonListDB.Configurations[name] ~= nil
end

-- 当前配置是否为角色通用配置
function Addon:IsConfigurationGlobal(name)
    name = name or ImprovedAddonListDBPC.Active
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
    if not ImprovedAddonListDBPC.Active then return end
    local currentEnabledAddons = self:GetEnabledAddons()
    local configurationAddons = self:GetConfiguration(ImprovedAddonListDBPC.Active).addons

    -- 这个判断没必要，以防万一
    if not configurationAddons then return end

    local currentEnabledAddonsLength = #currentEnabledAddons
    local configurationAddonsLength = #configurationAddons
    if currentEnabledAddonsLength ~= configurationAddonsLength then
        return false
    end

    for _, name in ipairs(configurationAddons) do
        if not tIndexOf(currentEnabledAddons, name) then
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

AddonList:HookScript("OnShow", Addon.OnAddonListShow)
hooksecurefunc("AddonList_Update", Addon.OnAddonListUpdate)