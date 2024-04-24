local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local function PlayerNamePatternToSettingsItem(playerNamePattern)
    local playerName = playerNamePattern.PlayerName
    if not playerName or playerName == "" then
        playerName = L["addon_set_settings_condition_name_and_realm"]
    end
    
    local server = playerNamePattern.Server
    if not server or server == "" then
        server = L["addon_set_settings_condition_name_and_realm"]
    end
    
    return {
        Title = playerNamePattern.Pattern,
        Value = playerNamePattern.Pattern,
        Type = "dynamicEditBoxItem",
        Tooltip = L["addon_set_settings_condition_name_and_realm_tooltip"]:format(playerName, ser)
    }
end

local function GetAddonSetPlayerNameConditionsSettingsInfo(addonSetName)
    local playerNams = Addon:GetAddonSetPlayerNameConditionsByName(addonSetName)
    if not playerNams then
        return 
    end

    local settings = {}
    for _, playerNamePattern in ipairs(playerNams) do
        tinsert(settings, PlayerNamePatternToSettingsItem(playerNamePattern))
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
                            local playerNamePattern = Addon:AddPlayerNameConditionToAddonSet(self.Arg1, playerName)
                            if playerNamePattern then
                                return PlayerNamePatternToSettingsItem(playerNamePattern)
                            end
                        end,
                        RemoveItem = function(self, playerName)
                            return Addon:RemovePlayerNameConditionFromAddonSet(self.Arg1, playerName)
                        end
                    },
                    -- 战争模式
                    {
                        Arg1= addonSetName,
                        Title = L["addon_set_settings_condition_warmode"],
                        Event = "AddonSetSettings.Conditions.WarMode",
                        Type = "singleChoice",
                        Tooltip = L["addon_set_settings_condition_warmode_tips"],
                        Description = function(self)
                            local warMode = self:GetValue()
                            if warMode == nil then
                                return L["addon_set_settings_condition_warmode_none"]
                            elseif warMode == true then
                                return L["addon_set_settings_condition_warmode_enabled"]
                            else
                                return L["addon_set_settings_condition_warmode_disabled"]
                            end
                        end,
                        GetValue = function(self)
                            return Addon:GetAddonSetWarModeConditionByName(self.Arg1)
                        end,
                        SetValue = function(self, warMode)
                            Addon:SetWarModeConditionToAddonSet(self.Arg1, warMode)
                        end,
                        Choices = {
                            {
                                Text = L["addon_set_settings_condition_warmode_choice_none"],
                                Value = nil
                            },
                            {
                                Text = L["addon_set_settings_condition_warmode_choice_enabled"],
                                Value = true
                            },
                            {
                                Text = L["addon_set_settings_condition_warmode_choice_disabled"],
                                Value = false
                            }
                        }
                    },
                    -- 阵营
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_faction"],
                        Event = "AddonSetSettings.Conditions.Faction",
                        Type = "singleChoice",
                        Tooltip = L["addon_set_settings_condition_faction_tips"],
                        Description = function(self)
                            local faction = self:GetValue()
                            local factionLabel = FACTION_LABELS_FROM_STRING[faction]
                            if not factionLabel then
                                factionLabel = L["addon_set_settings_condition_faction_none"]
                            else
                                local factionGroup = PLAYER_FACTION_GROUP[faction]
                                if factionGroup then
                                    factionLabel = WrapTextInColor(factionLabel, PLAYER_FACTION_COLORS[factionGroup])
                                    factionLabel = CreateSimpleTextureMarkup(FACTION_LOGO_TEXTURES[factionGroup], 14, 14) .. " " .. factionLabel
                                end
                            end
                            return factionLabel
                        end,
                        GetValue = function(self)
                            return Addon:GetAddonSetFactionConditionByName(self.Arg1)
                        end,
                        SetValue = function(self, faction)
                            Addon:SetFactionConditionToAddonSet(self.Arg1, faction)
                        end,
                        Choices = {
                            {
                                Text = L["addon_set_settings_condition_faction_choice_none"],
                                Value = nil
                            },
                            {
                                Text = FACTION_LABELS[0],
                                Value = PLAYER_FACTION_GROUP[0]
                            },
                            {
                                Text = FACTION_LABELS[1],
                                Value = PLAYER_FACTION_GROUP[1]
                            }
                        }
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

    if FindValueInTableIf(playerNames, function(item) return item.Pattern == playerName end) then
        self:ShowError(L["addon_set_settings_condition_name_and_realm_error_duplicate"]:format(WrapTextInColor(playerName, NORMAL_FONT_COLOR)))
        return
    end

    local playerNameLen, preByte, dashIndex = playerName:len(), nil, 0
    for index, byte in ipairs({strbyte(playerName, 1, playerNameLen)}) do
        -- 92:\ 45:-
        if byte == 45 and preByte ~= 92 then
            if dashIndex > 0 then
                self:ShowError(L["addon_set_settings_condition_name_and_realm_error_too_much_dash"]:format(WrapTextInColor(playerName, NORMAL_FONT_COLOR)))
                return
            end
            dashIndex = index
        end

        preByte = byte
    end

    local name, server
    if dashIndex > 0 then
        name = strsub(playerName, 1, dashIndex - 1)
        server = strsub(playerName, dashIndex + 1, playerNameLen)
    else
        name = playerName
    end

    name = name and name:gsub("\\%-", "-") or ""
    name = strtrim(name)
    server = server and server:gsub("\\%-", "-") or ""
    server = strtrim(server)

    if name == "" and server == "" then
        self:ShowError(L["addon_set_settings_condition_name_and_realm_error_empty"])
        return
    end

    local playerNamePattern = { Pattern = playerName, PlayerName = name, Server = server }
    tinsert(playerNames, playerNamePattern)

    return playerNamePattern
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

    local size = #playerNames;
	local index = size;
	while index > 0 do
        local item = playerNames[index] do
            if item and item.Pattern == playerName then
                table.remove(playerNames, index)
            else
                table.remove(playerNames, index)
            end
        end
		index = index - 1;
	end
    return size - #playerNames
end

-- 根据插件集名称获取插件集战争模式加载条件
function Addon:GetAddonSetWarModeConditionByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    return conditions.WarMode
end

-- 设置插件集战争模式加载条件
-- @param warMode: true:在战争模式下加载 false：非战争模式下加载 nil：无所谓
function Addon:SetWarModeConditionToAddonSet(addonSetName, warMode)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.WarMode = warMode
    return true
end

-- 根据插件集名称获取插件集阵营加载条件
function Addon:GetAddonSetFactionConditionByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    return conditions.Faction
end

-- 设置插件集阵营加载条件
-- @param faction: 阵营
function Addon:SetFactionConditionToAddonSet(addonSetName, faction)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.Faction = faction
    return true
end