#include <amxmodx>
#include <csx>
#include <fakemeta>
#include <fakemeta_util>
#include <cstrike>
#include <engine>
#include <hamsandwich>

new g_iHealthBonus
new g_pRadius
new g_iGive

new const CLASS_BOMB[] = "bomba_vida"
new const VIEW_BOMB[] = "models/v_smokegrenade.mdl"
new const WORLD_BOMB[] = "models/w_smokegrenade.mdl"
new const HEAL_SOUND[] = "weapons/reapi_healthnade/heal.wav"

new bool:g_bHasBomb[33]
new bool:g_bRound[33]
new bool:g_bThrowing[33]
new bool:g_bPlGive[33]
new g_iLastWeapon[33]
new Float:g_fThrowTime[33]
new Float:g_fExplodeOrigin[33][3]

new g_iHealShapeSpr
new g_iHealExplodeSpr
new g_iGlowSpr

public plugin_init()
{
	register_plugin("Bomba Da Vida", "8.0", "MITO")

	g_iHealthBonus = register_cvar("bomba_vida", "50")
	g_pRadius = register_cvar("bomba_vida_radius", "350.0")
	g_iGive = register_cvar("bomba_vida_give", "1")

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_UpdateClientData, "fw_UpdateClientData")
	register_touch("grenade", "*", "fw_GrenadeTouch")
	register_logevent("round_start", 2, "1=World triggered", "2=Round_Start")
	register_logevent("bomb_plant", 3, "2=Planted_The_Bomb")
	register_event("ResetHUD", "reset_hud", "b")
	RegisterHam(Ham_AddPlayerItem, "player", "ham_AddPlayerItem_post", 1)
}

