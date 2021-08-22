local addonName, Addon = ...

local L = LibStub("AceLocale-3.0"):GetLocale(addonName)

ImprovedAddonListConditionCheckButtonMixin = {}

function ImprovedAddonListConditionCheckButtonMixin:OnClick()
    local parent = self:GetParent()
    parent:SetType(parent.type + 1)
end

function ImprovedAddonListConditionCheckButtonMixin:SetLabel(text)
    self.Text:SetText(text)
end

ImprovedAddonListConditionDropDownMixin = {}

function ImprovedAddonListConditionDropDownMixin.OnItemSelected(itemButton, info)
    if itemButton and itemButton:GetParent() and itemButton:GetParent().dropdown then
        local self = itemButton:GetParent().dropdown
        self.selected = info
        UIDropDownMenu_SetText(self, info.text)
    end
    CloseDropDownMenus()
end

function ImprovedAddonListConditionDropDownMixin:OnInitialize(level, menuList)
    if not self.infos then return end
    for _, info in ipairs(self.infos) do
        local dropDownInfo = UIDropDownMenu_CreateInfo()
        dropDownInfo.arg1 = info
        dropDownInfo.text = info.text
        dropDownInfo.checked = self.selected and (self.selected.value == info.value) or false
        dropDownInfo.func = self.OnItemSelected
        UIDropDownMenu_AddButton(dropDownInfo, level)
    end
end

function ImprovedAddonListConditionDropDownMixin:Refresh(infos)
    self.infos = infos
    UIDropDownMenu_Initialize(self, self.OnInitialize)
    UIDropDownMenu_SetText(self, self.selected and self.selected.value)
end

function ImprovedAddonListConditionDropDownMixin:SetLabel(text)
    self.Label:SetText(text)
end

function ImprovedAddonListConditionDropDownMixin:Reset()
    self.selected = nil
    UIDropDownMenu_SetText(self, "")
end

ImprovedAddonListConditionDetailFrameMixin = {}
ImprovedAddonListConditionDetailFrameMixin.ROW_MARGIN = 15

function ImprovedAddonListConditionDetailFrameMixin:SetItems(infos)
    self.infos = infos
    if not infos then return end
    self.items = self.items or {}
    for index, info in ipairs(infos) do
        local item = CreateFrame("CheckButton", nil, self, "ImprovedAddonListCheckButtonTemplate")
        local tRelativeTo = (index == 1 or index == 2) and self or self.items[index-2]
        local lRelativePoint = (index % 2 == 0) and "CENTER" or "LEFT"
        local tRelativePoint = (index == 1 or index == 2) and "TOP" or "BOTTOM"
        item:SetPoint("LEFT", self, lRelativePoint, self.ROW_MARGIN, 0)
        item:SetPoint("TOP", tRelativeTo, tRelativePoint, 0, -self.ROW_MARGIN)

        item.info = info
        item.Text:SetText(info.text)
        self.items[index] = item
    end

    local rowCount = math.floor(#infos / 2) + (#infos % 2 > 0 and 1 or 0)
    self:SetHeight(rowCount * 26 + (rowCount+1) * self.ROW_MARGIN)
end

function ImprovedAddonListConditionDetailFrameMixin:Reset()
    for _, item in ipairs(self.items) do
        item:SetChecked(false)
    end
end

function ImprovedAddonListConditionDetailFrameMixin:ResetItems(infos)
    for _, info in ipairs(infos) do
        for _, item in ipairs(self.items) do
            if info.value == item.info.value then
                item:SetChecked(true)
                break
            end
        end
    end
end

ImprovedAddonListConditionItemMixin = {}
ImprovedAddonListConditionItemMixin.TYPE_DEFAULT = 0
ImprovedAddonListConditionItemMixin.TYPE_SINGLE_CHOICE = 1
ImprovedAddonListConditionItemMixin.TYPE_MULTIPLE_CHOIC = 2

function ImprovedAddonListConditionItemMixin:SetType(type)
    self.type = type % 3
    if self.type == self.TYPE_DEFAULT then
        self.CheckButton:SetChecked(false)
        self.DetailFrame:Hide()
        self.DropDown:Show()
        UIDropDownMenu_DisableDropDown(self.DropDown)
        self:SetHeight(self.CollapseHeight)
    elseif self.type == self.TYPE_SINGLE_CHOICE then
        self.CheckButton:SetChecked(true)
        self.DetailFrame:Hide()
        self.DropDown:Show()
        UIDropDownMenu_EnableDropDown(self.DropDown)
        self:SetHeight(self.CollapseHeight)
    elseif self.type == self.TYPE_MULTIPLE_CHOIC then
        self.CheckButton:SetChecked(true)
        self.DetailFrame:Show()
        self.DropDown:Hide()
        self:SetHeight(self.ExpandHeight)
    end
end

function ImprovedAddonListConditionItemMixin:SetItems(name, infos)
    self.CheckButton.tooltipText = L["condition_check_button_tooltip"]
    self.CheckButton:SetLabel(name)
    self.DropDown:SetLabel(name)
    self.DropDown:Refresh(infos)
    self.DetailFrame:SetItems(infos)
    self.ExpandHeight = self.DetailFrame:GetHeight() + 85
    self.CollapseHeight = 75
    self:SetType(self.TYPE_DEFAULT)
end

function ImprovedAddonListConditionItemMixin:ResetItems(infos)
    self.DropDown:Reset()
    self.DetailFrame:Reset()
    if not infos or #infos == 0 then
        self:SetType(self.TYPE_DEFAULT)
    elseif #infos == 1 then
        self:SetType(self.TYPE_SINGLE_CHOICE)
        self.DropDown.selected = infos[1]
        UIDropDownMenu_SetText(self, infos[1].text)
    else
        self:SetType(self.TYPE_MULTIPLE_CHOIC)
        self.DetailFrame:ResetItems(infos)
    end
end

function ImprovedAddonListConditionItemMixin:GetSelectedItems()
    if self.type == self.TYPE_DEFAULT then
        return
    elseif self.type == self.TYPE_SINGLE_CHOICE then
        local dropDown = self.DropDown
        if dropDown.selected then
            return { dropDown.selected }
        end
    elseif self.type == self.TYPE_MULTIPLE_CHOIC then
        local detailFrame = self.DetailFrame
        local infos = {}
        for _, item in ipairs(detailFrame.items) do
            if item:GetChecked() then
                tinsert(infos, item.info)
            end
        end
        return #infos > 0 and infos or nil
    end
end