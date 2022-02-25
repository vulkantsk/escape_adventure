
if ItemDrop == nil then
	_G.ItemDrop = class({})
end

ItemDrop.item_drop = {
--		{items = {"item_branches"}, chance = 5, duration = 5, limit = 3, units = {} },
--		{items = {"item_belt_of_strength","item_boots_of_elves","item_robe"}, chance = 10, limit = 5, units = {"npc_dota_neutral_kobold","npc_dota_neutral_centaur_outrunner"}},--50% drop from list with limit
		{items = {"item_flask_1"}, chance = 12, duration = 15},

		{items = {"item_baseitem_scroll"}, units = {"npc_creep_chest"}, chance = 25, duration = 10},

		{items = {"item_scroll_1"}, units = {"npc_creep_1"}, chance = 17, duration = 20},
		{items = {"item_scroll_2"}, units = {"npc_creep_2"}, chance = 15, duration = 20},
		{items = {"item_scroll_3"}, units = {"npc_creep_3"}, chance = 13, duration = 20},
		{items = {"item_scroll_4"}, units = {"npc_creep_4"}, chance = 12, duration = 20},
		{items = {"item_scroll_5"}, units = {"npc_creep_5"}, chance = 10, duration = 20},
		{items = {"item_scroll_6"}, units = {"npc_creep_6"}, chance = 10, duration = 20},
		{items = {"item_scroll_7"}, units = {"npc_creep_7"}, chance = 10, duration = 20},
		{items = {"item_scroll_8"}, units = {"npc_creep_8"}, chance = 10, duration = 20},

		{items = {"item_powerup_1"}, units = {"npc_boss_1"}, chance = 65, duration = 20},
		{items = {"item_powerup_2"}, units = {"npc_boss_2"}, chance = 65, duration = 20},
		{items = {"item_powerup_3"}, units = {"npc_boss_3"}, chance = 65, duration = 20},
		{items = {"item_powerup_4"}, units = {"npc_boss_4"}, chance = 65, duration = 20},
		{items = {"item_powerup_5"}, units = {"npc_boss_5"}, chance = 65, duration = 20},
		{items = {"item_powerup_6"}, units = {"npc_boss_6"}, chance = 65, duration = 20},
		{items = {"item_powerup_7"}, units = {"npc_boss_7"}, chance = 65, duration = 20},
		
		{items = {"item_endgame"}, units = {"npc_boss_8"}, chance = 75, duration = 20},
}

ItemDrop.secret_items = {
--	["point_name"] = "item_name",
	["item_spawner_key_simple"] = "item_key_simple",
	["item_spawner_key_enique"] = "item_key_enique",


}
function ItemDrop:InitGameMode()
	ListenToGameEvent('entity_killed', Dynamic_Wrap(self, 'OnEntityKilled'), self)
	ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(self, 'OnGameRulesStateChange'), self)
end

function ItemDrop:OnGameRulesStateChange()
	local newState = GameRules:State_Get()

	if newState == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		ItemDrop:SpawnItems()
	end
end

function ItemDrop:SpawnItems()
	local items = self.secret_items
	for point_name,item_name in pairs(items) do
		local points = Entities:FindAllByName(point_name)
		for _,point in pairs(points) do
			point = point:GetAbsOrigin()
			local newItem = CreateItem( item_name, nil, nil )
			local drop = CreateItemOnPositionSync( point, newItem )
			newItem.spawn_point = point
		end

		if #points == 0 then
			print("point with name "..point_name.." dont exist !")
		end
	end
end

function ItemDrop:OnEntityKilled( keys )
	local killedUnit = EntIndexToHScript( keys.entindex_killed )
	local name = killedUnit:GetUnitName()
	local team = killedUnit:GetTeam()

	if team ~= DOTA_TEAM_GOODGUYS and name ~= "npc_dota_thinker" then
		ItemDrop:RollItemDrop(killedUnit)
	end

end

function ItemDrop:RollItemDrop(unit)
	local unit_name = unit:GetUnitName()

	for _,drop in ipairs(self.item_drop) do
		local items = drop.items or nil
		local items_num = #items
		local units = drop.units or nil -- если юниты не были определены, то срабатывает для любого
		local chance = drop.chance or 100 -- если шанс не был определен, то он равен 100
		local loot_duration = drop.duration or nil -- длительность жизни предмета на земле
		local limit = drop.limit or nil -- лимит предметов
		local item_name = items[1] -- название предмета
		local roll_chance = RandomFloat(0, 100)
			
		if units then 
			for _,current_name in pairs(units) do
				if current_name == unit_name then
					units = nil
					break
				end
			end
		end

		if units == nil and (limit == nil or limit > 0) and roll_chance < chance then
			if limit then
				drop.limit = drop.limit - 1
			end

			if items_num > 1 then
				item_name = items[RandomInt(1, #items)]
			end

			local spawnPoint = unit:GetAbsOrigin()	
			local newItem = CreateItem( item_name, nil, nil )
			local drop = CreateItemOnPositionForLaunch( spawnPoint, newItem )
			local dropRadius = RandomFloat( 50, 100 )

			newItem:LaunchLootInitialHeight( false, 0, 150, 0.5, spawnPoint + RandomVector( dropRadius ) )
			if loot_duration then
				newItem:SetContextThink( "KillLoot", 
					function() 
						if drop:IsNull() then
							return
						end

						local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
						ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
						ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
						ParticleManager:ReleaseParticleIndex( nFXIndex )
					--	EmitGlobalSound("Item.PickUpWorld")

						UTIL_Remove( item )
						UTIL_Remove( drop )
					end, loot_duration )
			end
		end
	end	
end

function KillLoot( item, drop )

	if drop:IsNull() then
		return
	end

	local nFXIndex = ParticleManager:CreateParticle( "particles/items2_fx/veil_of_discord.vpcf", PATTACH_CUSTOMORIGIN, drop )
	ParticleManager:SetParticleControl( nFXIndex, 0, drop:GetOrigin() )
	ParticleManager:SetParticleControl( nFXIndex, 1, Vector( 35, 35, 25 ) )
	ParticleManager:ReleaseParticleIndex( nFXIndex )
--	EmitGlobalSound("Item.PickUpWorld")

	UTIL_Remove( item )
	UTIL_Remove( drop )
end

ItemDrop:InitGameMode()