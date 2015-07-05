function Activate()
	
end

function OnBankTriggerEnter(trigger)

	--print ("Enter Bank Trigger")
	--DeepPrintTable(trigger.activator)
	--DeepPrintTable(trigger.caller)
	print (trigger.activator:GetPlayerID())
	local event_data =
	{
		identity = trigger.activator:GetPlayerID()
	}
	--CustomGameEventManager:Send_ServerToPlayer( trigger.activator,"EnterBankZone", event_data )
	CustomGameEventManager:Send_ServerToAllClients( "EnterBankZone", event_data )

end
 
function OnBankTriggerLeave(trigger)
	--DeepPrintTable(trigger.activator)
	--DeepPrintTable(trigger.caller)

	--print ("Leave Bank Trigger")
	print (trigger.activator:GetPlayerID())
	
	local event_data =
	{
		identity = trigger.activator:GetPlayerID()
	}
	--CustomGameEventManager:Send_ServerToPlayer( trigger.activator,"LeaveBankZone", event_data )
	CustomGameEventManager:Send_ServerToAllClients( "LeaveBankZone", event_data )
 
end