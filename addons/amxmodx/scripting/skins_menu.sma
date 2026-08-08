#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <nvault>

#define AK_MAX 5
#define M4_MAX 5
#define AWP_MAX 5
#define DG_MAX 5
#define KN_MAX 11

new const gszAkNames[AK_MAX][] = {
	"Bloody", "Violeta", "Blanca", "Golden", "Celeste"
}

new const gszAkModels[AK_MAX][] = {
	"models/skins/ak47/v_ak47_bloody.mdl",
	"models/skins/ak47/violeta.mdl",
	"models/skins/ak47/blanca.mdl",
	"models/skins/ak47/v_golden_ak47.mdl",
	"models/skins/ak47/celeste.mdl"
}

new const gszM4Names[M4_MAX][] = {
	"Eagle", "Emperor", "Rainbow", "Sangrienta", "Lava"
}

new const gszM4Models[M4_MAX][] = {
	"models/skins/m4a1/v_m4a1_eagle.mdl",
	"models/skins/m4a1/v_m4a1_emperor.mdl",
	"models/skins/m4a1/v_m4a1_rainbow.mdl",
	"models/skins/m4a1/sangrienta.mdl",
	"models/skins/m4a1/v_m4a1_lava.mdl"
}

new const gszAwpNames[AWP_MAX][] = {
	"Hyper Blue", "Golden", "Ice", "Impulse", "Red Mechanic"
}

new const gszAwpModels[AWP_MAX][] = {
	"models/skins/awp/v_awp_hyperblue.mdl",
	"models/skins/awp/v_GoldenAWP.mdl",
	"models/skins/awp/v_awp_iceice.mdl",
	"models/skins/awp/v_awp_impulse.mdl",
	"models/skins/awp/v_awp_red_mechanic.mdl"
}

new const gszDgNames[DG_MAX][] = {
	"Golden", "Galaxy", "Gangsta", "Lightning", "Deagle 1"
}

new const gszDgModels[DG_MAX][] = {
	"models/skins/deagle/v_golden_deagle.mdl",
	"models/skins/deagle/v_deagle_galaxy.mdl",
	"models/skins/deagle/v_deagle_gangsta.mdl",
	"models/skins/deagle/v_deagle_lightning.mdl",
	"models/skins/deagle/v_deagle_1.mdl"
}

new const gszKnNames[KN_MAX][] = {
	"Combat", "Hacha", "Huntsman", "Dragon", "Daga Verde",
	"Bayonet", "Kukri", "Bowie", "Stiletto", "Karambit", "Violet (VIP)"
}

new const gszKnModels[KN_MAX][] = {
	"models/skins/knife/v_k_combat.mdl",
	"models/skins/knife/v_k_axe_cf.mdl",
	"models/skins/knife/v_k_huntsman.mdl",
	"models/skins/knife/v_k_dragon.mdl",
	"models/skins/knife/v_k_green_dagger.mdl",
	"models/skins/knife/v_bayonet.mdl",
	"models/skins/knife/v_kukri.mdl",
	"models/skins/knife/v_bowie.mdl",
	"models/skins/knife/v_k_stiletto.mdl",
	"models/skins/knife/v_karambit.mdl",
	"models/skins/knife/v_violet.mdl"
}

new g_ak[33]
new g_m4[33]
new g_awp[33]
new g_dg[33]
new g_kn[33]
new g_vault

public plugin_precache()
{
	new i

	for (i = 0; i < AK_MAX; i++)
		precache_model(gszAkModels[i])

	for (i = 0; i < M4_MAX; i++)
		precache_model(gszM4Models[i])

	for (i = 0; i < AWP_MAX; i++)
		precache_model(gszAwpModels[i])

	for (i = 0; i < DG_MAX; i++)
		precache_model(gszDgModels[i])

	for (i = 0; i < KN_MAX; i++)
		precache_model(gszKnModels[i])
}

