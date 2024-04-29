local addonName, Addon = ...
local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

-- 加载指示器：不显示
Addon.LOAD_INDICATOR_DISPLAY_INVISIBLE = 0
-- 加载指示器：只对标题带有颜色的插件显示
Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL = 1
-- 加载指示器：总是显示
Addon.LOAD_INDICATOR_DISPLAY_ALWAYS = 2
-- 插件图标：不显示
Addon.ADDON_ICON_DISPLAY_INVISIBLE = 0
-- 插件图标：只对有图标的插件显示
Addon.ADDON_ICON_DISPLAY_ONLY_AVAILABLE = 1
-- 插件图标：总是显示
Addon.ADDON_ICON_DISPLAY_ALWAYS = 2
-- 默认插件图标文本
Addon.DefaultIconText = CreateSimpleTextureMarkup([[Interface\ICONS\INV_Misc_QuestionMark]], 14, 14)

-- 基础设置
local AddonSettingsInfo = { 
    Title = L["settings_tips"],
    Groups = {
        {
            Title = L["settings_group_general"],
            Items = {
                -- 插件图标
                {
                    Title = L["settings_addon_icon_display_mode"],
                    Type = "singleChoice",
                    Event = "AddonSettings.AddonIconDisplayMode",
                    Description = function(self)
                        return Addon:GetAddonIconDisplayTypeDescription()
                    end,
                    GetValue = function(self)
                        return Addon:GetAddonIconDisplayType()
                    end,
                    SetValue = function(self, value)
                        Addon:SetAddonIconDisplayType(value)
                    end,
                    Reset = function(self)
                        Addon:SetAddonIconDisplayType(nil)
                    end,
                    Choices = {
                        {
                            Text = L["settings_addon_icon_dislay_invisble"],
                            Value = Addon.ADDON_ICON_DISPLAY_INVISIBLE,
                            Tooltip = L["settings_addon_icon_dislay_invisble_tooltip"]
                        },
                        {
                            Text = L["settings_addon_icon_display_only_available"],
                            Value = Addon.ADDON_ICON_DISPLAY_ONLY_AVAILABLE,
                            Tooltip = L["settings_addon_icon_display_only_available_tooltip"]
                        },
                        {
                            Text = L["settings_addon_icon_display_always"],
                            Value = Addon.ADDON_ICON_DISPLAY_ALWAYS,
                            Tooltip = L["settings_addon_icon_display_always_tooltip"]
                        }
                    }
                }
            }
        },
        {
            Title = L["settings_group_load_indicator"],
            Items = {
                -- 显示模式
                {
                    Title = L["settings_load_indicator_display_mode"],
                    Type = "singleChoice",
                    Event = "AddonSettings.LoadIndicatorDisplayMode",
                    Tooltip = L["settings_load_indicator_display_mode_tooltip"],
                    Description = function(self)
                        return Addon:GetLoadIndicatorDisplayTypeDescription()
                    end,
                    GetValue = function(self)
                        return Addon:GetLoadIndicatorDisplayType()
                    end,
                    SetValue = function(self, value)
                        Addon:SetLoadIndicatorDisplayType(value)
                    end,
                    Reset = function(self)
                        Addon:SetLoadIndicatorDisplayType(nil)
                    end,
                    Choices = {
                        {
                            Text = L["settings_load_indicator_dislay_invisble"],
                            Value = Addon.LOAD_INDICATOR_DISPLAY_INVISIBLE,
                            Tooltip = L["settings_load_indicator_dislay_invisble_tooltip"]
                        },
                        {
                            Text = L["settings_load_indicator_display_only_colorful"],
                            Value = Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL,
                            Tooltip = L["settings_load_indicator_display_only_colorful_tooltip"]
                        },
                        {
                            Text = L["settings_Load_indicator_display_always"],
                            Value = Addon.LOAD_INDICATOR_DISPLAY_ALWAYS,
                            Tooltip = L["settings_Load_indicator_display_always_tooltip"]
                        }
                    }
                },
                -- 重载颜色
                {
                    Title = L["settings_load_indicator_color_reload"],
                    SubTitle = L["settings_load_indicator_color_reload_description"],
                    Type = "colorPicker",
                    Event = "AddonSettings.LoadIndicatorColor",
                    GetColor = function(self)
                        return Addon:GetLoadIndicatorReloadColor()
                    end,
                    SetColor = function(self, value)
                        Addon:SetLoadIndicatorReloadColor(value)
                    end,
                    Reset = function(self)
                        Addon:SetLoadIndicatorReloadColor(nil)
                    end
                },
                -- 已加载颜色
                {
                    Title = L["settings_load_indicator_color_loaded"],
                    SubTitle = L["settings_load_indicator_color_loaded_description"],
                    Type = "colorPicker",
                    Event = "AddonSettings.LoadIndicatorColor",
                    GetColor = function(self)
                        return Addon:GetLoadIndicatorLoadedColor()
                    end,
                    SetColor = function(self, value)
                        Addon:SetLoadIndicatorLoadedColor(value)
                    end,
                    Reset = function(self)
                        Addon:SetLoadIndicatorLoadedColor(nil)
                    end
                },
                -- 未加载颜色
                {
                    Title = L["settings_load_indicator_color_unloaded"],
                    SubTitle = L["settings_load_indicator_color_unloaded_description"],
                    Type = "colorPicker",
                    Event = "AddonSettings.LoadIndicatorColor",
                    GetColor = function(self)
                        return Addon:GetLoadIndicatorUnloadedColor()
                    end,
                    SetColor = function(self, value)
                        Addon:SetLoadIndicatorUnloadedColor(value)
                    end,
                    Reset = function(self)
                        Addon:SetLoadIndicatorUnloadedColor(nil)
                    end
                },
                -- 无法加载颜色
                {
                    Title = L["settings_load_indicator_color_unloadable"],
                    SubTitle = L["settings_load_indicator_color_unloadable_description"],
                    Type = "colorPicker",
                    Event = "AddonSettings.LoadIndicatorColor",
                    GetColor = function(self)
                        return Addon:GetLoadIndicatorUnloadableColor()
                    end,
                    SetColor = function(self, value)
                        Addon:SetLoadIndicatorUnloadableColor(value)
                    end,
                    Reset = function(self)
                        Addon:SetLoadIndicatorUnloadableColor(nil)
                    end
                },
                -- 未启用颜色
                {
                    Title = L["settings_load_indicator_color_disabled"],
                    SubTitle = L["settings_load_indicator_color_disabled_description"],
                    Type = "colorPicker",
                    Event = "AddonSettings.LoadIndicatorColor",
                    GetColor = function(self)
                        return Addon:GetLoadIndicatorDisabledColor()
                    end,
                    SetColor = function(self, value)
                        Addon:SetLoadIndicatorDisabledColor(value)
                    end,
                    Reset = function(self)
                        Addon:SetLoadIndicatorDisabledColor(nil)
                    end
                },
            }
        }
    }
}

