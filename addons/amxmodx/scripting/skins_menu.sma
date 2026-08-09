#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <fakemeta_util>
#include <hamsandwich>
#include <nvault>

#define AK_MAX 16
#define M4_MAX 23
#define AWP_MAX 14
#define DG_MAX 11
#define KN_MAX 36

new const gszAkNames[AK_MAX][] = {
	"Bloody", "Violeta", "Blanca", "Golden", "Celeste",
	"Astronaut (VIP)", "Bloodsport (VIP)", "Carbon Lines (VIP)", "Frontside Misty (VIP)",
	"Furious Peacock (VIP)", "Graphics Light (VIP)", "Howl (VIP)", "Neon Revolution (VIP)",
	"Polar Bear (VIP)", "Sticker (VIP)", "Tigerstrike (VIP)"
}

new const gszAkModels[AK_MAX][] = {
	"models/skins/ak47/v_ak47_bloody.mdl",
	"models/skins/ak47/violeta.mdl",
	"models/skins/ak47/blanca.mdl",
	"models/skins/ak47/v_golden_ak47.mdl",
	"models/skins/ak47/celeste.mdl",
	"models/skins/ak47/v_ak47_astronaut.mdl",
	"models/skins/ak47/v_ak47_bloodsport.mdl",
	"models/skins/ak47/v_ak47_carbon_lines.mdl",
	"models/skins/ak47/v_ak47_frontside_misty.mdl",
	"models/skins/ak47/v_ak47_furious_peacock.mdl",
	"models/skins/ak47/v_ak47_graphics_light.mdl",
	"models/skins/ak47/v_ak47_howl.mdl",
	"models/skins/ak47/v_ak47_neon_revolution.mdl",
	"models/skins/ak47/v_ak47_polar_bear.mdl",
	"models/skins/ak47/v_ak47_sticker.mdl",
	"models/skins/ak47/v_ak47_tigerstrike.mdl"
}

new const gszM4Names[M4_MAX][] = {
	"Eagle", "Emperor", "Rainbow", "Sangrienta", "Lava",
	"Elite Build", "Green Neon", "Icarus Fell", "Water Elemental", "Wild Style",
	"Asiimov (VIP)", "Blue Purple (VIP)", "Bush Master (VIP)", "Desolate Space (VIP)",
	"Dragon King (VIP)", "Fade (VIP)", "Hot Lava (VIP)", "Howl V2 (VIP)",
	"Hyper Beast (VIP)", "M4A4 Zul (VIP)", "Master Piece (VIP)", "Purple Blue (VIP)",
	"VHS Error (VIP)"
}

new const gszM4Models[M4_MAX][] = {
	"models/skins/m4a1/v_m4a1_eagle.mdl",
	"models/skins/m4a1/v_m4a1_emperor.mdl",
	"models/skins/m4a1/v_m4a1_rainbow.mdl",
	"models/skins/m4a1/sangrienta.mdl",
	"models/skins/m4a1/v_m4a1_lava.mdl",
	"models/skins/m4a1/v_m4a1_elite_build.mdl",
	"models/skins/m4a1/v_m4a1_green_neon.mdl",
	"models/skins/m4a1/v_m4a1_icarus_fell.mdl",
	"models/skins/m4a1/v_m4a1_water_elemental.mdl",
	"models/skins/m4a1/v_m4a1_wild_style.mdl",
	"models/skins/m4a1/v_m4a1_asiimov.mdl",
	"models/skins/m4a1/v_m4a1_blue_purple.mdl",
	"models/skins/m4a1/v_m4a1_bush_master.mdl",
	"models/skins/m4a1/v_m4a1_desolate_space.mdl",
	"models/skins/m4a1/v_m4a1_dragon_king.mdl",
	"models/skins/m4a1/v_m4a1_fade.mdl",
	"models/skins/m4a1/v_m4a1_hot_lava.mdl",
	"models/skins/m4a1/v_m4a1_howl_v2.mdl",
	"models/skins/m4a1/v_m4a1_hyper_beast.mdl",
	"models/skins/m4a1/v_m4a1_m4a4_zul.mdl",
	"models/skins/m4a1/v_m4a1_master_piece.mdl",
	"models/skins/m4a1/v_m4a1_purple_blue.mdl",
	"models/skins/m4a1/v_m4a1_vhs_error.mdl"
}

new const gszAwpNames[AWP_MAX][] = {
	"Hyper Blue", "Golden", "Ice", "Impulse", "Red Mechanic",
	"Artistic (VIP)", "Asiimov Fnatic (VIP)", "Cloud9 (VIP)", "Dragon Lore (VIP)",
	"Fever Dream (VIP)", "Hyper Beast (VIP)", "Rave (VIP)", "Red Puzzle (VIP)",
	"Sticker Sticker (VIP)"
}

