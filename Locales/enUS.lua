local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):NewLocale(addonName, "enUS", true)

if not L then return end

L["true"] = "Yes"
L["false"] = "No"
L["ignore"] = "Ignore"

L["addon_set"] = "Addon Set"
L["settings_tips"] = "Settings"
L["enable_all_tips"] = "Enable All Addons"
L["disable_all_tips"] = "Disable All Addons"
L["addon_set_op_tips"] = "Add/Remove Current Enabled Addons to/from Addon Set"
L["reset_tips"] = "Reset"
L["lock_tips"] = "Locked"
L["cannot_unlock_tips"] = "This addon cannot be unlocked"
L["edit_remark_error_too_long"] = "Remark too long"
L["edit_remark_error_name_duplicate"] = "Duplicate name with addon \"%s\""
L["edit_remark_error_title_duplicate"] = "Duplicate title with addon \"%s\""
L["edit_remark_error_remark_duplicate"] = "Duplicate remark with addon \"%s\""
L["reload_ui_tips_title"] = "Addons That Require Reload"

L["settings_dynamic_edit_box_delete_tips"] = "Delete"
L["settings_slider_confirm_tips"] = "Save and Apply"
L["settings_group_expand_all_tips"] = "Expand All"
L["settings_group_collapse_all_tips"] = "Collapse All"

L["settings_group_general"] = "General"
L["settings_addon_icon_display_mode"] = "Addon Icon Display Mode"
L["settings_addon_icon_dislay_invisble"] = "Never"
L["settings_addon_icon_dislay_invisble_tooltip"] = "Do not show addon icons"
L["settings_addon_icon_display_only_available"] = "If Available"
L["settings_addon_icon_display_only_available_tooltip"] = "Show icons only for addons with icons"
L["settings_addon_icon_display_always"] = "Always"
L["settings_addon_icon_display_always_tooltip"] = "Show icons for all addons; addons without icons will be shown as question marks"
L["settings_ui_scale"] = "UI Scale"
L["settings_addon_enable_status_character_only"] = "Addon enable status saved per character"
L["settings_addon_enable_status_character_only_tooltip"] = "The enable or disable status of the addon is saved to the character. Each character has its own list of addons. If you want each character to use a different addon list upon login, you can enable this option."
L["settings_group_load_indicator"] = "Addon Load Indicator"
L["settings_load_indicator_display_mode"] = "Display Mode"
L["settings_load_indicator_display_mode_tooltip"] = "Some addons have colored names (e.g., DBM), which affects the readability of the addon load coloring. This option configures how the load indicator is displayed."
L["settings_load_indicator_dislay_invisble"] = "Never"
L["settings_load_indicator_dislay_invisble_tooltip"] = "Do not show addon indicators and remove colors from addon names"
L["settings_load_indicator_display_only_colorful"] = "Only Colored Names"
L["settings_load_indicator_display_only_colorful_tooltip"] = "Only show indicators for addons with colored names"
L["settings_load_indicator_display_always"] = "Always"
L["settings_load_indicator_display_always_tooltip"] = "Show load indicators for all addons, regardless of whether their names have colors"
L["settings_load_indicator_color_reload"] = "Reload Color"
L["settings_load_indicator_color_reload_description"] = "Color value for addons requiring reload"
L["settings_load_indicator_color_unloaded"] = "Not Loaded Color"
L["settings_load_indicator_color_unloaded_description"] = "Color value for unloaded addons"
L["settings_load_indicator_color_unloadable"] = "Unloadable Color"
L["settings_load_indicator_color_unloadable_description"] = "Color value for unloadable addons"
L["settings_load_indicator_color_loaded"] = "Loaded Color"
L["settings_load_indicator_color_loaded_description"] = "Color value for loaded addons"
L["settings_load_indicator_color_disabled"] = "Disabled Color"
L["settings_load_indicator_color_disabled_description"] = "Color value for disabled addons"
L["settings_group_addon_set"] = "Addon Set"
L["settings_addon_set_load_condition_detect"] = "Load Condition Detection"
L["settings_addon_set_load_condition_detect_tooltip"] = "Popup if suitable addon set(s) is available in the current scenario"
L["settings_addon_set_load_condition_prompt_auto_dismiss_time"] = "Auto Dismiss Time"
L["settings_addon_set_load_condition_prompt_auto_dismiss_time_tooltip"] = "Set the auto-dismiss time for the addon set load condition prompt dialog. If set to 0, auto-dismiss is disabled."
L["settings_addon_set_load_condition_prompt_position_save"] = "Position Save"
L["settings_addon_set_load_condition_prompt_position_save_tooltip"] = "Enable or disable the position save for the addon set load condition prompt dialog"

