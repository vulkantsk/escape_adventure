

local triggerActive = true

function OnStartTouch(trigger)
	local triggerName = thisEntity:GetName()
	local activator = trigger.activator
	--print("Trap Button Trigger Entered")
	local button = triggerName .. "_button"
	local model = triggerName .. "_model"
	local npc = Entities:FindByName( nil, triggerName .. "_npc" )
	local target = Entities:FindByName( nil, triggerName .. "_target" )
	local fireTrap = npc:FindAbilityByName("breathe_fire")
	if not triggerActive then
		print( "Trap Skip" )
		return
	end
	triggerActive = false
--	thisEntity:EmitSound( "ui.ui_player_disconnected" )
	local reset_time = 1
	npc:SetContextThink( "ResetButtonModel", reset_time, 1 )
--	npc:CastAbilityOnPosition(target:GetOrigin(), fireTrap, -1 )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_down", 0, self, self )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_down_idle", .35, self, self )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_up", reset_time, self, self )
	DoEntFire( button, "SetAnimation", "ancient_trigger001_idle", reset_time + 0.25, self, self )
	
	local pos1 = activator:GetAbsOrigin() 
	local pos2 = target:GetAbsOrigin() 
	local distance = (pos1 - pos2):Length2D()
	local fw_vector = (pos1 - pos2)/distance

	local kv = {
	should_stun = 1,
	knockback_duration = 0.75,
	duration = 0.75,
	knockback_distance = distance,
	knockback_height = 300,
	center_x = pos1 - fw_vector.x,
	center_y = pos1 - fw_vector.y,
	center_z = pos1 - fw_vector.z
	}
	activator:AddNewModifier( activator, self, "modifier_knockback", kv )
end

function OnEndTouch(trigger)
	local triggerName = thisEntity:GetName()
	local team = trigger.activator:GetTeam()
	--print("Trap Button Trigger Exited")
	local heroIndex = trigger.activator:GetEntityIndex()
	local heroHandle = EntIndexToHScript(heroIndex)
end

function ResetButtonModel()
--	print( "Trap RESET" )
	triggerActive = true
end

