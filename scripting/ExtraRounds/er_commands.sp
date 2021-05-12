public Action Call_round(int client, int args){
	if (!check_status(client))return Plugin_Handled;
	if(b_OnExtraRound){
		if(i_round_time == 0){
			CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "OnExtraRoundEnd");
			return Plugin_Handled;	
		}
		CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "OnExtraRound", i_round_time);
		return Plugin_Handled;
	}
	else if(b_VoteResult){
		CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "NextExtraRound", g_ExtraRounds[i_result_enumIndex].er_display_string);
		return Plugin_Handled;
	}
	else if(b_SendVote){
		CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "RoundEndVote");
		return Plugin_Handled;
	}
	else {
		if(bRound_iptal){
			CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "OnExtraRoundEnd");
		}else{
			CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "Call_round", (g_iVotingTime * 60) - i_vote_time);
		}
	}
	return Plugin_Handled;
}
public Action Call_roundIptal(int client, int args){
	if (!check_status(client))return Plugin_Handled;
	if (b_OnExtraRound){
		function_Sifirla(1);
		CPrintToChatAll("{darkred}%s %t", g_sPluginTitle, "RoundIptal", client);
	}else{
		CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "RoundIptalError");
	}
	return Plugin_Handled;
}
public Action Call_roundReload(int client, int args){
	if (!check_status(client))return Plugin_Handled;
	if(b_OnExtraRound || b_SendVote || b_VoteResult){
		CPrintToChatAll("{darkred}%s {green}Şuan ayarları tekrar yüklemek için uygun değil.(not available now)", g_sPluginTitle);
		return Plugin_Handled;
	}
	SetSettings();
	CPrintToChatAll("{darkred}%s {green}Ayarlar başarıyla tekrar yüklendi.(Success)", g_sPluginTitle);
	return Plugin_Handled;
}
public Action Call_roundList(int client, int args){
	if (!check_status(client))return Plugin_Handled;
	RoundList(client);
	return Plugin_Handled;
}
public int menu_roundlist(Menu menu, MenuAction action, int client, int item){
	switch (action){
		case MenuAction_Select:{
			Menu menu2 = CreateMenu(menu_menu_roundlist);
			SetMenuExitBackButton(menu2, true);
			SetMenuExitButton(menu2, true);
			SetMenuTitle(menu2, "%s\n%s", mtag);
			AddMenuItem(menu2, "", "Geri");
			DisplayMenu(menu2, client, MENU_TIME_FOREVER);
		}
		case MenuAction_End:{
			delete menu;
		}		
	}
}
public int menu_menu_roundlist(Menu menu, MenuAction action, int client, int item){

}
public void OnClientSayCommand_Post(int client, const char[] command, const char[] args){
	if (check_status(client) && GetUserFlagBits(client) & (g_sAdminFlag | ADMFLAG_ROOT)){
		for (int i = 0; i < i_toplam_ER; i++) {
			if (!StrEqual(g_ExtraRounds[i].er_shortcut, "Undefined")){
				if (!strcmp(args, g_ExtraRounds[i].er_shortcut, false)) {
					if(b_OnExtraRound){
						CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "ShortcutError");
						return;
					}					
					function_Sifirla(0, 1);
					CPrintToChatAll("{darkred}%s %t", g_sPluginTitle, "ShortcutSuccess", client, g_ExtraRounds[i].er_display_string);
					b_VoteResult = true;
					i_result_enumIndex = g_ExtraRounds[i].er_index;
				}
			}
		}
	}
}