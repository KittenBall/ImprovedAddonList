local AddonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(AddonName)

Addon.AddonInfos = {}

-- 插件初始启用状态
local AddonInfoInitialStates = {}
for i = 1, GetNumAddOns() do
    local name, title, notes, loadable, reason, security = GetAddOnInfo(i)
    local enabled = GetAddOnEnableState(UnitName("player"), i) > 0
    AddonInfoInitialStates[name] = { Enabled = enabled, Expired = (reason == "INTERFACE_VERSION") }
end

-- 更新插件初始启用状态
function Addon:UpdateAddonInitialEnableState(addonName, enabled)
    AddonInfoInitialStates[addonName].Enabled = enabled
end

-- 插件是否为管理者，即是否为本插件
function Addon:IsAddonManager(name)
    if type(name) ~= "string" then return end
    return name == AddonName
end

-- 应当一直被启用的插件，默认只有此插件
local ShouldAlwaysEnabledAddons = {
    [AddonName] = true
}

-- 插件是否应当被一直启用
function Addon:IsAddonShouldEnableAlways(addonName)
    return ShouldAlwaysEnabledAddons[addonName]
end

-- 插件是否被收藏
function Addon:IsAddonFavorite(name)
    if type(name) ~= "string" then return end
    return self.Saved.FavoriteAddons[name]
end

-- 设置插件收藏状态
function Addon:SetAddonFavorite(name, favorite)
    if type(name) ~= "string" then return end
    self.Saved.FavoriteAddons[name] = favorite
end

-- 插件是否被锁定
function Addon:IsAddonLocked(name)
    if type(name) ~= "string" then return end
    return self.Saved.LockedAddons[name]
end

-- 设置插件锁定状态
function Addon:SetAddonLock(name, lock)
    if type(name) ~= "string" then return end
    self.Saved.LockedAddons[name] = lock
end

-- 插件备注
function Addon:GetAddonRemark(name)
    if type(name) ~= "string" then return end
    return self.Saved.AddonRemarks[name]
end

-- 设置插件备注
function Addon:SetAddonRemark(name, remark)
    if type(name) ~= "string" then return end
    if remark == nil or remark == "" then
        self.Saved.AddonRemarks[name] = nil
    else
        remark = strtrim(remark)
        local addonInfos = self:GetAddonInfos()
        for _, addonInfo in ipairs(addonInfos) do
            -- 检查是否重名
            if addonInfo.Name == remark then
                self:ShowError(L["edit_remark_error_name_duplicate"]:format(addonInfo.Title))
                return
            elseif addonInfo.Title == remark or addonInfo.TitleWithoutColor == remark then
                self:ShowError(L["edit_remark_error_title_duplicate"]:format(addonInfo.Title))
                return
            elseif addonInfo.Remark == remark then
                self:ShowError(L["edit_remark_error_remark_duplicate"]:format(addonInfo.Title))
                return
            end
        end
        self.Saved.AddonRemarks[name] = remark
    end
end

