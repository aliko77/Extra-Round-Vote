void HookEvents(){
	HookEvent("round_end", Event_RoundEnd, EventHookMode_Pre);
	HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
	HookEvent("player_spawn", Event_PlayerSpawn, EventHookMode_Pre);
	HookEventEx("weapon_fire", Event_WeaponFire, EventHookMode_Pre);
}
public Action CS_OnCSWeaponDrop(int client, int weaponindex)
{
	if (b_OnExtraRound)return Plugin_Handled;
	return Plugin_Continue;
}
public Action OnPlayerRunCmd(int client, int &buttons, int &impulse, float vel[3], float angles[3], int &weapon, int &subtype, int &cmdnum, int &tickcount, int &seed, int mouse[2])
{
	if(b_OnExtraRound){
		if(!check_status(client)){
			return Plugin_Continue;
		}
		if(!IsPlayerAlive(client)){
			return Plugin_Continue;
		}
		if(buttons & IN_RELOAD){
			int weaponI =  GetEntPropEnt(client, Prop_Data, "m_hActiveWeapon");	
			SetFullAmmo(client, weaponI);
		}
	}
	return Plugin_Continue;
}
void Event_RoundEnd(Event event, const char[] name, bool dontBroadcast){
	if(b_SendVote){
		func_SendVote();
	}
	else if(b_VoteResult && i_result_enumIndex != -1){
		b_OnExtraRound = true;
		if(b_OnExtraRound && b_RoundTimeIsUp){
			function_Sifirla();
		}
	}
}
void Event_RoundStart(Event event, const char[] name, bool dontBroadcast){
	if(b_VoteResult && i_result_enumIndex != -1 && b_OnExtraRound){
		if(!t_round_timer){
			i_round_time = g_ExtraRounds[i_result_enumIndex].er_round_time;
			t_round_timer = CreateTimer(1.0, timer_func_round, _, TIMER_REPEAT);
		}
		if(b_OnExtraRound){
			if (!StrEqual(g_ExtraRounds[i_result_enumIndex].er_hud_msg, "Undefined") && strlen(g_ExtraRounds[i_result_enumIndex].er_hud_msg) > 0){
				CreateTimer(1.0, TMR_uyari, TIMER_FLAG_NO_MAPCHANGE);
			}
			if(g_ExtraRounds[i_result_enumIndex].er_gravity > -1){
				FindConVar("sv_gravity").SetInt(g_ExtraRounds[i_result_enumIndex].er_gravity);
			}
			if (g_ExtraRounds[i_result_enumIndex].er_no_recoil > 0){
				SetConVarInt(g_cvPredictionConVars[0], 1, true, false);
				SetConVarInt(g_cvPredictionConVars[1], 0, true, false);
				SetConVarInt(g_cvPredictionConVars[2], 99999, true, false);
				SetConVarInt(g_cvPredictionConVars[3], 99999, true, false);
				SetConVarInt(g_cvPredictionConVars[4], 99999, true, false);
				SetConVarInt(g_cvPredictionConVars[5], 0, true, false);
				SetConVarInt(g_cvPredictionConVars[6], 500, true, false);
			}
		}
	}
	if(!b_VoteResult && i_result_enumIndex == -1 && !b_OnExtraRound){
		if (bRound_iptal)bRound_iptal = false;
		if (!t_vote_timer)t_vote_timer = CreateTimer(1.0, timer_func_vote, _, TIMER_REPEAT);
	}
}
void Event_PlayerSpawn(Handle event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(b_OnExtraRound && i_result_enumIndex != -1 && client != -1){
		DoRound(client);
	}
}
void Event_WeaponFire(Handle event, const char[] name, bool dontBroadcast){
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(b_OnExtraRound && i_result_enumIndex != -1 && client != -1){
	    int activeweapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	    if (!IsValidEdict(activeweapon)) return;
	    char weaponname[64];
	    GetEdictClassname(activeweapon, weaponname, sizeof(weaponname));
	    if (StrContains(weaponname, "hegrenade") != -1 || StrContains(weaponname, "flashbang") != -1
	    || StrContains(weaponname, "smokegrenade") != -1 || StrContains(weaponname, "decoy") != -1 || StrContains(weaponname, "incgrenade") != -1
	    || StrContains(weaponname, "molotov") != -1){
	    	GivePlayerItem(client, g_ExtraRounds[i_result_enumIndex].er_weapon);
	  	}
	  	else if (StrContains(weaponname, "taser") != -1)SetEntProp(activeweapon, Prop_Send, "m_iPrimaryReserveAmmoCount", 1);
	}
}
public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &weapon, float damageForce[3], float damagePosition[3], int damagecustom){
	if(b_OnExtraRound && i_result_enumIndex != -1){
		if(g_ExtraRounds[i_result_enumIndex].er_knife_dmg < 1){
			if(victim > 0 && victim <= MaxClients && attacker > 0 && attacker <= MaxClients && IsClientInGame(victim) && IsClientInGame(attacker)){
				char WeaponName[128];
				GetClientWeapon(attacker, WeaponName, sizeof(WeaponName));
				if (StrContains(WeaponName, "weapon_knife", false) != -1 || StrContains(WeaponName, "weapon_bayonet") != -1){
					return Plugin_Handled;
				}
			}
		}
		if(g_ExtraRounds[i_result_enumIndex].er_only_hs > 0){
			if(victim > 0 && victim <= MaxClients && attacker > 0 && attacker <= MaxClients && IsClientInGame(victim) && IsClientInGame(attacker)){
				SetEntPropVector(victim, Prop_Send, "m_aimPunchAngle", NULL_VECTOR);
				SetEntPropVector(victim, Prop_Send, "m_aimPunchAngleVel", NULL_VECTOR);
				char WeaponName[256];
				GetClientWeapon(attacker, WeaponName, sizeof(WeaponName));
				if (StrEqual(WeaponName, g_ExtraRounds[i_result_enumIndex].er_weapon)){
					if(damagetype & CS_DMG_HEADSHOT){
						return Plugin_Continue;
					}
					return Plugin_Handled;
				}
			}
		}
	}
	return Plugin_Continue;
}
public Action OnWeaponCanUse(int client, int weapon){
	if(b_OnExtraRound && i_result_enumIndex != -1){
		char classname[64];
		if(GetEdictClassname(weapon, classname, 64) && (StrContains(classname, "weapon_knife") != -1 || StrContains(classname, "weapon_bayonet" ) != -1
			|| StrContains(classname, g_ExtraRounds[i_result_enumIndex].er_weapon) != -1) || StrContains(classname, g_ExtraRounds[i_result_enumIndex].er_extraItem) != -1){
			return Plugin_Continue;
		}
		else {
			return Plugin_Handled;
		}		
	}
	return Plugin_Continue;	
}
public Action OnPreThink(int client){
	if(check_status(client)){
		if(b_OnExtraRound && i_result_enumIndex != -1 && g_ExtraRounds[i_result_enumIndex].er_no_zoom == 1){
			SetNoScope(GetPlayerWeaponSlot(client, 0));
		}
	}
}