L["addon_detail_basic_info"] = "Basic Information"
L["addon_detail_name"] = "Name:"
L["addon_detail_title"] = "Title:"
L["addon_detail_remark"] = "Remark:"
L["addon_detail_notes"] = "Notes:"
L["addon_detail_author"] = "Author:"
L["addon_detail_version"] = "Version:"
L["addon_detail_dep_info"] = "Dependency Information"
L["addon_detail_dependencies"] = "Dependencies:"
L["addon_detail_optional_deps"] = "Optional Dependencies:"
L["addon_detail_status_info"] = "Status Information"
L["addon_detail_load_status"] = "Load Status:"
L["addon_detail_unload_reason"] = "Unload Reason:"
L["addon_detail_enable_status"] = "Enable Status:"
L["addon_detail_load_on_demand"] = "Load on Demand:"
L["addon_detail_memory_usage"] = "Memory Usage:"
L["addon_detail_no_dependency"] = "This addon has no dependencies"
L["addon_detail_in_addon_set"] = "In Addon Set:"
L["addon_detail_does_not_in_addon_set"] = "No"
L["addon_detail_loaded"] = "Loaded"
L["addon_detail_unload"] = "Not Loaded"
L["addon_detail_enabled"] = "Enabled"
L["addon_detail_disabled"] = "Disabled"
L["addon_detail_version_debug"] = "Debug Version"
L["addon_detail_lock_tips_title"] = "Addon Lock"
L["addon_detail_lock_tips"] = "The addon will maintain its current enable status and cannot be enabled or disabled.\nWhen enabling all, disabling all, or applying addon sets, it will be ignored unless unlocked.\n\nIf you enable or disable this addon at the character selection screen, the enable status will follow your setting."
L["addon_detail_unlock_tips"] = "Unlock"
L["addon_detail_addon_set_op_tips"] = "Add/Remove from Addon Set"

L["addon_set_active_label"] = "Current Addon Set"
L["addon_set_inactive_tip"] = "No Addon Set Selected"
L["addon_set_list"] = "Addon Set List"
L["addon_set_clear_tips"] = "Stop Using Addon Set"
L["addon_set_apply_tips"] = "Apply Current Selected Addon Set \"%s\""
L["addon_set_apply_alert"] = "Addon Set \"%s\" Applied"
L["addon_set_apply_later"] = "Later"
L["addon_set_apply_error_unsave"] = "Addon Set \"%s\" has unsaved changes, please save before applying"
L["addon_set_add_tips"] = "Add Addon Set"
L["addon_set_remove_tips"] = "Delete Current Selected Addon Set \"%s\""
L["addon_set_new"] = "New Addon Set"
L["addon_set_new_label"] = "Addon Set is a combination of several addons. Please name it and ensure its name is unique."
L["addon_set_name_error_too_long"] = "Addon Set name is too long"
L["addon_set_name_error_duplicate"] = "Addon Set name is duplicate"
L["addon_set_delete_confirm"] = "Confirm delete addon set\n%s"
L["addon_set_addon_switch"] = "Add/Remove from Addon Set"
L["addon_set_save_addon_list_tips"] = "Save current selected addons to \"%s\""
L["addon_set_replace_addons_tips"] = "Add current enabled addons to addon set \"%s\", disabled addons will be removed."
L["addon_set_enable_all_tips"] = "Add all addons to \"%s\""
L["addon_set_disable_all_tips"] = "Remove all addons from \"%s\""
L["addon_set_can_not_find"] = "Addon Set \"%s\" not found"
L["addon_set_not_perfect_match_tips"] = "Addon set \"%s\" is not matching perfectly.\nLeft click to replace: enable all addons in the addon set and disable all other addons.\nRight click to merge: enable all addons in the addon set; this operation will not disable addons that are currently enabled but not part of the current addon set.\nAny operation will not change the enable status of locked addons, regardless of whether they belong to the current addon set."
L["addon_set_not_perfect_match_enabled_but_not_in_addon_set"] = "Enabled but not in addon set (%d)"
L["addon_set_not_perfect_match_disabled_but_in_addon_set"] = "Disabled but in addon set (%d)"
L["addon_set_current"] = "Current Addon Set\n%s"

