#include <amxmodx>
#include <csstats>
#include <fakemeta>

#define PLUGIN "HUD Rank Info"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

#define HUD_X 0.01
#define HUD_Y 0.20
#define HUD_HOLD_TIME 2.1

new g_iSyncTitle
new g_iSyncStats
new g_iSyncRango
new g_iSyncIP

new g_iRankIndex[33]

new const g_szRanks[][] = {
	"Plata I",
	"Plata II",
	"Plata III",
	"Plata IV",
	"Plata Elite",
	"Oro Nova I",
	"Oro Nova II",
	"Oro Nova III",
	"Maestro Guardian I",
	"Maestro Guardian II",
	"Maestro Guardian X",
	"Sheriff",
	"Aguila",
	"Aguila Legendaria",
	"Supreme",
	"Global Elite ",
	"Legendary",
	".eXe"
}

new const g_iThresholds[] = {
	0,
	50,
	100,
	150,
	200,
	300,
	400,
	550,
	700,
	900,
	1100,
	1350,
	1600,
	1900,
	2200,
	3000,
	3500,
	6000
}

get_rank_index(kills)
{
	new iRank = 0
	for (new i = sizeof(g_iThresholds) - 1; i >= 0; i--)
	{
		if (kills >= g_iThresholds[i])
		{
			iRank = i
			break
		}
	}
	return iRank
}

get_rank_name(kills, szRank[], len)
{
	copy(szRank, len, g_szRanks[get_rank_index(kills)])
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_iSyncTitle = CreateHudSyncObj()
	g_iSyncStats = CreateHudSyncObj()
	g_iSyncRango = CreateHudSyncObj()
	g_iSyncIP = CreateHudSyncObj()

	set_task(2.0, "ShowRankHUD", _, _, _, "b")
	set_task(2.0, "checkRankUp", _, _, _, "b")
}

public client_putinserver(id)
{
	new iStats[8], iHits[8]
	get_user_stats(id, iStats, iHits)
	g_iRankIndex[id] = get_rank_index(iStats[0])
}

public checkRankUp()
{
	static iPlayers[32]
	static iNum
	static iPlayer

	get_players(iPlayers, iNum, "ch")

	for (new i = 0; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if (is_user_bot(iPlayer))
			continue

		new iStats[8], iHits[8]
		get_user_stats(iPlayer, iStats, iHits)

		new iRank = get_rank_index(iStats[0])

		if (iRank > g_iRankIndex[iPlayer])
			announceRankUp(iPlayer, iRank)

		g_iRankIndex[iPlayer] = iRank
	}
}

announceRankUp(id, iRank)
{
	new szName[32]
	get_user_name(id, szName, charsmax(szName))

	client_print_color(0, id, "^4[eXe]^1 ^3%s^1 subio de rango a ^4%s^1!", szName, g_szRanks[iRank])

	set_hudmessage(0, 255, 0, -1.0, 0.30, 0, 1.0, 4.0, 0.1, 0.2, -1)
	ShowSyncHudMsg(id, g_iSyncStats, "SUBISTE DE RANGO^n%s", g_szRanks[iRank])
}

	public ShowRankHUD()
{
	static iPlayers[32]
	static iNum
	static iPlayer
	static iStats[8]
	static iHits[8]

	get_players(iPlayers, iNum, "ch")

	for (new i = 0; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if (is_user_bot(iPlayer))
			continue

		new iTarget = iPlayer

		if (!is_user_alive(iPlayer))
		{
			new iSpec = pev(iPlayer, pev_iuser2)
			if (iSpec >= 1 && iSpec <= 32 && is_user_connected(iSpec))
				iTarget = iSpec
		}

		new iRankPos = get_user_stats(iTarget, iStats, iHits)

		new szRank[48]
		get_rank_name(iStats[0], szRank, charsmax(szRank))

		new szTargetName[32]
		get_user_name(iTarget, szTargetName, charsmax(szTargetName))

		new szServerIP[32]
		get_user_ip(0, szServerIP, charsmax(szServerIP), 1)

		set_hudmessage(
			0,
			255,
			0,
			HUD_X,
			HUD_Y,
			0,
			0.0,
			HUD_HOLD_TIME,
			0.0,
			0.0,
			1
		)

		ShowSyncHudMsg(
			iPlayer,
			g_iSyncTitle,
			"[eXe.ARG] "
		)

		set_hudmessage(
			255,
			255,
			255,
			HUD_X,
			HUD_Y + 0.05,
			0,
			0.0,
			HUD_HOLD_TIME,
			0.0,
			0.0,
			2
		)

		ShowSyncHudMsg(
			iPlayer,
			g_iSyncStats,
			"%s^nKills: %d^nMuertes: %d^n^nRanking: %d/%d",
			szTargetName,
			iStats[0],
			iStats[1],
			iRankPos,
			get_statsnum()
		)

		set_hudmessage(
			255,
			0,
			255,
			HUD_X,
			HUD_Y + 0.14,
			0,
			0.0,
			HUD_HOLD_TIME,
			0.0,
			0.0,
			3
		)

		ShowSyncHudMsg(
			iPlayer,
			g_iSyncRango,
			"Rango: %s",
			szRank
		)

		set_hudmessage(
			255,
			255,
			255,
			HUD_X,
			HUD_Y + 0.18,
			0,
			0.0,
			HUD_HOLD_TIME,
			0.0,
			0.0,
			4
		)

		ShowSyncHudMsg(
			iPlayer,
			g_iSyncIP,
			"IP DEL SERVIDOR: %s",
			szServerIP
		)
	}
}
