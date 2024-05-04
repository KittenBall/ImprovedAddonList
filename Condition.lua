local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

local Conditions = {
    -- 名字-服务器
    {
        Title = L["addon_set_settings_condition_name_and_realm"],
        Event = { "PLAYER_LOGIN" },
        Current = function(self)
            return UnitFullName("player")
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetPlayerNameConditions(addonSet, self:Current())
        end
    },
    -- 战争模式
    {
        Title = PVP_LABEL_WAR_MODE,
        Event = { "PLAYER_FLAGS_CHANGED" },
        Current = function(self)
            return C_PvP.IsWarModeDesired()
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetWarModeCondition(addonSet, self:Current())
        end
    },
    -- 阵营
    {
        Title = FACTION,
        Event = { "PLAYER_LOGIN" },
        Current = function(self)
            return UnitFactionGroup("player")
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetFactionCondition(addonSet, self:Current())
        end
    },
    -- 满级
    {
        Title = L["addon_set_settings_condition_max_level"],
        Event = { "PLAYER_LOGIN", "PLAYER_LEVEL_UP" },
        Current = function(self)
            return UnitLevel("player") == GetMaxPlayerLevel()
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetMaxLevelCondition(addonSet, self:Current())
        end
    },
    -- 职业和专精
    {
        Title = L["addon_set_settings_condition_specialization"],
        Event = { "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" },
        Current = function(self)
            local currentSpecIndex = GetSpecialization()
            return currentSpecIndex and GetSpecializationInfo(currentSpecIndex)
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetSpecializationCondition(addonSet, self:Current())
        end
    },
    -- 专精职责
    {
        Title = L["addon_set_settings_condition_specialization_role"],
        Event = { "ACTIVE_PLAYER_SPECIALIZATION_CHANGED" },
        Current = function(self)
            local currentSpecIndex = GetSpecialization()
            if currentSpecIndex then
                local _, _, _, _, role = GetSpecializationInfo(currentSpecIndex)
                return role
            end
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetSpecializationRoleCondition(addonSet, self:Current())
        end
    },
    -- 玩家种族
    {
        Title = L["addon_set_settings_condition_race"],
        Event = { "PLAYER_LOGIN" },
        Current = function(self)
            local _, _, raceId = UnitRace("player")
            if raceId then
                local raceInfo = C_CreatureInfo.GetRaceInfo(raceId)
                if raceInfo then
                    return raceInfo.clientFileString
                end
            end
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetRaceCondition(addonSet, self:Current())
        end
    },
    -- 副本类型
    {
        Title = L["addon_set_settings_condition_instance_type"],
        Event = { "ZONE_CHANGED_NEW_AREA" },
        Current = function(self)
            local _, instanceType = GetInstanceInfo()
            return instanceType
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetInstanceTypeCondition(addonSet, self:Current())
        end
    },
    -- 副本难度
    {
        Title = L["addon_set_settings_condition_instance_difficulty"],
        Event = { "PLAYER_DIFFICULTY_CHANGED", "ZONE_CHANGED_NEW_AREA" },
        Current = function(self)
            local _, _, difficultyId = GetInstanceInfo()
            if difficultyId then
                return Addon.InstanceDifficultyInfo[difficultyId]
            end
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetInstanceDifficultyCondition(addonSet, self:Current())
        end
    },
    -- 副本难度类型
    {
        Title = L["addon_set_settings_condition_instance_difficulty_type"],
        Event = { "PLAYER_DIFFICULTY_CHANGED", "ZONE_CHANGED_NEW_AREA" },
        Current = function(self)
            local _, _, difficultyId = GetInstanceInfo()
            return difficultyId
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetInstanceDifficultyTypeCondition(addonSet, self:Current())
        end
    },
    -- 史诗钥石词缀
    {
        Title = L["addon_set_settings_condition_mythic_plus_affix"],
        Event = { "CHALLENGE_MODE_START", "CHALLENGE_MODE_COMPLETED" },
        Current = function(self)
            local _, affixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
            return affixIDs
        end,
        MetCondition = function(self, addonSet)
            return Addon:IsAddonSetMetMythicPlusAffixCondition(addonSet, self:Current())
        end
    }
}

local function CheckAddonSetCondition()
    local addonSets = Addon:GetAddonSets()
    local metConditionAddonSets = {}

    for _, addonSet in ipairs(addonSets) do
        if addonSet.Enabled then
            local metCondition = true
            
            for _, condition in ipairs(Conditions) do
                if not condition:MetCondition(addonSet) then
                    metCondition = false
                    break
                end
            end

            if metCondition then
                tinsert(metConditionAddonSets, addonSet)
            end
        end
    end

    for _, addonSet in ipairs(metConditionAddonSets) do
        print("满足加载条件的插件集：", addonSet.Name)
    end
end

do
    local function OnEventTrigger(self, event, arg1, arg2)
        if event == "PLAYER_FLAGS_CHANGED" and arg1 ~= "player" then
            return
        end

        if self.debounceJob then
            self.debounceJob:Cancel()
        end
        self.debounceJob = C_Timer.After(1, CheckAddonSetCondition)
    end
    
    local conditionFrame = CreateFrame("Frame")
    conditionFrame:SetScript("OnEvent", OnEventTrigger)

    for _, item in ipairs(Conditions) do
        for _, event in ipairs(item.Event) do
            conditionFrame:RegisterEvent(event)
        end
    end
end