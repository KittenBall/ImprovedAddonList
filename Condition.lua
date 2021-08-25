local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)
local LCG = LibStub("LibCustomGlow-1.0")
local IsRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
local IsBCC = WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC

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
        text = "|c" .. PLAYER_FACTION_COLORS[0]:GenerateHexColor() .. FACTION_HORDE .. FONT_COLOR_CODE_CLOSE,
        value = "Horde"
    },
    {
        text = "|c" .. PLAYER_FACTION_COLORS[1]:GenerateHexColor() .. FACTION_ALLIANCE .. FONT_COLOR_CODE_CLOSE,
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
        text = L["instance_type_party"],
        value = "party"
    },
    {
        text = L["instance_type_raid"],
        value = "raid"
    }
}

if IsBCC or IsRetail then
    table.insert(instanceTypeInfos,
    {
        text = L["instance_type_arena"],
        value = "arena"
    })
end

if IsRetail then
    table.insert(instanceTypeInfos,
    {
        text = L["instance_type_scenario"],
        value = "scenario"
    })
end

local function checkItemMeetCondition(item, conditions)
    if conditions == nil or #conditions == 0 then return true, 0 end
    local value = item.getValue()

    for _, condition in ipairs(conditions) do
        if condition.value == value then
            return true, 1/#conditions
        end
    end
end

local ConditionItems = {
    players = {
        item = ImprovedAddonListConditionContent.PlayerNameItem,
        getValue = function()
            local name, realm = UnitFullName("player")
            return name .. "-" .. realm
        end,
        checkCondition = checkItemMeetCondition
    },
    factions = {
        item = ImprovedAddonListConditionContent.FactionItem,
        getValue = function()
            return UnitFactionGroup("player")
        end,
        checkCondition = checkItemMeetCondition
    },
    instanceTypes = {
        item = ImprovedAddonListConditionContent.InstanceTypeItem,
        getValue = IsInInstance,
        checkCondition = function(item, conditions)
            if conditions == nil or #conditions == 0 then return true, 0 end
            local inInstance, instanceType = item.getValue()

            for _, condition in ipairs(conditions) do
                -- 选中野外时，要判断 inInstance，某些场景instanceType ~= "none" 但 inInstance 为 false，比如要塞
                if (condition.value == "none" and inInstance ~= true) or condition.value == instanceType then
                    return true, 1/#conditions
                end
            end
        end
    },
    classAndSpecs = {
        item = ImprovedAddonListConditionContent.ClassAndSpecItem,
        getValue = function()
            if IsRetail then
                return GetSpecializationInfo(GetSpecialization())
            else
                local _, classFileName = UnitClass("player")
                return classFileName
            end
        end,
        checkCondition = checkItemMeetCondition
    }
}

Addon.Frame:RegisterEvent("PLAYER_LOGIN")
Addon.Frame:RegisterEvent("PLAYER_FLAGS_CHANGED")
Addon.Frame:RegisterEvent("PLAYER_ENTERING_WORLD")

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
    Addon.Frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    ConditionItems.warModes = {
        item = ImprovedAddonListConditionContent.WarModeItem,
        getValue = function()
            return C_PvP.IsWarModeDesired() and 1 or 2
        end,
        checkCondition = checkItemMeetCondition
    }
end

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
    ImprovedAddonListConditionContent.FactionItem:SetItems(FACTION, factionInfos)
    ImprovedAddonListConditionContent.InstanceTypeItem:SetItems(L["condition_instance_type_label"], instanceTypeInfos)
    ImprovedAddonListConditionContent.ClassAndSpecItem:SetItems(L["condition_class_and_spec_label"], self:GetClassAndSpecInfos())

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        ImprovedAddonListConditionContent.WarModeItem:SetItems(PVP_LABEL_WAR_MODE, WarModeInfos)
    else
        ImprovedAddonListConditionContent.WarModeItem:Hide()
    end
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

