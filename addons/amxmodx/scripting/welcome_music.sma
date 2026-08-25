#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>

new const SOUND[] = "misc/welcomexe.wav"

new g_pWelcome
new g_pDelay
new g_pMinTime
new bool:g_bPlayed[33]
new Float:g_fJoined[33]

public plugin_init()
{
	register_plugin("Welcome Music", "4.0", "MITO")
	g_pWelcome = create_cvar("welcome_music", "1")
	g_pDelay = create_cvar("welcome_delay", "0.2")
	g_pMinTime = create_cvar("welcome_mintime", "3.0")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	RegisterHam(Ham_Spawn, "player", "fw_PlayerSpawn", 1)
}

public plugin_precache()
{
	precache_sound(SOUND)
}

public client_putinserver(id)
{
	if (!is_user_bot(id))
	{
		g_fJoined[id] = get_gametime()
		set_task(get_pcvar_float(g_pDelay), "play_welcome", id)
	}
}

public play_welcome(id)
{
	if (!is_user_connected(id) || g_bPlayed[id] || !get_pcvar_num(g_pWelcome))
		return

	g_bPlayed[id] = true
	client_cmd(id, "spk %s", SOUND)
}

public cut_welcome(id)
{
	if (!g_bPlayed[id])
		return

	g_bPlayed[id] = false
	client_cmd(id, "stopsound")
}

public fw_PlayerSpawn(id)
{
	if (g_bPlayed[id] && get_gametime() - g_fJoined[id] > get_pcvar_float(g_pMinTime))
		cut_welcome(id)

	return FMRES_IGNORED
}

public fw_PlayerPreThink(id)
{
	if (!g_bPlayed[id])
		return FMRES_IGNORED

	if (cs_get_user_team(id) != CS_TEAM_UNASSIGNED)
		cut_welcome(id)

	return FMRES_IGNORED
}

public client_disconnected(id)
{
	g_bPlayed[id] = false
	g_fJoined[id] = 0.0
}
