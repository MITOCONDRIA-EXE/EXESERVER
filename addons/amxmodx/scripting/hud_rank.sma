#include <amxmodx>
#include <csstats>

#define PLUGIN "HUD Rank Info"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

#define HUD_X 0.01
#define HUD_Y 0.20
#define HUD_HOLD_TIME 2.1

new g_iSyncHud

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_iSyncHud = CreateHudSyncObj()

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

		set_hudmessage(
			255,
			255,
			255,
			HUD_X,
			HUD_Y,
			0,
			0.0,
			HUD_HOLD_TIME,
			0.0,
			0.0,
			8
		)

		ShowSyncHudMsg(
			iPlayer,
			g_iSyncHud,
			"[eXe SERVER ARG]^nAsesinatos: %d^nMuertes: %d^nRanking: #%d",
			iStats[0],
			iStats[1],
			iRankPos
		)
	}
}
