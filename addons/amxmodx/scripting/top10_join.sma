#include <amxmodx>
#include <csstats>

#define PLUGIN "Top 10 Join Announce"
#define VERSION "1.0"
#define AUTHOR "eXe Server"

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
}

public client_putinserver(id)
{
	if (is_user_bot(id))
		return

	new iStats[8], iHits[8]
	new iRank = get_user_stats(id, iStats, iHits)

	if (iRank < 1 || iRank > 10)
		return

	new szName[32]
	get_user_name(id, szName, charsmax(szName))

	client_print_color(0, print_team_default, "^4[eXe]^1 Entro ^3%s^1 (TOP #%d) al servidor!", szName, iRank)
	client_cmd(0, "spk vox/hello")
}