-- 显示插件设置
function Addon:ShowAddonSettings()
    self:GetAddonDetailContainer():Hide()
    
    local AddonSettingsFrame = self:GetOrCreateAddonSettingsFrame()
    AddonSettingsFrame:ShowSettings(AddonSettingsInfo)
end

-- 获取插件设置框体
function Addon:GetOrCreateAddonSettingsFrame()
    local AddonDetailContainer = self:GetAddonDetailContainer()

    local AddonSettingsFrame = AddonDetailContainer.AddonSettingsFrame
   
    if not AddonSettingsFrame then
        AddonSettingsFrame = self:CreateSettingsFrame()
        AddonDetailContainer.AddonSettingsFrame = AddonSettingsFrame
        AddonSettingsFrame:SetAllPoints(AddonDetailContainer)  
    end

    return AddonSettingsFrame
end

-- 获取加载指示器显示方式
function Addon:GetLoadIndicatorDisplayType()
    return self.Saved.Config.LoadIndicatorDisplayType or Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL
end

-- 设置加载指示器显示方式
function Addon:SetLoadIndicatorDisplayType(loadIndicatorDisplayType)
    self.Saved.Config.LoadIndicatorDisplayType = loadIndicatorDisplayType
end

-- 获取加载指示器说明文本
function Addon:GetLoadIndicatorDisplayTypeDescription()
    local loadIndicatorDisplayType = self:GetLoadIndicatorDisplayType()
    if loadIndicatorDisplayType == Addon.LOAD_INDICATOR_DISPLAY_INVISIBLE then
        return L["settings_load_indicator_dislay_invisble"]
    elseif loadIndicatorDisplayType == Addon.LOAD_INDICATOR_DISPLAY_ONLY_COLORFUL then
        return L["settings_load_indicator_display_only_colorful"]
    else
        return L["settings_Load_indicator_display_always"]
    end
