#include <amxmodx>
#include <csstats>

#define PLUGIN "HUD Rank Info"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

#define HUD_X 0.01
#define HUD_Y 0.20
#define HUD_HOLD_TIME 2.1

new g_iSyncTitle
new g_iSyncStats

new const g_szRanks[][] = {
	"Plata I",
	"Plata II",
	"Plata III",
	"Plata IV",
	"Plata Elite",
	"Gran Maestro Plata",
	"Oro Nova I",
	"Oro Nova II",
	"Oro Nova III",
	"Gran Maestro Oro Nova",
	"Guardian Maestro I",
	"Guardian Maestro II",
	"Guardian Maestro Elite",
	"Guardian Maestro Distinguido",
	"Aguila Legendaria",
	"Gran Maestro Aguila Legendaria",
	"Supremo Maestro de Primera Clase",
	"Elite Global"
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
	2600,
	3000,
	3500
}

get_rank_name(kills, szRank[], len)
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
	copy(szRank, len, g_szRanks[iRank])
}

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_iSyncTitle = CreateHudSyncObj()
	g_iSyncStats = CreateHudSyncObj()

	set_task(2.0, "ShowRankHUD", _, _, _, "b")
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

		new iRankPos = get_user_stats(iPlayer, iStats, iHits)

		new szRank[48]
		get_rank_name(iStats[0], szRank, charsmax(szRank))

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
			"[eXe SERVER ARG]"
		)

		set_hudmessage(
			0,
			255,
			255,
			HUD_X,
			HUD_Y + 0.03,
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
			"Ranking: #%d / %d^nAsesinatos: %d^nMuertes: %d^nRango: %s",
			iRankPos,
			get_statsnum(),
			iStats[0],
			iStats[1],
			szRank
		)
	}
}
