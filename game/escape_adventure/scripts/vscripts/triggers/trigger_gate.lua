

local triggerActive = true

function OnStartTouch(trigger)
	if not triggerActive then
		print( "Trap Skip" )
		return
	end
		
	local triggerName = thisEntity:GetName()
	local npc_activator = trigger.activator
	local team = npc_activator:GetTeam()
	local level = npc_activator:GetLevel()
	--print("Trap Button Trigger Entered")
	if npc_activator:HasItemInInventory("item_key_simple") or npc_activator:HasItemInInventory("item_key_enique") then
		local item = npc_activator:FindItemInInventory("item_key_simple") 
		if not item then
			item = npc_activator:FindItemInInventory("item_key_enique")
		end
		item:Destroy()
	else
		return
	end

	local gate = triggerName .. "_gate"
	local gate_ent = Entities:FindByName( nil, gate )
	local gate_origin = gate_ent:GetOrigin()
	local obstructions = Entities:FindAllByName(triggerName .. "_obstruction")

	triggerActive = false

	DoEntFire( gate, "SetAnimation", "gate_entrance002_open", 0, self, self )
--	DoEntFire( gate, "SetAnimation", "bindPose", 1, self, self )
	for _,obstruction in pairs (obstructions) do
		obstruction:RemoveSelf()
	end
	EmitGlobalSound("gate_open")
	GameRules:ExecuteTeamPing(team, gate_origin.x, gate_origin.y, npc_activator, 0)
	AddFOWViewer(team, gate_origin, 400, 10, false)


--	Timers:CreateTimer(4,function()
--		wall_ent:RemoveSelf()
--	end)

	local heroIndex = trigger.activator:GetEntityIndex()
	local heroHandle = EntIndexToHScript(heroIndex)
end



