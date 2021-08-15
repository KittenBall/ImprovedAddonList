local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN", true)

L["save"] = "将当前启用插件保存到当前插件加载方案\n双击重命名当前插件加载方案"
L["save_as"] = "将当前启用插件另存为一个新的插件加载方案"
L["delete"] = "删除当前插件加载方案"
L["tips"] = "当前启用插件与当前插件加载方案不一致！"
L["input_configuration_name"] = "输入方案名"
L["error_input_empty"] = "你不能创建一个无名的插件加载方案！"
L["error_input_distinct"] = "已有同名的插件加载方案！"
L["disable_me_tips"] = "你保存的插件加载方案中没有本插件！"
L["max_configuration_num_limit"] = "你最多只能拥有25个插件加载方案"
L["delete_confirm"] = "确定删除插件加载方案\n|cff00ff00%s|r"
L["save_error"] = "当前没有选中任意插件加载方案"
L["rename_error"] = "当前没有选中任意插件加载方案"
L["delete_error"] = "当前没有选中任意插件加载方案"
L["change_default_error"] = "你无法更改默认插件加载方案"