#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta_util>
#include <engine>
#include <hamsandwich>

new bool:g_bAutoMenu[33]

enum _:WeaponCombo
{
	WC_Name[24],
	WC_W1[20],
	WC_W2[20],
	WC_CSW1,
	WC_CSW2,
	WC_Ammo1,
	WC_Ammo2
}

new const gCombos[][WeaponCombo] = {
	{ "M4A1 + Deagle", "weapon_m4a1", "weapon_deagle", CSW_M4A1, CSW_DEAGLE, 90, 35 },
	{ "AK-47 + Deagle", "weapon_ak47", "weapon_deagle", CSW_AK47, CSW_DEAGLE, 90, 35 },
	{ "AWP + USP", "weapon_awp", "weapon_usp", CSW_AWP, CSW_USP, 30, 48 },
	{ "FAMAS + Glock", "weapon_famas", "weapon_glock18", CSW_FAMAS, CSW_GLOCK18, 75, 120 },
	{ "Galil + Deagle", "weapon_galil", "weapon_deagle", CSW_GALIL, CSW_DEAGLE, 90, 35 },
	{ "AK-47 + USP", "weapon_ak47", "weapon_usp", CSW_AK47, CSW_USP, 90, 48 },
	{ "AWP + Deagle", "weapon_awp", "weapon_deagle", CSW_AWP, CSW_DEAGLE, 30, 35 },
	{ "M4A1 + Glock", "weapon_m4a1", "weapon_glock18", CSW_M4A1, CSW_GLOCK18, 90, 120 }
}

public plugin_init()
{
	register_plugin("Menu de Armas", "1.0", "MITO")

	register_clcmd("say /armas", "cmd_armas")
	register_clcmd("say armas", "cmd_armas")

	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn", 1)
}

public client_putinserver(id)
{
	g_bAutoMenu[id] = true
}

public fw_PlayerSpawn(id)
{
	if (is_user_alive(id) && g_bAutoMenu[id])
		set_task(1.0, "task_show_menu", id)
}

public task_show_menu(id)
{
	show_menu_armas(id)
}

public cmd_armas(id)
{
	new szArg[6]
	read_argv(1, szArg, charsmax(szArg))

	if (equali(szArg, "auto"))
	{
		g_bAutoMenu[id] = !g_bAutoMenu[id]
		client_print(id, print_chat, "[eXe] Menu automatico al spawnear: %s", g_bAutoMenu[id] ? "ON" : "OFF")
		return PLUGIN_HANDLED
	}

	show_menu_armas(id)
	return PLUGIN_HANDLED
}

public show_menu_armas(id)
{
	if (!is_user_alive(id))
	{
		client_print(id, print_chat, "[eXe] Tenes que estar vivo para elegir armas.")
		return PLUGIN_HANDLED
	}

	new menu = menu_create("\yCombos de Armas\w:", "menu_armas_handler")
	new i

	for (i = 0; i < sizeof(gCombos); i++)
		menu_additem(menu, gCombos[i][WC_Name])

	menu_setprop(menu, MPROP_EXITNAME, "Salir")
	menu_display(id, menu)

	return PLUGIN_HANDLED
}

public menu_armas_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	if (is_user_alive(id) && item >= 0 && item < sizeof(gCombos))
	{
		strip_weapons_safe(id)
		fm_give_item(id, gCombos[item][WC_W1])
		fm_give_item(id, gCombos[item][WC_W2])

		cs_set_user_bpammo(id, gCombos[item][WC_CSW1], gCombos[item][WC_Ammo1])
		cs_set_user_bpammo(id, gCombos[item][WC_CSW2], gCombos[item][WC_Ammo2])

		client_print(id, print_chat, "[eXe] Armas: %s", gCombos[item][WC_Name])
	}

	menu_destroy(menu)

	return PLUGIN_HANDLED
}

strip_weapons_safe(id)
{
	new weapons[32], num, i, ent
	new szWeapon[24]

	get_user_weapons(id, weapons, num)

	for (i = 0; i < num; i++)
	{
		if (weapons[i] == CSW_KNIFE || weapons[i] == CSW_C4 ||
			weapons[i] == CSW_HEGRENADE || weapons[i] == CSW_FLASHBANG || weapons[i] == CSW_SMOKEGRENADE)
			continue

		get_weaponname(weapons[i], szWeapon, charsmax(szWeapon))

		ent = fm_find_ent_by_owner(-1, szWeapon, id)
		if (ent > 0)
			ExecuteHamB(Ham_RemovePlayerItem, id, ent)
	}
}
