#include <amxmodx>
#include <csstats>
#include <csx>

#define PLUGIN "HUD Rank Info"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

new g_iSyncHud
new g_iMaxPlayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_iSyncHud = CreateHudSyncObj()
	g_iMaxPlayers = get_maxplayers()
	set_task(2.0, "ShowRankHUD", _, _, _, "b")
}

public ShowRankHUD()
{
	static iPlayers[32], iNum, iPlayer, iRankPos
	get_players(iPlayers, iNum, "ch")

	for (new i = 0; i < iNum; i++)
	{
		iPlayer = iPlayers[i]

		if (is_user_connected(iPlayer) && !is_user_bot(iPlayer))
		{
			static iStats[8], iHits[8], szName[32]
			get_user_name(iPlayer, szName, charsmax(szName))
			
			iRankPos = get_user_stats(iPlayer, iStats, iHits)
			
			new iTotal = get_statsnum()
			new iKills = iStats[0]
			new iDeaths = iStats[1]
			new iHS = iStats[2]

			new iNextRankKills
			if (iRankPos > 1)
			{
				static iNextStats[8], iNextHits[8], szNextName[32]
				get_stats(iRankPos - 1, iNextStats, iNextHits, szNextName, charsmax(szNextName))
				iNextRankKills = iNextStats[0]
			}
			else
			{
				iNextRankKills = iKills + 1
			}

			new iKillsNeeded = (iNextRankKills - iKills)
			if (iKillsNeeded < 1)
				iKillsNeeded = 0

			set_hudmessage(255, 255, 255, -1.0, 0.02, 0, 0.0, 2.1, 0.0, 0.0, 8)
			ShowSyncHudMsg(iPlayer, g_iSyncHud, "Rango: #%d de %d^nNombre: %s^nKills: %d  |  Muertes: %d^nHeadShots: %d^nProx. Rango: %d kills^nKDR: %.2f",
				iRankPos, iTotal, szName, iKills, iDeaths, iHS, iKillsNeeded,
				(iDeaths > 0) ? (float(iKills) / float(iDeaths)) : float(iKills))
		}
	}
}
