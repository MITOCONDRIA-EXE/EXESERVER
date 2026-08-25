#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

new const g_WeaponModels[][] = {
	"weapon_aug",     "models/default/v_aug.mdl",
	"weapon_famas",   "models/default/v_famas.mdl",
	"weapon_glock18", "models/default/v_glock18.mdl",
	"weapon_m249",    "models/default/v_m249.mdl",
	"weapon_mp5navy", "models/default/v_mp5.mdl",
	"weapon_p90",     "models/default/v_p90.mdl",
	"weapon_scout",   "models/default/v_scout.mdl",
	"weapon_ump45",   "models/default/v_ump45.mdl",
	"weapon_usp",     "models/default/v_usp.mdl"
}

new const g_WeaponCount = sizeof(g_WeaponModels) / (2 * 32)

new g_iWeaponModel[MAX_PLAYERS + 1][64]

public plugin_precache()
{
	for (new i = 0; i < g_WeaponCount; i++)
		precache_model(g_WeaponModels[i][1])
}

public plugin_init()
{
	register_plugin("Default Weapon Skins", "1.1", "MITO")

	for (new i = 0; i < g_WeaponCount; i++)
	{
		RegisterHam(Ham_Item_Deploy, g_WeaponModels[i][0], "fw_Deploy_Default", 1)
		RegisterHam(Ham_AddPlayerItem, g_WeaponModels[i][0], "fw_AddPlayerItem", 1)
	}
}

public fw_Deploy_Default(ent)
{
	static classname[32]
	pev(ent, pev_classname, classname, charsmax(classname))

	for (new i = 0; i < g_WeaponCount; i++)
	{
		if (equal(classname, g_WeaponModels[i][0]))
		{
			new id = pev(ent, pev_owner)
			if (is_user_alive(id))
			{
				copy(g_iWeaponModel[id], charsmax(g_iWeaponModel[]), g_WeaponModels[i][1])
				set_pev(id, pev_viewmodel2, g_WeaponModels[i][1])
				set_task(0.1, "task_apply_skin", id)
			}
			break
		}
	}
	return HAM_IGNORED
}

public fw_AddPlayerItem(ent)
{
	static classname[32]
	pev(ent, pev_classname, classname, charsmax(classname))

	for (new i = 0; i < g_WeaponCount; i++)
	{
		if (equal(classname, g_WeaponModels[i][0]))
		{
			new id = pev(ent, pev_owner)
			if (is_user_alive(id))
			{
				copy(g_iWeaponModel[id], charsmax(g_iWeaponModel[]), g_WeaponModels[i][1])
				set_task(0.15, "task_apply_skin", id)
			}
			break
		}
	}
	return HAM_IGNORED
}

public task_apply_skin(id)
{
	if (is_user_alive(id) && g_iWeaponModel[id][0])
		set_pev(id, pev_viewmodel2, g_iWeaponModel[id])
}