L["addon_set_choice_enable_all_tips"] = "Select All Addon Sets"
L["addon_set_choice_disable_all_tips"] = "Deselect All Addon Sets"
L["addon_set_choice_merge_tips"] = "Merge into selected addon set\n current addon list"
L["addon_set_choice_replace_tips"] = "Replace selected addon set\n current addon list"
L["addon_set_choice_delete_tips"] = "Remove from selected addon set\n current addon list"

L["addon_set_settings_group_basic"] = "Basic Information"
L["addon_set_settings_name"] = "Name"
L["addon_set_settings_enabled"] = "Enabled"
L["addon_set_settings_enabled_tooltip"] = "Enabling or disabling addon set determines whether it participates in load condition checks"
L["addon_set_settings_group_load_condition"] = "Load Conditions"
L["addon_set_settings_condition_name_and_realm"] = "Player Name/Realm"
L["addon_set_settings_condition_name_and_realm_any"] = "(*)Any"
L["addon_set_settings_condition_name_and_realm_name_tooltip"] = "Player Name"
L["addon_set_settings_condition_name_and_realm_realm_tooltip"] = "Realm"
L["addon_set_settings_condition_name_and_realm_tips"] = "Filter format: \"Name\", \"Name-Realm\", \"-Realm\", you can use \"\\\" to escape \"-\""
L["addon_set_settings_condition_name_and_realm_error_too_much_dash"] = "There are too many \"-\" in %s, you may need to escape it with \\"
L["addon_set_settings_condition_name_and_realm_error_duplicate"] = "Duplicate character name/realm filter format: %s"
L["addon_set_settings_condition_name_and_realm_error_empty"] = "Valid character name or realm not found"
L["addon_set_settings_condition_warmode_tips"] = "Select whether to load addon set in war mode"
L["addon_set_settings_condition_warmode_none"] = "None"
L["addon_set_settings_condition_warmode_enabled"] = "Enabled"
L["addon_set_settings_condition_warmode_disabled"] = "Disabled"
L["addon_set_settings_condition_warmode_choice_none"] = "Do not participate in condition check"
L["addon_set_settings_condition_warmode_choice_enabled"] = "When war mode is enabled"
L["addon_set_settings_condition_warmode_choice_disabled"] = "When war mode is disabled"
L["addon_set_settings_condition_max_level"] = "Max Level"
L["addon_set_settings_condition_maxlevel_tips"] = "Select whether to load addon set at max level"
L["addon_set_settings_condition_maxlevel_none"] = "None"
L["addon_set_settings_condition_maxlevel_enabled"] = "Yes"
L["addon_set_settings_condition_maxlevel_disabled"] = "No"
L["addon_set_settings_condition_maxlevel_choice_none"] = "Do not participate in condition check"
L["addon_set_settings_condition_maxlevel_choice_enabled"] = "At max level"
L["addon_set_settings_condition_maxlevel_choice_disabled"] = "Not at max level"
L["addon_set_settings_condition_faction"] = "Player Faction"
L["addon_set_settings_condition_faction_tips"] = "Select the faction when loading addon set"
L["addon_set_settings_condition_faction_none"] = "None"
L["addon_set_settings_condition_faction_choice_none"] = "Do not participate in condition check"
L["addon_set_settings_condition_specialization_role"] = "Specialization Role"
L["addon_set_settings_condition_race"] = "Player Race"
L["addon_set_settings_condition_specialization"] = "Class and Specialization"
L["addon_set_settings_condition_instance_type"] = "Instance Type"
L["addon_set_settings_condition_instance_type_none"] = "Outdoor"
L["addon_set_settings_condition_instance_type_party"] = "Dungeon"
L["addon_set_settings_condition_instance_type_raid"] = "Raid"
L["addon_set_settings_condition_instance_type_arena"] = "Arena"
L["addon_set_settings_condition_instance_type_pvp"] = "Battleground"
L["addon_set_settings_condition_instance_type_scenario"] = "Scenario"
L["addon_set_settings_condition_instance_difficulty_type"] = "Instance Difficulty Type"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_normal"] = "Dungeon (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_heroic"] = "Dungeon (Heroic)"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_mythic"] = "Dungeon (Mythic)"
L["addon_set_settings_condition_instance_difficulty_type_dungeon_timewalking"] = "Dungeon (Timewalking)"
L["addon_set_settings_condition_instance_difficulty_type_legecy_raid_10_normal"] = "Legacy Raid 10 (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_25_normal"] = "Legacy Raid 25 (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_legecy_raid_10_heroic"] = "Legacy Raid 10 (Heroic)"
L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_25_heroic"] = "Legacy Raid 25 (Heroic)"
L["addon_set_settings_condition_instance_difficulty_type_legacy_lfr"] = "Legacy Raid (LFR)"
L["addon_set_settings_condition_instance_difficulty_type_legacy_raid_40"] = "Legacy 40-Player Raid"
L["addon_set_settings_condition_instance_difficulty_type_scenario_normal"] = "Scenario (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_scenario_heroic"] = "Scenario (Heroic)"
L["addon_set_settings_condition_instance_difficulty_type_raid_lfr"] = "Raid (LFR)"
L["addon_set_settings_condition_instance_difficulty_type_raid_normal"] = "Raid (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_raid_heroic"] = "Raid (Heroic)"
L["addon_set_settings_condition_instance_difficulty_type_raid_mythic"] = "Raid (Mythic)"
L["addon_set_settings_condition_instance_difficulty_type_raid_timewalking"] = "Raid (Timewalking)"
L["addon_set_settings_condition_instance_difficulty_type_island_normal"] = "Island Expedition (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_island_heroic"] = "Island Expedition (Heroic)"
L["addon_set_settings_condition_instance_difficulty_type_island_mythic"] = "Island Expedition (Mythic)"
L["addon_set_settings_condition_instance_difficulty_type_island_pvp"] = "Island Expedition (PvP)"
L["addon_set_settings_condition_instance_difficulty_type_warfront_normal"] = "Warfront (Normal)"
L["addon_set_settings_condition_instance_difficulty_type_warfront_heroic"] = "Warfront (Heroic)"
L["addon_set_settings_condition_instance_difficulty"] = "Instance Difficulty"
L["addon_set_settings_condition_mythic_plus_affix"] = "Mythic+ Affixs"

L["addon_set_condition_tooltip_label"] = "Addon Set\n%s\n\nMet the following conditions:\n%s"
L["addon_set_condition_met_none"] = "Addon set has no conditions set"
L["addon_set_switch_tips_dialog_label"] = "Detected more suitable addon set(s) for the current scenario."
L["addon_set_condition_met_count"] = "Hit %d conditions."
L["addon_set_not_perfect_match_alert"] = "Addon set \"%s\" is not matching perfectly"
L["addon_set_not_perfect_match_confirm"] = "Apply Addon Set"

L["load_addon"] = "Load this addon"
L["enable_addon"] = "Enable addon"
L["disable_addon"] = "Disable addon"
L["edit_remark"] = "Edit remark"
L["enable_switch"] = "Enable/Disable addon"