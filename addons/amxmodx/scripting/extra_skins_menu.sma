#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <nvault>

new const gWeaponNames[][] = {
	"AUG", "FAMAS", "Galil", "Glock18", "M3",
	"MAC-10", "MP5", "P228", "P90", "Scout",
	"SG 550", "SG 552", "TMP", "UMP-45", "USP",
	"XM1014", "Dual Elite", "Five-SeveN", "G3SG1"
}

new const gWeaponCmds[][] = {
	"aug", "famas", "galil", "glock", "m3",
	"mac10", "mp5", "p228", "p90", "scout",
	"sg550", "sg552", "tmp", "ump", "usp",
	"xm1014", "elite", "fiveseven", "g3sg1"
}

new const gWeaponClasses[][] = {
	"weapon_aug", "weapon_famas", "weapon_galil", "weapon_glock18", "weapon_m3",
	"weapon_mac10", "weapon_mp5navy", "weapon_p228", "weapon_p90", "weapon_scout",
	"weapon_sg550", "weapon_sg552", "weapon_tmp", "weapon_ump45", "weapon_usp",
	"weapon_xm1014", "weapon_elite", "weapon_fiveseven", "weapon_g3sg1"
}

new const gSkinModels[][] = {
	"models/skins/aug/v_aug_custom.mdl",
	"models/skins/famas/v_famas_custom.mdl",
	"models/skins/galil/v_galil_custom.mdl",
	"models/skins/glock18/v_glock18_custom.mdl",
	"models/skins/m3/v_m3_custom.mdl",
	"models/skins/mac10/v_mac10_custom.mdl",
	"models/skins/mp5/v_mp5_custom.mdl",
	"models/skins/p228/v_p228_custom.mdl",
	"models/skins/p90/v_p90_custom.mdl",
	"models/skins/scout/v_scout_custom.mdl",
	"models/skins/sg550/v_sg550_custom.mdl",
	"models/skins/sg552/v_sg552_custom.mdl",
	"models/skins/tmp/v_tmp_custom.mdl",
	"models/skins/ump45/v_ump45_custom.mdl",
	"models/skins/usp/v_usp_custom.mdl",
	"models/skins/xm1014/v_xm1014_custom.mdl",
	"models/skins/elite/v_elite_custom.mdl",
	"models/skins/fiveseven/v_fiveseven_custom.mdl",
	"models/skins/g3sg1/v_g3sg1_custom.mdl"
}

new const gDefaultModels[][] = {
	"models/v_aug.mdl",
	"models/v_famas.mdl",
	"models/v_galil.mdl",
	"models/v_glock18.mdl",
	"models/v_m3.mdl",
	"models/v_mac10.mdl",
	"models/v_mp5.mdl",
	"models/v_p228.mdl",
	"models/v_p90.mdl",
	"models/v_scout.mdl",
	"models/v_sg550.mdl",
	"models/v_sg552.mdl",
	"models/v_tmp.mdl",
	"models/v_ump45.mdl",
	"models/v_usp.mdl",
	"models/v_xm1014.mdl",
	"models/v_elite.mdl",
	"models/v_fiveseven.mdl",
	"models/v_g3sg1.mdl"
}

#define WEAPON_MAX sizeof(gWeaponClasses)

new g_playerSkin[MAX_PLAYERS + 1][WEAPON_MAX]
new g_menuWeapon[MAX_PLAYERS + 1]
new g_vault

public plugin_precache()
{
	for (new i = 0; i < WEAPON_MAX; i++)
		precache_model(gSkinModels[i])
}

public plugin_init()
{
	register_plugin("Extra Skins Menu", "1.0", "eXe")

	new cmd[64]
	for (new i = 0; i < WEAPON_MAX; i++)
	{
		formatex(cmd, charsmax(cmd), "say /%s", gWeaponCmds[i])
		register_clcmd(cmd, "menu_open")
		formatex(cmd, charsmax(cmd), "say_team /%s", gWeaponCmds[i])
		register_clcmd(cmd, "menu_open")

		RegisterHam(Ham_Item_Deploy, gWeaponClasses[i], "fw_Deploy", 1)
	}

	g_vault = nvault_open("extra_skins_vault")
}

