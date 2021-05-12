void RoundList(int client){
	if (!check_status(client))return;
	Menu menu = CreateMenu(menu_RoundList);
	SetMenuTitle(menu, "%s | Extra Roundlar", mtag);
	SetMenuExitButton(menu, true);
	for (int i = 0; i < i_toplam_ER; i++){
		char sIndex[11];
		IntToString(g_ExtraRounds[i].er_index, sIndex,11);
		AddMenuItem(menu, sIndex, g_ExtraRounds[i].er_display_string);
	}
	DisplayMenu(menu, client, MENU_TIME_FOREVER);
}
public int menu_RoundList(Menu menu, MenuAction action, int client, int item){
	switch (action){
		case MenuAction_Select:{
			char sInfo[11];
			GetMenuItem(menu, item, sInfo, 11);
			int iInfo = StringToInt(sInfo);
			RoundListOnItemSelect(client, iInfo);
		}
		case MenuAction_End:{
			delete menu;
		}		
	}
}
void RoundListOnItemSelect(int client, int index){
	if (!check_status(client))return;
	char buf[512];
	Format(buf, 512, "%s", GetRoundInfo(index));
	Menu menu2 = CreateMenu(menu_RoundListOnItemSelect);
	SetMenuExitButton(menu2, true);
	SetMenuTitle(menu2, "%s | Round Bilgisi\n%s", mtag, buf);
	AddMenuItem(menu2, "", "Geri");
	DisplayMenu(menu2, client, MENU_TIME_FOREVER);	
}
public int menu_RoundListOnItemSelect(Menu menu, MenuAction action, int client, int item){
	switch (action){
		case MenuAction_Select:{
			RoundList(client);
		}
		case MenuAction_End:{
			delete menu;
		}
	}
}