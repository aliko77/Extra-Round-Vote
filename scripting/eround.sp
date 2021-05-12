#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "alikoc77"
#define PLUGIN_VERSION "1.02"
#define mtag "[Extra Rounds]"

#include <sourcemod>
#include <sdktools>
#include <multicolors>
#include <sdkhooks>
#include <cstrike>

#pragma newdecls required

enum struct enum_ExtraRounds {
	char er_display_string[48];
	int er_round_time;
	char er_weapon[32];
	int er_only_hs;
	char er_hud_msg[512];
	int er_knife_dmg;
	int er_armor;
	int er_hp;
	int er_enable;
	char er_shortcut[32];
	int er_index;
	int er_no_zoom;
	int er_gravity;
	float er_speed;
	char er_extraItem[32];
	int er_no_recoil;
	char er_cmd[512];
}

char g_sPluginTitle[64],
	g_sDefaultPrimaryW[32],
	g_sDefaultSecondaryW[32];

int g_iVotingTime,
	g_iRoundTime,
	g_iRound_info,
	i_vote_time,
	i_round_time,
	i_toplam_ER,
	i_result_enumIndex = -1,
	m_flNextSecondaryAttack = -1,
	g_sAdminFlag;

Handle t_vote_timer,
	t_round_timer;

bool b_SendVote,
	b_VoteResult,
	b_OnExtraRound,
	b_RoundTimeIsUp,
	bRound_iptal;

ConVar g_cvPredictionConVars[9] = {null, ...};
ArrayList g_mapCmd;

enum_ExtraRounds g_ExtraRounds[48];

#include "ExtraRounds/er_settings.sp"
#include "ExtraRounds/er_functions.sp"
#include "ExtraRounds/er_commands.sp"
#include "ExtraRounds/er_events.sp"
#include "ExtraRounds/er_menus.sp"

public Plugin myinfo = 
{
	name = "[Extra Round]",
	author = PLUGIN_AUTHOR,
	description = "Play a random customized round.",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/id/alikoc77"
};

public void OnPluginStart(){
	LoadTranslations("common.phrases");
	LoadTranslations("ExtraRounds.phrases");
	SetSettings();
	HookEvents();
	GetCVars();
	m_flNextSecondaryAttack = FindSendPropInfo("CBaseCombatWeapon", "m_flNextSecondaryAttack");
	RegConsoleCmd("sm_round", Call_round, "Extra Round hakkında bilgi verir.");
	RegAdminCmd("sm_roundiptal", Call_roundIptal, ADMFLAG_BAN, "Mevcut roundu iptal eder ve ayarları sıfırlar");
	RegAdminCmd("sm_roundreload", Call_roundReload, ADMFLAG_ROOT, "Extra Round ayarlarını tekrar yükler.");
	RegConsoleCmd("sm_roundlar", Call_roundList, "Extra Roundları listeler");
	for(int  i = 1; i <= MaxClients; i++){
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
	}
}
public void OnPluginEnd(){
	FindConVar("sv_gravity").SetInt(800);
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
	SetConVarInt(g_cvPredictionConVars[0], 0, true, false);
	SetConVarFloat(g_cvPredictionConVars[1], 0.55, true, false);
	SetConVarFloat(g_cvPredictionConVars[2], 3.5, true, false);
	SetConVarInt(g_cvPredictionConVars[3], 8, true, false);
	SetConVarInt(g_cvPredictionConVars[4], 18, true, false);
	SetConVarInt(g_cvPredictionConVars[5], 2, true, false);
	SetConVarInt(g_cvPredictionConVars[6], 4, true, false);	
}
public void OnClientPutInServer(int client){
	SDKHook(client, SDKHook_WeaponCanUse, OnWeaponCanUse);
	SDKHook(client, SDKHook_OnTakeDamage , OnTakeDamage);
	SDKHook(client, SDKHook_PreThink, OnPreThink);
}