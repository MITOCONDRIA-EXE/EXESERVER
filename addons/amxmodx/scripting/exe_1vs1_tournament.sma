/*
 * EXE 1VS1 Duel
 * Counter-Strike 1.6 / AMX Mod X 1.10+
 *
 * Simple 1vs1 duel between two players chosen by an admin.
 * First to 100 kills wins. Side switch every 20 rounds.
 * All other players are forced to spectator.
 *
 * Commands:
 *   1v1 <id1> <id2>
 *   1v1stop
 *   1v1status
 *
 * CVARs:
 *   exe_duel_weapon   1=AK47, 2=M4A1, 3=AWP, 4=DEAGLE, 5=SCOUT, 6=KNIFE
 *   exe_duel_freeze   freeze time for each round
 *   exe_duel_hud      HUD enabled
 */

#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN_NAME    "EXE 1VS1 Duel"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR  "EXE"

#define MAX_PLAYERS 32
#define MAX_NAME_LEN 32

#define TEAM_T 1
#define TEAM_CT 2

#define KILLS_TO_WIN 12
#define SIDE_SWITCH_EVERY 6

enum _:DuelState
{
    DUEL_IDLE = 0,
    DUEL_RUNNING,
    DUEL_FINISHED
}

new g_state = DUEL_IDLE

new g_playerA
new g_playerB
new g_killsA
new g_killsB
new g_roundNumber
new bool:g_roundEnded

new g_cvarWeapon
new g_cvarFreeze
new g_cvarHud

new g_hudSync

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR)

    register_concmd("1v1", "cmdStart", ADMIN_KICK, "<id1> <id2> - Inicia un duelo 1vs1")
    register_concmd("1v1stop", "cmdStop", ADMIN_KICK, "Detiene el duelo actual")
    register_concmd("1v1status", "cmdStatus", ADMIN_KICK, "Muestra el estado del duelo")

    register_event("DeathMsg", "eventDeath", "a")
    register_logevent("eventRoundStart", 2, "1=Round_Start")
    register_logevent("eventRoundEnd", 2, "1=Round_End")

    g_cvarWeapon = register_cvar("exe_duel_weapon", "1")
    g_cvarFreeze = register_cvar("exe_duel_freeze", "0")
    g_cvarHud = register_cvar("exe_duel_hud", "1")

    g_hudSync = CreateHudSyncObj()

    set_task(1.0, "taskHUD", _, _, _, "b")
}

public client_disconnected(id)
{
    if (g_state != DUEL_RUNNING)
        return

    if (id == g_playerA || id == g_playerB)
        handleForfeit(id)
}

public cmdStart(id, level, cid)
{
    if (!cmd_access(id, level, cid, 3))
        return PLUGIN_HANDLED

    new arg1[8], arg2[8]
    read_argv(1, arg1, charsmax(arg1))
    read_argv(2, arg2, charsmax(arg2))

    new p1 = str_to_num(arg1)
    new p2 = str_to_num(arg2)

    if (p1 == p2)
    {
        console_print(id, "[eXe] Los dos jugadores deben ser distintos.")
        return PLUGIN_HANDLED
    }

    if (!is_user_connected(p1) || !is_user_connected(p2))
    {
        console_print(id, "[eXe] Uno de los jugadores no esta conectado.")
        return PLUGIN_HANDLED
    }

    if (g_state == DUEL_RUNNING)
    {
        console_print(id, "[eXe] Ya hay un duelo en curso.")
        return PLUGIN_HANDLED
    }

    startDuel(p1, p2)
    return PLUGIN_HANDLED
}

public cmdStop(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    stopDuel()
    return PLUGIN_HANDLED
}

public cmdStatus(id, level, cid)
{
    if (!cmd_access(id, level, cid, 1))
        return PLUGIN_HANDLED

    console_print(id, "----- EXE DUEL -----")
    console_print(id, "Estado: %d", g_state)

    if (g_playerA > 0 && g_playerB > 0)
    {
        new nameA[MAX_NAME_LEN], nameB[MAX_NAME_LEN]
        get_user_name(g_playerA, nameA, charsmax(nameA))
        get_user_name(g_playerB, nameB, charsmax(nameB))
        console_print(id, "Duelo: %s %d - %d %s", nameA, g_killsA, g_killsB, nameB)
        console_print(id, "Ronda: %d | Primero a %d kills", g_roundNumber, KILLS_TO_WIN)
    }

    return PLUGIN_HANDLED
}

