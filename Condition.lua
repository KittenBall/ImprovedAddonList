local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LCG = LibStub("LibCustomGlow-1.0")

-- 战争模式
local WarModeInfos = {
    {
        text = ERR_PVP_WARMODE_TOGGLE_ON,
        value = 1
    },
    {
        text = ERR_PVP_WARMODE_TOGGLE_OFF,
        value = 2
    }
}

-- 阵营
local factionInfos = {
    {
        text = "|c" .. PLAYER_FACTION_COLORS_HEX[0] .. FACTION_HORDE .. FONT_COLOR_CODE_CLOSE,
        value = "Horde"
    },
    {
        text = "|c" .. PLAYER_FACTION_COLORS_HEX[1] .. FACTION_ALLIANCE .. FONT_COLOR_CODE_CLOSE,
        value = "Alliance"
    }
}

-- 副本类型
local instanceTypeInfos = {
    {
        text = L["instance_type_none"],
        value = "none"
    },
    {
        text = L["instance_type_pvp"],
        value = "pvp"
    },
    {
        text = L["instance_type_arena"],
        value = "arena"
    },
    {
        text = L["instance_type_party"],
        value = "party"
    },
    {
        text = L["instance_type_raid"],
        value = "raid"
    },
    {
        text = L["instance_type_scenario"],
        value = "scenario"
    },
}

Addon.Frame:RegisterEvent("PLAYER_LOGIN")
Addon.Frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
Addon.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Addon.Frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

function Addon:PLAYER_LOGIN()
    -- 当前角色存入角色列表
    ImprovedAddonListDB.Players = ImprovedAddonListDB.Players or {}
    local playerName, realmName = UnitFullName("player")
    local _, className = UnitClass("player")
    ImprovedAddonListDB.Players[playerName .. "-" .. realmName] = className

    ImprovedAddonListInputDialog.ShowStaticPop.Text:SetText(L["show_static_pop"])
    ImprovedAddonListInputDialog.ShowStaticPop.tooltipText = L["show_static_pop_tips"]
    ImprovedAddonListSwitchConfigurationPromptDialog.TitleText:SetText(L["configuration_switch_prompt_dialog_title"])

    ImprovedAddonListConditionContent.PlayerNameItem:SetItems(L["condition_player_name_label"], self:GetPlayerInfos())
end

function Addon:PLAYER_ENTERING_WORLD()
    self:CheckConfigurationCondition()
end

function Addon:PLAYER_SPECIALIZATION_CHANGED(unit)
    if unit == "player" then
        self:CheckConfigurationCondition()
    end
end

-- 战争模式切换
function Addon:PLAYER_FLAGS_CHANGED()
    self:CheckConfigurationCondition()
end

-- 初始化条件内容
function Addon:InitConditionContent()
    ImprovedAddonListConditionContent.WarModeItem:SetItems(PVP_LABEL_WAR_MODE, WarModeInfos)
    ImprovedAddonListConditionContent.FactionItem:SetItems(FACTION, factionInfos)
    ImprovedAddonListConditionContent.InstanceTypeItem:SetItems(L["condition_instance_type_label"], instanceTypeInfos)
    ImprovedAddonListConditionContent.ClassAndSpecItem:SetItems(L["condition_class_and_spec_label"], self:GetClassAndSpecInfos())
end

-- 获取角色信息
function Addon:GetPlayerInfos()
    local infos = {}
    for name, class in pairs(ImprovedAddonListDB.Players) do
        local info = {}
        info.text = "|c" .. RAID_CLASS_COLORS[class].colorStr .. name .. FONT_COLOR_CODE_CLOSE
        info.value = name
        tinsert(infos, info)
    end
    return infos
end

-- 获取职业和专精信息
function Addon:GetClassAndSpecInfos()
    local infos = {}
    for i = 1, GetNumClasses() do
        local classLocalizationName, className, classId =  GetClassInfo(i)
        local classColor = "|c" .. RAID_CLASS_COLORS[className].colorStr
        for j = 1, GetNumSpecializationsForClassID(classId) do
            local info = {}
            local id, name, _, icon = GetSpecializationInfoForClassID(i, j) 
            info.text =  ("|T%s:14|t%s%s %s%s"):format(icon, classColor, name, classLocalizationName, FONT_COLOR_CODE_CLOSE)
            info.value = id
            tinsert(infos, info)
        end
    end
    return infos
end

