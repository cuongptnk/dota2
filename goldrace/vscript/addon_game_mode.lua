-- Generated from template

if CGoldRushGameMode == nil then
	CGoldRushGameMode = class({})
end

function Precache( context )
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
	GameRules.AddonTemplate = CGoldRushGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CGoldRushGameMode:InitGameMode()
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_GOODGUYS, 5 )
	GameRules:SetCustomGameTeamMaxPlayers( DOTA_TEAM_BADGUYS, 5 )
	
	GameRules:SetUseUniversalShopMode( true )
	GameRules:SetHeroSelectionTime( 30.0 )
	GameRules:SetPreGameTime (15)
	GameRules:SetPostGameTime( 60 )
	GameRules:SetGoldPerTick( 50 )
	
	
	GameRules:GetGameModeEntity():SetThink( "OnThink", self, 1 ) 
	
	
end

-- Evaluate the state of the game
function CGoldRushGameMode:OnThink()
	-- Stop thinking if game is paused
	if GameRules:IsGamePaused() == true then
        return 1
    end

    sum_good_guys = 0
    sum_bad_guys = 0
    for nPlayerID = 0, DOTA_MAX_TEAM_PLAYERS-1 do
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_GOODGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				gold = PlayerResource:GetGold(nPlayerID)
				sum_good_guys = sum_good_guys + gold 
			end
		end
		if PlayerResource:GetTeam( nPlayerID ) == DOTA_TEAM_BADGUYS then
			if PlayerResource:HasSelectedHero( nPlayerID ) then
				gold = PlayerResource:GetGold(nPlayerID)
				sum_bad_guys = sum_bad_guys + gold 
			end
		end
	end

	if sum_good_guys > 20000 then 
		GameRules:SetGameWinner( DOTA_TEAM_GOODGUYS )
	elseif sum_bad_guys > 20000 then 
		GameRules:SetGameWinner( DOTA_TEAM_BADGUYS )
	end




	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		--print( "Template addon script is running." )
	elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
		return nil
	end
	return 1
end