startDuel(p1, p2)
{
    resetDuel()

    g_playerA = p1
    g_playerB = p2
    g_state = DUEL_RUNNING

    server_cmd("mp_freezetime %d", get_pcvar_num(g_cvarFreeze))
    server_cmd("mp_autoteambalance 0")
    server_cmd("mp_limitteams 0")

    setupPlayers()

    announceStart()

    server_cmd("sv_restart 1")
}

resetDuel()
{
    g_state = DUEL_IDLE
    g_playerA = 0
    g_playerB = 0
    g_killsA = 0
    g_killsB = 0
    g_roundNumber = 0
    g_roundEnded = false
}

stopDuel()
{
    if (g_state == DUEL_IDLE)
        return

    restoreSpectators()

    client_print_color(0, print_team_default, "^4[eXe]^1 ^3Duelo detenido.")

    resetDuel()
}

public eventRoundStart()
{
    if (g_state != DUEL_RUNNING)
        return

    if (!is_user_connected(g_playerA) || !is_user_connected(g_playerB))
        return

    g_roundNumber++
    g_roundEnded = false

    applySides()
    giveLoadout(g_playerA)
    giveLoadout(g_playerB)
}

public eventRoundEnd()
{
    if (g_state != DUEL_RUNNING)
        return

    if (g_roundEnded)
        return

    g_roundEnded = true

    set_task(1.5, "taskRestartRound")
}

public eventDeath()
{
    if (g_state != DUEL_RUNNING)
        return

    new killer = read_data(1)
    new victim = read_data(2)

    if (victim == g_playerA && killer == g_playerB)
        g_killsB++
    else if (victim == g_playerB && killer == g_playerA)
        g_killsA++
    else
        return

    announceKill(killer, victim)

    if (g_killsA >= KILLS_TO_WIN || g_killsB >= KILLS_TO_WIN)
    {
        finishDuel(killer)
        return
    }
}

public taskRestartRound()
{
    if (g_state != DUEL_RUNNING)
        return

    g_roundEnded = false

    server_cmd("sv_restart 1")
}

setupPlayers()
{
    new players[32], count
    get_players(players, count, "ch")

    for (new i = 0; i < count; i++)
    {
        new id = players[i]
        if (id == g_playerA || id == g_playerB)
            continue
        forceSpectator(id)
    }

    applySides()
    giveLoadout(g_playerA)
    giveLoadout(g_playerB)
}

applySides()
{
    new swap = ((g_roundNumber - 1) / SIDE_SWITCH_EVERY) % 2

    if (swap)
    {
        forceTeam(g_playerA, TEAM_T)
        forceTeam(g_playerB, TEAM_CT)
    }
    else
    {
        forceTeam(g_playerA, TEAM_CT)
        forceTeam(g_playerB, TEAM_T)
    }
}

forceSpectator(id)
{
    if (!is_user_connected(id))
        return

    if (cs_get_user_team(id) != CS_TEAM_SPECTATOR)
    {
        cs_set_user_team(id, CS_TEAM_SPECTATOR)
        user_silentkill(id)
    }
}

forceTeam(id, team)
{
    if (!is_user_connected(id))
        return

    new CsTeams:current = cs_get_user_team(id)
    new CsTeams:target = (team == TEAM_CT) ? CS_TEAM_CT : CS_TEAM_T

    if (current != target)
        cs_set_user_team(id, target)

    if (!is_user_alive(id))
        ExecuteHamB(Ham_CS_RoundRespawn, id)
}