new const gszAwpModels[AWP_MAX][] = {
	"models/skins/awp/v_awp_hyperblue.mdl",
	"models/skins/awp/v_GoldenAWP.mdl",
	"models/skins/awp/v_awp_iceice.mdl",
	"models/skins/awp/v_awp_impulse.mdl",
	"models/skins/awp/v_awp_red_mechanic.mdl",
	"models/skins/awp/v_awp_artistic.mdl",
	"models/skins/awp/v_awp_asiimov_fnatic.mdl",
	"models/skins/awp/v_awp_cloud9.mdl",
	"models/skins/awp/v_awp_dragon_lore.mdl",
	"models/skins/awp/v_awp_fever_dream.mdl",
	"models/skins/awp/v_awp_hyper_beast.mdl",
	"models/skins/awp/v_awp_rave.mdl",
	"models/skins/awp/v_awp_red_puzzle.mdl",
	"models/skins/awp/v_awp_sticker_sticker.mdl"
}

new const gszDgNames[DG_MAX][] = {
	"Golden", "Galaxy", "Gangsta", "Lightning", "Deagle 1",
	"Code Red", "Dragon Lore DK", "Oxide Blaze",
	"Blaze V2 (VIP)", "Hyper Beast DK (VIP)", "Kumicho Dragon (VIP)"
}

new const gszDgModels[DG_MAX][] = {
	"models/skins/deagle/v_golden_deagle.mdl",
	"models/skins/deagle/v_deagle_galaxy.mdl",
	"models/skins/deagle/v_deagle_gangsta.mdl",
	"models/skins/deagle/v_deagle_lightning.mdl",
	"models/skins/deagle/v_deagle_1.mdl",
	"models/skins/deagle/v_deagle_code_red.mdl",
	"models/skins/deagle/v_deagle_dragon_lore_dk.mdl",
	"models/skins/deagle/v_deagle_oxide_blaze.mdl",
	"models/skins/deagle/v_deagle_blaze_v2.mdl",
	"models/skins/deagle/v_deagle_hyper_beast_dk.mdl",
	"models/skins/deagle/v_deagle_kumicho_dragon.mdl"
}

new const gszKnNames[KN_MAX][] = {
	"Combat", "Hacha", "Huntsman", "Dragon", "Daga Verde",
	"Bayonet", "Kukri", "Bowie", "Stiletto", "Karambit",
	"Frozen", "Grizzly", "Kz Tron Blue", "Kz Tron Green", "Kz Tron Orange",
	"Abstr Karambit (VIP)", "Autotronic Bayonet (VIP)", "Autotronic Karambit (VIP)",
	"Autotronic M9 (VIP)", "Chang M9 (VIP)", "Fade Butterfly (VIP)",
	"Gamma Doppler M9 (VIP)", "Hyper Beast Karambit (VIP)", "Lore Bayonet (VIP)",
	"Lore Karambit (VIP)", "Lore M9 (VIP)", "Ultraviolet M9 (VIP)", "Violet (VIP)",
	"Bayonet Copy (VIP)", "Butterfly (VIP)", "Falchion (VIP)", "Flip (VIP)",
	"Huntsman Copy (VIP)", "M9 Bayonet (VIP)", "Navaja (VIP)", "Stiletto Copy (VIP)"
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
	"models/skins/knife/v_frozen.mdl",
	"models/skins/knife/v_grizzly.mdl",
	"models/skins/knife/v_kz_tron_blue.mdl",
	"models/skins/knife/v_kz_tron_green.mdl",
	"models/skins/knife/v_kz_tron_orange.mdl",
	"models/skins/knife/v_abstr_karambit.mdl",
	"models/skins/knife/v_autotronic_bayonet.mdl",
	"models/skins/knife/v_autotronic_karambit.mdl",
	"models/skins/knife/v_autotronic_m9.mdl",
	"models/skins/knife/v_chang_m9.mdl",
	"models/skins/knife/v_fade_butterfly.mdl",
	"models/skins/knife/v_gamma_doppler_m9.mdl",
	"models/skins/knife/v_hyper_beast_karambit.mdl",
	"models/skins/knife/v_lore_bayonet.mdl",
	"models/skins/knife/v_lore_karambit.mdl",
	"models/skins/knife/v_lore_m9.mdl",
	"models/skins/knife/v_ultraviolet_m9.mdl",
	"models/skins/knife/v_violet.mdl",
	"models/skins/knife/v_bayonet_vip.mdl",
	"models/skins/knife/v_butterfly_vip.mdl",
	"models/skins/knife/v_falchion_vip.mdl",
	"models/skins/knife/v_flip_vip.mdl",
	"models/skins/knife/v_huntsman_vip.mdl",
	"models/skins/knife/v_m9_bayonet_vip.mdl",
	"models/skins/knife/v_navaja_vip.mdl",
	"models/skins/knife/v_stiletto_vip.mdl"
}