public plugin_init()
{
	register_plugin("Menu de Skins", "2.1", "MITO")

	register_clcmd("say /ak", "menu_ak")
	register_clcmd("say /M4", "menu_m4")
	register_clcmd("say /m4", "menu_m4")
	register_clcmd("say /awp", "menu_awp")
	register_clcmd("say /dk", "menu_deagle")
	register_clcmd("say /deagle", "menu_deagle")
	register_clcmd("say /knife", "menu_knife")

	RegisterHam(Ham_Item_Deploy, "weapon_ak47", "fw_Deploy_Ak", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_m4a1", "fw_Deploy_M4", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_awp", "fw_Deploy_Awp", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_deagle", "fw_Deploy_Dg", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_knife", "fw_Deploy_Kn", 1)

	g_vault = nvault_open("skins_vault")
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

	new data[64]
	if (nvault_get(g_vault, authid, data, charsmax(data)) > 0)
	{
		new s1[8], s2[8], s3[8], s4[8], s5[8]
		parse(data, s1, charsmax(s1), s2, charsmax(s2), s3, charsmax(s3), s4, charsmax(s4), s5, charsmax(s5))

		g_ak[id] = clamp(str_to_num(s1), 0, AK_MAX)
		g_m4[id] = clamp(str_to_num(s2), 0, M4_MAX)
		g_awp[id] = clamp(str_to_num(s3), 0, AWP_MAX)
		g_dg[id] = clamp(str_to_num(s4), 0, DG_MAX)
		g_kn[id] = clamp(str_to_num(s5), 0, KN_MAX)
	}
	else
	{
		g_ak[id] = random_num(1, AK_MAX)
		g_m4[id] = random_num(1, M4_MAX)
		g_awp[id] = random_num(1, AWP_MAX)
		g_dg[id] = random_num(1, DG_MAX)
		g_kn[id] = random_num(1, KN_MAX - 1)
		save_skins(id)
	}
}

public client_disconnected(id)
{
	g_ak[id] = 0
	g_m4[id] = 0
	g_awp[id] = 0
	g_dg[id] = 0
	g_kn[id] = 0
}