public plugin_end()
{
	nvault_close(g_vault)
}

public client_putinserver(id)
{
	new authid[32]
	get_user_authid(id, authid, charsmax(authid))
	if (!authid[0] || equali(authid, "STEAM_ID_PENDING"))
		return

	new data[128]
	if (nvault_get(g_vault, authid, data, charsmax(data)) > 0)
	{
		new s[8]
		for (new i = 0; i < WEAPON_MAX; i++)
		{
			argbreak(data, s, charsmax(s), data, charsmax(data))
			g_playerSkin[id][i] = clamp(str_to_num(s), 0, 1)
		}
	}
}

public client_disconnected(id)
{
	for (new i = 0; i < WEAPON_MAX; i++)
		g_playerSkin[id][i] = 0
}

public menu_open(id)
{
	new args[32]
	read_args(args, charsmax(args))
	remove_quotes(args)

	new cmd[32]
	if (args[0] == '/')
		copy(cmd, charsmax(cmd), args[1])
	else
		copy(cmd, charsmax(cmd), args)

	for (new i = 0; i < WEAPON_MAX; i++)
	{
		if (equali(cmd, gWeaponCmds[i]))
		{
			g_menuWeapon[id] = i
			show_menu_custom(id, i)
			return PLUGIN_HANDLED
		}
	}
	return PLUGIN_HANDLED
}

show_menu_custom(id, weaponIdx)
{
	new menu = menu_create(fmt("\ySkin %s\w:", gWeaponNames[weaponIdx]), "menu_handler")

	menu_additem(menu, "Skin Custom")
	menu_additem(menu, "Original")

	menu_setprop(menu, MPROP_EXITNAME, "Salir")
	menu_display(id, menu, 0)
}

public menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new weaponIdx = g_menuWeapon[id]

	if (item == 0)
		g_playerSkin[id][weaponIdx] = 1
	else
		g_playerSkin[id][weaponIdx] = 0

	save_skins(id)

	new wpn = get_user_weapon(id)
	new weaponCsw = get_csw_from_idx(weaponIdx)
	if (weaponCsw && wpn == weaponCsw)
	{
		if (g_playerSkin[id][weaponIdx] > 0)
			set_pev(id, pev_viewmodel2, gSkinModels[weaponIdx])
		else
			set_pev(id, pev_viewmodel2, gDefaultModels[weaponIdx])
	}

	client_print(id, print_chat, "[eXe] Skin %s: %s", gWeaponNames[weaponIdx], item == 0 ? "Custom" : "Original")

	menu_destroy(menu)
	return PLUGIN_HANDLED
}

public fw_Deploy(ent)
{
	new id = pev(ent, pev_owner)
	if (!is_user_alive(id))
		return HAM_IGNORED

	static classname[32]
	pev(ent, pev_classname, classname, charsmax(classname))

	for (new i = 0; i < WEAPON_MAX; i++)
	{
		if (equal(classname, gWeaponClasses[i]))
		{
			if (g_playerSkin[id][i] > 0)
				set_pev(id, pev_viewmodel2, gSkinModels[i])
			else
				set_pev(id, pev_viewmodel2, gDefaultModels[i])
			break
		}
	}
	return HAM_IGNORED
}

stock save_skins(id)
{
	new authid[32]
	get_user_authid(id, authid, charsmax(authid))
	if (!authid[0] || equali(authid, "STEAM_ID_PENDING"))
		return

	new data[128]
	new len = 0
	for (new i = 0; i < WEAPON_MAX; i++)
		len += formatex(data[len], charsmax(data) - len, "%d ", g_playerSkin[id][i])

	nvault_set(g_vault, authid, data)
}

stock get_csw_from_idx(idx)
{
	new const cswMap[] = {
		CSW_AUG, CSW_FAMAS, CSW_GALIL, CSW_GLOCK18, CSW_M3,
		CSW_MAC10, CSW_MP5NAVY, CSW_P228, CSW_P90, CSW_SCOUT,
		CSW_SG550, CSW_SG552, CSW_TMP, CSW_UMP45, CSW_USP,
		CSW_XM1014, CSW_ELITE, CSW_FIVESEVEN, CSW_G3SG1
	}
	return cswMap[idx]
}
