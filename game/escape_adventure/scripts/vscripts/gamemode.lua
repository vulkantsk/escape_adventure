if GameMode == nil then
	_G.GameMode = class({})
end

function GameMode:InitGameMode()
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
	ListenToGameEvent("npc_spawned",Dynamic_Wrap( self, 'OnNPCSpawned' ), self )
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)

end

function GameMode:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		self:InitGuards()
	end
end


function GameMode:OnNPCSpawned(keys)
--	print("[BAREBONES] NPC Spawned")
--	DeepPrintTable(keys)
	local npc = EntIndexToHScript(keys.entindex)
	local name = npc:GetUnitName()
	
	if npc:IsRealHero() and npc.bbFirstSpawned == nil then
--		GameSpawner:OnHeroInGame(npc)			
		npc.bbFirstSpawned = true
		local playerID = npc:GetPlayerID()
		local steamID = PlayerResource:GetSteamAccountID(playerID)

		local ability = npc:FindAbilityByName("survior_passive"):SetLevel(1)
		local ability = npc:FindAbilityByName("sled_penguin_active"):SetLevel(1)
	elseif npc:IsRealHero() and npc.spawn_point then
		npc:SetAbsOrigin(npc.spawn_point)
	end
end

function GameMode:InitGuards()
	patrol_guards = {
		{	unit_name = "npc_patrol_guard_kobold", 
			spawn_points = {"path_corner_patrol_1_1","path_corner_patrol_1_2",}
		},-- patrol guard example #1
		{	unit_name = "npc_patrol_guard_ogre", 
			spawn_points = {"path_corner_patrol_3_1","path_corner_patrol_3_3",}
		},-- patrol guard example #2
	}
	cycle_guards = {
		{	unit_name = "npc_cycle_guard_mud_golem", 
			spawn_interval = 1.5,
			spawn_points = {"path_corner_cycle_1_1","path_corner_cycle_2_1",}
		},-- cycle guard example #2
		{	unit_name = "npc_cycle_guard_rock_golem", 
			spawn_interval = 2,
			spawn_points = {"path_corner_cycle_3_1","path_corner_cycle_4_1",}
		},-- cycle guard example #2
	}

	for _,patrol in pairs(patrol_guards) do
		local unit_name = patrol.unit_name
		local points = patrol.spawn_points
		
		for _,point_name in pairs(points) do
			local point_origin = Entities:FindByName(nil, point_name):GetAbsOrigin()
			local unit = CreateUnitByName(unit_name, point_origin, false, nil, nil, DOTA_TEAM_NEUTRALS)
			unit:SetInitialWaypoint(point_name)
		end
	end

	for _,cycle in pairs(cycle_guards) do
		local unit_name = cycle.unit_name
		local points = cycle.spawn_points
		local spawn_interval = cycle.spawn_interval
		
		for _,point_name in pairs(points) do
			local point_origin = Entities:FindByName(nil, point_name):GetAbsOrigin()
			Timers:CreateTimer(0, function()
				local unit = CreateUnitByName(unit_name, point_origin, false, nil, nil, DOTA_TEAM_NEUTRALS)
				unit:SetInitialWaypointCycle(point_name)
				return spawn_interval
			end)
		end
	end
end

function GameMode:OnEntityKilled(keys)

	local unit = EntIndexToHScript(keys.entindex_killed)
	local unit_name = unit:GetUnitName()
	
	if unit_name == "npc_goodguys_fort" then
		GameRules:SetGameWinner(DOTA_TEAM_BADGUYS)		
	end

	if unit.reward then
		local ent_index = unit:entindex()
		
		self.current_units[ent_index] = nil
		local units = 0
		for key,value in pairs(self.current_units) do
			units = units + 1
		end

		if units == 0 then
			local current_wave = self.wave_list[self.wave_number]
			local reward_gold = current_wave.reward_gold
			local reward_exp = current_wave.reward_exp

			GiveGoldPlayers( reward_gold )
			GiveExperiencePlayers( reward_exp )
			GameMode:LineBossSpawner()
		end
	end
end

function GiveGoldPlayers( gold )
	for index=0 ,4 do
		if PlayerResource:HasSelectedHero(index) then
			local player = PlayerResource:GetPlayer(index)
			local hero = PlayerResource:GetSelectedHeroEntity(index)
			hero:ModifyGold(gold, false, 0)
			SendOverheadEventMessage( player, OVERHEAD_ALERT_GOLD, hero, gold, nil )
		end
	end
end

function GiveExperiencePlayers( experience )
	for index=0 ,4 do
		if PlayerResource:HasSelectedHero(index) then
			local player = PlayerResource:GetPlayer(index)
			local hero = PlayerResource:GetSelectedHeroEntity(index)
			hero:AddExperience(experience, 0, false, true )
		end
	end
end

GameMode:InitGameMode()