local AddonName, Addon = ...

-- 获取插件信息
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

function Addon:GetAddonInfo(query)
    local info = self:GetAddonInfoOrNil(query)
    if not info then error("You cannot get a not exists addon's info by " .. query) end

    return info
end

-- 获取插件信息
function Addon:GetAddonInfos()
    local addonInfos = {}
    for i = 1, GetNumAddOns() do
        addonInfos[i] = self:GetAddonInfo(i)
    end
    return addonInfos
end

-- 获取插件列表数据提供者
function Addon:GetAddonDataProvider()
    local dataProvider = CreateLinearizedTreeListDataProvider()
    local node = dataProvider:GetRootNode()
    local addonInfos = self:GetAddonInfos()
    for _, addonInfo in pairs(addonInfos) do
        node:Insert({ addonInfo = addonInfo })
    end

    return dataProvider
end