local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "zhCN")

if not L then return end

L["save"] = "左键点击将当前启用插件保存到当前插件加载方案\n右键点击重新设置当前插件加载方案"
L["save_as"] = "将当前启用插件另存为一个新的插件加载方案"
L["delete"] = "删除当前插件加载方案"
L["tips"] = "当前启用插件与当前插件加载方案不一致！\n双击按钮可加载当前选中方案"
L["remark"] = "为插件添加备注"
L["export"] = "导出当前插件列表\n\n导出内容含有NGA论坛格式代码，可直接在论坛发送。"
L["save_as_input_dialog_title"] = "另存为"
L["save_input_dialog_title"] = "重新设定"
L["remark_input_dialog_title"] = "添加备注（按回车确定）"
L["export_title"] = "导出插件列表"
L["error_input_empty"] = "你不能创建一个无名的插件加载方案！"
L["error_input_distinct"] = "已有同名的插件加载方案！"
L["error_must_save_to_global"] = "你必须勾选所有角色通用选项，因你选择了部分当前角色无法满足的条件"
L["disable_me_tips"] = "你保存的插件加载方案中没有本插件！"
L["max_configuration_num_limit"] = "你最多只能拥有%d个插件加载方案"
L["delete_confirm"] = "确定删除插件加载方案\n|cff00ff00%s|r"
L["remark_confirm"] = "确定为插件|cff00ff00%s|r添加备注：\n|cffffd200%s|r"
L["remark_delete_confirm"] = "确定删除插件|cff00ff00%s|r的备注？"
L["save_error"] = "当前没有选中任意插件加载方案"
L["save_success"] = "保存成功"
L["reset_error"] = "当前没有选中任意插件加载方案"
L["delete_error"] = "当前没有选中任意插件加载方案"
L["unselect_configuration"] = "取消选择"
L["version"] = "版本：%s"
L["author"] = "作者：%s"
L["credit"] = "鸣谢：%s"
L["website"] = "发布页：%s"
L["dependencies"] = "依赖项：%s"
L["addon_tooltip_remark"] = "备注：%s"
L["addon_list"] = "插件列表"
L["enabled_addons"] = "已启用插件列表"
L["disabled_addons"] = "未启用插件列表"
L["addon_name"] = "插件名：%s"

L["cmd_help_reset"] = "/imapl reset：重置角色配置"
L["cmd_help_reset_all"] = "/impal reset all：重置通用配置"
L["cmd_help_switch_configuration"] = "/impal switch 配置名：切换通用配置"
L["cmd_help_switch_char_configuration"] = "/impal switch 配置名：切换角色配置"

L["save_to_global"] = "所有角色通用"
L["save_to_global_tips"] = "新建的插件加载方案默认属于当前角色，勾选按钮后会使其对所有角色可见"
L["show_static_pop"] = "弹窗提示"
L["show_static_pop_tips"] = "默认情况下，满足加载条件时会在右下角显示提示窗，如果勾选此选项，则会显示系统提示弹窗，并且会显著提高此项方案的优先级"
L["auto_dismiss"] = "自动消失"
L["auto_dismiss_tooltip"] = "默认情况下，系统提示弹窗会在一段时间后自动消失，取消勾选此选项，则提示窗将一直显示直到手动取消。"
L["load_condition_title"] = "载入条件"
L["load_condition_tips"] = "此插件并不能自动切换方案\n而是用较醒目的方式提示您切换"
L["input_configuration_name"] ="输入配置名："
L["configuration_switch_text"] = "检测到当前场景下更适合的插件加载方案\n|cff00ff00%s|r\n是否切换？"
L["configuration_active_reset"] = "当前插件加载方案|cff00ff00%s|r和当前启用插件没有完全匹配，是否启用？"
L["configuration_switch_prompt_dialog_title"] = "切换插件"
L["configuration_switch_prompt_dialog_item_tooltip"] = "点击更换此插件加载方案"

L["condition_check_button_tooltip"] = "点击可以切换单选、多选和不选，不选情况下默认为全部启用！"
L["condition_player_name_label"] = "角色-服务器"
L["condition_instance_type_label"] = "场景类型"
L["condition_class_and_spec_label"] = "职业和专精"
L["instance_type_none"] = "野外"
L["instance_type_pvp"] = "战场"
L["instance_type_arena"] = "竞技场"
L["instance_type_party"] = "地下城"
L["instance_type_raid"] = "团队副本"
L["instance_type_scenario"] = "场景战役"

L["true"] = "是"
L["false"] = "否"

L["options"] = "选项"

L["addon_detail_basic_info"] = "基本信息"
L["addon_detail_name"] = "名称："
L["addon_detail_title"] = "标题："
L["addon_detail_remark"] = "备注："
L["addon_detail_notes"] = "说明："
L["addon_detail_author"] = "作者："
L["addon_detail_version"] = "版本："
L["addon_detail_dep_info"] = "依赖信息"
L["addon_detail_dependencies"] = "依赖项："
L["addon_detail_optional_deps"] = "可选依赖："
L["addon_detail_status_info"] = "状态信息"
L["addon_detail_load_status"] = "加载状态："
L["addon_detail_unload_reason"] = "未加载原因："
L["addon_detail_enable_status"] = "启用状态："
L["addon_detail_load_on_demand"] = "按需加载："
L["addon_detail_memory_usage"] = "内存占用："
L["addon_detail_no_dependency"] = "此插件不依赖任何插件"
L["addon_detail_loaded"] = "已加载"
L["addon_detail_unload"] = "未加载"
L["addon_detail_enabled"] = "已启用"
L["addon_detail_disabled"] = "未启用"
L["addon_detail_version_debug"] = "调试版本"

L["load_addon"] = "加载此插件"
L["load_addon_unnecessary"] = "插件已加载"
L["load_addon_not_allowed_reason_not_on_demand"] = "此插件非按需加载，你可以先启用它并重载界面来加载此插件。"
L["load_addon_not_allowed_reason_dep_not_load"] = "此插件的依赖插件尚未加载"