public fw_UpdateClientData(id, sendweapons, cd_handle)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED

	if (get_user_weapon(id) == CSW_SMOKEGRENADE && g_bHasBomb[id])
	{
		set_cd(cd_handle, CD_ViewModel, VIEW_BOMB)
		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

public reset_hud(id)
{
	if (!is_user_alive(id))
		return

	g_bThrowing[id] = false
	g_bHasBomb[id] = false
	g_bRound[id] = true

			if (get_pcvar_num(g_iGive))
		{
			give_bomb(id)
			g_bHasBomb[id] = true
		}
}

public ham_AddPlayerItem_post(id, item)
{
	if (!pev_valid(item))
		return

	static classname[32]
	pev(item, pev_classname, classname, charsmax(classname))
	if (equal(classname, "weapon_smokegrenade"))
	{
		if (g_bPlGive[id])
			return

		g_bHasBomb[id] = false
	}
	else if (equal(classname, "weapon_hegrenade"))
	{
		client_print(id, print_chat, "[DEBUG] Agarraste HE")
		client_cmd(id, "spk misc/peluca")
	}
}

public round_start()
{
	for (new i = 1; i <= 32; i++)
	{
		if (!is_user_connected(i))
			continue

		g_bRound[i] = false
		g_bThrowing[i] = false
		g_bHasBomb[i] = false

		remove_task(i)

		if (!is_user_alive(i) || !get_pcvar_num(g_iGive))
			continue

		give_bomb(i)
		g_bHasBomb[i] = true
	}
}

public plugin_precache()
{
	precache_model(VIEW_BOMB)
	precache_model(WORLD_BOMB)
	precache_sound("misc/llego_el_lechero.wav")
	precache_sound("misc/peluca.wav")
	precache_sound("misc/peluca.wav")
	precache_sound(HEAL_SOUND)
	g_iHealShapeSpr = precache_model("sprites/reapi_healthnade/heal_shape.spr")
	g_iHealExplodeSpr = precache_model("sprites/reapi_healthnade/heal_explode.spr")
	g_iGlowSpr = precache_model("sprites/glow01.spr")
}

public bomb_plant()
{
	client_cmd(0, "spk misc/llego_el_lechero")
}

public client_disconnected(id)
{
	g_bHasBomb[id] = false
	g_bRound[id] = false
	g_bThrowing[id] = false
	remove_task(id)
}

public client_death(killer, victim, wpnindex, hitplace, TK)
{
	if (!is_user_connected(victim))
		return

	g_bThrowing[victim] = false
	remove_task(victim)

	if (g_bHasBomb[victim] && get_pcvar_num(g_iGive))
	{
		new Float:o[3]
		pev(victim, pev_origin, o)
		drop_bomb(o)

		new name[32]
		get_user_name(victim, name, charsmax(name))
		client_print(0, print_chat, "[eXe] %s murio y dejo su bomba de vida en el piso! Robala!", name)
	}

	g_bHasBomb[victim] = false

	if (is_user_connected(killer) && killer != victim)
	{
		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, killer)
		write_short(256)
		write_short(0)
		write_short(0x0001)
		write_byte(0)
		write_byte(100)
		write_byte(220)
		write_byte(120)
		message_end()
	}
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED

	if (get_pcvar_num(g_iGive))
	{
		if (!g_bRound[id])
		{
			g_bRound[id] = true
			if (give_bomb(id))
				g_bHasBomb[id] = true
		}
		else if (g_bHasBomb[id] && !user_has_weapon(id, CSW_SMOKEGRENADE))
		{
			if (give_bomb(id))
				g_bHasBomb[id] = true
		}
	}

	new iCurWpn = get_user_weapon(id)
	if (iCurWpn != g_iLastWeapon[id])
	{
		g_iLastWeapon[id] = iCurWpn

		message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("ScreenFade"), _, id)
		if (iCurWpn == CSW_SMOKEGRENADE)
		{
			write_short(512)
			write_short(999999)
			write_short(0x0000)
			if (g_bHasBomb[id])
			{
				write_byte(0)
				write_byte(255)
				write_byte(0)
				write_byte(20)
			}
			else
			{
				write_byte(255)
				write_byte(0)
				write_byte(0)
				write_byte(20)
			}
		}
		else
		{
			write_short(0)
			write_short(0)
			write_short(0x0001)
			write_byte(0)
			write_byte(0)
			write_byte(0)
			write_byte(0)
		}
		message_end()
	}

	new buttons = pev(id, pev_button)
	new oldbuttons = pev(id, pev_oldbuttons)

	if (get_user_weapon(id) == CSW_SMOKEGRENADE)
	{
		new iWeapon = fm_find_ent_by_owner(-1, "weapon_smokegrenade", id)
		if (iWeapon)
		{
			if (g_bHasBomb[id])
			{
				set_pev(iWeapon, pev_viewmodel2, VIEW_BOMB)
				set_pev(iWeapon, pev_weaponmodel2, WORLD_BOMB)

				new Float:fGreen[3] = {0.0, 255.0, 0.0}
				set_pev(iWeapon, pev_renderfx, kRenderFxNone)
				set_pev(iWeapon, pev_rendermode, kRenderTransAdd)
				set_pev(iWeapon, pev_renderamt, 80.0)
				set_pev(iWeapon, pev_rendercolor, fGreen)

				if ((oldbuttons & IN_ATTACK) && !(buttons & IN_ATTACK) && !g_bThrowing[id])
				{
					g_bThrowing[id] = true
					g_bHasBomb[id] = false
					g_fThrowTime[id] = get_gametime()
					pev(id, pev_origin, g_fExplodeOrigin[id])
					remove_task(id)
					set_task(3.0, "heal_blast", id)
				}
			}
			else
			{
				new Float:fRed[3] = {255.0, 0.0, 0.0}
				set_pev(iWeapon, pev_renderfx, kRenderFxNone)
				set_pev(iWeapon, pev_rendermode, kRenderTransAdd)
				set_pev(iWeapon, pev_renderamt, 80.0)
				set_pev(iWeapon, pev_rendercolor, fRed)
			}
		}
	}

	if (g_bThrowing[id])
	{
		new Float:fElapsed = get_gametime() - g_fThrowTime[id]

		if (fElapsed > 3.0)
		{
			g_bThrowing[id] = false
		}
		else
		{
			new Float:fColor[3] = {0.0, 255.0, 0.0}
			new ent = -1
			while ((ent = fm_find_ent_by_class(ent, "grenade")) > 0)
			{
				if (pev(ent, pev_owner) == id)
				{
					set_pev(ent, pev_dmg, 0.0)
					set_pev(ent, pev_model, WORLD_BOMB)
					set_pev(ent, pev_renderfx, kRenderFxNone)
					set_pev(ent, pev_rendermode, kRenderTransAdd)
					set_pev(ent, pev_renderamt, 80.0)
					set_pev(ent, pev_rendercolor, fColor)
					set_pev(ent, pev_dmgtime, get_gametime() + 30.0)

					if (pev(ent, pev_iuser3) == 0)
					{
						message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
						write_byte(TE_BEAMFOLLOW)
						write_short(ent)
						write_short(g_iGlowSpr)
						write_byte(5)
						write_byte(3)
						write_byte(0)
						write_byte(255)
						write_byte(0)
						write_byte(200)
						message_end()
					}

					set_pev(ent, pev_iuser3, 1)
					pev(ent, pev_origin, g_fExplodeOrigin[id])

					if (pev(ent, pev_flags) & FL_ONGROUND)
					{
						new Float:v[3]
						pev(ent, pev_velocity, v)
						if (floatsqroot(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]) < 40.0)
						{
							do_heal(id, g_fExplodeOrigin[id])
							engfunc(EngFunc_RemoveEntity, ent)
							break
						}
					}
				}
			}
		}
	}

	static Float:fRed2[3] = {255.0, 0.0, 0.0}
	new fent = -1
	while ((fent = fm_find_ent_by_class(fent, "grenade")) > 0)
	{
		if (pev(fent, pev_owner) != id)
			continue
		if (pev(fent, pev_iuser3) != 0)
			continue

		set_pev(fent, pev_renderfx, kRenderFxNone)
		set_pev(fent, pev_rendermode, kRenderTransAdd)
		set_pev(fent, pev_renderamt, 80.0)
		set_pev(fent, pev_rendercolor, fRed2)

		message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
		write_byte(TE_BEAMFOLLOW)
		write_short(fent)
		write_short(g_iGlowSpr)
		write_byte(5)
		write_byte(3)
		write_byte(255)
		write_byte(0)
		write_byte(0)
		write_byte(200)
		message_end()

		set_pev(fent, pev_iuser3, 2)
	}

	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, CLASS_BOMB)) > 0)
	{
		new Float:eo[3]
		pev(ent, pev_origin, eo)

		new Float:po[3]
		pev(id, pev_origin, po)

		if (get_distance_f(eo, po) < 55.0)
		{
			remove_task(ent)
			engfunc(EngFunc_RemoveEntity, ent)

			if (!g_bHasBomb[id])
			{
				if (give_bomb(id))
				{
					g_bHasBomb[id] = true
					client_print(id, print_chat, "[eXe] Robaste una bomba de vida del piso!")
				}
			}

			break
		}
	}

	return FMRES_IGNORED
}

