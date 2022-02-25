
if not PathGraph then
  PathGraph = class({})
end

local tCorners = Entities:FindAllByClassname('path_corner')
local tNameIndexed = {}
for _, hCorner in pairs( tCorners ) do
	hCorner.tPrevs = {}
	
	local sName = hCorner:GetName()
	tNameIndexed[ sName ] = hCorner
	
	local tSorces = Entities:FindAllByTarget( sName )
	for _, hSource in pairs( tSorces ) do
		if hSource:GetClassname() == 'path_corner' then
			hSource.hNext = hCorner
			hCorner.tPrevs[ hSource ] = true
		end
	end
end

function PathGraph:GetPathCorner( sName )
	return tNameIndexed[ sName ]
end

function PathGraph:DrawPathCorners(pathCornerName, duration, color)
	duration = duration or 10
	color = color or Vector(255,255,255)
	local path_corner = PathGraph:GetPathCorner( pathCornerName )
	
	if path_corner ~= nil then
		if pathCorner:GetClassname() ~= "path_corner" then
		   ----print("[PathGraph] An invalid path_corner was passed to PathGraph:DrawPaths.")
		  return
		end

		local corner = path_corner
		local edges = corner.tPrevs
		DebugDrawCircle(corner:GetAbsOrigin(), color, 50, 20, true, duration)
		seen[corner:entindex()] = corner

		local next_edge = corner.hNext 
		if hNext then
			DebugDrawLine_vCol(corner:GetAbsOrigin(), next_edge:GetAbsOrigin(), color, true, duration)
		end

		for edge,_ in pairs(edges) do
		--		if seen[index] == nil then
			  DebugDrawLine_vCol(corner:GetAbsOrigin(), edge:GetAbsOrigin(), color, true, duration)
		--		  table.insert(toDo, edge)
		--		end
		end
	else
		for _, path_corner in pairs (tCorners) do
			local corner = path_corner
			local edges = corner.tPrevs
			DebugDrawCircle(corner:GetAbsOrigin(), color, 50, 20, true, duration)
			seen[corner:entindex()] = corner

			local next_edge = corner.hNext 
			if hNext then
				DebugDrawLine_vCol(corner:GetAbsOrigin(), next_edge:GetAbsOrigin(), color, true, duration)
			end

			for edge,_ in pairs(edges) do
			--		if seen[index] == nil then
				DebugDrawLine_vCol(corner:GetAbsOrigin(), edge:GetAbsOrigin(), color, true, duration)
			--		  table.insert(toDo, edge)
			--		end
			end	
		end	
	end
end

function PathGraph:MoveToCorner( hUnit, hCorner, nOffset, bQueue )
-- This function have limit for count of coreners 25, so use another function	
	if hCorner then
		local vPos = hCorner:GetOrigin()
		if nOffset then
			vPos = vPos + RandomRangeVector( nOffset )
		end
		
		ExecuteOrderFromTable({
			UnitIndex = hUnit:entindex(), 
			OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
			Position = vPos,
			Queue = bQueue and 1 or 0
		})
		
		if exist( hCorner.hNext ) and hCorner.hNext ~= hCorner then
			self:MoveToCorner( hUnit, hCorner.hNext, nOffset, true )
		end
	end
end


local TableCount = function(t)
  local n = 0
  for _ in pairs( t ) do
    n = n + 1
  end
  return n
end

function PathGraph:OnGameRulesStateChange()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_CUSTOM_GAME_SETUP then
		PathGraph:Initialize()
	end
end

function PathGraph:Initialize()
  local corners = Entities:FindAllByClassname('path_corner')
  local points = {} 
  for _,corner in ipairs(corners) do
    points[corner:entindex()] = corner
  end

  local names = {}

  for _,corner in ipairs(corners) do
    local name = corner:GetName()
    if names[name] ~= nil then
       ----print("[PathGraph] Initialization error, duplicate path_corner named '" .. name .. "' found. Skipping...")
    else
      local parents = Entities:FindAllByTarget(corner:GetName())
      corner.edges = corner.edges or {}
      print("name = "..corner:GetName())
      
      for _,parent in ipairs(parents) do
      	print(parent:GetName())
       	corner.edges[parent:entindex()] = parent
        parent.edges = parent.edges or {}
        parent.edges[corner:entindex()] = corner
        parent.next_corner = corner
      end
    end
  end
end

