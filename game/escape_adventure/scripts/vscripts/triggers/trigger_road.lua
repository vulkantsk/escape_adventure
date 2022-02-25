function OnStartTouch(data)
	local triggerName = thisEntity:GetName()
	local ent_index = thisEntity:entindex()
	local unit = data.activator
	local unit_name = unit:GetUnitName()
	local team = unit:GetTeam()

	if team == DOTA_TEAM_NEUTRALS then
		return
	end

	if unit.trigger_count == nil then
		unit.trigger_count = 0
	end

	unit.trigger_count = unit.trigger_count + 1
--	print("trigger_count = "..unit.trigger_count)
end

function OnEndTouch(data)
	local triggerName = thisEntity:GetName()
	local ent_index = thisEntity:entindex()
	local unit = data.activator
	local unit_name = unit:GetUnitName()
	local team = unit:GetTeam()

	if team == DOTA_TEAM_NEUTRALS then
		return
	end	

	unit.trigger_count = unit.trigger_count - 1
--	print("trigger_count = "..unit.trigger_count)
	if unit.trigger_count == 0 and not unit.toss then
		unit:ForceKill(false)
	end	
end