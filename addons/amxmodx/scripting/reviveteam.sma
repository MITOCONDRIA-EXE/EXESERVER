#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>
#include <xs>

#define PLUGIN "Revive + Plant Bomb"
#define VERSION "1.2"
#define AUTHOR "MITO"

#define REVIVE_TIME 2.0
#define BOMB_TIME 4.0
#define REVIVE_DISTANCE 150.0

new g_iReviveTarget[33]
new Float:g_fReviveStart[33]
new g_iBombTarget[33]
new Float:g_fBombStart[33]
new g_iHudSync
new g_iCTRevives
new g_iTRvives
const MAX_REVIVES_PER_TEAM = 2

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_PlayerPostThink, "fw_PlayerPostThink")
	RegisterHam(Ham_Killed, "player", "fw_PlayerKilled")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	g_iHudSync = CreateHudSyncObj()
}

public event_round_start()
{
	for (new id = 1; id <= get_maxplayers(); id++)
	{
		g_iReviveTarget[id] = 0
		g_iBombTarget[id] = 0
	}
	g_iCTRevives = 0
	g_iTRvives = 0
}

public fw_PlayerKilled(id, killer, shouldgib)
{
	g_iReviveTarget[id] = 0
	g_iBombTarget[id] = 0
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return

	new buttons = pev(id, pev_button)
	if (!(buttons & IN_USE))
	{
		g_iReviveTarget[id] = 0
		g_iBombTarget[id] = 0
		return
	}

	new target = GetAimEntity(id)
	if (target < 1 || target > get_maxplayers() || !is_user_connected(target) || is_user_alive(target))
	{
		g_iReviveTarget[id] = 0
		g_iBombTarget[id] = 0
		return
	}

	new CsTeams:revTeam = cs_get_user_team(id)
	new CsTeams:tgtTeam = cs_get_user_team(target)
	new bool:sameTeam = (revTeam == tgtTeam)

	new Float:origin1[3], Float:origin2[3]
	pev(id, pev_origin, origin1)
	pev(target, pev_origin, origin2)
	if (get_distance_f(origin1, origin2) > REVIVE_DISTANCE)
	{
		g_iReviveTarget[id] = 0
		g_iBombTarget[id] = 0
		return
	}

	if (sameTeam)
	{
		if (g_iReviveTarget[id] != target)
		{
			new bool:canRevive = false
			if (revTeam == CS_TEAM_T && g_iTRvives < MAX_REVIVES_PER_TEAM)
				canRevive = true
			else if (revTeam == CS_TEAM_CT && g_iCTRevives < MAX_REVIVES_PER_TEAM)
				canRevive = true

			if (!canRevive)
			{
				client_print(id, print_center, "Tu equipo llego al limite de revivir esta ronda!")
				g_iReviveTarget[id] = 0
			}
			else
			{
				g_iReviveTarget[id] = target
				g_iBombTarget[id] = 0
				g_fReviveStart[id] = get_gametime()
			}
		}
	}
	else
	{
		if (g_iBombTarget[id] != target)
		{
			g_iBombTarget[id] = target
			g_iReviveTarget[id] = 0
			g_fBombStart[id] = get_gametime()
		}
	}
}

public fw_PlayerPostThink(id)
{
	if (g_iReviveTarget[id] > 0)
	{
		new Float:timeHeld = get_gametime() - g_fReviveStart[id]
		if (timeHeld >= REVIVE_TIME)
		{
			if (is_user_connected(g_iReviveTarget[id]) && !is_user_alive(g_iReviveTarget[id]))
				RevivePlayer(g_iReviveTarget[id], id)
			g_iReviveTarget[id] = 0
		}
		else
		{
			set_hudmessage(255, 255, 255, -1.0, 0.45, 0, 0.0, 0.1, 0.0, 0.0, -1)
			ShowSyncHudMsg(id, g_iHudSync, "Reviviendo... %.0f%%", timeHeld / REVIVE_TIME * 100.0)
		}
	}

	if (g_iBombTarget[id] > 0)
	{
		new Float:timeHeld = get_gametime() - g_fBombStart[id]
		if (timeHeld >= BOMB_TIME)
		{
			if (is_user_connected(g_iBombTarget[id]) && !is_user_alive(g_iBombTarget[id]))
				PlantBomb(g_iBombTarget[id], id)
			g_iBombTarget[id] = 0
		}
		else
		{
			set_hudmessage(255, 50, 50, -1.0, 0.45, 0, 0.0, 0.1, 0.0, 0.0, -1)
			ShowSyncHudMsg(id, g_iHudSync, "Bombeando... %.0f%%", timeHeld / BOMB_TIME * 100.0)
		}
	}
}