public menu_ak(id)
{
	new menu = menu_create("\ySkines AK-47\w:", "menu_ak_handler")
	build_skin_menu(menu, gszAkNames, AK_MAX)
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public menu_m4(id)
{
	new menu = menu_create("\ySkines M4A4\w:", "menu_m4_handler")
	build_skin_menu(menu, gszM4Names, M4_MAX)
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public menu_awp(id)
{
	new menu = menu_create("\ySkines AWP\w:", "menu_awp_handler")
	build_skin_menu(menu, gszAwpNames, AWP_MAX)
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public menu_deagle(id)
{
	new menu = menu_create("\ySkines Deagle\w:", "menu_deagle_handler")
	build_skin_menu(menu, gszDgNames, DG_MAX)
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public menu_knife(id)
{
	new menu = menu_create("\ySkines Cuchillo\w:", "menu_knife_handler")
	build_skin_menu(menu, gszKnNames, KN_MAX)
	menu_display(id, menu)
	return PLUGIN_HANDLED
}

public menu_ak_handler(id, menu, item)
{
	return skin_menu_pick(id, menu, item, 0)
}

public menu_m4_handler(id, menu, item)
{
	return skin_menu_pick(id, menu, item, 1)
}

public menu_awp_handler(id, menu, item)
{
	return skin_menu_pick(id, menu, item, 2)
}

public menu_deagle_handler(id, menu, item)
{
	return skin_menu_pick(id, menu, item, 3)
}

public menu_knife_handler(id, menu, item)
{
	return skin_menu_pick(id, menu, item, 4)
}

stock build_skin_menu(menu, const names[][], const max)
{
	new i

	for (i = 0; i < max; i++)
		menu_additem(menu, names[i])

	menu_additem(menu, "Ninguna (original)")
	menu_setprop(menu, MPROP_EXITNAME, "Salir")
}

public skin_menu_pick(id, menu, item, type)
{
	new selected

	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new max = (type == 4) ? KN_MAX : (type == 3) ? DG_MAX : (type == 2) ? AWP_MAX : (type == 1) ? M4_MAX : AK_MAX

	if (item == max)
		selected = 0
	else if (item >= 0 && item < max)
		selected = item + 1
	else
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	if (type == 4 && selected == KN_MAX && !(get_user_flags(id) & (ADMIN_RESERVATION | ADMIN_BAN)))
	{
		client_print(id, print_chat, "[eXe] Violet es solo para VIPs!")
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	switch (type)
	{
		case 0: g_ak[id] = selected
		case 1: g_m4[id] = selected
		case 2: g_awp[id] = selected
		case 3: g_dg[id] = selected
		case 4: g_kn[id] = selected
	}

	save_skins(id)

	new szName[32]
	new szWpn[16]

	switch (type)
	{
		case 0:
		{
			szWpn = "AK-47"
			copy(szName, charsmax(szName), selected ? gszAkNames[selected - 1] : "Original")
		}
		case 1:
		{
			szWpn = "M4A4"
			copy(szName, charsmax(szName), selected ? gszM4Names[selected - 1] : "Original")
		}
		case 2:
		{
			szWpn = "AWP"
			copy(szName, charsmax(szName), selected ? gszAwpNames[selected - 1] : "Original")
		}
		case 3:
		{
			szWpn = "Deagle"
			copy(szName, charsmax(szName), selected ? gszDgNames[selected - 1] : "Original")
		}
		case 4:
		{
			szWpn = "Cuchillo"
			copy(szName, charsmax(szName), selected ? gszKnNames[selected - 1] : "Original")
		}
	}

	client_print(id, print_chat, "[eXe] Skin %s: %s", szWpn, szName)

	apply_current(id, type)

	menu_destroy(menu)

	return PLUGIN_HANDLED
}

public fw_Deploy_Ak(ent)
{
	new id = weapon_owner(ent)
	if (id && g_ak[id] > 0)
		set_pev(id, pev_viewmodel2, gszAkModels[g_ak[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_M4(ent)
{
	new id = weapon_owner(ent)
	if (id && g_m4[id] > 0)
		set_pev(id, pev_viewmodel2, gszM4Models[g_m4[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Awp(ent)
{
	new id = weapon_owner(ent)
	if (id && g_awp[id] > 0)
		set_pev(id, pev_viewmodel2, gszAwpModels[g_awp[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Dg(ent)
{
	new id = weapon_owner(ent)
	if (id && g_dg[id] > 0)
		set_pev(id, pev_viewmodel2, gszDgModels[g_dg[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Kn(ent)
{
	new id = weapon_owner(ent)
	if (id && g_kn[id] > 0)
		set_pev(id, pev_viewmodel2, gszKnModels[g_kn[id] - 1])
	return HAM_IGNORED
}

stock weapon_owner(const ent)
{
	new owner = pev(ent, pev_owner)
	if (owner > 0 && owner <= 32 && is_user_connected(owner))
		return owner
	return 0
}

stock apply_current(id, type)
{
	if (!is_user_alive(id))
		return

	new wpn = get_user_weapon(id)

	switch (type)
	{
		case 0:
		{
			if (wpn == CSW_AK47)
				set_pev(id, pev_viewmodel2, g_ak[id] > 0 ? gszAkModels[g_ak[id] - 1] : "models/v_ak47.mdl")
			return
		}
		case 1:
		{
			if (wpn == CSW_M4A1)
				set_pev(id, pev_viewmodel2, g_m4[id] > 0 ? gszM4Models[g_m4[id] - 1] : "models/v_m4a1.mdl")
			return
		}
		case 2:
		{
			if (wpn == CSW_AWP)
				set_pev(id, pev_viewmodel2, g_awp[id] > 0 ? gszAwpModels[g_awp[id] - 1] : "models/v_awp.mdl")
			return
		}
		case 3:
		{
			if (wpn == CSW_DEAGLE)
				set_pev(id, pev_viewmodel2, g_dg[id] > 0 ? gszDgModels[g_dg[id] - 1] : "models/v_deagle.mdl")
			return
		}
		case 4:
		{
			if (wpn == CSW_KNIFE)
				set_pev(id, pev_viewmodel2, g_kn[id] > 0 ? gszKnModels[g_kn[id] - 1] : "models/v_knife.mdl")
			return
		}
	}
}

stock save_skins(id)
{
	new authid[32]
	get_user_authid(id, authid, charsmax(authid))

	if (!authid[0] || equali(authid, "STEAM_ID_PENDING"))
		return

	new data[64]
	formatex(data, charsmax(data), "%d %d %d %d %d", g_ak[id], g_m4[id], g_awp[id], g_dg[id], g_kn[id])
	nvault_set(g_vault, authid, data)
}
