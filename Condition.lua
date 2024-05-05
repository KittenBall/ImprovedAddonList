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
            local metConditions = {}
            local metCondition = true
            for _, condition in ipairs(Conditions) do
                -- conditionEmpty true:条件为空 false:条件不为空
                local met, conditionEmpty = condition:MetCondition(addonSet)
                if not met then
                    metCondition = false
                    break
                end
                if not conditionEmpty then
                    tinsert(metConditions, condition.Title)
                end
            end

            if metCondition then
                tinsert(metConditionAddonSets, { AddonSet = addonSet, MetConditions = metConditions })
            end
        end
    end

    -- for _, item in ipairs(metConditionAddonSets) do
    --     print("满足加载条件的插件集：", item.AddonSet.Name, table.concat(item.MetConditions, "，"))
    -- end
    if #metConditionAddonSets > 0 then
        table.sort(metConditionAddonSets, function(a, b) return #a.MetConditions > #b.MetConditions end)
        Addon:ShowAddonSetConditionDialog(metConditionAddonSets)
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

ImprovedAddonListConditionAddonSetItemMixin = {}

local NormalAddonSetBackgroundColor = CreateColor(DISABLED_FONT_COLOR:GetRGB())
NormalAddonSetBackgroundColor.a = 0.33

local CurrentAddonSetBackgroundColor = CreateColor(NORMAL_FONT_COLOR:GetRGB())
CurrentAddonSetBackgroundColor.a = 0.33

function ImprovedAddonListConditionAddonSetItemMixin:Update(data)
    local activeAddonSetName = Addon:GetActiveAddonSetName()
    local name = data.AddonSet.Name
    local backgroundColor = NormalAddonSetBackgroundColor
    if activeAddonSetName == name then
        name = CreateSimpleTextureMarkup("Interface\\AddOns\\ImprovedAddonList\\Media\\location.png", 14, 14) .. " " .. name
        backgroundColor = CurrentAddonSetBackgroundColor
    end
    self.Label:SetText(name)
    self.Background:SetColorTexture(backgroundColor:GetRGBA())
end

function ImprovedAddonListConditionAddonSetItemMixin:OnEnter()
    local item = self:GetElementData()
    local addonSet = item.AddonSet
    if not addonSet or not addonSet.Addons then
        return
    end

    local addons = {}
    local addonInfos = Addon:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        local addonName = addonInfo.Name
        if not Addon:IsAddonManager(addonName) and addonSet.Addons[addonName] then
            tinsert(addons, { Name = addonName })
        end
    end

    local conditions = item.MetConditions and table.concat(item.MetConditions, "\n")
    if conditions == nil or conditions == "" then
        conditions = WrapTextInColor(L["addon_set_condition_met_none"], NORMAL_FONT_COLOR)
    end

    local addonListTooltipInfo = {
        Addons = addons,
        Label = L["addon_set_condition_tooltip_label"]:format(WrapTextInColor(addonSet.Name, NORMAL_FONT_COLOR), conditions)
    }
    Addon:ShowAddonListTooltips(self, addonListTooltipInfo)
end

function ImprovedAddonListConditionAddonSetItemMixin:OnLeave()
    Addon:HideAddonListTooltips()
end

function ImprovedAddonListConditionAddonSetItemMixin:OnClick()
    local item = self:GetElementData()
    local addonSet = item.AddonSet
    if not addonSet then
        return
    end
    Addon:SetActiveAddonSetName(addonSet.Name)
    Addon:ApplyAddonSetAddons(addonSet.Name)
    ReloadUI()
end

local AddonSetConditionDialogMixin = {}

function AddonSetConditionDialogMixin:Init()
    self:SetWidth(200)
    self:SetHeight(400)
    self:SetFrameStrata("DIALOG")
    self:SetPoint("BOTTOMRIGHT", -180, 30)

    local Label = self:CreateFontString(nil, nil, "GameFontNormalSmall")
    self.Label = Label
    Label:SetWidth(170)
    Label:SetPoint("TOP", 0, -10)
    Label:SetPoint("LEFT")
    Label:SetPoint("RIGHT")
    Label:SetText("检测到当前场景下更适合的插件集，点击应用插件集并重载界面")

    local ScrollBox = CreateFrame("Frame", nil, self, "WowScrollBoxList")
    self.ScrollBox = ScrollBox

    local ScrollBar = CreateFrame("EventFrame", nil, self, "MinimalScrollBar")
    ScrollBar:SetPoint("TOP", Label, "BOTTOM", 0, -10)
    ScrollBar:SetPoint("RIGHT", self, "RIGHT", -10, 0)
    ScrollBar:SetPoint("BOTTOM", 0, 10)

    local anchorsWithScrollBar = {
        CreateAnchor("TOP", ScrollBar, "TOP"),
        CreateAnchor("LEFT", 10, 0),
        CreateAnchor("BOTTOMRIGHT", ScrollBar, "BOTTOMLEFT", -5, 0),
    }
    
    local anchorsWithoutScrollBar = {
        CreateAnchor("TOP", ScrollBar, "TOP"),
        CreateAnchor("LEFT", 10, 0),
        CreateAnchor("BOTTOMRIGHT", -10, 10);
    }

    local ScrollView = CreateScrollBoxListLinearView(1, 1, 1, 1)
    ScrollView:SetElementInitializer("ImprovedAddonListConditionAddonSetItemTemplate", function(button, node) button:Update(node) end)
    ScrollView:SetElementExtentCalculator(function() return 25 end)
    
    ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)
    ScrollUtil.AddManagedScrollBarVisibilityBehavior(ScrollBox, ScrollBar, anchorsWithScrollBar, anchorsWithoutScrollBar)
end

function AddonSetConditionDialogMixin:GetDataProvider()
    self.DataProvider = self.DataProvider or CreateDataProvider()
    return self.DataProvider
end

function AddonSetConditionDialogMixin:RefreshAddonSets(addonSets)
    local dataProvider = self:GetDataProvider()
    dataProvider:Flush()

    if addonSets then
        dataProvider:InsertTable(addonSets)
    end

    self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.DiscardScrollPosition)
end

function AddonSetConditionDialogMixin:Setup(info)
    if self.FadeOutJob then
        self.FadeOutJob:Cancel()
    end

    self:SetScale(Addon:GetUIScale())
    self:RefreshAddonSets(info)
    self:Show()
    
    self.FadeOutJob = C_Timer.After(10, function() self:Hide() end)
end

function Addon:ShowAddonSetConditionDialog(info)
    local addonSetConditionDialog = self.AddonSetConditionDialog
    if not addonSetConditionDialog then
        addonSetConditionDialog = Mixin(CreateFrame("Frame", nil, UIParent), AddonSetConditionDialogMixin)
        -- addonSetConditionDialog = Mixin(self:CreateDialog(nil, UIParent), AddonSetConditionDialogMixin)
        self.AddonSetConditionDialog = addonSetConditionDialog
        addonSetConditionDialog:Init()
    end

    addonSetConditionDialog:Setup(info)
end