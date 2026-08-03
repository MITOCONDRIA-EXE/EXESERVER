#include <amxmodx>

#define PLUGIN "eXe Chat Ads"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

#define CHAT_INTERVAL 15.0
#define HUD_INTERVAL  90.0

new g_iChatMsg

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	set_task(5.0, "show_welcome", _, _, _, "a", 1)
	set_task(CHAT_INTERVAL, "show_chat_ad", _, _, _, "b")
}

public show_welcome()
{
	new iPlayers[32], iNum, id
	get_players(iPlayers, iNum, "ch")

	for (new i = 0; i < iNum; i++)
	{
		id = iPlayers[i]
		client_print_color(id, id, "^4Bienvenido a ^3ARGENTINA | eXe Server")
		client_print_color(id, id, "^1Usá ^4/armas ^1| ^4/knife ^1| ^4/rank ^1| ^4/top15 ^1| ^4/vip")
	}
}

public show_chat_ad()
{
	g_iChatMsg++
	if (g_iChatMsg >= 5) g_iChatMsg = 0

	switch (g_iChatMsg)
	{
		case 0:
			client_print_color(0, print_team_default, "^4[eXe]^1 Escribí ^3/knife ^1| ^3/ak ^1| ^3/m4 ^1| ^3/awp ^1| ^3/dk ^1para skins")
		case 1:
			client_print_color(0, print_team_default, "^4[eXe]^1 Escribí ^3/armas ^1para combos | ^3/armas auto ^1ON/OFF")
		case 2:
			client_print_color(0, print_team_default, "^4[eXe]^1 Apretá ^3E ^1sobre un aliado muerto para ^3REVIVIRLO")
		case 3:
			client_print_color(0, print_team_default, "^4[eXe]^1 Escribí ^3/rank ^1y ^3/top15 ^1para estadísticas")
		case 4:
			client_print_color(0, print_team_default, "^4[eXe]^1 Escribí ^3/vip ^1| WP: 3547 63-7174 o 354751-5201")
	}
}