public give_bomb(id)
{
	if (!is_user_alive(id) || !get_pcvar_num(g_iGive))
		return 0

	g_bPlGive[id] = true

	if (fm_give_item(id, "weapon_smokegrenade") > 0)
	{
		g_bPlGive[id] = false
		cs_set_user_bpammo(id, CSW_SMOKEGRENADE, 1)
		return 1
	}

	g_bPlGive[id] = false
	return 0
}

public drop_bomb(const Float:origin[3])
{
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	if (!pev_valid(ent))
		return

	set_pev(ent, pev_classname, CLASS_BOMB)
	set_pev(ent, pev_model, WORLD_BOMB)
	set_pev(ent, pev_origin, origin)
	set_pev(ent, pev_solid, SOLID_TRIGGER)
	set_pev(ent, pev_movetype, MOVETYPE_NONE)

	new Float:fColor[3] = {0.0, 255.0, 0.0}
	set_pev(ent, pev_renderfx, kRenderFxGlowShell)
	set_pev(ent, pev_rendermode, kRenderNormal)
	set_pev(ent, pev_renderamt, 255.0)
	set_pev(ent, pev_rendercolor, fColor)

	set_task(30.0, "despawn_bomb", ent)
}

public despawn_bomb(ent)
{
	if (pev_valid(ent))
		engfunc(EngFunc_RemoveEntity, ent)
}

