local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 玩家名称/服务器
local function PlayerNamePatternToSettingsItem(playerNamePattern)
    local playerName = playerNamePattern.PlayerName
    if not playerName or playerName == "" then
        playerName = L["addon_set_settings_condition_name_and_realm_any"]
    end
    
    local server = playerNamePattern.Server
    if not server or server == "" then
        server = L["addon_set_settings_condition_name_and_realm_any"]
    end
    
    return {
        Title = playerNamePattern.Pattern,
        Value = playerNamePattern.Pattern,
        Type = "dynamicEditBoxItem",
        OnEnter = function(self, frame)
            GameTooltip:SetOwner(frame)
            GameTooltip:AddLine(L["addon_set_settings_condition_name_and_realm"], 1, 1, 1)
            GameTooltip:AddDoubleLine(L["addon_set_settings_condition_name_and_realm_name_tooltip"], playerName, nil, nil, nil, 1, 1, 1)
            GameTooltip:AddDoubleLine(L["addon_set_settings_condition_name_and_realm_realm_tooltip"], server, nil, nil, nil, 1, 1, 1)
            GameTooltip:Show()
        end
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

-- 专精职责
local SPECIALIZATION_ROLES = { 
    "TANK", "DAMAGER", "HEALER", 
    ["TANK"] = INLINE_TANK_ICON .. " " .. TANK,
    ["DAMAGER"] = INLINE_DAMAGER_ICON .. " " .. DAMAGER,
    ["HEALER"] = INLINE_HEALER_ICON .. " " .. HEALER
}

local function GetAddonSetSpecializationRoleConditionsSettingInfo(addonSetName)
    local specializationRoles = Addon:GetAddonSetSpecializationRoleConditionsByName(addonSetName)
    if not specializationRoles then
        return
    end

    local settings = {}
    for _, role in ipairs(SPECIALIZATION_ROLES) do
        local setting = {
            Title = SPECIALIZATION_ROLES[role],
            Value = role,
            Type = "multiChoiceItem",
            Checked = specializationRoles[role]
        }

        tinsert(settings, setting)
    end

    return settings
end

-- 专精
local SPECIALIZATIONS = {}

-- copied from WeakAuras
do
    for classId = 1, GetNumClasses() do
        SPECIALIZATIONS[classId] = {}

        local className, classFile = GetClassInfo(classId)
        if classFile then
           for i = 1, GetNumSpecializationsForClassID(classId) do
                local specId, specName, _, icon = GetSpecializationInfoForClassID(classId, i)
                if specName then
                    local color = RAID_CLASS_COLORS[classFile]
                    local title = CreateAtlasMarkup(GetClassAtlas(classFile)) .. "|T"..(icon or "error")..":0|t "..(WrapTextInColor(specName, color) or "error")
                    SPECIALIZATIONS[classId][i] = { SpecId = specId, Title = title }
                end
           end 
        end
    end
end

local function GetAddonSetSpecializationConditionsSettingInfo(addonSetName)
    local specializations = Addon:GetAddonSetSpecializationConditionsByName(addonSetName)
    if not specializations then
        return
    end

    local settings = {}
    for classId, specs in pairs(SPECIALIZATIONS) do
        for _, specInfo in pairs(specs) do
            local setting = {
                Title = specInfo.Title,
                Value = specInfo.SpecId,
                Type = "multiChoiceItem",
                Checked = specializations[specInfo.SpecId]
            }

            tinsert(settings, setting)
        end
    end

    return settings
end

-- 种族
local RACES = {}

-- copied from WeakAuras
do
    local races = {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = true,
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [22] = true,
        [24] = true,
        [25] = true,
        [26] = true,
        [27] = true,
        [28] = true,
        [29] = true,
        [30] = true,
        [31] = true,
        [32] = true,
        [34] = true,
        [35] = true,
        [36] = true,
        [37] = true,
        [52] = true,
        [70] = true,
    }

    for raceId, enabled in pairs(races) do
        if enabled then
            local raceInfo = C_CreatureInfo.GetRaceInfo(raceId)
            if raceInfo then
                RACES[raceInfo.clientFileString] = raceInfo.raceName
            end
        end
    end
end

local function GetAddonSetRaceConditionsSettingInfo(addonSetName)
    local races = Addon:GetAddonSetRaceConditionsByName(addonSetName)
    if not races then
        return
    end

    local settings = {}
    for raceFileName, raceName in pairs(RACES) do
        local setting = {
            Title = raceName,
            Value = raceFileName,
            Type = "multiChoiceItem",
            Checked = races[raceFileName]
        }
        tinsert(settings, setting)
    end

    return settings
end

-- 副本类型
local INSTANCE_TYPES = {
    ["none"] = L["addon_set_settings_condition_instance_type_none"],
    ["pvp"] = L["addon_set_settings_condition_instance_type_pvp"],
    ["arena"] = L["addon_set_settings_condition_instance_type_arena"],
    ["scenario"] = L["addon_set_settings_condition_instance_type_scenario"],
    ["raid"] = L["addon_set_settings_condition_instance_type_raid"],
    ["party"] = L["addon_set_settings_condition_instance_type_party"]
}

local function GetAddonSetInstanceTypeConditionsSettingInfo(addonSetName)
    local instanceTypes = Addon:GetAddonSetInstanceTypeConditionsByName(addonSetName)
    if not instanceTypes then
        return
    end

    local settings = {}
    for instanceType, title in pairs(INSTANCE_TYPES) do
        local setting = {
            Title = title,
            Value = instanceType,
            Type = "multiChoiceItem",
            Checked = instanceTypes[instanceType]
        }
        tinsert(settings, setting)
    end

    return settings
end

-- 副本难度类型
-- copied from WeakAuras
local InstanceDifficultyTypes = {
    -- 5人普通
    [1] = L["addon_set_settings_condition_instance_difficulty_type_dungeon_normal"],
    -- 5人英雄
    [2] = L["addon_set_settings_condition_instance_difficulty_type_dungeon_heroic"],
    -- 10人团 普通难度
    [3] = L["addon_set_settings_condition_instance_difficulty_type_legecy_raid_10_normal"],
    -- 25人团 普通难度
    [4] = L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_25_normal"],
    -- 10人团 英雄难度
    [5] = L["addon_set_settings_condition_instance_difficulty_type_legecy_raid_10_heroic"],
    -- 25人团 英雄难度
    [6] = L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_25_heroic"],
    -- 随机团
    [7] = L["addon_set_settings_condition_instance_difficulty_type_legacy_lfr"],
    -- 史诗钥石
    [8] = L["addon_set_settings_condition_instance_difficulty_type_mythic_keystone"],
    -- 40人
    [9] = L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_40"],
    -- 场景战役 英雄
    [11] = L["addon_set_settings_condition_instance_difficulty_type_scenario_heroic"],
    -- 场景战役 普通
    [12] = L["addon_set_settings_condition_instance_difficulty_type_scenario_normal"],
    -- 团队副本 普通
    [14] = L["addon_set_settings_condition_instance_difficulty_type_raid_normal"],
    -- 团队副本 英雄
    [15] = L["addon_set_settings_condition_instance_difficulty_type_raid_heroic"],
    -- 团队副本 史诗
    [16] = L["addon_set_settings_condition_instance_difficulty_type_raid_mythic"],
    -- 随机团
    [17] = L["addon_set_settings_condition_instance_difficulty_type_raid_lfr"],
    -- 地下城 史诗
    [23] = L["addon_set_settings_condition_instance_difficulty_type_dungeon_mythic"],
    -- 地下城 时光漫游
    [24] = L["addon_set_settings_condition_instance_difficulty_type_dungeon_timewalking"],
    -- 团队副本 时光漫游
    [33] = L["addon_set_settings_condition_instance_difficulty_type_raid_timewalking"],
    -- 海岛探险 普通
    [38] = L["addon_set_settings_condition_instance_difficulty_type_island_normal"],
    -- 海岛探险 英雄
    [39] = L["addon_set_settings_condition_instance_difficulty_type_island_heroic"],
    -- 海岛探险 史诗
    [40] = L["addon_set_settings_condition_instance_difficulty_type_island_mythic"],
    -- 海岛探险 PVP
    [45] = L["addon_set_settings_condition_instance_difficulty_type_island_pvp"],
    -- 战争前线 普通
    [147] = L["addon_set_settings_condition_instance_difficulty_type_warfront_normal"],
    -- 战争前线 英雄
    [149] = L["addon_set_settings_condition_instance_difficulty_type_warfront_heroic"],
    -- 恩佐斯的幻象
    [152] = GetDifficultyInfo(152),
    -- 托加斯特
    [167] = GetDifficultyInfo(167),
    -- 晋升之路：勇气
    [168] = GetDifficultyInfo(168),
    -- 晋升之路：忠诚
    [169] = GetDifficultyInfo(169),
    -- 晋升之路：智慧
    [170] = GetDifficultyInfo(170),
    -- 晋升之路：谦逊
    [171] = GetDifficultyInfo(171),
}

local function GetAddonSetInstanceDifficultyTypesSettingInfo(addonSetName)
    local instanceDifficultyTypes = Addon:GetAddonSetInstanceDifficultyTypeConditionsByName(addonSetName)
    if not instanceDifficultyTypes then
        return
    end

    local settings = {}
    for difficulty, title in pairs(InstanceDifficultyTypes) do
        local setting = {
            Title = title,
            Value = difficulty,
            Type = "multiChoiceItem",
            Checked = instanceDifficultyTypes[difficulty]
        }
        tinsert(settings, setting)
    end
    table.sort(settings, function(a, b) return b.Title > a.Title end)

    return settings
end

-- 副本难度
-- 副本难度，难度id和难度的映射
Addon.InstanceDifficultyInfo = {
    -- 5人普通
    [1] = "normal",
    -- 5人英雄
    [2] = "heroic",
    -- 10人团 普通难度
    [3] = "normal",
    -- 25人团 普通难度
    [4] = "normal",
    -- 10人团，英雄难度
    [5] = "heroic",
    -- 25人团，英雄难度
    [6] = "heroic",
    -- 随机团，
    [7] = "lfr",
    -- 史诗钥石
    [8] = "challenge",
    -- 40人团
    [9] = "normal",
    -- 场景战役，英雄
    [11] = "heroic",
    -- 场景战役，普通
    [12] = "normal",
    -- 团队副本，普通
    [14] = "normal",
    -- 团队副本，英雄
    [15] = "heroic",
    -- 团队副本，史诗
    [16] = "mythic",
    -- 随机团，
    [17] = "lfr",
    -- 史诗地下城
    [23] = "mythic",
    -- 时光漫游地下城
    [24] = "timewalking",
    -- 时光漫游团本
    [33] = "timewalking",
    -- 海岛探险，普通
    [38] = "normal",
    -- 海岛探险，英雄
    [39] = "heroic",
    -- 海岛探险，史诗
    [40] = "mythic",
    -- 战争前线，普通
    [147] = "normal",
    -- 战争前线，英雄
    [149] = "heroic"
}

local InstanceDifficulties = {
    none = NONE,
    normal = PLAYER_DIFFICULTY1,
    heroic = PLAYER_DIFFICULTY2,
    mythic = PLAYER_DIFFICULTY6,
    lfr = PLAYER_DIFFICULTY3,
    challenge = PLAYER_DIFFICULTY5,
    timewalking = PLAYER_DIFFICULTY_TIMEWALKER
}

local function GetAddonSetInstanceDifficultyConditionsSettingInfo(addonSetName)
    local instanceDifficulties = Addon:GetAddonSetInstanceDifficultyConditionsByName(addonSetName)
    if not instanceDifficulties then
        return
    end

    local settings = {}
    for difficulty, title in pairs(InstanceDifficulties) do
        local setting = {
            Title = title,
            Value = difficulty,
            Type = "multiChoiceItem",
            Checked = instanceDifficulties[difficulty]
        }
        tinsert(settings, setting)
    end

    return settings
end

-- 词缀
local AffixsInfo = {}

do
    local Affixs = {
        9, 10,
        3, 124, 134, 135, 136, 124,
        6, 7, 8, 11, 123
    }

    for _, affixId in ipairs(Affixs) do
        local name, description, icon = C_ChallengeMode.GetAffixInfo(affixId)
        AffixsInfo[affixId] = {
            Name = CreateSimpleTextureMarkup(icon, 14, 14) .. " " .. name,
            Description = description,
        }
    end
end

local function GetAddonSetMythicPlusAffixConditionsSettingInfo(addonSetName)
    local mythicPlusAffixs = Addon:GetAddonSetMythicPlusAffixConditionsByName(addonSetName)
    if not mythicPlusAffixs then
        return
    end

    local settings = {}
    for affixId, info in pairs(AffixsInfo) do
        local setting = {
            Title = info.Name,
            Value = affixId,
            Type = "multiChoiceItem",
            Checked = mythicPlusAffixs[affixId],
            Tooltip = info.Description
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
                            local playerNamePattern = Addon:AddPlayerNameConditionToAddonSet(self.Arg1, playerName)
                            if playerNamePattern then
                                return PlayerNamePatternToSettingsItem(playerNamePattern)
                            end
                        end,
                        RemoveItem = function(self, playerName)
                            return Addon:RemovePlayerNameConditionFromAddonSet(self.Arg1, playerName)
                        end
                    },
                    -- 满级
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_max_level"],
                        Event = "AddonSetSettings.Conditions.MaxLevel",
                        Type = "switch",
                        IsEnabled = function(self)
                            return Addon:IsAddonSetMaxLevelEnabledToAddonSet(self.Arg1)
                        end,
                        SetEnabled = function(self, enabled)
                            return Addon:SetMaxLevelConditionEnabledToAddonSet(self.Arg1, enabled)
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
                    },
                    -- 专精
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_specialization"],
                        Event = "AddonSetSettings.Conditions.Specialization",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetSpecializationConditionsSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, specializationId, checked)
                            return Addon:SetSpecializationConditionEnabledToAddonSet(self.Arg1, specializationId, checked)
                        end
                    },
                    -- 专精角色
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_specialization_role"],
                        Event = "AddonSetSettings.Conditions.SpecializationRole",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetSpecializationRoleConditionsSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, role, checked)
                            return Addon:SetSpecializationRoleConditionEnabledToAddonSet(self.Arg1, role, checked)
                        end
                    },
                    -- 玩家种族
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_race"],
                        Event = "AddonSetSettings.Conditions.Races",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetRaceConditionsSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, raceName, checked)
                            return Addon:SetRaceConditionEnabledToAddonSet(self.Arg1, raceName, checked)
                        end
                    },
                    -- 副本类型
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_instance_type"],
                        Event = "AddonSetSettings.Conditions.InstanceTypes",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetInstanceTypeConditionsSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, instanceType, checked)
                            return Addon:SetInstanceTypeConditionEnabledToAddonSet(self.Arg1, instanceType, checked)
                        end
                    },
                    -- 副本难度
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_instance_difficulty"],
                        Event = "AddonSetSettings.Conditions.InstanceDifficulty",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetInstanceDifficultyConditionsSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, difficulty, checked)
                            return Addon:SetInstanceDifficultyConditionEnabledToAddonSet(self.Arg1, difficulty, checked)
                        end
                    },
                    -- 副本难度类型
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_instance_difficulty_type"],
                        Event = "AddonSetSettings.Conditions.InstanceDifficultyType",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetInstanceDifficultyTypesSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, difficulty, checked)
                            return Addon:SetInstanceDifficultyTypeConditionEnabledToAddonSet(self.Arg1, difficulty, checked)
                        end
                    },
                    -- 史诗钥石词缀
                    {
                        Arg1 = addonSetName,
                        Title = L["addon_set_settings_condition_mythic_plus_affix"],
                        Event = "AddonSetSettings.Conditions.MythicPlusAffix",
                        Type = "multiChoice",
                        GetItems = function(self)
                            return GetAddonSetMythicPlusAffixConditionsSettingInfo(self.Arg1)
                        end,
                        OnItemCheckedChange = function(self, affixId, checked)
                            return Addon:SetMythicPlusAffixConditionEnabledToAddonSet(self.Arg1, affixId, checked)
                        end
                    },
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

