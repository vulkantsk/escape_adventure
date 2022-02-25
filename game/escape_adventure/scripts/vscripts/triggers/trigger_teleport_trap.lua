

local triggerActive = true

function OnStartTouch(trigger)
	local triggerName = thisEntity:GetName()
	local activator = trigger.activator
	local target = Entities:FindByName( nil, triggerName .. "_target" )

	FindClearSpaceForUnit(activator, target:GetAbsOrigin(), true)
	activator:Stop()
	activator:EmitSound("Portal.Hero_Appear")
end



