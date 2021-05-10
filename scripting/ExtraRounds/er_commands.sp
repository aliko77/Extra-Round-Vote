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
public void OnClientSayCommand_Post(int client, const char[] command, const char[] args){
	if (check_status(client) && GetUserFlagBits(client) & (g_sAdminFlag | ADMFLAG_ROOT)){
		for (int i = 0; i < i_toplam_ER; i++) {
			if(b_OnExtraRound){
				CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "ShortcutError");
				return;
			}			
			if (!StrEqual(g_ExtraRounds[i].er_shortcut, "Undefined")){
				if (!strcmp(args, g_ExtraRounds[i].er_shortcut, false)) {
					function_Sifirla(0, 1);
					CPrintToChatAll("{darkred}%s %t", g_sPluginTitle, "ShortcutSuccess", client, g_ExtraRounds[i].er_display_string);
					b_VoteResult = true;
					i_result_enumIndex = g_ExtraRounds[i].er_index;
				}
			}
		}
	}
}