-- 获取插件信息，返回值可能为nil
-- query:要么为index:与GetNumAddOns对应的插件位置；要么为name：插件名
function Addon:GetAddonInfoOrNil(query, addonInfo)
    if not query then return end
    if type(query) ~= "string" and type(query) ~= "number" then return end

    local name, title, notes, loadable, reason, security = GetAddOnInfo(query)
    if reason == "MISSING" then
        return
    end

    addonInfo = addonInfo or {}
    
    if type(query) == "number" then
        addonInfo.Index = query
    end

    addonInfo.Name = name
    -- 标题
    addonInfo.Title = title
    -- 标题是否具有颜色
    addonInfo.TitleColorful = title:find("|c%x%x%x%x%x%x%x%x") and true or false
    -- 不带颜色的标题
    addonInfo.TitleWithoutColor = title:gsub("|c%x%x%x%x%x%x%x%x", "")
    addonInfo.Notes = notes
    addonInfo.Author = addonInfo.Author or C_AddOns.GetAddOnMetadata(query, "Author")
    addonInfo.Version = addonInfo.Version or C_AddOns.GetAddOnMetadata(query, "Version")
    
    -- 图标
    local iconTexture = C_AddOns.GetAddOnMetadata(query, "IconTexture")
	local iconAtlas = C_AddOns.GetAddOnMetadata(query, "IconAtlas")
    if not iconTexture and not iconAtlas then
		iconTexture = [[Interface\ICONS\INV_Misc_QuestionMark]]
	end

    local iconText 
    if iconTexture then
		iconText = CreateSimpleTextureMarkup(iconTexture, 14, 14)
	elseif iconAtlas then
		iconText = CreateAtlasMarkup(iconAtlas, 14, 14)
	end
    -- 图标文本
    addonInfo.IconText = iconText

    -- 是否可加载（或已加载）
    addonInfo.Loadable = loadable
    -- 是否已加载
    addonInfo.Loaded = IsAddOnLoaded(query)
    -- 是否按需加载
    addonInfo.LoadOnDemand = IsAddOnLoadOnDemand(query)
    -- 是否启用
    addonInfo.Enabled = GetAddOnEnableState(UnitName("player"), query) > 0
    -- 初始启用状态
    addonInfo.InitialEnabled = AddonInfoInitialStates[name].Enabled
    -- 初始过期状态
    addonInfo.InitialExpired = AddonInfoInitialStates[name].Expired
    -- 不可加载原因
    addonInfo.UnloadableReason = not loadable and reason and _G["ADDON_" .. reason] or ""
    -- 可能值：不安全，安全，非法
    addonInfo.Security = security
    -- 插件依赖
    addonInfo.Deps = addonInfo.Deps or { GetAddOnDependencies(query) }
    -- 可选依赖
    addonInfo.OptionalDeps = addonInfo.OptionalDeps or { GetAddOnOptionalDependencies(query) }
    -- 备注
    addonInfo.Remark = self:GetAddonRemark(name)
    -- 是否收藏
    addonInfo.IsFavorite = self:IsAddonFavorite(name)
    -- 是否锁定
    addonInfo.IsLocked = name == AddonName or self:IsAddonLocked(name)
    -- 是否允许解除锁定
    addonInfo.Unlockable = not self:IsAddonManager(name)

    return addonInfo
end

-- 获取插件信息，返回值不为nil
function Addon:GetAddonInfo(query, addonInfo)
    local info = self:GetAddonInfoOrNil(query, addonInfo)
    if not info then error("You cannot get a unexists addon's info by " .. query) end

    return info
end

-- 根据插件名获取插件信息，可能为nil
-- @param update:是否先刷新，再获取
function Addon:GetAddonInfoByNameOrNil(name, update)
    local addonInfos = self:GetAddonInfos()
    local addonIndex = addonInfos[name]
    if not addonIndex then return end

    return self:GetAddonInfoByIndexOrNil(addonIndex, update)
end

-- 根据插件名获取插件信息，返回值不为nil
function Addon:GetAddonInfoByName(name, update)
    local addonInfo = self:GetAddonInfoByNameOrNil(name, update)
    if not addonInfo then error("You cannot get a unexists addon's info by " .. name) end

    return addonInfo
end

-- 根据插件index获取插件信息，可能为nil
-- @param update:是否先刷新，再获取
function Addon:GetAddonInfoByIndexOrNil(index, update)
    local addonInfos = self:GetAddonInfos()
    if update then
        self:UpdateAddonInfoByIndex(index)
    end

    return addonInfos[index]
end

-- 根据插件index获取插件信息，返回值不为nil
function Addon:GetAddonInfoByIndex(index, update)
    local addonInfo = self:GetAddonInfoByIndexOrNil(index, update)
    if not addonInfo then error("You cannot get a unexists addon's info by " .. index) end

    return addonInfo
end

-- 根据插件index更新插件信息
-- 返回对应插件信息
function Addon:UpdateAddonInfoByIndex(index)
    local addonInfos = self:GetAddonInfos()
    local addonInfo = self:GetAddonInfo(index, addonInfos[index])
    -- 按插件index存储
    addonInfos[index] = addonInfo
    -- 插件名和index映射
    addonInfos[addonInfo.Name] = index

    return addonInfo