#define DEF_MAX 9

new const g_DefaultModels[DEF_MAX][] = {
	"models/v_aug.mdl",
	"models/v_famas.mdl",
	"models/v_glock18.mdl",
	"models/v_m249.mdl",
	"models/v_mp5.mdl",
	"models/v_p90.mdl",
	"models/v_scout.mdl",
	"models/v_ump45.mdl",
	"models/v_usp.mdl"
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

	for (i = 0; i < DEF_MAX; i++)
		precache_model(g_DefaultModels[i])
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

	RegisterHam(Ham_Item_Deploy, "weapon_aug", "fw_Deploy_Aug", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_famas", "fw_Deploy_Famas", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_glock18", "fw_Deploy_Glock", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_m249", "fw_Deploy_M249", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_mp5navy", "fw_Deploy_Mp5", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_p90", "fw_Deploy_P90", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_scout", "fw_Deploy_Scout", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_ump45", "fw_Deploy_Ump", 1)
	RegisterHam(Ham_Item_Deploy, "weapon_usp", "fw_Deploy_Usp", 1)

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
		g_dg[id] = random_num(1, 8)
		g_kn[id] = random_num(1, 15)
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

	if (skin_is_vip(type, selected) && !(get_user_flags(id) & (ADMIN_RESERVATION | ADMIN_KICK)))
	{
		client_print(id, print_chat, "[eXe] Solicita VIP para usar esta skin!")
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
	new id = weapon_owner(ent, "weapon_ak47")
	if (id && g_ak[id] > 0)
		set_pev(id, pev_viewmodel2, gszAkModels[g_ak[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_M4(ent)
{
	new id = weapon_owner(ent, "weapon_m4a1")
	if (id && g_m4[id] > 0)
		set_pev(id, pev_viewmodel2, gszM4Models[g_m4[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Awp(ent)
{
	new id = weapon_owner(ent, "weapon_awp")
	if (id && g_awp[id] > 0)
		set_pev(id, pev_viewmodel2, gszAwpModels[g_awp[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Dg(ent)
{
	new id = weapon_owner(ent, "weapon_deagle")
	if (id && g_dg[id] > 0)
		set_pev(id, pev_viewmodel2, gszDgModels[g_dg[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Kn(ent)
{
	new id = weapon_owner(ent, "weapon_knife")
	if (id && g_kn[id] > 0)
		set_pev(id, pev_viewmodel2, gszKnModels[g_kn[id] - 1])
	return HAM_IGNORED
}

public fw_Deploy_Aug(ent)
{
	new id = weapon_owner(ent, "weapon_aug")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[0])
	return HAM_IGNORED
}

public fw_Deploy_Famas(ent)
{
	new id = weapon_owner(ent, "weapon_famas")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[1])
	return HAM_IGNORED
}

public fw_Deploy_Glock(ent)
{
	new id = weapon_owner(ent, "weapon_glock18")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[2])
	return HAM_IGNORED
}

public fw_Deploy_M249(ent)
{
	new id = weapon_owner(ent, "weapon_m249")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[3])
	return HAM_IGNORED
}

public fw_Deploy_Mp5(ent)
{
	new id = weapon_owner(ent, "weapon_mp5navy")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[4])
	return HAM_IGNORED
}

public fw_Deploy_P90(ent)
{
	new id = weapon_owner(ent, "weapon_p90")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[5])
	return HAM_IGNORED
}

public fw_Deploy_Scout(ent)
{
	new id = weapon_owner(ent, "weapon_scout")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[6])
	return HAM_IGNORED
}

public fw_Deploy_Ump(ent)
{
	new id = weapon_owner(ent, "weapon_ump45")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[7])
	return HAM_IGNORED
}

public fw_Deploy_Usp(ent)
{
	new id = weapon_owner(ent, "weapon_usp")
	if (id)
		set_pev(id, pev_viewmodel2, g_DefaultModels[8])
	return HAM_IGNORED
}

stock weapon_owner(const ent, const classname[])
{
	new id

	for (id = 1; id <= MaxClients; id++)
	{
		if (is_user_alive(id) && fm_find_ent_by_owner(-1, classname, id) == ent)
			return id
	}

	return 0
}

stock skin_is_vip(type, selected)
{
	switch (type)
	{
		case 0: return selected > 5
		case 1: return selected > 10
		case 2: return selected > 5
		case 3: return selected > 8
		case 4: return selected > 15
	}
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
