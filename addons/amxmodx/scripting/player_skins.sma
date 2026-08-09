#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <nvault>
#include <cstrike>
#include <engine>

#define MAX_SKINS 10

enum _:SkinData {
	SkinName[32],
	SkinModel[64],
	SkinTeam,      // 1=TT, 2=CT
	SkinFlags,     // ADMIN_BAN for admin, ADMIN_RESERVATION for VIP
	SkinLabel[16]  // "(Admin CT)", "(VIP TT)", etc.
}

new const g_Skins[MAX_SKINS][SkinData] = {
	{ "Splinter Cell",   "gign_splin",     2, ADMIN_RESERVATION,  "(VIP CT)"     },
	{ "V de Vendetta",   "venom",          1, ADMIN_RESERVATION,  "(VIP TT)"     },
	{ "Agent Smith",     "urban_smith",    1, ADMIN_RCON,         "(Owner TT)"   },
	{ "Morfeo",          "gign_morfeo",    2, ADMIN_RESERVATION,  "(VIP CT)"     },
	{ "Neo Matrix",      "urban_neo",              2, ADMIN_RCON,         "(Owner CT)"   },
	{ "Rambo",                "rambo",                  1, ADMIN_RESERVATION,  "(VIP TT)"     },
	{ "Tactical Black GIGN",  "tactical_black_gign",    1, ADMIN_BAN,          "(Admin TT)"   },
	{ "Tactical Black GSG9",  "tactical_black_gsg9",    2, ADMIN_BAN,          "(Admin CT)"   },
	{ "Tactical Black SAS",   "tactical_black_sas",     2, ADMIN_BAN,          "(Admin CT)"   },
	{ "Tactical Black Urban", "tactical_black_urban",   1, ADMIN_BAN,          "(Admin TT)"   }
}

new g_iSelected[33]
new g_vault

public plugin_init()
{
	register_plugin("Player Skins", "1.0", "MITO")
	register_clcmd("say /skin", "cmd_skin")
	register_clcmd("say /skins", "cmd_skin")
	register_event("ResetHUD", "event_spawn", "b")
	g_vault = nvault_open("player_skins")
}

	public plugin_precache()
{
	for (new i = 0; i < MAX_SKINS; i++)
	{
		new szPath[128]
		formatex(szPath, charsmax(szPath), "models/player/%s/%s.mdl", g_Skins[i][SkinModel], g_Skins[i][SkinModel])
		precache_model(szPath)

		formatex(szPath, charsmax(szPath), "models/player/%s/%sT.mdl", g_Skins[i][SkinModel], g_Skins[i][SkinModel])
		precache_model(szPath)
	}
}

public plugin_end()
{
	nvault_close(g_vault)
}

public client_putinserver(id)
{
	g_iSelected[id] = 0
	load_skin(id)
}

public event_spawn(id)
{
	if (!is_user_alive(id))
		return

	set_task(0.5, "apply_skin", id)
}

public cmd_skin(id)
{
	new menu = menu_create("\yPlayer Skins\w:", "menu_handler")
	new flags = get_user_flags(id)

	for (new i = 0; i < MAX_SKINS; i++)
	{
		if (!(flags & g_Skins[i][SkinFlags]) && !(flags & ADMIN_BAN))
			continue

		new szItem[96]
		new teamName[4]
		copy(teamName, charsmax(teamName), g_Skins[i][SkinTeam] == 1 ? "TT" : "CT")

		formatex(szItem, charsmax(szItem), "%s %s %s",
			g_Skins[i][SkinName],
			g_Skins[i][SkinLabel],
			g_iSelected[id] == i + 1 ? "[*]" : "")

		menu_additem(menu, szItem)
	}

	menu_additem(menu, "Original (por defecto)")
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	if (item < MAX_SKINS)
	{
		new flags = get_user_flags(id)

		if (!(flags & g_Skins[item][SkinFlags]) && !(flags & ADMIN_BAN))
		{
			new szRank[16]
			if (g_Skins[item][SkinFlags] == ADMIN_RCON)
				copy(szRank, charsmax(szRank), "Owner+")
			else if (g_Skins[item][SkinFlags] == ADMIN_BAN)
				copy(szRank, charsmax(szRank), "Admin")
			else
				copy(szRank, charsmax(szRank), "VIP")

			client_print(id, print_chat, "[eXe] Esta skin requiere ser %s", szRank)
			menu_destroy(menu)
			return PLUGIN_HANDLED
		}

		g_iSelected[id] = item + 1
		save_skin(id)

		client_print(id, print_chat, "[eXe] Skin %s seleccionada", g_Skins[item][SkinName])
	}
	else
	{
		g_iSelected[id] = 0
		save_skin(id)
		client_print(id, print_chat, "[eXe] Skin original restaurada")
	}

	menu_destroy(menu)

	if (is_user_alive(id))
		apply_skin(id)

	return PLUGIN_HANDLED
}

public apply_skin(id)
{
	if (!is_user_alive(id))
		return

	new sel = g_iSelected[id]
	if (sel < 1 || sel > MAX_SKINS)
		return

	new idx = sel - 1

	new team = get_user_team(id)
	if (team != g_Skins[idx][SkinTeam])
	{
		client_print(id, print_chat, "[eXe] Esta skin es para el otro equipo, se restauro la original")
		g_iSelected[id] = 0
		save_skin(id)
		return
	}

	new flags = get_user_flags(id)
	if (!(flags & g_Skins[idx][SkinFlags]) && !(flags & ADMIN_BAN))
	{
		g_iSelected[id] = 0
		save_skin(id)
		return
	}

	cs_set_user_model(id, g_Skins[idx][SkinModel])
}

save_skin(id)
{
	new authid[32]
	get_user_authid(id, authid, charsmax(authid))
	if (!authid[0] || equali(authid, "STEAM_ID_PENDING"))
		return

	new key[64], data[16]
	formatex(key, charsmax(key), "skin_%s", authid)
	formatex(data, charsmax(data), "%d", g_iSelected[id])
	nvault_set(g_vault, key, data)
}

load_skin(id)
{
	new authid[32]
	get_user_authid(id, authid, charsmax(authid))
	if (!authid[0] || equali(authid, "STEAM_ID_PENDING"))
		return

	new key[64], data[16], ts
	formatex(key, charsmax(key), "skin_%s", authid)
	if (nvault_lookup(g_vault, key, data, charsmax(data), ts))
		g_iSelected[id] = str_to_num(data)
}