-- 是否必须全角色通用
function Addon:MustbeSaveToGlobal()
    --  选择了阵营
    local factionInfos = ImprovedAddonListConditionContent.FactionItem:GetSelectedItems()
    if factionInfos then
        if #factionInfos > 1 then
            return true
        elseif #factionInfos == 1 then
            local faction = UnitFactionGroup("player")
            -- 只选中了一个阵营且不为当前角色阵营，则必须全角色通用
            if faction ~= factionInfos[1].value then
                return true
            end
        end
    end

    -- 选择了角色名
    local playerNames = ImprovedAddonListConditionContent.PlayerNameItem:GetSelectedItems()
    if playerNames then
        if #playerNames > 1 then
            return true
        elseif #playerNames == 1 then
            -- 只选中了一个角色且不为当前角色，则必须全角色通用
            local playerName, realmName = UnitFullName("player")
            if playerNames[1].value ~= playerName .. "-" .. realmName then
                return true
            end 
        end
    end

    -- 选择了职业和专精
    local classAndSpecInfos = ImprovedAddonListConditionContent.ClassAndSpecItem:GetSelectedItems()
    if not classAndSpecInfos then return end
    local currentClassSpecs = {}
    local _, _, classId = UnitClass("player")
    for i = 1, GetNumSpecializationsForClassID(classId) do
        local id = GetSpecializationInfoForClassID(classId, i)
        tinsert(currentClassSpecs, id)
    end

    for _, info in ipairs(classAndSpecInfos) do
        -- 选择的专精不属于这个职业，则必须全角色通用
        if not tContains(currentClassSpecs, info.value) then
            return true
        end
    end
end

-- 获取带载入条件的配置项
function Addon:GetConfigurationWithConditions()
    local configuration = {}
    configuration.addons = self:GetEnabledAddons()
    
    local conditions = {}
    conditions.players = ImprovedAddonListConditionContent.PlayerNameItem:GetSelectedItems()
    conditions.factions = ImprovedAddonListConditionContent.FactionItem:GetSelectedItems()
    conditions.instanceTypes = ImprovedAddonListConditionContent.InstanceTypeItem:GetSelectedItems()
    conditions.classAndSpecs = ImprovedAddonListConditionContent.ClassAndSpecItem:GetSelectedItems()
    conditions.warModes = ImprovedAddonListConditionContent.WarModeItem:GetSelectedItems()
    configuration.conditions = conditions

    configuration.showStaticPop = ImprovedAddonListInputDialog.ShowStaticPop:GetChecked()
    return configuration
end

-- 重设条件
function Addon:ResetConditions(configuration)
    ImprovedAddonListConditionContent.PlayerNameItem:ResetItems(configuration and configuration.conditions.players)
    ImprovedAddonListConditionContent.FactionItem:ResetItems(configuration and configuration.conditions.factions)
    ImprovedAddonListConditionContent.InstanceTypeItem:ResetItems(configuration and configuration.conditions.instanceTypes)
    ImprovedAddonListConditionContent.ClassAndSpecItem:ResetItems(configuration and configuration.conditions.classAndSpecs)
    ImprovedAddonListConditionContent.WarModeItem:ResetItems(configuration and configuration.conditions.warModes)
    ImprovedAddonListInputDialog.ShowStaticPop:SetChecked(configuration and configuration.showStaticPop)
end

-- 检查角色
 function Addon:CheckPlayersCondition(conditions)
    if conditions == nil or #conditions == 0 then return true end
    local name, realm = UnitFullName("player")
    local playerName = name .. "-" .. realm

    for _, condition in ipairs(conditions) do
        if condition.value == playerName then
            return true
        end
    end
end

-- 检查副本类型
-- @return meetCondition 命中条件
-- @return priority 优先级
function Addon:CheckInstanceTypesCondition(conditions)
    if conditions == nil or #conditions == 0 then return true, 0 end
    local inInstance, instanceType = IsInInstance()

    for _, condition in ipairs(conditions) do
        -- 选中野外时，要判断 inInstance，某些场景instanceType ~= "none" 但 inInstance 为 false，比如要塞
        if (condition.value == "none" and inInstance ~= true) or condition.value == instanceType then
            return true, 1/#conditions
        end
    end
end

-- 检查职业和专精
-- @return meetCondition 命中条件
-- @return priority 优先级
function Addon:CheckClassAndSpecsCondition(conditions)
    if conditions == nil or #conditions == 0 then return true, 0 end
    local specId = GetSpecializationInfo(GetSpecialization())

    for _, condition in ipairs(conditions) do
        if condition.value == specId then
            return true, 1/#conditions
        end
    end
end

-- 检查战争模式
-- @return meetCondition 命中条件
-- @return priority 优先级
function Addon:CheckWarModeCondition(conditions)
    if conditions == nil or #conditions == 0 then return true, 0 end
    local warModeOn = C_PvP.IsWarModeDesired() and 1 or 2

    for _, condition in ipairs(conditions) do
        if condition.value == warModeOn then
            return true, 1/#conditions
        end
    end
end

-- 检查阵营
function Addon:CheckFactionCondition(conditions)
    if conditions == nil or #conditions == 0 then return true end
    local faction = UnitFactionGroup("player")

    for _, condition in ipairs(conditions) do
        if condition.value == faction then
            return true
        end
    end
