var count = 0;
var id = Players.GetLocalPlayer();
var My_Bank_Account = 0;
var amount_select_text = $("#entry1").text;
var amount_select = 0;
ConvertAmountTextToInt();
var is_in_bank_zone = true; 
var team_id = -1 


function ConvertAmountTextToInt(gold) {
	if (amount_select_text == "100")
		amount_select = 100;
	else if (amount_select_text == "500")
		amount_select = 500;
	else if (amount_select_text == "1000")
		amount_select = 1000;
	else if (amount_select_text == "All" && $("#Radio1").checked == true) //deposit
		amount_select = gold;
	else if (amount_select_text == "All" && $("#Radio2").checked == true) //withdraw
		amount_select = My_Bank_Account;
}

function OnBankButtonPressed() {
	//GameUI.PingMinimapAtLocation( [-1018.375, 5598.75, 256]);
	if (count % 2 ==0)
		$("#BankMenu").style.visibility = "visible";
	else 
		$("#BankMenu").style.visibility = "collapse";
	count += 1;

}

function OnSubmitButtonPressed() {
	//Check if inside bank zone 
	if (is_in_bank_zone == true ) {
	
		var gold = Players.GetGold(id);
		//get text from dropdown panel
		if ($("#entry1") != null) {
			amount_select_text = $("#entry1").text;
		} else if ($("#entry2") != null)  {
			amount_select_text = $("#entry2").text;
		} else if ($("#entry3") != null)  {
			amount_select_text = $("#entry3").text;
		} else if ($("#entry4") != null)  {
			amount_select_text = $("#entry4").text;
		}
		//convert text to int 
		ConvertAmountTextToInt(gold);

		if ($("#Radio1").checked == true) { //deposit
			if (gold >= amount_select)
				GameEvents.SendCustomGameEventToServer( "Transaction", { "direction" : 0, "amount" : amount_select } );
		}
		else if (($("#Radio2").checked == true)){ //withdraw
			if (My_Bank_Account >= amount_select)
				GameEvents.SendCustomGameEventToServer( "Transaction", { "direction" : 1, "amount" : amount_select } );
		}

	}
	else {
		if (team_id == -1) {
			//get team_id for this local player 
			var goodGuyIDs = Game.GetPlayerIDsOnTeam( DOTATeam_t.DOTA_TEAM_GOODGUYS );
			var badGuyIDs = Game.GetPlayerIDsOnTeam( DOTATeam_t.DOTA_TEAM_BADGUYS );
			if (goodGuyIDs.indexOf(id) > -1)
				team_id = DOTATeam_t.DOTA_TEAM_GOODGUYS;
			else if (badGuyIDs.indexOf(id) > -1)
				team_id = DOTATeam_t.DOTA_TEAM_BADGUYS;
		}
		//team_id is already set
		
		if (team_id == DOTATeam_t.DOTA_TEAM_GOODGUYS) {
			GameUI.PingMinimapAtLocation( [-1018.375, 5598.75, 256] );
		}
		else if (team_id == DOTATeam_t.DOTA_TEAM_BADGUYS) {
			GameUI.PingMinimapAtLocation( [381.6875, -5467.375, 256] );
		}
		
	}
}

function OnReceiveBankBalanceEvent( event_data )
{
	//$.Msg( "On Receive Bank Balance: ", event_data['money_in_bank'] );
	if (id == event_data['identity']) {
		My_Bank_Account = event_data['money_in_bank'];
		$("#BankAccount").text = "Your Bank Balance : " + My_Bank_Account.toString();
	}
	if (event_data['team_id'] == DOTATeam_t.DOTA_TEAM_GOODGUYS)
		$("#RadiantBank").text = "Radiant Bank : " + event_data['team_balance'];
	else if (event_data['team_id'] == DOTATeam_t.DOTA_TEAM_BADGUYS)
		$("#DireBank").text = "Dire Bank : " + event_data['team_balance'];
}
 
function OnEnterBankZoneEvent( event_data )
{
	if (id == event_data['identity']) {
		$.Msg( "On Enter Bank Zone JS ");
		is_in_bank_zone = true;
	}
}

function OnLeaveBankZoneEvent( event_data )
{
	if (id == event_data['identity']) {
		$.Msg( "On Leave Bank Zone JS ");
		is_in_bank_zone = false;
	}
}

GameEvents.Subscribe( "SendBankToClient", OnReceiveBankBalanceEvent);
GameEvents.Subscribe( "EnterBankZone", OnEnterBankZoneEvent);
GameEvents.Subscribe( "LeaveBankZone", OnLeaveBankZoneEvent);