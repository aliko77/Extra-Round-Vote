void SetSettings(){
	static char buffer[256];
	static char sPath[PLATFORM_MAX_PATH];
	KeyValues Kv = new KeyValues("Extra_Rounds");
	BuildPath(Path_SM, sPath, sizeof(sPath), "configs/ExtraRounds/settings.ini");
	if(!Kv.ImportFromFile(sPath))
	{
		SetFailState("%s %s - is not found", mtag, sPath);
	}
	Kv.GotoFirstSubKey();
	Kv.Rewind();
	Kv.JumpToKey("MainSettings");
	Kv.GetString("plugin_title", buffer, 64, "Extra Rounds");
	Format(g_sPluginTitle, 64, "[%s]", buffer);
	Kv.GetString("round_command_flag", buffer, 32, "d");
	g_sAdminFlag = ReadFlagString(buffer);
	Kv.GetString("voting_minute", buffer, 32, "10");
	g_iVotingTime = (StringToInt(buffer) < 1) ? 1 : StringToInt(buffer);
	Kv.GetString("extra_round_time", buffer, 32, "45");
	g_iRoundTime = (StringToInt(buffer) < 10) ? 10 : StringToInt(buffer);
	Kv.GetString("round_info_atHud", buffer, 256, "0");
	g_iRound_info = StringToInt(buffer) > 0 ? 1 : 0;
	Kv.GetString("default_primary_weapon", g_sDefaultPrimaryW, 32, "weapon_awp");
	Kv.GetString("default_secondary_weapon", g_sDefaultSecondaryW, 32, "weapon_deagle");
	Kv.Close();
	
	strcopy(sPath[strlen(sPath) - 12], 48, "extra_rounds.ini");
	if(!(Kv = new KeyValues("Extra_Rounds")).ImportFromFile(sPath))
	{
		SetFailState("%s | %s - is not found", mtag, sPath);
	}
	if(!(Kv.GotoFirstSubKey())){
		SetFailState("%s - Dosya bozuk.(file is corrupt) | %s", mtag, sPath);
	}
	Kv.Rewind();
	if(!(Kv.GotoFirstSubKey())){
		SetFailState("%s - Hiç Extra round ayarlanmamış.(No Extra round is set) | %s", mtag, sPath);
	}
	int i = 0;
	do{
		Kv.GetString("display_string", g_ExtraRounds[i].er_display_string, 48, "Undefined");
		Kv.GetString("round_time", buffer, 32, "45");
		g_ExtraRounds[i].er_round_time = (StringToInt(buffer) < 10) ? 10 :  StringToInt(buffer);
		Kv.GetString("weapon", g_ExtraRounds[i].er_weapon, 32, "Undefined");
		Kv.GetString("only_hs", buffer, 32, "0");
		g_ExtraRounds[i].er_only_hs = StringToInt(buffer);
		Kv.GetString("hud_msg", g_ExtraRounds[i].er_hud_msg, 512, "Undefined");
		if(g_iRound_info == 1){
			if (StrEqual(g_ExtraRounds[i].er_hud_msg, "Undefined"))
				Format(g_ExtraRounds[i].er_hud_msg, 512, "> %t <\n%s", "RoundInfoAtHud", g_ExtraRounds[i].er_display_string);
			else
				Format(g_ExtraRounds[i].er_hud_msg, 512, "> %t <\n%s\n%s", "RoundInfoAtHud", g_ExtraRounds[i].er_display_string, g_ExtraRounds[i].er_hud_msg);
		}
		Kv.GetString("knife_dmg", buffer, 32, "0");
		g_ExtraRounds[i].er_knife_dmg = StringToInt(buffer);
		Kv.GetString("armor", buffer, 32, "0");
		g_ExtraRounds[i].er_armor = StringToInt(buffer);
		Kv.GetString("hp", buffer, 32, "0");
		g_ExtraRounds[i].er_hp = StringToInt(buffer);
		Kv.GetString("shortcut", g_ExtraRounds[i].er_shortcut, 32, "Undefined");
		Kv.GetString("extra_item", g_ExtraRounds[i].er_extraItem, 32, "Undefined");
		Kv.GetString("enable", buffer, 32, "0");
		g_ExtraRounds[i].er_enable = StringToInt(buffer);
		Kv.GetString("no_zoom", buffer, 32, "0");
		g_ExtraRounds[i].er_no_zoom = StringToInt(buffer);
		Kv.GetString("gravity", buffer, 32, "-1");
		g_ExtraRounds[i].er_gravity = StringToInt(buffer);
		Kv.GetString("no_recoil", buffer, 32, "0");
		g_ExtraRounds[i].er_no_recoil = StringToInt(buffer);		
		Kv.GetString("player_speed", buffer, 32, "1");
		g_ExtraRounds[i].er_speed = StringToFloat(buffer);
		g_ExtraRounds[i].er_index = i;
		Kv.GetString("cmd", g_ExtraRounds[i].er_cmd, sizeof(g_ExtraRounds[].er_cmd), "Undefined");
		if (StrEqual(g_ExtraRounds[i].er_display_string, "Undefined") || StrEqual(g_ExtraRounds[i].er_weapon, "Undefined") || g_ExtraRounds[i].er_enable == 0){
			continue;
		}
		i++;
	} while (Kv.GotoNextKey());
	Kv.Close();
	i_toplam_ER = i;
	if (i_toplam_ER == 0){
		SetFailState("[Extra Rounds] Round bilgileri çekilemedi. Lütfen dosyayı (configs/ExtraRounds/extra_rounds.ini) kontrol edin.");
	}if(i_toplam_ER < 6){
		SetFailState("En az 6 adet Extra Round yaratmalısınız. (configs/ExtraRounds/extra_rounds.ini) kontrol edin.");
	}
	function_SettingsThenSettings();
}
public void GetCVars() {
	g_cvPredictionConVars[0] = FindConVar("weapon_accuracy_nospread");
	g_cvPredictionConVars[1] = FindConVar("weapon_recoil_cooldown");
	g_cvPredictionConVars[2] = FindConVar("weapon_recoil_decay1_exp");
	g_cvPredictionConVars[3] = FindConVar("weapon_recoil_decay2_exp");
	g_cvPredictionConVars[4] = FindConVar("weapon_recoil_decay2_lin");
	g_cvPredictionConVars[5] = FindConVar("weapon_recoil_scale");
	g_cvPredictionConVars[6] = FindConVar("weapon_recoil_suppression_shots");
	g_cvPredictionConVars[7] = FindConVar("weapon_recoil_variance");
	g_cvPredictionConVars[8] = FindConVar("weapon_recoil_view_punch_extra");
	g_mapCmd = new ArrayList();
}