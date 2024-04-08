local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 加载指示器：不显示
Addon.LOAD_INDICATOR_DISPLAY_INVISIBLE = 0
-- 加载指示器：只对标题带有颜色的插件显示
Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL = 1
-- 加载指示器：总是显示
Addon.LOAD_INDICATOR_DISPLAY_ALWAYS = 2

-- 颜色：需重载
Addon.ADDON_RELOAD_COLOR = RARE_BLUE_COLOR
-- 颜色：未加载
Addon.ADDON_UNLOADED_COLOR = ORANGE_FONT_COLOR
-- 颜色：无法加载
Addon.ADDON_UNLOADABLE_COLOR = RED_FONT_COLOR
-- 颜色：已加载
Addon.ADDON_LOADED_COLOR = WHITE_FONT_COLOR
-- 颜色：未启用
Addon.ADDON_DISABLED_COLOR = DISABLED_FONT_COLOR

-- 基础设置
local AddonSettingsInfo = { 
    Title = L["settings_tips"],
    Groups = {
        {
            Title = L["settings_group_load_indicator"],
            Items = {
                {
                    Title = L["settings_load_indicator_display_mode"],
                    Type = "singleChoice",
                    Event = "AddonSettings.LoadIndicatorDisplayMode",
                    Description = function(self)
                        return Addon:GetLoadIndicatorDisplayTypeDescription()
                    end,
                    GetValue = function(self)
                        return Addon:GetLoadIndicatorDisplayType()
                    end,
                    SetValue = function(self, value)
                        Addon:SetLoadIndicatorDisplayType(value)
                    end,
                    Choices = {
                        {
                            Text = L["settings_load_indicator_dislay_invisble"],
                            Value = Addon.LOAD_INDICATOR_DISPLAY_INVISIBLE
                        },
                        {
                            Text = L["settings_load_indicator_display_only_colorful"],
                            Value = Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL
                        },
                        {
                            Text = L["settings_Load_indicator_display_always"],
                            Value = Addon.LOAD_INDICATOR_DISPLAY_ALWAYS
                        }
                    }
                },
                {
                    Title = L["settings_load_indicator_color_reload"],
                    SubTitle = L["settings_load_indicator_color_reload_description"],
                    Type = "singleChoice",
                    Event = "AddonSettings.LoadIndicatorReloadColor",
                    Description = function(self)

                    end,
                    GetValue = function(self)

                    end,
                    SetValue = function(self, value)

                    end,
                    Choices = {
                        
                    }
                },
            }
        }
    }
}

-- 显示插件设置
function Addon:ShowAddonSettings()
    self:GetAddonDetailContainer():Hide()
    self:HideEditRemarkDialog()
    
    local AddonSettingsFrame = self:GetOrCreateAddonSettingsFrame()
    AddonSettingsFrame:ShowSettings(AddonSettingsInfo)
end

-- 获取插件设置框体
function Addon:GetOrCreateAddonSettingsFrame()
    local UI = self:GetOrCreateUI()

    local AddonSettingsFrame = UI.AddonSettingsFrame
   
    if not AddonSettingsFrame then
        local AddonDetailContainer = self:GetAddonDetailContainer()
        AddonSettingsFrame = self:CreateSettingsFrame()
        UI.AddonSettingsFrame = AddonSettingsFrame
        AddonSettingsFrame:SetAllPoints(AddonDetailContainer)  
    end

    return AddonSettingsFrame
end