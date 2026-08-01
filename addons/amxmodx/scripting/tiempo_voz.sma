#include <amxmodx>
#include <amxmisc>

#define PLUGIN "Time Voice"
#define VERSION "1.0"
#define AUTHOR "MITO"

new g_iEnabled
new g_iLastAnnounced
new bool:g_bMaleVoice

enum {
	T_300 = 300,
	T_180 = 180,
	T_60  = 60,
	T_30  = 30
}

new const g_szTimes[][][] = {
	{ "five",    "minutes", "remaining" },
	{ "three",   "minutes", "remaining" },
	{ "one",     "minutes", "remaining" },
	{ "thirty",  "second",  "remaining" }
}

new const g_iTimeValues[] = { T_300, T_180, T_60, T_30 }

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	g_iEnabled = register_cvar("timevoice_enabled", "1")
	register_logevent("round_start", 2, "1=World triggered", "2=Round_Start")
	set_task(5.0, "check_time", 123456, "", 0, "b")
}

public round_start()
{
	g_iLastAnnounced = 9999
}

public check_time()
{
	if (!get_pcvar_num(g_iEnabled))
		return

	new iTimeLeft = get_timeleft()
	if (iTimeLeft < 1)
		return

	new iThreshold = -1

	for (new i = 0; i < sizeof(g_iTimeValues); i++)
	{
		if (iTimeLeft <= g_iTimeValues[i] && g_iLastAnnounced > g_iTimeValues[i])
		{
			iThreshold = i
			break
		}
	}

	if (iThreshold != -1)
	{
		announce(iThreshold)
		g_iLastAnnounced = g_iTimeValues[iThreshold]
	}
}

public announce(threshold)
{
	g_bMaleVoice = !g_bMaleVoice

	new szVoice[8]
	if (g_bMaleVoice)
		copy(szVoice, charsmax(szVoice), "vox")
	else
		copy(szVoice, charsmax(szVoice), "fvox")

	new szCmd[192]
	formatex(szCmd, charsmax(szCmd), "spk %s/%s %s %s",
		szVoice,
		g_szTimes[threshold][0],
		g_szTimes[threshold][1],
		g_szTimes[threshold][2])

	client_cmd(0, szCmd)
}