function PathGraph:DrawPaths(pathCorner, duration, color)
  duration = duration or 10
  color = color or Vector(255,255,255)
  if pathCorner ~= nil then
    if pathCorner:GetClassname() ~= "path_corner" or pathCorner.edges == nil then
       ----print("[PathGraph] An invalid path_corner was passed to PathGraph:DrawPaths.")
      return
    end

    local seen = {}
    local toDo = {pathCorner}

    repeat 
      local corner = table.remove(toDo)
      local edges = corner.edges
      DebugDrawCircle(corner:GetAbsOrigin(), color, 50, 20, true, duration)
      seen[corner:entindex()] = corner

      for index,edge in pairs(edges) do
        if seen[index] == nil then
          DebugDrawLine_vCol(corner:GetAbsOrigin(), edge:GetAbsOrigin(), color, true, duration)
          table.insert(toDo, edge)
        end
      end
    until (#toDo == 0)
  else
    local corners = Entities:FindAllByClassname('path_corner')
    local points = {} 
    for _,corner in ipairs(corners) do
      points[corner:entindex()] = corner
    end

    repeat 
      local seen = {}
      local k,v = next(points)
      local toDo = {v}

      repeat 
        local corner = table.remove(toDo)
        points[corner:entindex()] = nil
        local edges = corner.edges
        DebugDrawCircle(corner:GetAbsOrigin(), color, 50, 20, true, duration)
        seen[corner:entindex()] = corner

        for index,edge in pairs(edges) do
          if seen[index] == nil then
            DebugDrawLine_vCol(corner:GetAbsOrigin(), edge:GetAbsOrigin(), color, true, duration)
            table.insert(toDo, edge)
          end
        end
      until (#toDo == 0)
    until (TableCount(points) == 0)
  end
end

function MoveToNextCornerThink(unit, corner_name)
	if unit:IsNull() or not unit:IsAlive() then return nil end

	if unit.current_corner == nil then
		unit.current_corner = Entities:FindByName(nil, corner_name)
		if unit.current_corner == nil then
			print("path corner with name of '"..corner_name.."' not exist!")
			return
		end
	end

	local current_corner = unit.current_corner
	local next_corner = current_corner.next_corner or nil
	local point_corner = unit.current_corner:GetAbsOrigin()
	local point_unit = unit:GetAbsOrigin()
	local vector_dist = (point_corner - point_unit):Length2D()

	if  vector_dist < 25 then 		
		if next_corner then
			unit.current_corner = next_corner
		else
			print("next corner for '"..current_corner:GetName().."' not exist!")
			return
		end
	else
		unit:MoveToPosition(point_corner)
--		Timers:CreateTimer(0, function()
--[[			ExecuteOrderFromTable({
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = point_corner,
				Queue = false,
			})
]]--		end)
		
	end

	
	return 0.1
end

function MoveToNextCornerCycleThink(unit, corner_name)
	if unit:IsNull() or not unit:IsAlive() then return nil end

	if unit.current_corner == nil then
		unit.current_corner = Entities:FindByName(nil, corner_name)
		if unit.current_corner == nil then
			print("path corner with name of '"..corner_name.."' not exist!")
			return
		end
	end

	local current_corner = unit.current_corner
	local next_corner = current_corner.next_corner or nil
	local point_corner = unit.current_corner:GetAbsOrigin()
	local point_unit = unit:GetAbsOrigin()
	local vector_dist = (point_corner - point_unit):Length2D()

	if  vector_dist < 25 then 		
		if next_corner then
			unit.current_corner = next_corner
		else
--			print("next corner for '"..current_corner:GetName().."' not exist!")
			UTIL_Remove(unit)
			return
		end
	else
		unit:MoveToPosition(point_corner)
--		Timers:CreateTimer(0, function()
--[[			ExecuteOrderFromTable({
				UnitIndex = unit:entindex(),
				OrderType = DOTA_UNIT_ORDER_ATTACK_MOVE,
				Position = point_corner,
				Queue = false,
			})
]]--		end)
		
	end

	return 0.1
end

function CDOTA_BaseNPC:SetInitialWaypoint(corner_name)
	self:SetContextThink( "Think", function()
		return MoveToNextCornerThink(self, corner_name) end,
		 0.1 )
end

function CDOTA_BaseNPC:SetInitialWaypointCycle(corner_name)
	self:SetContextThink( "Think", function()
		return MoveToNextCornerCycleThink(self, corner_name) end,
		 0.1 )
end

ListenToGameEvent( "game_rules_state_change", Dynamic_Wrap( PathGraph, "OnGameRulesStateChange" ), PathGraph )