-- 获取插件集专精职责加载条件
function Addon:GetAddonSetSpecializationRoleConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.SpecializationRoles = conditions.SpecializationRoles or {}

    return conditions.SpecializationRoles
end

-- 设置插件集专精职责是否启用

function Addon:SetSpecializationRoleConditionEnabledToAddonSet(addonSetName, role, enabled)
    local roles = self:GetAddonSetSpecializationRoleConditionsByName(addonSetName)
    if not roles then
        return
    end

    roles[role] = enabled and true or nil
    return true
end

-- 获取插件集玩家种族加载条件
function Addon:GetAddonSetRaceConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.Races = conditions.Races or {}

    return conditions.Races
end

-- 设置插件集玩家种族是否启用
function Addon:SetRaceConditionEnabledToAddonSet(addonSetName, raceName, enabled)
    local races = self:GetAddonSetRaceConditionsByName(addonSetName)
    if not races then
        return
    end

    races[raceName] = enabled and true or nil
    return true
end

-- 获取插件集专精加载条件
function Addon:GetAddonSetSpecializationConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.Specializations = conditions.Specializations or {}

    return conditions.Specializations
end

-- 设置插件集专精是否启用

function Addon:SetSpecializationConditionEnabledToAddonSet(addonSetName, specializationId, enabled)
    local specializations = self:GetAddonSetSpecializationConditionsByName(addonSetName)
    if not specializations then
        return
    end

    specializations[specializationId] = enabled and true or nil
    return true