end

-- 根据插件名更新插件信息
function Addon:UpdateAddonInfoByName(name)
    local addonInfos = self:GetAddonInfos()
    local addonIndex = addonInfos[name]
    
    -- 获取不到插件索引，就没有必要更新了
    if not addonIndex then return end

    return self:UpdateAddonInfoByIndex(addonIndex)
end

-- 获取插件信息
-- @param query:如果为nil，则更新所有插件信息，否则只更新指定插件信息
function Addon:UpdateAddonInfos(query)
    if query then
        if type(query) == "number" then
            self:UpdateAddonInfoByIndex(query)
        elseif type(query) == "string" then
            self:UpdateAddonInfoByName(query)
        end
    else
        local addonInfos = self:GetAddonInfos()
        
        for i = 1, GetNumAddOns() do
            self:UpdateAddonInfoByIndex(i)
        end
    end
end

-- 获取所有插件信息
function Addon:GetAddonInfos()
    return self.AddonInfos
end

-- 查询插件信息
function Addon:QueryAddonInfo(query)
    local addonInfos = self:GetAddonInfos()
    local addonInfo
    if type(query) == "string" then
        addonInfo = addonInfos[addonInfos[query]]
    elseif type(query) == "number" then
        addonInfo = addonInfos[query]
    end
    return addonInfo
end

-- 获取插件列表数据提供者
function Addon:GetAddonDataProvider(search)
    self.AddonDataProvider = self.AddonDataProvider or CreateTreeDataProvider()
    self.AddonDataProvider:Flush()
    local node = self.AddonDataProvider:GetRootNode()
    local addonInfos = self:GetAddonInfos()
    search = search and strtrim(search)
    search = search and search:lower()
    local shouldFilter = search and strlen(search) > 0
    for _, addonInfo in ipairs(addonInfos) do
        -- node:Insert({ CategoryInfo = { Name = "测试" } })
        if shouldFilter then
            if addonInfo.Title:lower():match(search) or addonInfo.Name:lower():match(search) then
                node:Insert({ AddonInfo = addonInfo })
            end
        else
            node:Insert({ AddonInfo = addonInfo })
        end
    end

    return self.AddonDataProvider
end

-- 插件是否可以按需加载
function Addon:CanAddonLoadOnDemand(query)
    local addonInfo = self:QueryAddonInfo(query)
    
    if not addonInfo.Enabled or not addonInfo.LoadOnDemand or addonInfo.Loaded then return false end

    for _, dep in pairs(addonInfo.Deps) do
        if dep and not IsAddOnLoaded(dep) then
            return false
        end
    end

    return true
end

-- 插件是否需要重载
function Addon:IsAddonShouldReload(query)
    local addonInfo = self:QueryAddonInfo(query)
    return addonInfo.Enabled ~= addonInfo.InitialEnabled and addonInfo.UnloadableReason ~= ADDON_DEP_DISABLED
end

-- 启用所有插件
function Addon:EnableAllAddons()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if not addonInfo.IsLocked then
            EnableAddOn(addonInfo.Name)
        end
    end
end

-- 禁用所有插件
function Addon:DisableAllAddons()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if self:IsAddonManager(addonInfo.Name) then
            EnableAddOn(addonInfo.Name)
        elseif not addonInfo.IsLocked then
            DisableAddOn(addonInfo.Name)
        end
    end
end

-- 所有插件是否都已启用
function Addon:IsAllAddonsEnabled()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if not addonInfo.IsLocked and not addonInfo.Enabled then
            return false
        end
    end

    return true
end

-- 所有插件是否都已禁用
function Addon:IsAllAddonsDisabled()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        if not addonInfo.IsLocked and addonInfo.Enabled then
            return false
        end
    end

    return true
end

-- 获取加载指示器显示方式
function Addon:GetLoadIndicatorDisplayType()
    return self.Saved.Config.LoadIndicatorDisplayType or Addon.LOAD_INDICATOR_DISPLAY_ALWAYS
end