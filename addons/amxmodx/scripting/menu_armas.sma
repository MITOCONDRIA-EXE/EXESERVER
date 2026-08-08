#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>

new bool:g_bAutoMenu[33]
new bool:g_bUsado[33]
new g_iComboSelected[33]

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
	{ "AK-47 + Deagle", "weapon_ak47", "weapon_deagle", CSW_AK47, CSW_DEAGLE, 90, 35 },
	{ "M4A1 + Deagle", "weapon_m4a1", "weapon_deagle", CSW_M4A1, CSW_DEAGLE, 90, 35 },
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
	g_bUsado[id] = false
	if (is_user_alive(id) && g_bAutoMenu[id])
		set_task(0.5, "show_menu_armas", id)
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
	if (!is_user_connected(id) || !is_user_alive(id))
	{
		client_print(id, print_chat, "[eXe] Tenes que estar vivo para elegir armas.")
		return PLUGIN_HANDLED
	}

	if (g_bUsado[id])
	{
		client_print(id, print_chat, "[eXe] Ya has elegido armas esta ronda.")
		return PLUGIN_HANDLED
	}

	new menu = menu_create("\yCombos de Armas\w:", "menu_armas_handler")
	for (new i = 0; i < sizeof(gCombos); i++)
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

	if (!is_user_alive(id) || g_bUsado[id] || item < 0 || item >= sizeof(gCombos))
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	g_iComboSelected[id] = item
	
	// Limpiar armas secundarias ANTES de dar las nuevas
	strip_secondary_weapons(id)
	
	// Dar las nuevas armas con delays pequeños para garantizar orden
	set_task(0.05, "task_give_w1", id)
	set_task(0.1, "task_give_w2", id)
	set_task(0.15, "task_set_ammo", id)

	g_bUsado[id] = true
	client_print(id, print_chat, "[eXe] Armas: %s", gCombos[item][WC_Name])

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

// Función para limpiar armas secundarias (excepto knife y C4)
stock strip_secondary_weapons(id)
{
	if (!is_user_alive(id))
		return

	// Array de clases de armas a remover
	new const weapons_to_remove[][] = {
		"weapon_ak47", "weapon_m4a1", "weapon_awp", "weapon_famas",
		"weapon_galil", "weapon_m249", "weapon_sg550", "weapon_sg552",
		"weapon_aug", "weapon_deagle", "weapon_usp", "weapon_glock18",
		"weapon_p228", "weapon_p90", "weapon_mac10", "weapon_ump45",
		"weapon_mp5", "weapon_tmp", "weapon_scout", "weapon_xm1014",
		"weapon_m3", "weapon_fiveseven", "weapon_elite"
	}

	// Remover cada arma secundaria del inventario del jugador
	for (new i = 0; i < sizeof(weapons_to_remove); i++)
	{
		new entity = -1
		while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", weapons_to_remove[i])) != 0)
		{
			// Verificar que el arma pertenece al jugador
			if (pev(entity, pev_owner) == id)
			{
				engfunc(EngFunc_RemoveEntity, entity)
			}
		}
	}
}

public task_give_w1(id)
{
	if (!is_user_alive(id))
		return

	new item = g_iComboSelected[id]
	give_item(id, gCombos[item][WC_W1])
}

public task_give_w2(id)
{
	if (!is_user_alive(id))
		return

	new item = g_iComboSelected[id]
	give_item(id, gCombos[item][WC_W2])
}

public task_set_ammo(id)
{
	if (!is_user_alive(id))
		return

	new item = g_iComboSelected[id]
	cs_set_user_bpammo(id, gCombos[item][WC_CSW1], gCombos[item][WC_Ammo1])
	cs_set_user_bpammo(id, gCombos[item][WC_CSW2], gCombos[item][WC_Ammo2])
}