end

-- 获取插件集是否满级加载
function Addon:IsAddonSetMaxLevelEnabledToAddonSet(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end
    
    return conditions.MaxLevel and true or false
end

-- 设置插件集是否满级加载
function Addon:SetMaxLevelConditionEnabledToAddonSet(addonSetName, enabled)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end 

    conditions.MaxLevel = enabled and true or false
    return true
end

-- 获取插件集副本类型加载条件
function Addon:GetAddonSetInstanceTypeConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.InstanceTypes = conditions.InstanceTypes or {}
    return conditions.InstanceTypes
end

-- 设置插件集副本类型是否启用
function Addon:SetInstanceTypeConditionEnabledToAddonSet(addonSetName, instanceType, enabled)
    local instanceTyps = self:GetAddonSetInstanceTypeConditionsByName(addonSetName)
    if not instanceTyps then
        return
    end

    instanceTyps[instanceType] = enabled and true or nil
    return true
end

-- 获取插件集副本难度加载条件
function Addon:GetAddonSetInstanceDifficultyConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.InstanceDifficulties = conditions.InstanceDifficulties or {}
    return conditions.InstanceDifficulties
end

-- 设置插件集副本难度是否启用
function Addon:SetInstanceDifficultyConditionEnabledToAddonSet(addonSetName, instanceDifficulty, enabled)
    local instanceDifficulties = self:GetAddonSetInstanceDifficultyConditionsByName(addonSetName)
    if not instanceDifficulties then
        return
    end

    instanceDifficulties[instanceDifficulty] = enabled and true or nil
    return true
end

-- 获取插件集副本难度类型加载条件
function Addon:GetAddonSetInstanceDifficultyTypeConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.InstanceDifficultyTypes = conditions.InstanceDifficultyTypes or {}
    return conditions.InstanceDifficultyTypes
end

-- 设置插件集副本难度类型是否启用
function Addon:SetInstanceDifficultyTypeConditionEnabledToAddonSet(addonSetName, instanceDifficultyType, enabled)
    local instanceDifficultyTypes = self:GetAddonSetInstanceDifficultyTypeConditionsByName(addonSetName)
    if not instanceDifficultyTypes then
        return
    end

    instanceDifficultyTypes[instanceDifficultyType] = enabled and true or nil
    return true
end

-- 获取插件集史诗钥石词缀加载条件
function Addon:GetAddonSetMythicPlusAffixConditionsByName(addonSetName)
    local conditions = self:GetAddonSetConditionsByName(addonSetName)
    if not conditions then
        return
    end

    conditions.MythicPlusAffixs = conditions.MythicPlusAffixs or {}
    return conditions.MythicPlusAffixs
end

-- 设置插件集史诗钥石词缀是否启用
function Addon:SetMythicPlusAffixConditionEnabledToAddonSet(addonSetName, affixId, enabled)
    local mythicPlusAffixs = self:GetAddonSetMythicPlusAffixConditionsByName(addonSetName)
    if not mythicPlusAffixs then
        return
    end

    mythicPlusAffixs[affixId] = enabled and true or nil
    return true
end