stock RevivePlayer(target, reviver)
{
	if (is_user_alive(target) || !is_user_connected(target) || !is_user_connected(reviver))
		return

	new CsTeams:team = cs_get_user_team(target)
	if ((team == CS_TEAM_T && g_iTRvives >= MAX_REVIVES_PER_TEAM) ||
		(team == CS_TEAM_CT && g_iCTRevives >= MAX_REVIVES_PER_TEAM))
		return

	new Float:reviverOrigin[3]
	pev(reviver, pev_origin, reviverOrigin)

	ExecuteHam(Ham_CS_RoundRespawn, target)

	reviverOrigin[2] += 40.0
	set_pev(target, pev_origin, reviverOrigin)

	if (team == CS_TEAM_T)
		g_iTRvives++
	else
		g_iCTRevives++

	client_print(0, print_chat, "%n revivio a %n! [%s: %d/%d]",
		reviver, target,
		(team == CS_TEAM_T) ? "TT" : "CT",
		(team == CS_TEAM_T) ? g_iTRvives : g_iCTRevives,
		MAX_REVIVES_PER_TEAM)
}

stock PlantBomb(target, planter)
{
	if (!is_user_connected(target))
		return

	new Float:origin[3]
	pev(target, pev_origin, origin)

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(floatround(origin[0]))
	write_coord(floatround(origin[1]))
	write_coord(floatround(origin[2]))
	write_short(engfunc(EngFunc_ModelIndex, "sprites/eexplo.spr"))
	write_byte(30)
	write_byte(15)
	write_byte(TE_EXPLFLAG_NONE)
	message_end()

	new players[32], pnum
	get_players(players, pnum, "a")
	for (new i = 0; i < pnum; i++)
	{
		new pid = players[i]
		if (pid == planter)
			continue

		new Float:pOrigin[3]
		pev(pid, pev_origin, pOrigin)
		new Float:dist = get_distance_f(origin, pOrigin)
		if (dist > 200.0)
			continue

		new Float:dmg = 80.0 * (1.0 - dist / 200.0)
		if (dmg < 1.0)
			continue

		ExecuteHam(Ham_TakeDamage, pid, 0, planter, dmg, DMG_BLAST)
	}

	client_print(0, print_chat, "%n planto una bomba en el cadaver de un enemigo!")
}

stock GetAimEntity(id)
{
	new Float:reviverOrigin[3], Float:targetOrigin[3]
	pev(id, pev_origin, reviverOrigin)
	new Float:aimDir[3], Float:viewOfs[3]
	pev(id, pev_view_ofs, viewOfs)
	xs_vec_add(reviverOrigin, viewOfs, reviverOrigin)
	velocity_by_aim(id, 9999, aimDir)
	xs_vec_normalize(aimDir, aimDir)
	new closestTarget = 0
	new Float:closestDist = 9999.0
	for (new target = 1; target <= get_maxplayers(); target++)
	{
		if (target == id || is_user_alive(target) || !is_user_connected(target))
			continue
		pev(target, pev_origin, targetOrigin)
		new Float:dist = get_distance_f(reviverOrigin, targetOrigin)
		if (dist > REVIVE_DISTANCE)
			continue
		new Float:vecToTarget[3]
		xs_vec_sub(targetOrigin, reviverOrigin, vecToTarget)
		xs_vec_normalize(vecToTarget, vecToTarget)
		new Float:dot = xs_vec_dot(vecToTarget, aimDir)
		if (dot > 0.7)
		{
			if (dist < closestDist)
			{
				closestDist = dist
				closestTarget = target
			}
		}
	}
	return closestTarget
}