giveLoadout(id)
{
    if (!is_user_connected(id))
        return

    strip_user_weapons(id)
    give_item(id, "weapon_knife")

    cs_set_user_armor(id, 100, CS_ARMOR_VESTHELM)
    set_user_health(id, 100)

    new weapon = get_pcvar_num(g_cvarWeapon)

    switch (weapon)
    {
        case 1:
        {
            give_item(id, "weapon_ak47")
            cs_set_user_bpammo(id, CSW_AK47, 90)
        }
        case 2:
        {
            give_item(id, "weapon_m4a1")
            cs_set_user_bpammo(id, CSW_M4A1, 90)
        }
        case 3:
        {
            give_item(id, "weapon_awp")
            cs_set_user_bpammo(id, CSW_AWP, 30)
        }
        case 4:
        {
            give_item(id, "weapon_deagle")
            cs_set_user_bpammo(id, CSW_DEAGLE, 35)
        }
        case 5:
        {
            give_item(id, "weapon_scout")
            cs_set_user_bpammo(id, CSW_SCOUT, 90)
        }
        case 6:
        {
            // Knife only.
        }
        default:
        {
            give_item(id, "weapon_ak47")
            cs_set_user_bpammo(id, CSW_AK47, 90)
        }
    }
}

handleForfeit(leaver)
{
    if (g_state != DUEL_RUNNING)
        return

    new winner = (leaver == g_playerA) ? g_playerB : g_playerA

    if (winner > 0 && is_user_connected(winner))
    {
        client_print_color(0, print_team_default, "^4[eXe]^1 Un Jugador abandono. el ^3rival gana por abandono.^1")
        finishDuel(winner)
    }
    else
    {
        stopDuel()
    }
}

finishDuel(winner)
{
    if (g_state != DUEL_RUNNING)
        return

    g_state = DUEL_FINISHED

    if (is_user_connected(winner))
    {
        new name[MAX_NAME_LEN]
        get_user_name(winner, name, charsmax(name))

        client_print_color(0, print_team_default, "^4[eXe]^1 DUELO FINALIZADO. ^3Ganador:%s", name)

        set_hudmessage(0, 255, 0, -1.0, 0.28, 0, 6.0, 8.0, 0.1, 0.2, -1)
        ShowSyncHudMsg(0, g_hudSync, "[eXe]^nGANADOR: %s", name)
    }
}

restoreSpectators()
{
    new players[32], count
    get_players(players, count, "ch")

    for (new i = 0; i < count; i++)
    {
        new id = players[i]

        if (!is_user_connected(id))
            continue

        if (cs_get_user_team(id) == CS_TEAM_SPECTATOR)
        {
            cs_set_user_team(id, random_num(0, 1) ? CS_TEAM_T : CS_TEAM_CT)
            ExecuteHamB(Ham_CS_RoundRespawn, id)
        }
    }
}

announceStart()
{
    new nameA[MAX_NAME_LEN], nameB[MAX_NAME_LEN]
    get_user_name(g_playerA, nameA, charsmax(nameA))
    get_user_name(g_playerB, nameB, charsmax(nameB))

    client_print_color(0, print_team_default, "^4[eXe]^1 DUELO: ^3%s^1 vs ^3%s", nameA, nameB)
    client_print_color(0, print_team_default, "^4[eXe]^1 Primero a ^4%d kills gana^1. Cambio de lado cada ^3%d rondas", KILLS_TO_WIN, SIDE_SWITCH_EVERY)
}

announceKill(killer, victim)
{
    if (!is_user_connected(killer))
        return

    new killerName[MAX_NAME_LEN], victimName[MAX_NAME_LEN]
    get_user_name(killer, killerName, charsmax(killerName))
    get_user_name(victim, victimName, charsmax(victimName))

    client_print_color(0, print_team_default, "^4[eXe]^1 ^3%s^1 elimino a ^3%s^1. ^4marcador^1 ^3%d^1 - ^3%d", killerName, victimName, g_killsA, g_killsB)
}

public taskHUD()
{
    if (!get_pcvar_num(g_cvarHud))
        return

    if (g_state != DUEL_RUNNING)
        return

    if (!is_user_connected(g_playerA) || !is_user_connected(g_playerB))
        return

    new nameA[MAX_NAME_LEN], nameB[MAX_NAME_LEN]
    get_user_name(g_playerA, nameA, charsmax(nameA))
    get_user_name(g_playerB, nameB, charsmax(nameB))

    set_hudmessage(0, 255, 0, -1.0, 0.04, 0, 0.0, 1.1, 0.0, 0.0, -1)
    ShowSyncHudMsg(0, g_hudSync, "[eXe]^n%s  %d - %d  %s^nRonda %d | Primero a %d kills",
        nameA, g_killsA, g_killsB, nameB, g_roundNumber, KILLS_TO_WIN)
}

public plugin_end()
{
    remove_task()
}