public fw_GrenadeTouch(ent, other)
{
	if (!pev_valid(ent))
		return

	new owner = pev(ent, pev_owner)
	if (!is_user_connected(owner) || owner == other || !g_bThrowing[owner])
		return

	new Float:dmg
	pev(ent, pev_dmg, dmg)
	if (dmg != 0.0)
		return

	new Float:eo[3]
	pev(ent, pev_origin, eo)

	do_heal(owner, eo)
	engfunc(EngFunc_RemoveEntity, ent)
}

public heal_blast(id)
{
	if (!g_bThrowing[id])
		return

	g_bThrowing[id] = false

	new ent = -1
	while ((ent = fm_find_ent_by_class(ent, "grenade")) > 0)
	{
		if (pev(ent, pev_owner) == id)
		{
			engfunc(EngFunc_RemoveEntity, ent)
			break
		}
	}

	do_heal(id, g_fExplodeOrigin[id])
}

public do_heal(id, const Float:eo[3])
{
	g_bThrowing[id] = false
	remove_task(id)

	if (!is_user_connected(id))
		return

	new bonus = get_pcvar_num(g_iHealthBonus)
	new Float:radius = get_pcvar_float(g_pRadius)
	new healed = 0

	for (new i = 1; i <= 32; i++)
	{
		if (!is_user_alive(i) || get_user_team(i) != get_user_team(id))
			continue

		new Float:po[3]
		pev(i, pev_origin, po)

		if (get_distance_f(po, eo) > radius)
			continue

		new Float:health
		pev(i, pev_health, health)
		set_pev(i, pev_health, floatmin(health + float(bonus), 100.0))

		healed++
	}

	show_heal_effect(eo)
	emit_sound(id, CHAN_AUTO, HEAL_SOUND, 1.0, ATTN_NORM, 0, PITCH_NORM)

	new name[32]
	get_user_name(id, name, charsmax(name))

	new iTeam = get_user_team(id)
	for (new i = 1; i <= 32; i++)
	{
		if (is_user_connected(i) && get_user_team(i) == iTeam)
			client_print(i, print_chat, "[eXe] %s lanzo la bomba de vida! +%d de vida a %d aliado(s).", name, bonus, healed)
	}

	set_hudmessage(0, 255, 0, -1.0, 0.45, 0, 6.0, 3.0, 0.1, 0.2, -1)
	for (new i = 1; i <= 32; i++)
	{
		if (is_user_connected(i) && get_user_team(i) == iTeam)
			show_hudmessage(i, "%s lanzo la bomba de vida! +%d de vida en el radio.", name, bonus)
	}
}

public show_heal_effect(const Float:eo[3])
{
	new x = floatround(eo[0])
	new y = floatround(eo[1])
	new z = floatround(eo[2])

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_GLOWSPRITE)
	write_coord(x)
	write_coord(y)
	write_coord(z)
	write_short(g_iHealShapeSpr)
	write_byte(30)
	write_byte(10)
	write_byte(200)
	message_end()

	message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
	write_byte(TE_EXPLOSION)
	write_coord(x)
	write_coord(y)
	write_coord(z)
	write_short(g_iHealExplodeSpr)
	write_byte(16)
	write_byte(20)
	write_byte(0)
	message_end()
}
