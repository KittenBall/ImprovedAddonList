local _, Addon = ...

-- 事件Frame
local eventFrame = CreateFrame("Frame")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    local observers = self[event]
    if not observers then return end
    for _, func in pairs(observers) do
        func(...)
    end
end)

function Addon:RegisterEvent(event, func)
    if type(event) ~= "string" then error("event must be a string") end
    if not func then return end

    eventFrame:RegisterEvent(event)
    eventFrame[event] = eventFrame[event] or {}
    tinsert(eventFrame[event], func)
end

function Addon:UnregisterEvent(event, func)
    if type(event) ~= "string" then error("event must be a string") end
    local observers = eventFrame[event]
    if not observers then return end

    if not func then
        wipe(observers)
    else
        tDeleteItem(observers, func)
    end

    if #observers <= 0 then
        eventFrame:UnregisterEvent(event)
    end
end

-- 绕过暴雪的战斗中Show/HideUIPanel检查
local Delegate = EnumerateFrames()
while Delegate do
    if Delegate.SetUIPanel and issecurevariable(Delegate, 'SetUIPanel') then
        break
    end
    Delegate = EnumerateFrames(Delegate)
end

local function GetUIPanelAttribute(frame, name)
	if not frame:GetAttribute("UIPanelLayout-defined") then
	    local attributes = UIPanelWindows[frame:GetName()];
	    if not attributes then
			return;
	    end
		SetFrameAttributes(frame, attributes);
	end
	return frame:GetAttribute("UIPanelLayout-"..name);
end

function Addon:HideUIPanel(frame)
    if not frame or not frame:IsShown() then
        return
    end

    if frame.editModeManuallyShown or not GetUIPanelAttribute(frame, "area") then
        frame:Hide()
        return
    end

    Delegate:SetAttribute("panel-frame", frame);
    Delegate:SetAttribute("panel-skipSetPoint", skipSetPoint);
    Delegate:SetAttribute("panel-hide", true);
end