if IsRetail then
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
elseif IsBCC then
    -- 获取职业信息
    function Addon:GetClassAndSpecInfos()
        local infos = {}
        for i = 1, GetNumClasses() do
            local classLocalizationName, className =  GetClassInfo(i)
            if className then
                local info = {}
                local classColor = "|c" .. RAID_CLASS_COLORS[className].colorStr
                info.text =  ("%s%s%s"):format(classColor, classLocalizationName, FONT_COLOR_CODE_CLOSE)
                info.value = className
                tinsert(infos, info)
            end
        end
        return infos
    end
else
    function Addon:GetClassAndSpecInfos()
        local infos = {}
        for i = 1, MAX_CLASSES do
            local className = CLASS_SORT_ORDER[i]
            local classLocalizationName =  LOCALIZED_CLASS_NAMES_MALE[className]
            if className then
                local info = {}
                local classColor = "|c" .. RAID_CLASS_COLORS[className].colorStr
                info.text =  ("%s%s%s"):format(classColor, classLocalizationName, FONT_COLOR_CODE_CLOSE)
                info.value = className
                tinsert(infos, info)
            end
        end
        return infos
    end
end

-- 是否必须全角色通用
function Addon:MustbeSaveToGlobal()
    --  选择了阵营
    local factionInfos = ConditionItems.factions.item:GetSelectedItems()
    if factionInfos then
        if #factionInfos > 1 then
            return true
        elseif #factionInfos == 1 then
            local faction = ConditionItems.factions.getValue()
            -- 只选中了一个阵营且不为当前角色阵营，则必须全角色通用
            if faction ~= factionInfos[1].value then
                return true
            end
        end
    end

    -- 选择了角色名
    local playerNames = ConditionItems.players.item:GetSelectedItems()
    if playerNames then
        if #playerNames > 1 then
            return true
        elseif #playerNames == 1 then
            -- 只选中了一个角色且不为当前角色，则必须全角色通用
            if playerNames[1].value ~= ConditionItems.players.getValue() then
                return true
            end 
        end
    end

    -- 选择了职业和专精
    local classAndSpecInfos = ConditionItems.classAndSpecs.item:GetSelectedItems()
    if not classAndSpecInfos then return end

    if IsRetail then
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
    else
        if #classAndSpecInfos > 1 then
            return true
        elseif #classAndSpecInfos == 1 then
            -- 选择了非当前职业，则必须全角色通用
            if classAndSpecInfos[1].value ~= ConditionItems.classAndSpecs.getValue() then
                return true
            end 
        end
    end
end

-- 获取带载入条件的配置项
function Addon:GetConfigurationWithConditions()
    local configuration = {}
    configuration.addons = self:GetEnabledAddons()
    
    local conditions = {}
    for key in pairs(ConditionItems) do
        conditions[key] = ConditionItems[key].item:GetSelectedItems()
    end

    configuration.conditions = conditions
    configuration.showStaticPop = ImprovedAddonListInputDialog.ShowStaticPop:GetChecked()
    return configuration
end

-- 重设条件
function Addon:ResetConditions(configuration)
    for key in pairs(ConditionItems) do
        ConditionItems[key].item:ResetItems(configuration and configuration.conditions[key])
    end
    ImprovedAddonListInputDialog.ShowStaticPop:SetChecked(configuration and configuration.showStaticPop)
end

-- 配置是否满足条件
function Addon:IsConfigurationMeetCondition(name)
    local configuration = self:GetConfiguration(name)
    local conditions = configuration.conditions

    local totalPriority = 0
    for key in pairs(ConditionItems) do
        local meetCondition, priority = ConditionItems[key]:checkCondition(conditions[key])
        if not meetCondition then return false end
        totalPriority = totalPriority + priority
    end

    return true, totalPriority + (configuration.showStaticPop and 200 or 0) + (self:IsConfigurationGlobal(name) and 0 or 100)
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
    local bestConfiguration = self:GetConfiguration(bestConfigurationName)

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