end


function Addon:IsConfigurationMeetCondition(name)
    local configuration = self:GetConfiguration(name)
    local conditions = configuration.conditions

    if self:CheckPlayersCondition(conditions.players) and self:CheckFactionCondition(conditions.factions) then
        local meetInstance, priorityInstance = self:CheckInstanceTypesCondition(conditions.instanceTypes)
        local meetClassAndSpec, priorityClassAndSpec = self: CheckClassAndSpecsCondition(conditions.classAndSpecs)
        local meetWarMode, priorityWarMode = self:CheckWarModeCondition(conditions.warModes)
        
        if meetInstance and meetClassAndSpec and meetWarMode then
            return true, priorityInstance + priorityClassAndSpec + priorityWarMode + (configuration.showStaticPop and 200 or 0) + (self:IsConfigurationGlobal(name) and 0 or 100)
        end
    end
end

-- 检查满足条件的Configuration
function Addon:CheckConfigurationCondition()
    local configurations = Addon:GetConfigurations()
    if configurations == nil or #configurations == 0 then return end

    local meetConditionConfigurations = {}

    for _, name in ipairs(configurations) do
        if name ~= ImprovedAddonListDBPC.Active then
            local meetCondition, priority = self:IsConfigurationMeetCondition(name)
            if meetCondition then
                tinsert(meetConditionConfigurations, {
                    name = name,
                    priority = priority
                })
            end
        end
    end

    if #meetConditionConfigurations <= 0 then
        return
    end

    local maxPriorityName, maxPriority = nil, -1
    if ImprovedAddonListDBPC.Active then
        local _, currentConfigurationPriority = self:IsConfigurationMeetCondition(ImprovedAddonListDBPC.Active)
        maxPriority = currentConfigurationPriority or -1
    end

    table.sort(meetConditionConfigurations, function(a, b)
        return a.priority > b.priority
    end)

    for _, v in ipairs(meetConditionConfigurations) do
        if v.priority > maxPriority then
            maxPriority = v.priority
            maxPriorityName = v.name
        end
    end
    
    if maxPriorityName then
        self:ShowConfigurationSwitchPrompt(maxPriorityName, meetConditionConfigurations)
    end
end

-- 显示提示
function Addon:ShowConfigurationSwitchPrompt(bestConfigurationName, meetConditionConfigurations)
    local  bestConfiguration = self:GetConfiguration(bestConfigurationName)

    if bestConfiguration.showStaticPop then
        StaticPopupDialogs["IMRPOVED_ADDON_LIST_CONFIGURATION_SWITCH"] = {
            text = L["configuration_switch_text"]:format(bestConfigurationName),
            button1 = OKAY,
            button2 = CANCEL,
            timeout = 20,
            OnAccept = function(self)
                Addon.OnConfigurationSelected(nil, bestConfigurationName)
                ReloadUI()
            end,
            OnUpdate = function(self)
                self.button1:SetText((OKAY .. "|cffffffff(%d)|r"):format(math.ceil(self.timeleft)))
            end,
            hideOnEscape = true
        }
        StaticPopup_Show("IMRPOVED_ADDON_LIST_CONFIGURATION_SWITCH")
    else
        self:ShowConfigurationSwitchPromptDialog(meetConditionConfigurations)
    end
end

-- 显示提示弹窗
function Addon:ShowConfigurationSwitchPromptDialog(meetConditionConfigurations)
    local content = ImprovedAddonListSwitchConfigurationPromptDialog.List.Content
    content.buttons = {}
    for index, v in ipairs(meetConditionConfigurations) do
        local button = content.buttons[index]
        if not button then
            button = CreateFrame("Button", nil, content, "ImprovedAddonListSwitchConfigurationPromptItemTemplate")
            local relativeTo = index == 1 and content or content.buttons[index-1]      
            local relativePoint = index == 1 and "TOPLEFT" or "BOTTOMLEFT"
            local x = index == 1 and 6 or 0
            local y = index == 1 and -4 or 0
            button:SetPoint("TOPLEFT", relativeTo, relativePoint, x, y)
            button.tooltipText = L["configuration_switch_prompt_dialog_item_tooltip"]
            button:SetScript("OnClick", function(self)
                Addon.OnConfigurationSelected(nil, self.name)
                ReloadUI()
            end)

            content.buttons[index] = button
        end

        button.name = v.name
        button.Text:SetText(v.name)
        button:Show()
    end

    for i = #meetConditionConfigurations+1, #content.buttons do
        content.buttons[i]:Hide()
    end

    ImprovedAddonListSwitchConfigurationPromptDialog:Show()
    LCG.AutoCastGlow_Start(ImprovedAddonListSwitchConfigurationPromptDialog)
end