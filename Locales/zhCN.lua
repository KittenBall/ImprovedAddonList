local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN", true)

L["save"] = "左键点击将当前启用插件保存到当前插件加载方案\n右键点击重新设置当前插件加载方案"
L["save_as"] = "将当前启用插件另存为一个新的插件加载方案"
L["delete"] = "删除当前插件加载方案"
L["tips"] = "当前启用插件与当前插件加载方案不一致！\n双击按钮可加载当前选中方案"
L["input_dialog_title"] = "保存前设置"
L["error_input_empty"] = "你不能创建一个无名的插件加载方案！"
L["error_input_distinct"] = "已有同名的插件加载方案！"
L["disable_me_tips"] = "你保存的插件加载方案中没有本插件！"
L["max_configuration_num_limit"] = "你最多只能拥有25个插件加载方案"
L["delete_confirm"] = "确定删除插件加载方案\n|cff00ff00%s|r"
L["save_error"] = "当前没有选中任意插件加载方案"
L["save_success"] = "保存成功"
L["reset_error"] = "当前没有选中任意插件加载方案"
L["delete_error"] = "当前没有选中任意插件加载方案"
L["save_to_global"] = "所有角色通用"
L["save_to_global_tips"] = "新建的插件加载方案默认属于当前角色，勾选按钮后会使其对所有角色可见"