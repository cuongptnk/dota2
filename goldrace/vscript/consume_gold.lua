if consumeGold == nil then
	print ( '[consumeGold] creating consumeGold' )
	consumeGold = {} -- Creates an array to let us beable to index consumeGold when creating new functions
	consumeGold.__index = consumeGold
end
 
function consumeGold:new() -- Creates the new class
	print ( '[consumeGold] consumeGold:new' )
	o = o or {}
	setmetatable( o, consumeGold )
	return o
end
 
function consumeGold:start() -- Runs whenever the consumeGold.lua is ran
	print('[consumeGold] consumeGold started!')
end
 
function ConsumeGold(keys) -- keys is the information sent by the ability
	print( '[consumeGold] ConsumeGold Called' )
	--DeepPrintTable(keys)
	local hero = EntIndexToHScript( keys.caster_entindex ) -- EntIndexToHScript takes the keys.caster_entindex, which is the number assigned to the entity that ran the function from the ability, and finds the actual entity from it.
	if hero:IsHero()  then  
		local gold = keys.ability:GetCurrentCharges()
		local id = hero:GetPlayerID()
		PlayerResource:ModifyGold(id,gold, true, 0)
	end
end