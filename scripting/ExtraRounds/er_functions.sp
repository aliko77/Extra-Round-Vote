void function_SettingsThenSettings(){
	if (!t_vote_timer)t_vote_timer = CreateTimer(1.0, timer_func_vote, _, TIMER_REPEAT);
}
public Action timer_func_vote(Handle timer){
	if (t_vote_timer != timer){
		return Plugin_Stop;
	}
	i_vote_time++;
	if(i_vote_time >= (g_iVotingTime * 60)){
		b_SendVote = true;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
public Action timer_func_round(Handle timer){
	if(t_round_timer != timer){
		return Plugin_Stop;
	}
	i_round_time--;
	if (i_round_time <= 0){
		b_RoundTimeIsUp = true;
		CPrintToChatAll("{darkred}%s %t", g_sPluginTitle, "RoundTimeEnd");
		return Plugin_Stop;
	}
	return Plugin_Continue;
}
bool check_status(int client){
	return (IsClientInGame(client) && !IsFakeClient(client));
}
public Action TMR_uyari(Handle timer){
	for (int i = 1; i <= MaxClients; i++){
		if (check_status(i)){
			Handle hHudText = CreateHudSynchronizer();
			SetHudTextParams(-1.0, -0.60, 3.0, 153, 51, 51, 0, 2, 1.0, 0.1, 0.2);
			ShowSyncHudText(i, hHudText, g_ExtraRounds[i_result_enumIndex].er_hud_msg);
			CloseHandle(hHudText);
		}
	}	
}
///////
void func_SendVote(){
	ArrayList sended_index = CreateArray();
	Handle menu = CreateMenu(VoteMenuHandler, MenuAction_Select);
	SetMenuTitle(menu, "%s | %t", g_sPluginTitle, "SendVote_Title");
	SetMenuExitButton(menu, false);
	for (int i = 0; i < 6; i++){
		int random_int = GetRandomInt(0, i_toplam_ER - 1);
		if (FindValueInArray(sended_index, random_int) != -1){
			i--;
			continue;
		}
		char info[11];
		IntToString(random_int, info, 11);
		AddMenuItem(menu, info, g_ExtraRounds[random_int].er_display_string);
		sended_index.Push(random_int);
	}
	VoteMenuToAll(menu, 12, 0);
}
public int VoteMenuHandler(Menu menu, MenuAction action, int param1, int param2) // Oylama Bittiğinde
{
	if (action == MenuAction_VoteEnd && b_SendVote)
	{
		char result[48],
			dResult[48];
		GetMenuItem(menu, param1, result, 32, _, dResult, 48);
		CPrintToChatAll("{darkred}%s %t", g_sPluginTitle, "VoteResult", dResult);
		b_VoteResult = true;
		b_SendVote = false;
		i_result_enumIndex = StringToInt(result);
		CPrintToChatAll("{darkred}%s %t", g_sPluginTitle, "NextExtraRound", g_ExtraRounds[i_result_enumIndex].er_display_string);		
	}
	else if (action == MenuAction_End)
		delete menu;
}
/////////
void DoRound(int client){
	if (!check_status(client))return;
	if (!b_OnExtraRound || i_result_enumIndex == -1)return;
	StripAllWeapons(client);
	if (GivePlayerItem(client, g_ExtraRounds[i_result_enumIndex].er_weapon) != -1){
		if (!(StrEqual(g_ExtraRounds[i_result_enumIndex].er_weapon, "weapon_knife"))){
			GivePlayerItem(client, "weapon_knife");
		}
		if (!(StrEqual(g_ExtraRounds[i_result_enumIndex].er_extraItem, "Undefined"))){
			GivePlayerItem(client, g_ExtraRounds[i_result_enumIndex].er_extraItem);
		}
		if(g_ExtraRounds[i_result_enumIndex].er_armor > 0){
			SetEntProp(client, Prop_Data, "m_ArmorValue", 100, 1);
		}
		if(g_ExtraRounds[i_result_enumIndex].er_hp > 0){
			SetEntityHealth(client, g_ExtraRounds[i_result_enumIndex].er_hp);
		}
		if(g_ExtraRounds[i_result_enumIndex].er_speed != 1){
			SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", g_ExtraRounds[i_result_enumIndex].er_speed);
		}		
	}else{
		CPrintToChat(client, "{darkred}%s %t", g_sPluginTitle, "GivePlayerItemError", g_ExtraRounds[i_result_enumIndex].er_weapon);
	}
}
void function_Sifirla(int iptal = 0, int handle = 0){
	b_SendVote = false;
	b_VoteResult = false;
	b_OnExtraRound = false;
	b_RoundTimeIsUp = false;
	i_vote_time = 0;
	i_round_time = 0;
	if(t_round_timer)t_round_timer = null;
	if (t_vote_timer)t_vote_timer = null;
	i_result_enumIndex = -1;
	if(g_mapCmd.Length > 0){
		for (int i = 0; i < g_mapCmd.Length; i++){
			char sI[11],
				sConvarName[48],
				sConvarValue[48];
			IntToString(i, sI, 11);
			Handle trie = GetArrayCell(g_mapCmd, i);
			GetTrieString(trie, "ConvarName", sConvarName, 48);
			GetTrieString(trie, "ConvarValue", sConvarValue, 48);
			FindConVar(sConvarName).SetString(sConvarValue);
		}
		g_mapCmd.Clear();
	}	
	FindConVar("sv_gravity").SetInt(800);
	if(handle == 0){
		for (int i = 1; i <= MaxClients; i++){
			if (check_status(i)){
				StripAllWeapons(i);
				GivePlayerItem(i, "weapon_knife");
				GivePlayerItem(i, g_sDefaultSecondaryW);
				GivePlayerItem(i, g_sDefaultPrimaryW);
				SetEntityHealth(i, 100);
				SetEntProp(i, Prop_Data, "m_ArmorValue", 0, 1);
				SetEntPropFloat(i, Prop_Send, "m_flLaggedMovementValue", 1.0);
			}
		}
	}
	if(iptal == 1){
		bRound_iptal = true;
	}
	SetConVarInt(g_cvPredictionConVars[0], 0, true, false);
	SetConVarFloat(g_cvPredictionConVars[1], 0.55, true, false);
	SetConVarFloat(g_cvPredictionConVars[2], 3.5, true, false);
	SetConVarInt(g_cvPredictionConVars[3], 8, true, false);
	SetConVarInt(g_cvPredictionConVars[4], 18, true, false);
	SetConVarInt(g_cvPredictionConVars[5], 2, true, false);
	SetConVarInt(g_cvPredictionConVars[6], 4, true, false);	
}
stock void StripAllWeapons(int client)
{
    int iEnt;
    for (int i = 0; i <= 4; i++)
    {
		while ((iEnt = GetPlayerWeaponSlot(client, i)) != -1)
		{
            RemovePlayerItem(client, iEnt);
            AcceptEntityInput(iEnt, "Kill");
		}
    }
}
public Action SetFullAmmo(int client, int weapon){
	SetEntProp(weapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 999); //set reserve to 999
}
stock void SetNoScope(int weapon)
{
	if (IsValidEdict(weapon))
	{
		char classname[MAX_NAME_LENGTH];
		if (GetEdictClassname(weapon, classname, sizeof(classname))
			 || StrEqual(classname[7], "ssg08") || StrEqual(classname[7], "aug")
			 || StrEqual(classname[7], "sg550") || StrEqual(classname[7], "sg552")
			 || StrEqual(classname[7], "sg556") || StrEqual(classname[7], "awp")
			 || StrEqual(classname[7], "scar20") || StrEqual(classname[7], "g3sg1"))
		{
			SetEntDataFloat(weapon, m_flNextSecondaryAttack, GetGameTime() + 1.0);
		}
	}
}
char[] GetRoundInfo(int index){
	char buf[512];
	Format(buf, 512, "Round İsmi: %s", g_ExtraRounds[index].er_display_string);
	if (g_ExtraRounds[index].er_round_time != 45){
		Format(buf, 512, "%s\n"...
		"Round Süresi: %i sn", buf, g_ExtraRounds[index].er_round_time);
	}
	if (!StrEqual(g_ExtraRounds[index].er_weapon, "Undefined")){
		Format(buf, 512, "%s\n"...
		"Round Silahı: %s", buf, g_ExtraRounds[index].er_weapon);
	}
	if (g_ExtraRounds[index].er_only_hs != 0){
		Format(buf, 512, "%s\n"...
		"Only Hs: Açık", buf);
	}
	if (!StrEqual(g_ExtraRounds[index].er_hud_msg, "Undefined")){
		Format(buf, 512, "%s\n"...
		"Hud Mesajı: Mevcut", buf);
	}
	if (g_ExtraRounds[index].er_knife_dmg != 0){
		Format(buf, 512, "%s\n"...
		"Bıçak Hasarı: Açık", buf);
	}
	if (g_ExtraRounds[index].er_armor != 0){
		Format(buf, 512, "%s\n"...
		"Zırh ve Kask: Açık", buf);
	}
	if (g_ExtraRounds[index].er_hp != 0){
		Format(buf, 512, "%s\n"...
		"Can Ayarı: %i", buf, g_ExtraRounds[index].er_hp);
	}
	if (!StrEqual(g_ExtraRounds[index].er_shortcut, "Undefined")){
		Format(buf, 512, "%s\n"...
		"Kısa Yol: %s", buf, g_ExtraRounds[index].er_shortcut);
	}
	if (g_ExtraRounds[index].er_no_zoom != 0){
		Format(buf, 512, "%s\n"...
		"No Scoper: Aktif", buf);
	}
	if (g_ExtraRounds[index].er_gravity != -1){
		Format(buf, 512, "%s\n"...
		"Gravity: %i", buf, g_ExtraRounds[index].er_gravity);
	}
	if (g_ExtraRounds[index].er_speed != 1){
		Format(buf, 512, "%s\n"...
		"Oyuncu Hızı: %0.2f", buf, g_ExtraRounds[index].er_speed);
	}
	if (!StrEqual(g_ExtraRounds[index].er_extraItem, "Undefined")){
		Format(buf, 512, "%s\n"...
		"Extra İtem: %s", buf, g_ExtraRounds[index].er_extraItem);
	}
	if (g_ExtraRounds[index].er_no_recoil != 0){
		Format(buf, 512, "%s\n"...
		"Silah Sekmeme: Aktif", buf);
	}
	if (!StrEqual(g_ExtraRounds[index].er_cmd, "Undefined")){
		Format(buf, 512, "%s\n"...
		"Server Komut: Mevcut", buf);
	}	
	(g_ExtraRounds[index].er_enable == 1) ? Format(buf, 512, "%s\nRound Durumu: Aktif", buf) : Format(buf, 512, "%s\nRound Durumu: Deaktif", buf);
	return buf;
}