end

local function CreateColorFromRGB(rgb)
    return CreateColor(rgb.r, rgb.g, rgb.b)
end

-- 获取插件加载指示器：重载颜色
function Addon:GetLoadIndicatorReloadColor()
    local color = self.Saved.Config.LoadIndicatorReloadColor
    return color and CreateColorFromRGB(color) or RARE_BLUE_COLOR
end

-- 设置插件加载指示器：重载颜色
function Addon:SetLoadIndicatorReloadColor(color)
    self.Saved.Config.LoadIndicatorReloadColor = color and { r = color.r, g = color.g, b = color.b }
end

-- 获取插件加载指示器：未加载
function Addon:GetLoadIndicatorUnloadedColor()
    local color = self.Saved.Config.LoadIndicatorUnloadedColor
    return color and CreateColorFromRGB(color) or ORANGE_FONT_COLOR
end

-- 设置插件加载指示器：未加载
function Addon:SetLoadIndicatorUnloadedColor(color)
    self.Saved.Config.LoadIndicatorUnloadedColor = color and { r = color.r, g = color.g, b = color.b }
end

-- 获取插件加载指示器：无法加载
function Addon:GetLoadIndicatorUnloadableColor()
    local color = self.Saved.Config.LoadIndicatorUnloadableColor
    return color and CreateColorFromRGB(color) or RED_FONT_COLOR
end

-- 设置插件加载指示器：无法加载
function Addon:SetLoadIndicatorUnloadableColor(color)
    self.Saved.Config.LoadIndicatorUnloadableColor = color and { r = color.r, g = color.g, b = color.b }
end

-- 获取插件加载指示器：已加载
function Addon:GetLoadIndicatorLoadedColor()
    local color = self.Saved.Config.LoadIndicatorLoadedColor
    return color and CreateColorFromRGB(color) or WHITE_FONT_COLOR
end

-- 设置插件加载指示器：已加载
function Addon:SetLoadIndicatorLoadedColor(color)
    self.Saved.Config.LoadIndicatorLoadedColor = color and { r = color.r, g = color.g, b = color.b }
end

-- 获取插件加载指示器：未启用
function Addon:GetLoadIndicatorDisabledColor()
    local color = self.Saved.Config.LoadIndicatorDisabledColor
    return color and CreateColorFromRGB(color) or DISABLED_FONT_COLOR
end

-- 设置插件加载指示器：未启用
function Addon:SetLoadIndicatorDisabledColor(color)
    self.Saved.Config.LoadIndicatorDisabledColor = color and { r = color.r, g = color.g, b = color.b }
end

-- 获取插件图标显示方式
function Addon:GetAddonIconDisplayType()
    return self.Saved.Config.AddonIconDisplayType or Addon.ADDON_ICON_DISPLAY_ALWAYS
end

-- 设置加载指示器显示方式
function Addon:SetAddonIconDisplayType(addonIconDisplayType)
    self.Saved.Config.AddonIconDisplayType = addonIconDisplayType
end

-- 获取插件图标显示方式描述
function Addon:GetAddonIconDisplayTypeDescription()
    local addonIconDisplayType = self:GetAddonIconDisplayType()
    if addonIconDisplayType == Addon.ADDON_ICON_DISPLAY_INVISIBLE then
        return L["settings_addon_icon_dislay_invisble"]
    elseif addonIconDisplayType == Addon.ADDON_ICON_DISPLAY_ALWAYS then
        return L["settings_addon_icon_display_always"]
    else
        return L["settings_addon_icon_display_only_available"]
    end
end

-- 创建插件图标文本
function Addon:CreateAddonIconText(iconText)
    local addonIconDisplayType = self:GetAddonIconDisplayType()
    if addonIconDisplayType == Addon.ADDON_ICON_DISPLAY_ALWAYS then
        iconText = iconText or Addon.DefaultIconText
    elseif addonIconDisplayType == Addon.ADDON_ICON_DISPLAY_ONLY_AVAILABLE then 
        iconText = iconText or ""
    else
        iconText = ""
    end

    return iconText
end