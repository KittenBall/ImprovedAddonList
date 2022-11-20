local AddonName, Addon = ...

-- 获取插件信息，返回值可能为nil
-- query:要么为index:与GetNumAddOns对应的插件位置；要么为name：插件名
function Addon:GetAddonInfoOrNil(query)
    if not query then return end
    if type(query) ~= "string" and type(query) ~= "number" then return end

    local name, title, notes, loadable, reason, security = GetAddOnInfo(query)
    if reason == "MISSING" then
        return
    end
    
    local addonInfo = {}
    
    if type(query) == "number" then
        addonInfo.Index = query
    end

    addonInfo.Name = name
    addonInfo.Title = title
    addonInfo.Notes = notes
    addonInfo.Author = GetAddOnMetadata(query, "Author")
    addonInfo.Version = GetAddOnMetadata(query, "Version")
    -- 是否可加载（或已加载）
    addonInfo.Loadable = loadable
    -- 是否已加载
    addonInfo.Loaded = IsAddOnLoaded(query)
    -- 是否按需加载
    addonInfo.LoadOnDemand = IsAddOnLoadOnDemand(query)
    -- 是否启用
    addonInfo.Enabled = GetAddOnEnableState(UnitName("player"), query) > 0
    -- 不可加载原因，可能为nil
    addonInfo.UnLoadableReason = reason
    -- 可能值：不安全，安全，非法
    addonInfo.Security = security
    -- 插件依赖
    addonInfo.Deps = { GetAddOnDependencies(query) }
    -- 可选依赖
    addonInfo.OptionalDeps = { GetAddOnOptionalDependencies(query) }

    return addonInfo
end

-- 获取插件信息，返回值不为nil
function Addon:GetAddonInfo(query)
    local info = self:GetAddonInfoOrNil(query)
    if not info then error("You cannot get a unexists addon's info by " .. query) end

    return info
end

-- 根据插件index更新插件信息
function Addon:UpdateAddonInfoByIndex(index)
    local addonInfo = self:GetAddonInfo(index)
    self.AddonInfos = self.AddonInfos or {}
    -- 按插件index存储
    self.AddonInfos[index] = addonInfo
    -- 插件名和index映射
    self.AddonInfos[addonInfo.Name] = index
end

-- 根据插件名更新插件信息
function Addon:UpdateAddonInfoByName(name)
    self.AddonInfos = self.AddonInfos or {}
    local addonIndex = self.AddonInfos[name]
    
    -- 获取不到插件索引，就没有必要存了
    if not addonIndex then return end

    self:UpdateAddonInfoByIndex(addonIndex)
end

-- 根据插件名获取插件信息，可能为nil
-- @param update:是否先刷新，再获取
function Addon:GetAddonInfoByNameOrNil(name, update)
    if update then
        self:UpdateAddonInfoByName(name)
    end

    if not self.AddonInfos then return end

    local addonIndex = self.AddonInfos[name]
    if not addonIndex then return end

    return self.AddonInfos[addonIndex]
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
    if update then
        self:UpdateAddonInfoByIndex(index)
    end

    if not self.AddonInfos then return end

    return self.AddonInfos[index]
end

-- 根据插件index获取插件信息，返回值不为nil
function Addon:GetAddonInfoByIndex(index, update)
    local addonInfo = self:GetAddonInfoByIndexOrNil(index, update)
    if not addonInfo then error("You cannot get a unexists addon's info by " .. index) end

    return addonInfo
end

-- 获取插件信息
-- @param query:如果为nil，则更新所有插件信息吗，否则只更新指定插件信息
function Addon:UpdateAddonInfos(query)
    if query then
        if type(query) == "number" then
            self:UpdateAddonInfoByIndex(query)
        elseif type(query) == "string" then
            self:UpdateAddonInfoByName(query)
        end
    else
        if self.AddonInfos then wipe(self.AddonInfos) end
        for i = 1, GetNumAddOns() do
            self:UpdateAddonInfoByIndex(i)
        end
    end
end

function Addon:GetAddonInfos()
    return self.AddonInfos
end

-- 获取插件列表数据提供者
function Addon:GetAddonDataProvider()
    local dataProvider = CreateLinearizedTreeListDataProvider()
    local node = dataProvider:GetRootNode()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in ipairs(addonInfos) do
        node:Insert({ addonInfo = addonInfo })
    end

    return dataProvider
end