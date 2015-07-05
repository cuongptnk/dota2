TIME_THRESHOLD = 60 * 15


banks = {}
for i= 0, 9 do
  banks[i] = 0
end

if CGoldRaceGameMode == nil then
	CGoldRaceGameMode = class({})
end

function Precache( context )

	PrecacheItemByNameSync( "item_bag_of_gold", context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CGoldRaceGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function OnEventTransaction( eventSourceIndex, args )
	if GameRules:IsGamePaused() == true then
        return 1
    end
	
	-- print( "My event: ( " .. eventSourceIndex .. " )" )
	local id = args['PlayerID']
	-- add to bank 
	if args['direction'] == 0 and PlayerResource:GetGold(id) >= args['amount'] then 
		banks[id] = banks[id] + args['amount']
		PlayerResource:SpendGold(id, args['amount'],0)
	-- withdraw from bank 
	elseif banks[id] >= args['amount'] then
		banks[id] = banks[id] - args['amount']
		PlayerResource:ModifyGold(id,args['amount'], true, 0)
	end
	local event_data =
	{
		identity = id,
		money_in_bank = banks[id],
		team_id = 0,
		team_balance = 0,
	}
	
	-- print(banks[id])
	
	--recompute radiant bank and dire bank 
	local sum_good_guys = 0
    local sum_bad_guys = 0
	local gold = 0
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				gold = banks[nPlayerID]
				sum_good_guys = sum_good_guys + gold 
			end
		end
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				gold = banks[nPlayerID]
				sum_bad_guys = sum_bad_guys + gold 
			end
		end
	end
	--update event data 
	if PlayerResource:GetTeam(id) == DOTA_TEAM_GOODGUYS then
		event_data['team_id'] = DOTA_TEAM_GOODGUYS
		event_data['team_balance'] = sum_good_guys
	elseif PlayerResource:GetTeam(id) == DOTA_TEAM_BADGUYS then
		event_data['team_id'] = DOTA_TEAM_BADGUYS
		event_data['team_balance'] = sum_bad_guys
	end 
	
	-- send new bank balance to client
	CustomGameEventManager:Send_ServerToAllClients( "SendBankToClient", event_data )
end

function CGoldRaceGameMode:InitGameMode()
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime (5)
	GameRules:SetPostGameTime( 60 )
	GameRules:SetGoldPerTick( 0 )
	
	--Convars:RegisterCommand( "holdout_spawn_gold", function(...) return self._GoldDropConsoleCommand( ... ) end, "Spawn a gold bag.", FCVAR_CHEAT )
	

	ListenToGameEvent( "dota_player_gained_level", Dynamic_Wrap( CGoldRaceGameMode, "OnPlayerGainLevel" ), self )
	ListenToGameEvent( "dota_player_killed", Dynamic_Wrap( CGoldRaceGameMode, "OnPlayerKilled" ), self )

	CustomGameEventManager:RegisterListener( "Transaction", OnEventTransaction )
	
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 
	
	
end

function CGoldRaceGameMode:OnPlayerGainLevel(eventInfo)
	DeepPrintTable(eventInfo)
	--print ("Hello World")

	local heroEnt = EntIndexToHScript(eventInfo.player):GetAssignedHero()
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )
	

	newItem:SetCurrentCharges( 100 )
	local spawnPoint = Vector( 0, 0, 0 )
	if heroEnt ~= nil then
		spawnPoint = heroEnt:GetAbsOrigin()
	end
	
	print ("SpawnPoint : " ,spawnPoint)

	CreateItemOnPositionSync( spawnPoint, newItem )

end

function CGoldRaceGameMode:OnPlayerKilled(eventInfo)
	DeepPrintTable(eventInfo)
	--print ("Hello World")
	local id = eventInfo.PlayerID
	local gold = PlayerResource:GetGold(id)
	PlayerResource:SpendGold(id, gold,0)
	
	local newItem = CreateItem( "item_bag_of_gold", nil, nil )
	newItem:SetPurchaseTime( 0 )

	newItem:SetCurrentCharges( gold )
	local spawnPoint = Vector( 0, 0, 0 )
	local heroEnt = PlayerResource:GetPlayer(id):GetAssignedHero()
	if heroEnt ~= nil then
		spawnPoint = heroEnt:GetAbsOrigin()
	end

	CreateItemOnPositionSync( spawnPoint, newItem )
	--newItem:LaunchLoot( false, 300, 0.75, spawnPoint  )
end

-- Evaluate the state of the game
function CGoldRaceGameMode:OnThink()
	-- Stop thinking if game is paused
	if GameRules:IsGamePaused() == true then
        return 1
    end

    local sum_good_guys = 0
    local sum_bad_guys = 0
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				gold = banks[nPlayerID]
				sum_good_guys = sum_good_guys + gold 
			end
		end
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				gold = banks[nPlayerID]
				sum_bad_guys = sum_bad_guys + gold 
			end
		end
	end

	time = GameRules:GetDOTATime(false, false)
	if time >  TIME_THRESHOLD then 
		if sum_good_guys > sum_bad_guys then 
			GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
		elseif sum_bad_guys > sum_good_guys then 
			GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
		else 
			TIME_THRESHOLD = TIME_THRESHOLD + 60 
		end 
	end 
	
	
	
	
	




	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end