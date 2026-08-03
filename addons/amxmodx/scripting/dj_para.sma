#include <amxmodx>
#include <fakemeta>

new g_iMaxJumps
new g_fParaGrav
new g_fBhopBoost
new g_fBhopMax
new g_iJumps[33]
new g_bPara[33]

public plugin_init()
{
	register_plugin("Doble Salto + Paracaidas", "3.5", "MITO")

	g_iMaxJumps = register_cvar("dj_maxjumps", "1")
	g_fParaGrav = register_cvar("dj_paragrav", "0.4")
	g_fBhopBoost = register_cvar("dj_bhopboost", "16.0")
	g_fBhopMax = register_cvar("dj_bhopmax", "320.0")

	register_clcmd("say /para", "toggle_para")
	register_clcmd("say para", "toggle_para")

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
}

public client_putinserver(id)
{
	g_bPara[id] = true
	g_iJumps[id] = 0
}

public client_disconnected(id)
{
	g_bPara[id] = false
	g_iJumps[id] = 0
}

public toggle_para(id)
{
	if (!is_user_connected(id))
		return PLUGIN_HANDLED

	g_bPara[id] = !g_bPara[id]
	client_print(id, print_chat, "[eXe] Paracaidas: %s", g_bPara[id] ? "ON" : "OFF")

	return PLUGIN_HANDLED
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
	{
		if (pev(id, pev_gravity) != 1.0)
			set_pev(id, pev_gravity, 1.0)

		return FMRES_IGNORED
	}

	new flags = pev(id, pev_flags)
	new buttons = pev(id, pev_button)
	new oldbuttons = pev(id, pev_oldbuttons)

	if (flags & FL_ONGROUND)
		g_iJumps[id] = 0
	else if ((buttons & IN_JUMP) && !(oldbuttons & IN_JUMP))
	{
		if (g_iJumps[id] < get_pcvar_num(g_iMaxJumps))
		{
			g_iJumps[id]++

			new Float:v[3]
			pev(id, pev_velocity, v)

			new Float:fSpeed = floatsqroot(v[0] * v[0] + v[1] * v[1])
			if (fSpeed > 60.0 && fSpeed < get_pcvar_float(g_fBhopMax))
			{
				new Float:fScale = (fSpeed + get_pcvar_float(g_fBhopBoost)) / fSpeed
				v[0] *= fScale
				v[1] *= fScale
			}

			v[2] = 265.0
			set_pev(id, pev_velocity, v)
		}
	}

	if (g_bPara[id])
	{
		if (!(flags & FL_ONGROUND) && (buttons & IN_USE) && g_iJumps[id] > 0)
		{
			if (pev(id, pev_gravity) != get_pcvar_float(g_fParaGrav))
				set_pev(id, pev_gravity, get_pcvar_float(g_fParaGrav))
		}
		else if (pev(id, pev_gravity) != 1.0)
			set_pev(id, pev_gravity, 1.0)
	}
	else if (pev(id, pev_gravity) != 1.0)
		set_pev(id, pev_gravity, 1.0)

	return FMRES_IGNORED
}
