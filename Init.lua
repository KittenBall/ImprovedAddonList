local AddonName, Addon = ...

local function presetSaved()
    ImprovedAddonListSaved = ImprovedAddonListSaved or {}
    -- 插件偏好
    ImprovedAddonListSaved.FavoriteAddons = ImprovedAddonListSaved.FavoriteAddons or {}
    -- 插件分组
    ImprovedAddonListSaved.AddonCategories = ImprovedAddonListSaved.AddonCategories or {}
    -- 插件备注
    ImprovedAddonListSaved.AddonRemarks = ImprovedAddonListSaved.AddonRemarks or {}
    -- 排序方式
    ImprovedAddonListSaved.SortMethod = ImprovedAddonListSaved.SortMethod or Addon.SORT_BY_INDEX
    -- 升序/降序
    ImprovedAddonListSaved.SortOrder = ImprovedAddonListSaved.SortOrder or Addon.ORDER_ASCENDING
    -- 分组方式
    ImprovedAddonListSaved.GroupMethod = ImprovedAddonListSaved.GroupMethod or Addon.GROUP_BY_DEP
    
    Addon.Saved = ImprovedAddonListSaved
end

local function OnInitialize()
    presetSaved()

    --刷新插件信息
    Addon:UpdateAddonInfos()
end

Addon:RegisterEvent("PLAYER_LOGIN", OnInitialize)