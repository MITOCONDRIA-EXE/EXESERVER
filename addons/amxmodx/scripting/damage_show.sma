#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>

new g_pDamage

public plugin_init()
{
	register_plugin("Mostrar Dano", "1.0", "MITO")

	g_pDamage = create_cvar("show_damage", "1")

	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage", 1)
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damagebits)
{
	if (victim == attacker || attacker < 1 || attacker > MaxClients)
		return HAM_IGNORED

	if (!is_user_connected(attacker) || !is_user_alive(victim))
		return HAM_IGNORED

	if (!get_pcvar_num(g_pDamage))
		return HAM_IGNORED

	new Float:fDmg
	pev(victim, pev_dmg_take, fDmg)

	new iDmg = floatround(fDmg)
	if (iDmg <= 0)
		return HAM_IGNORED

	set_hudmessage(255, 64, 64, -1.0, 0.45, 0, 0.05, 0.05, 0.1, 0.6, 6)
	show_hudmessage(attacker, "-%d", iDmg)

	return HAM_IGNORED
}
