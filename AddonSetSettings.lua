local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local function GetAddonSetPlayerNameConditionsSettingsInfo(addonSetName)
    local playerNams = Addon:GetAddonSetPlayerNameConditionsByName(addonSetName)
    if not playerNams then
        return 
    end

    local settings = {}
    for _, playerName in ipairs(playerNams) do
        local setting = {
            Title = playerName,
            Value = playerName,
            Type = "dynamicEditBoxItem",
        }
        tinsert(settings, setting)
    end

    return settings
end

-- 创建插件集设置信息
local function CreateAddonSetSettingsInfo(addonSetName)
    if not addonSetName then
        return
    end

    return {
        Groups = {
            {
                -- 基础信息
                Title = L["addon_set_settings_group_basic"],
                Items = {
                    -- 名字
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_name"],
                        Event = "AddonSetSettings.AddonSetName",
                        Type = "editBox",
                        Label = addonSetName,
                        MaxLetters = Addon.ADDON_SET_NAME_MAX_LENGTH,
                        MaxLines = 2,
                        GetText = function(self)
                            return self.Arg1
                        end,
                        SetText = function(self, newAddonSetName)
                            if Addon:EditAddonSetName(addonSetName, newAddonSetName) then
                                self.Arg2 = newAddonSetName
                                return true
                            end
                        end
                    },
                    -- 是否启用
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_enabled"],
                        Event = "AddonSetSettings.AddonSetEnabled",
                        Type = "switch",
                        Tooltip= L["addon_set_settings_enabled_tooltip"],
                        IsEnabled = function(self)
                            return Addon:IsAddonSetEnabled(self.Arg1)
                        end,
                        SetEnabled = function(self, enabled)
                            return Addon:SetAddonSetEnabled(self.Arg1, enabled)
                        end
                    }
                }
            },
            {
                -- 载入条件
                Title = L["addon_set_settings_group_load_condition"],
                Items = {
                    -- 玩家名称/服务器
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_name_and_realm"],
                        Event = "AddonSetSettings.Conditions.NameAndRealm",
                        Tooltip = L["addon_set_settings_condition_name_and_realm_tips"],
                        Label = L["addon_set_settings_condition_name_and_realm_tips"],
                        Type = "dynamicEditBox",
                        MaxLines = 2,
                        MaxLetters = 60,
                        GetItems = function(self)
                            return GetAddonSetPlayerNameConditionsSettingsInfo(self.Arg1)
                        end,
                        AddItem = function(self, playerName)
                            if Addon:AddPlayerNameConditionToAddonSet(self.Arg1, playerName) then
                                return { Title = playerName, Value = playerName, Type = "dynamicEditBoxItem" }
                            end
                        end,
                        RemoveItem = function(self, playerName)
                            return Addon:RemovePlayerNameConditionFromAddonSet(self.Arg1, playerName)
                        end
                    }
                }
            }
        }
    }
end

function Addon:GetAddonSetSettingsFrame()
    return self:GetOrCreateUI().AddonSetDialog.SettingsFrame
end

-- 刷新插件集设置信息
function Addon:RefreshAddonSetSettings()
    local settingsFrame = self:GetAddonSetSettingsFrame()
    local focusAddonSetName = self:GetCurrentFocusAddonSetName()
    if not settingsFrame then
        return
    end

    settingsFrame:ShowSettings(CreateAddonSetSettingsInfo(focusAddonSetName))
end

-- 修改插件集名称
-- @param:addonSetName 现在的插件集名称
-- @param:newAddonSetName 新插件集名称
-- @return: true:修改成功
function Addon:EditAddonSetName(addonSetName, newAddonSetName)
    if newAddonSetName == addonSetName then
        return true
    end

    if type(newAddonSetName) ~= "string" or newAddonSetName == "" then
        return
    end
    
    if strlen(newAddonSetName) > self.ADDON_SET_NAME_MAX_LENGTH then
        self:ShowError(L["addon_set_name_error_too_long"])
        return
    end

    local addonSets = self:GetAddonSets()
    for _, addonSet in ipairs(addonSets) do
        if addonSet.Name == newAddonSetName and addonSet.Name ~= addonSetName then
            self:ShowError(L["addon_set_name_error_duplicate"])
            return
        end
    end

    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet then
        self:ShowError(L["addon_set_can_not_find"]:format(WrapTextInColor(addonSetName, NORMAL_FONT_COLOR)))
        return
    end

    addonSet.Name = newAddonSetName

    if self:GetActiveAddonSetName() == addonSetName then
        self:SetActiveAddonSetName(newAddonSetName)
    end

    return true
end

-- 插件集是否启用
function Addon:IsAddonSetEnabled(addonSetName)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet then
        return false
    end

    return addonSet.Enabled
end

-- 设置插件集启用状态
function Addon:SetAddonSetEnabled(addonSetName, enabled)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet then
        return false
    end

    addonSet.Enabled = enabled

    return true
end

-- 根据插件集名称获取插件集加载条件
function Addon:GetAddonSetConditionsByName(addonSetName)
    local addonSet = self:GetAddonSetByName(addonSetName)
    if not addonSet then
        return
    end
    
    addonSet.Conditions = addonSet.Conditions or {}
    
    return addonSet.Conditions
end

-- 根据插件集名称获取插件集角色名加载条件
function Addon:GetAddonSetPlayerNameConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.PlayerNames = conditions.PlayerNames or {}

    return conditions.PlayerNames
end

-- 添加插件集条件：玩家名称
function Addon:AddPlayerNameConditionToAddonSet(addonSetName, playerName)
    if not playerName or type(playerName) ~= "string" then
        return
    end

    local playerNames = self:GetAddonSetPlayerNameConditionsByName(addonSetName)
    if not playerNames then
        return
    end

    playerName = strtrim(playerName)

    if playerName == "" then
        return
    end

    if strsub(playerName, -1) == "-" then
        self:ShowError(L["addon_set_settings_condition_name_and_realm_error_ends_with_dash"]:format(WrapTextInColor(playerName, NORMAL_FONT_COLOR)))
        return
    end

    if tContains(playerNames, playerName) then
        self:ShowError(L["addon_set_settings_condition_name_and_realm_error_duplicate"]:format(WrapTextInColor(playerName, NORMAL_FONT_COLOR)))
        return
    end

    tinsert(playerNames, playerName)
    return true
end

-- 移除插件集条件：玩家名称
function Addon:RemovePlayerNameConditionFromAddonSet(addonSetName, playerName)
    if not playerName or type(playerName) ~= "string" then
        return
    end

    local playerNames = self:GetAddonSetPlayerNameConditionsByName(addonSetName)
    if not playerNames then
        return
    end

    return tDeleteItem(playerNames, playerName)
end