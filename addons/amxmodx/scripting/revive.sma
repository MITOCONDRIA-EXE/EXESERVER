#include <amxmodx>
#include <fakemeta>
#include <cstrike>
#include <hamsandwich>
#include <hlsdk_const>
#include <message_const>

#define REVIVE_TIME 4.0
#define PLANT_TIME 1.0
#define TRIGGER_TIME 1.0
#define REVIVE_RANGE 90.0
#define TRAP_DAMAGE 500.0

new const TRAP_SPRITE[] = "sprites/zerogxplode.spr"
new const TRAP_MODEL[] = "models/w_c4.mdl"

new bool:g_bCorpse[33]
new bool:g_bTrapped[33]
new g_iTrapOwner[33]
new g_iTrapEnt[33]
new Float:g_fDeathOrigin[33][3]

new g_iTarget[33]
new Float:g_fHold[33]
new Float:g_fLastThink[33]

new g_iExplosionSpr

public plugin_precache()
{
	g_iExplosionSpr = precache_model(TRAP_SPRITE)
	precache_model(TRAP_MODEL)
}

public plugin_init()
{
	register_plugin("Revive Con E", "1.0", "MITO")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}

public client_disconnected(id)
{
	clear_corpse(id)
	g_iTarget[id] = 0
	g_fHold[id] = 0.0
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if (!is_user_connected(victim))
		return

	pev(victim, pev_origin, g_fDeathOrigin[victim])
	g_bCorpse[victim] = true
	g_bTrapped[victim] = false
	g_iTrapOwner[victim] = 0

	g_iTarget[killer] = 0
	g_fHold[killer] = 0.0
}

public clear_corpse(id)
{
	g_bCorpse[id] = false
	g_bTrapped[id] = false
	g_iTrapOwner[id] = 0

	if (pev_valid(g_iTrapEnt[id]))
		engfunc(EngFunc_RemoveEntity, g_iTrapEnt[id])

	g_iTrapEnt[id] = 0
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED

	new Float:fNow = get_gametime()
	new Float:fDt = fNow - g_fLastThink[id]
	g_fLastThink[id] = fNow

	if (fDt <= 0.0 || fDt > 0.5)
		fDt = 0.1

	for (new i = 1; i <= 32; i++)
	{
		if (g_bCorpse[i] && is_user_alive(i))
			clear_corpse(i)
	}

	new Float:po[3]
	pev(id, pev_origin, po)

	new target = 0
	new Float:best = REVIVE_RANGE

	for (new i = 1; i <= 32; i++)
	{
		if (!g_bCorpse[i] || i == id)
			continue

		new Float:d = get_distance_f(po, g_fDeathOrigin[i])
		if (d < best)
		{
			best = d
			target = i
		}
	}

	if (!target || !(pev(id, pev_button) & IN_USE))
	{
		if (g_iTarget[id] == target)
		{
			g_iTarget[id] = 0
			g_fHold[id] = 0.0
		}

		return FMRES_IGNORED
	}

	if (g_iTarget[id] != target)
	{
		g_iTarget[id] = target
		g_fHold[id] = 0.0
	}

	g_fHold[id] += fDt

	if (g_bTrapped[target])
	{
		if (g_iTrapOwner[target] != id && g_fHold[id] >= TRIGGER_TIME)
			trap_explode(target, id)
	}
	else if (get_user_team(id) == get_user_team(target))
	{
		if (g_fHold[id] >= REVIVE_TIME)
			do_revive(id, target)
		else
			show_revive_hud(id, target)
	}
	else
	{
		if (g_fHold[id] >= PLANT_TIME)
			plant_trap(id, target)
		else
			show_plant_hud(id, target)
	}

	return FMRES_IGNORED
}

public do_revive(id, target)
{
	new name[32], tname[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(target, tname, charsmax(tname))

	g_iTarget[id] = 0
	g_fHold[id] = 0.0

	set_pev(target, pev_deadflag, DEAD_RESPAWNABLE)
	dllfunc(DLLFunc_Spawn, target)

	if (is_user_alive(target))
		engfunc(EngFunc_SetOrigin, target, g_fDeathOrigin[target])

	client_print(0, print_chat, "[eXe] %s revivio a %s!", name, tname)

	clear_corpse(target)
}

public plant_trap(id, target)
{
	new name[32], tname[32]
	get_user_name(id, name, charsmax(name))
	get_user_name(target, tname, charsmax(tname))

	g_iTarget[id] = 0
	g_fHold[id] = 0.0

	g_bTrapped[target] = true
	g_iTrapOwner[target] = id

	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (pev_valid(ent))
	{
		new Float:fColor[3] = {255.0, 0.0, 0.0}

		set_pev(ent, pev_classname, "bomba_trampa")
		set_pev(ent, pev_model, TRAP_MODEL)
		set_pev(ent, pev_origin, g_fDeathOrigin[target])
		set_pev(ent, pev_solid, SOLID_NOT)
		set_pev(ent, pev_movetype, MOVETYPE_NONE)
		set_pev(ent, pev_renderfx, kRenderFxGlowShell)
		set_pev(ent, pev_rendermode, kRenderNormal)
		set_pev(ent, pev_renderamt, 255.0)
		set_pev(ent, pev_rendercolor, fColor)

		g_iTrapEnt[target] = ent
	}

	client_print(id, print_chat, "[eXe] Le plantaste una bomba al cadaver de %s!", tname)
	client_print(0, print_chat, "[eXe] %s planto una bomba en el cadaver de %s!", name, tname)
}

public trap_explode(target, holder)
{
	new Float:o[3]
	pev(target, pev_origin, o)

	if (o[0] == 0.0 && o[1] == 0.0 && o[2] == 0.0)
		o = g_fDeathOrigin[target]

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(floatround(o[0]))
	write_coord(floatround(o[1]))
	write_coord(floatround(o[2]))
	write_byte(30)
	write_byte(10)
	write_short(g_iExplosionSpr)
	write_byte(15)
	write_byte(0)
	write_byte(0)
	message_end()

	new owner = g_iTrapOwner[target]

	if (is_user_connected(owner) && is_user_alive(holder))
		ExecuteHam(Ham_TakeDamage, holder, holder, owner, TRAP_DAMAGE, DMG_BLAST)

	new tname[32]
	get_user_name(target, tname, charsmax(tname))
	client_print(0, print_chat, "[eXe] La bomba en el cadaver de %s exploto!", tname)

	g_iTarget[holder] = 0
	g_fHold[holder] = 0.0
	clear_corpse(target)
}

public show_revive_hud(id, target)
{
	new tname[32]
	get_user_name(target, tname, charsmax(tname))

	new name[32]
	get_user_name(id, name, charsmax(name))

	new pct = floatround(g_fHold[id] / REVIVE_TIME * 100.0)

	set_hudmessage(0, 255, 0, -1.0, 0.35, 0, 6.0, 0.1, 0.1, 0.1, -1)
	show_hudmessage(id, "Reviviendo a %s... %d%%", tname, pct)

	set_hudmessage(0, 255, 0, -1.0, 0.55, 0, 6.0, 0.1, 0.1, 0.1, -1)
	show_hudmessage(target, "%s te esta reviviendo!", name)
}

public show_plant_hud(id, target)
{
	new tname[32]
	get_user_name(target, tname, charsmax(tname))

	new pct = floatround(g_fHold[id] / PLANT_TIME * 100.0)

	set_hudmessage(255, 80, 0, -1.0, 0.35, 0, 6.0, 0.1, 0.1, 0.1, -1)
	show_hudmessage(id, "Plantando bomba en el cadaver de %s... %d%%", tname, pct)
}
